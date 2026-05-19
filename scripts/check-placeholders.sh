#!/usr/bin/env bash
# C3 placeholder linter (B-024).
#
# Walks the meta-repo's Markdown documentation and fails non-zero if any
# canonical substitution placeholder (the angle-bracketed strings consumers
# are expected to `sed` away when bootstrapping a project from the template)
# appears in plain prose — i.e., outside an inline code span or a fenced
# code block. Catches the failure mode where an unresolved placeholder
# leaks from the template's bootstrap surface into a user-facing meta-repo
# document, which would read as "the docs ship with TODO markers."
#
# Scope (deliberately narrow to keep the false-positive rate at zero):
#   - Scans `*.md` files only.
#   - Excludes `templates/`, where placeholders are expected and load-bearing
#     (consumers `sed` them on bootstrap).
#   - Excludes `codex improvement plan.md` (external doc — frozen content).
#   - Strips fenced code blocks (lines starting with three backticks toggle
#     the fence) entirely and strips inline single-backtick code spans
#     before scanning. Mentions like "the `<package_name>` placeholder" are
#     references to the placeholder concept, not unresolved placeholders.
#   - Only the canonical placeholder set below is checked. Generic angle-
#     bracket meta-syntax used in prose (e.g. `<verb>`, `<file>`, `<X.Y.Z>`)
#     is NOT a substitution placeholder and is not flagged.
#
# The allowed-set is the union of placeholders consumers `sed` during
# bootstrap, per `PROJECT_STARTER.md §1`, `README.md`'s Known Limitations,
# and the smoke test (`scripts/smoke-test.sh`).
#
# Exit codes:
#   0 — no canonical placeholder appears in plain prose anywhere
#   1 — one or more leaks (each printed as `<file>:<line> -> <placeholder>`)
#
# CI: wired into `.github/workflows/template-self-test.yml` after the
# doc-reference linter (B-023) and before the smoke test (B-014).

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

PLACEHOLDERS=(
  '<package_name>'
  '<PACKAGE_NAME>'
  '<PROJECT_NAME>'
  '<PROJECT_SLUG>'
  '<GITHUB_USER>'
  '<HOST>'
  '<DOMAIN>'
  '<PROJECT_DESCRIPTION>'
  '<COPYRIGHT_HOLDER>'
  '<YEAR>'
)

# Build a single ERE alternation for grep. `<` and `>` are literal in ERE.
PATTERN=""
for p in "${PLACEHOLDERS[@]}"; do
  if [[ -z "$PATTERN" ]]; then PATTERN="$p"; else PATTERN="$PATTERN|$p"; fi
done

mapfile -t FILES < <(find . -type f -name '*.md' \
  -not -path './.git/*' \
  -not -path './templates/*' \
  -not -name 'codex improvement plan.md' \
  | sort)

EXIT=0
HITS=0

strip_code() {
  # Replace fenced-block lines and inline code spans with whitespace-preserving
  # placeholders so the line numbers in subsequent grep output still match the
  # source file.
  awk '
    BEGIN { in_fence = 0 }
    /^[[:space:]]*```/ { in_fence = !in_fence; print ""; next }
    in_fence { print ""; next }
    {
      s = $0
      gsub(/`[^`]+`/, "", s)
      print s
    }
  ' "$1"
}

for f in "${FILES[@]}"; do
  # grep -n on the stripped stream preserves source line numbers since
  # strip_code emits one output line per input line.
  while IFS= read -r match; do
    line_no="${match%%:*}"
    content="${match#*:}"
    for p in "${PLACEHOLDERS[@]}"; do
      if [[ "$content" == *"$p"* ]]; then
        printf '%s:%s -> %s\n' "$f" "$line_no" "$p" >&2
        HITS=$((HITS + 1))
        EXIT=1
      fi
    done
  done < <(strip_code "$f" | grep -nE "$PATTERN" || true)
done

if [[ $EXIT -eq 0 ]]; then
  echo "OK: no canonical placeholders found in plain prose across ${#FILES[@]} meta-repo files."
else
  echo "FAIL: ${HITS} canonical placeholder occurrence(s) leaked into plain prose across ${#FILES[@]} meta-repo files." >&2
fi

exit $EXIT
