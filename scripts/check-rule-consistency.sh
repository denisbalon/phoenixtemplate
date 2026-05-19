#!/usr/bin/env bash
# C4 rule-consistency linter (B-022).
#
# Verifies that named "rule regions" appear byte-for-byte identically across
# the three canonical doc tiers (B-021):
#   - PROJECT_STARTER.md  (canonical for core workflow rules + rationale)
#   - templates/CONTRIBUTING.md  (canonical for per-project operational concretization)
#   - templates/CLAUDE.md  (session-facing summary for the AI)
#
# Each region in each file is bracketed by HTML-comment anchors:
#     <!-- C4:<region>:start -->
#     ...canonical text...
#     <!-- C4:<region>:end -->
#
# The linter extracts content between matching anchors in each file, diffs every
# pair (against the first file as reference), and fails on any drift or missing
# region. CI invokes this script on every push/PR via template-self-test.yml.
#
# Adding a new region: add the anchored region (same text) to all three files
# in the same commit, then append the region name to REGIONS below.
#
# Exit codes:
#   0 — all regions match
#   1 — drift detected or a region is missing/empty

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

FILES=(
  "PROJECT_STARTER.md"
  "templates/CONTRIBUTING.md"
  "templates/CLAUDE.md"
)

REGIONS=(
  "gate-clause"
  "proposal-format"
  "bare-gogogo"
)

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

extract_region() {
  local file="$1" region="$2"
  local start_marker="<!-- C4:${region}:start -->"
  local end_marker="<!-- C4:${region}:end -->"
  awk -v start="$start_marker" -v end="$end_marker" '
    index($0, start) { capture = 1; next }
    index($0, end)   { capture = 0; next }
    capture          { print }
  ' "$file"
}

slugify_path() {
  printf '%s' "$1" | tr '/' '_'
}

EXIT=0

for region in "${REGIONS[@]}"; do
  # Extract once per (region, file).
  for file in "${FILES[@]}"; do
    out="$TMPDIR/${region}__$(slugify_path "$file")"
    extract_region "$file" "$region" > "$out"
    if [[ ! -s "$out" ]]; then
      echo "ERROR: region '$region' missing or empty in $file" >&2
      EXIT=1
    fi
  done

  # Compare every other file against the first as reference.
  first_file="${FILES[0]}"
  first_out="$TMPDIR/${region}__$(slugify_path "$first_file")"
  for ((i = 1; i < ${#FILES[@]}; i++)); do
    other_file="${FILES[i]}"
    other_out="$TMPDIR/${region}__$(slugify_path "$other_file")"
    [[ -s "$first_out" && -s "$other_out" ]] || continue
    if ! diff -u "$first_out" "$other_out" > "$TMPDIR/diff" 2>&1; then
      echo "DRIFT: region '$region' differs between $first_file and $other_file:" >&2
      sed -e "s|$first_out|$first_file (region: $region)|" \
          -e "s|$other_out|$other_file (region: $region)|" \
          "$TMPDIR/diff" >&2
      EXIT=1
    fi
  done
done

if [[ $EXIT -eq 0 ]]; then
  echo "OK: canonical rule regions match across ${#FILES[@]} files."
fi

exit $EXIT
