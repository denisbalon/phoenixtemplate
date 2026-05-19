#!/usr/bin/env bash
# Manifest linter (B-033, v1.31.1).
#
# Verifies templates/manifest.yaml (B-032) against the actual file tree.
# Three invariants:
#
#   1. No orphans — every regular file under templates/ has a manifest entry.
#      (Scope intentionally limited to templates/; meta-only scripts under
#      scripts/ are listed in the manifest for completeness but not enforced
#      as orphans — adding a new linter shouldn't force a manifest edit in
#      the same commit just to keep CI green. Future tightening possible.)
#
#   2. No stale entries — every `path` in the manifest resolves to an
#      existing file. Covers all three tiers (common / python-preset /
#      meta-only).
#
#   3. Placeholders match — for each manifest entry under templates/
#      (except the self-referential templates/manifest.yaml), the declared
#      `placeholders` list equals the set of B-024 canonical placeholders
#      (<package_name>, <PACKAGE_NAME>, <PROJECT_NAME>, <PROJECT_SLUG>,
#      <GITHUB_USER>, <HOST>, <DOMAIN>, <PROJECT_DESCRIPTION>,
#      <COPYRIGHT_HOLDER>, <YEAR>) that actually appear in the file's
#      content. Illustrative angle-bracket syntax in prose (<METHOD>, <N>,
#      <CMD>, <DEPLOY_CMD>, etc.) is intentionally NOT tracked — same
#      canonical-set distinction as scripts/check-placeholders.sh (B-024).
#      Placeholders that appear only in path components (e.g. the literal
#      <package_name> in templates/src/<package_name>/__init__.py's path)
#      are NOT content placeholders for that file.
#
#      Scope rationale: root-exported docs (PROJECT_STARTER.md etc.) and
#      meta-only scripts mention canonical placeholder strings as
#      references TO the substitution targets, not as substitution
#      targets themselves; they're meta-documentation, not consumed
#      templates. Enforcing the match on them would false-positive on
#      every doc that explains how placeholders work. templates/manifest.yaml
#      is excluded for the same reason — it documents paths that contain
#      <package_name>, but the YAML data is not itself substituted.
#
# Manifest format (B-032): each entry is a YAML map under top-level `files:`
# with fields path / purpose / tier / placeholders / exported_by_starter.
# Inline list syntax for placeholders (`[A, B, C]` or `[]`) keeps parsing
# bash-awk-friendly with no YAML library dependency.
#
# Exit codes:
#   0 — all three invariants hold
#   1 — at least one violation (each printed with file/path + diagnostic)
#
# CI: wired into .github/workflows/template-self-test.yml alongside the
# other linters. Also invoked from scripts/smoke-test.sh as a pre-flight
# integrity check (belt-and-suspenders for local-dev runs).

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

MANIFEST="templates/manifest.yaml"

if [ ! -f "$MANIFEST" ]; then
  echo "✗ $MANIFEST not found" >&2
  exit 1
fi

EXIT=0

# Canonical B-024 placeholder set. Keep in sync with PLACEHOLDERS in
# scripts/check-placeholders.sh.
CANONICAL_RE='<(package_name|PACKAGE_NAME|PROJECT_NAME|PROJECT_SLUG|GITHUB_USER|HOST|DOMAIN|PROJECT_DESCRIPTION|COPYRIGHT_HOLDER|YEAR)>'

# Parse the manifest into TSV: path<TAB>tier<TAB>placeholders<TAB>exported
# One row per entry. `placeholders` keeps the raw `[...]` form for later
# normalization.
parse_manifest() {
  awk '
    function trim(s) { sub(/^[[:space:]]+/, "", s); sub(/[[:space:]]+$/, "", s); return s }
    function emit() {
      if (path != "") {
        printf "%s\t%s\t%s\t%s\n", path, tier, placeholders, exported
      }
    }
    /^  - path:/ {
      emit()
      path = trim(substr($0, index($0, ":") + 1))
      tier = ""; placeholders = ""; exported = ""
      next
    }
    /^    tier:/                { tier = trim(substr($0, index($0, ":") + 1)); next }
    /^    placeholders:/        { placeholders = trim(substr($0, index($0, ":") + 1)); next }
    /^    exported_by_starter:/ { exported = trim(substr($0, index($0, ":") + 1)); next }
    END { emit() }
  ' "$MANIFEST"
}

# Normalize a placeholders field: strip brackets, split on comma, drop
# blanks, sort under C locale for deterministic comparison.
# Subshell + `|| true` wrappers keep empty-input cases from failing the
# pipeline under set -o pipefail.
normalize_list() {
  local raw="$1"
  raw="${raw#[}"
  raw="${raw%]}"
  echo "$raw" | tr ',' '\n' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//' \
    | (grep -v '^$' || true) \
    | LC_ALL=C sort -u \
    | paste -sd, -
}

# Extract canonical placeholders actually appearing in a file's content.
# Same pipefail concern — grep returns 1 when a file has no placeholders;
# wrap so the empty case yields empty output instead of killing the script.
actual_placeholders() {
  local f="$1"
  (grep -oE "$CANONICAL_RE" "$f" 2>/dev/null || true) \
    | sed 's/[<>]//g' \
    | LC_ALL=C sort -u \
    | paste -sd, -
}

ENTRY_COUNT=0
ORPHAN_COUNT=0
STALE_COUNT=0
PLACEHOLDER_MISMATCH_COUNT=0

# Build the set of manifest paths for the orphan check.
declare -A MANIFEST_PATHS
while IFS=$'\t' read -r path tier placeholders exported; do
  MANIFEST_PATHS["$path"]=1
  ENTRY_COUNT=$((ENTRY_COUNT + 1))
done < <(parse_manifest)

# Invariant 1: no orphans under templates/.
while IFS= read -r -d '' f; do
  rel="${f#./}"
  if [ -z "${MANIFEST_PATHS[$rel]:-}" ]; then
    echo "✗ orphan: $rel is under templates/ but not declared in $MANIFEST" >&2
    ORPHAN_COUNT=$((ORPHAN_COUNT + 1))
    EXIT=1
  fi
done < <(find templates -type f -print0)

# Invariant 2: no stale entries.
# Invariant 3: declared placeholders == actual canonical placeholders in content.
while IFS=$'\t' read -r path tier placeholders exported; do
  if [ ! -e "$path" ]; then
    echo "✗ stale: $path declared in $MANIFEST but does not exist" >&2
    STALE_COUNT=$((STALE_COUNT + 1))
    EXIT=1
    continue
  fi
  [ -f "$path" ] || continue  # skip non-files (shouldn't happen with current schema)
  # Placeholder-match invariant: only for consumed templates under
  # templates/ (excluding the self-referential manifest.yaml).
  case "$path" in
    templates/manifest.yaml) continue ;;
    templates/*) ;;
    *) continue ;;
  esac
  declared=$(normalize_list "$placeholders")
  actual=$(actual_placeholders "$path")
  if [ "$declared" != "$actual" ]; then
    echo "✗ placeholder mismatch: $path" >&2
    echo "    declared: [${declared}]" >&2
    echo "    actual:   [${actual}]" >&2
    PLACEHOLDER_MISMATCH_COUNT=$((PLACEHOLDER_MISMATCH_COUNT + 1))
    EXIT=1
  fi
done < <(parse_manifest)

if [ "$EXIT" -eq 0 ]; then
  echo "OK: manifest valid — ${ENTRY_COUNT} entries, no orphans under templates/, no stale paths, placeholders match content."
else
  echo "FAIL: manifest violations — ${ORPHAN_COUNT} orphan(s), ${STALE_COUNT} stale entry(ies), ${PLACEHOLDER_MISMATCH_COUNT} placeholder mismatch(es)." >&2
fi

exit "$EXIT"
