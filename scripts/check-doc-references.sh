#!/usr/bin/env bash
# C2 doc-reference linter (B-023).
#
# Walks every Markdown file in the repo (excluding .git) and verifies that
# Markdown link targets of the form `[label](target)` resolve to a file or
# directory that exists on disk. Catches doc drift — recommending files that
# don't ship, paths that have been renamed, references that rot after a
# refactor — which is the trust-break B-016 flags as the invariant and was
# previously gated only by manual audit.
#
# Scope (deliberately narrow to keep false-positive rate at zero):
#   - Only Markdown link syntax `[..](..)` is parsed. Backtick-quoted paths
#     in prose are NOT linted — too many false positives from placeholder
#     paths (`src/<package_name>/...`) and from rendered examples that
#     describe the consumer's layout rather than this repo's.
#   - URLs (http/https/mailto/tel/data), anchor-only links (`#...`), and
#     autolinks (`<...>`) are skipped.
#   - Trailing `#anchor` and `?query` are stripped from the target before
#     the existence check; the file/dir must exist, anchors are not verified.
#   - Optional Markdown link titles (`[label](path "title")`) are stripped.
#   - Existence is checked with `[ -e ]` so directory targets (e.g.
#     `[templates/](templates/)`) pass.
#
# Resolution: relative targets resolve from the linking file's directory;
# absolute targets (starting `/`) resolve from the repo root.
#
# Export-layout awareness: `scripts/export-starter.sh` flattens the contents
# of `templates/` next to meta-repo-root files (currently only
# `PROJECT_STARTER.md`) inside the archive. Links inside `templates/` are
# authored against that consumer layout, so the linter treats those
# promoted root files as virtually present inside `templates/` when
# checking existence. Update VIRTUAL_TEMPLATES_FILES below if the export
# script ever promotes additional files.
#
# Exit codes:
#   0 — every parsed link target resolves
#   1 — one or more targets are broken (each is printed as
#       `<file>:<line> -> <target>  (resolved: <path>)`)
#
# CI: wired into .github/workflows/template-self-test.yml alongside the
# rule-consistency linter and the smoke test.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

EXIT=0
BROKEN_COUNT=0
LINK_COUNT=0

# Files copied from meta-repo root into the templates-flattened export stage
# by scripts/export-starter.sh (its ROOT_DOCS array). Inside `templates/`,
# links targeting these names resolve correctly in the archive even though
# the file lives one directory up in the source tree. Keep in sync with
# ROOT_DOCS in scripts/export-starter.sh.
VIRTUAL_TEMPLATES_FILES=(
  "PROJECT_STARTER.md"
  "TEMPLATE_INVENTORY.md"
  "DEPLOY_BASELINE.md"
  "HARNESS_QUIRKS.md"
)

# All Markdown files except anything under .git/.
mapfile -t MD_FILES < <(find . -type f -name '*.md' -not -path './.git/*' | sort)

extract_links() {
  # Print "<line_no>\t<target>" for every Markdown link on every line.
  # Skips fenced code blocks entirely and strips inline code spans before
  # scanning — Markdown links never live inside code, but documentation
  # often shows the literal `[label](target)` syntax inside backticks as
  # an example, which the linter must NOT mistake for a real reference.
  # Handles multiple links per line. Does NOT handle escaped brackets or
  # parens inside URLs — accepted limitation; none occur in this repo.
  awk '
    BEGIN { in_fence = 0 }
    /^[[:space:]]*```/ { in_fence = !in_fence; next }
    in_fence { next }
    {
      s = $0
      # Strip inline code spans (single-backtick form). Multi-backtick
      # spans are not used in this repo; would need a more complex parser.
      gsub(/`[^`]+`/, "", s)
      while (match(s, /\[[^]]*\]\([^)]+\)/)) {
        chunk = substr(s, RSTART, RLENGTH)
        # Strip the leading "[..](" and trailing ")".
        sub(/^\[[^]]*\]\(/, "", chunk)
        sub(/\)$/, "", chunk)
        printf "%d\t%s\n", NR, chunk
        s = substr(s, RSTART + RLENGTH)
      }
    }
  ' "$1"
}

for f in "${MD_FILES[@]}"; do
  dir="$(dirname "$f")"
  while IFS=$'\t' read -r line_no target; do
    [[ -z "${target:-}" ]] && continue
    LINK_COUNT=$((LINK_COUNT + 1))

    # Strip optional title: `path "Title"` or `path 'Title'`.
    target="${target%% \"*}"
    target="${target%% \'*}"
    # Trim surrounding whitespace.
    target="${target#"${target%%[![:space:]]*}"}"
    target="${target%"${target##*[![:space:]]}"}"

    # Skip URL-ish, mailto/tel/data, anchor-only, autolinks.
    case "$target" in
      http://*|https://*|mailto:*|tel:*|data:*|ftp://*) continue ;;
      \#*) continue ;;
      \<*) continue ;;
      '') continue ;;
    esac

    # Strip ?query and #anchor for the existence check.
    path="${target%%\?*}"
    path="${path%%#*}"
    [[ -z "$path" ]] && continue

    # Resolve.
    if [[ "$path" = /* ]]; then
      resolved=".${path}"
    else
      resolved="${dir}/${path}"
    fi

    # Normalize (collapse ./ and ../) — realpath -m doesn't require existence.
    if normalized="$(realpath -m --relative-to="$REPO_ROOT" "$resolved" 2>/dev/null)"; then
      check_path="$REPO_ROOT/$normalized"
    else
      normalized="$resolved"
      check_path="$resolved"
    fi

    if [[ ! -e "$check_path" ]]; then
      # Export-layout fallback: if the link sits under templates/ and resolves
      # to a virtual file the export script promotes into the templates root,
      # accept it as long as the underlying meta-repo file exists.
      accepted=0
      if [[ "$f" = ./templates/* ]]; then
        for virt in "${VIRTUAL_TEMPLATES_FILES[@]}"; do
          if [[ "$normalized" = "templates/$virt" && -e "$REPO_ROOT/$virt" ]]; then
            accepted=1
            break
          fi
        done
      fi
      if [[ $accepted -eq 0 ]]; then
        printf '%s:%s -> %s  (resolved: %s)\n' "$f" "$line_no" "$target" "$normalized" >&2
        BROKEN_COUNT=$((BROKEN_COUNT + 1))
        EXIT=1
      fi
    fi
  done < <(extract_links "$f")
done

if [[ $EXIT -eq 0 ]]; then
  echo "OK: ${LINK_COUNT} Markdown link targets resolved across ${#MD_FILES[@]} files."
else
  echo "FAIL: ${BROKEN_COUNT} broken doc reference(s) across ${#MD_FILES[@]} files (${LINK_COUNT} links scanned)." >&2
fi

exit $EXIT
