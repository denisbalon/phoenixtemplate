#!/usr/bin/env bash
# C2 doc-reference linter (B-023 + B-029 fragment-validation extension).
#
# Walks every Markdown file in the repo (excluding .git) and verifies that
# Markdown link targets of the form `[label](target)` resolve to a file or
# directory that exists on disk. As of v1.29.0 (B-029) also validates URL
# fragments (`#anchor` suffixes) by computing GitHub-style slugs from each
# heading in the target file and verifying the anchor matches.
#
# Catches doc drift — recommending files that don't ship, paths that have
# been renamed, anchors that point at headings that no longer exist —
# which is the trust-break B-016 flags as the invariant and was previously
# gated only by manual audit.
#
# Scope (deliberately narrow to keep false-positive rate at zero):
#   - Only Markdown link syntax `[..](..)` is parsed. Backtick-quoted paths
#     in prose are NOT linted — too many false positives from placeholder
#     paths (`src/<package_name>/...`) and from rendered examples that
#     describe the consumer's layout rather than this repo's.
#   - URLs (http/https/mailto/tel/data), anchor-only links (`#...`), and
#     autolinks (`<...>`) are skipped.
#   - Trailing `?query` is stripped before any check.
#   - Trailing `#anchor` is stripped from the path for the file-existence
#     check, then validated against the target file's heading slugs as a
#     separate step (B-029 fragment validation, added v1.29.0).
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
# URL fragment validation (B-029, v1.29.0):
# After file existence is confirmed (real or via virtual fallback), if the
# target had a `#anchor` portion, the linter computes GitHub-style slugs
# from every heading in the resolved file and verifies the anchor matches
# at least one of them. Slug rule (matches GitHub's auto-slug behavior):
# lowercase, drop punctuation that isn't alphanumeric/space/hyphen/underscore,
# replace whitespace runs with single hyphen, trim leading/trailing hyphens.
# Fenced code blocks are skipped during heading extraction (lines starting
# with `#` inside ``` fences are not headings).
#
# Exit codes:
#   0 — every parsed link target resolves AND every fragment matches a heading
#   1 — one or more targets are broken (each is printed as
#       `<file>:<line> -> <target>  (resolved: <path>)` for missing files
#       OR `<file>:<line> -> <target>  (broken URL fragment: #<frag>)` for
#       missing anchors)
#
# CI: wired into .github/workflows/template-self-test.yml alongside the
# rule-consistency linter, the spec-consistency linter (B-029), and the
# smoke test.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

EXIT=0
BROKEN_COUNT=0
LINK_COUNT=0
FRAGMENT_COUNT=0
BROKEN_FRAGMENT_COUNT=0

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
  "WORKFLOW.md"
  "BOOTSTRAP.md"
  "MIGRATION.md"
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

extract_headings() {
  # Print each heading line (without the leading # marks + leading whitespace)
  # from the given Markdown file. Skips fenced code blocks so shell comments
  # (e.g. `# === Section ===` inside a ```sh block) aren't mistaken for
  # headings. Used by github_slug for fragment validation.
  awk '
    BEGIN { in_fence = 0 }
    /^[[:space:]]*```/ { in_fence = !in_fence; next }
    in_fence { next }
    /^#+[[:space:]]/ {
      h = $0
      sub(/^#+[[:space:]]+/, "", h)
      print h
    }
  ' "$1"
}

github_slug() {
  # Compute the GitHub-style auto-anchor slug for a heading text.
  # Rule (matches GitHub's behavior for most cases):
  #   1. Lowercase.
  #   2. Drop characters not in [a-z0-9 _-] (punctuation: dots, commas,
  #      backticks, em-dashes, etc. are dropped, NOT replaced with space).
  #   3. Replace runs of whitespace with single hyphen.
  #   4. Trim leading/trailing hyphens.
  # Examples:
  #   "Branch protection on `main`"        -> "branch-protection-on-main"
  #   "1.6 Branch protection on `main`"    -> "16-branch-protection-on-main"
  #   "v1.28.0 — 2026-05-19"                -> "v1280-2026-05-19"
  # Does NOT handle GitHub's duplicate-anchor disambiguation (-1, -2 suffixes);
  # an anchor link that targets a duplicated heading checks against the slug
  # before disambiguation. Accepted limitation; no duplicates in this repo.
  local heading="$1"
  heading="$(printf '%s' "$heading" | tr '[:upper:]' '[:lower:]')"
  heading="$(printf '%s' "$heading" | tr -cd 'a-z0-9 _-')"
  heading="$(printf '%s' "$heading" | sed -E 's/[[:space:]]+/-/g')"
  heading="$(printf '%s' "$heading" | sed -E 's/^-+|-+$//g')"
  printf '%s' "$heading"
}

validate_fragment() {
  # Given a file path and an anchor fragment (without leading #), return 0
  # if the fragment matches a heading slug in the file, 1 otherwise.
  local file="$1" fragment="$2"
  [[ -f "$file" ]] || return 1
  local heading slug
  while IFS= read -r heading; do
    slug="$(github_slug "$heading")"
    if [[ "$slug" == "$fragment" ]]; then
      return 0
    fi
  done < <(extract_headings "$file")
  return 1
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

    # Strip ?query first, then capture #anchor separately for later validation.
    target_no_query="${target%%\?*}"
    if [[ "$target_no_query" == *\#* ]]; then
      path="${target_no_query%%#*}"
      fragment="${target_no_query#*#}"
    else
      path="$target_no_query"
      fragment=""
    fi
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

    # Existence check (with export-layout virtual fallback).
    actual_file=""
    if [[ -e "$check_path" ]]; then
      actual_file="$check_path"
    else
      # Export-layout fallback: if the link sits under templates/ and resolves
      # to a virtual file the export script promotes into the templates root,
      # accept it as long as the underlying meta-repo file exists.
      if [[ "$f" = ./templates/* ]]; then
        for virt in "${VIRTUAL_TEMPLATES_FILES[@]}"; do
          if [[ "$normalized" = "templates/$virt" && -e "$REPO_ROOT/$virt" ]]; then
            actual_file="$REPO_ROOT/$virt"
            break
          fi
        done
      fi
    fi

    if [[ -z "$actual_file" ]]; then
      printf '%s:%s -> %s  (resolved: %s)\n' "$f" "$line_no" "$target" "$normalized" >&2
      BROKEN_COUNT=$((BROKEN_COUNT + 1))
      EXIT=1
      continue
    fi

    # Fragment validation (B-029, v1.29.0).
    # Only validate fragments against Markdown files (anchors on directories
    # or non-Markdown files don't have heading semantics).
    if [[ -n "$fragment" && "$actual_file" == *.md && -f "$actual_file" ]]; then
      FRAGMENT_COUNT=$((FRAGMENT_COUNT + 1))
      if ! validate_fragment "$actual_file" "$fragment"; then
        printf '%s:%s -> %s  (broken URL fragment: #%s in %s)\n' \
          "$f" "$line_no" "$target" "$fragment" "$normalized" >&2
        BROKEN_FRAGMENT_COUNT=$((BROKEN_FRAGMENT_COUNT + 1))
        BROKEN_COUNT=$((BROKEN_COUNT + 1))
        EXIT=1
      fi
    fi
  done < <(extract_links "$f")
done

if [[ $EXIT -eq 0 ]]; then
  echo "OK: ${LINK_COUNT} Markdown link targets resolved across ${#MD_FILES[@]} files (${FRAGMENT_COUNT} URL fragments validated)."
else
  echo "FAIL: ${BROKEN_COUNT} broken doc reference(s) across ${#MD_FILES[@]} files (${LINK_COUNT} links scanned, ${BROKEN_FRAGMENT_COUNT} broken URL fragment(s))." >&2
fi

exit $EXIT
