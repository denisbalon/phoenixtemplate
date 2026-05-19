#!/usr/bin/env bash
# Spec-consistency linter (B-029, v1.29.0).
#
# Narrow semantic-invariant checker. Catches the kind of drift that the
# other linters miss: prose claims in active docs that contradict frozen
# spec behavior in docs/spec.md. The doc-reference linter (B-023) catches
# link-target drift; the rule-consistency linter (B-022) catches byte-exact
# regions drift; the placeholder linter (B-024) catches unresolved
# placeholders; this linter catches *semantic* drift the others don't see.
#
# Scope (deliberately narrow to keep false-positive rate at zero):
#   - Only the 5 active root docs + 2 trio template files. Excludes
#     PROJECT_STARTER.md (its Template changelog tail has historical
#     mentions), CHANGELOG.md (audit trail), docs/spec.md (historical-
#     superseded section + decision-log have intentional historical
#     mentions of pre-supersession state).
#   - Forbidden-phrase checks only. Each invariant lists exact phrases
#     that MUST NOT appear in active prose (outside backtick code spans
#     and fenced code blocks). If a phrase appears, fail with file:line.
#   - Phrases are case-sensitive ERE patterns. Conservative wording chosen
#     to avoid legitimate prose matches. Add more invariants over time as
#     new regression classes surface.
#
# Active-doc scope: README.md, BOOTSTRAP.md, WORKFLOW.md,
# templates/CONTRIBUTING.md, templates/CLAUDE.md.
#
# Invariants:
#
#   A — env-metadata @directive contract (per B-020).
#       Catches the v1.26.1 regression class: active doc described
#       requiredness as "Optional prose" / "comment block contains Optional"
#       while the spec said `@directive` metadata. Forbidden phrases:
#         - 'Optional prose'
#         - 'comment block .* Optional' (regex; "comment block" then "Optional")
#         - '"Optional" if'  (specific v1.26.1-era phrasing)
#       Reason: B-020 froze @directive as the contract in v1.14.1.
#
# Exit codes:
#   0 — no forbidden phrases found
#   1 — at least one forbidden phrase detected (each printed as
#       `<file>:<line> [Invariant <id>] forbidden phrase "<pattern>": <line content>`)
#
# CI: wired into .github/workflows/template-self-test.yml alongside the
# other linters and the smoke test.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

ACTIVE_DOCS=(
  "README.md"
  "BOOTSTRAP.md"
  "WORKFLOW.md"
  "templates/CONTRIBUTING.md"
  "templates/CLAUDE.md"
)

# Invariant A — env-metadata @directive contract.
# Each entry is a regex (POSIX ERE). Conservative; case-sensitive.
INV_A_PATTERNS=(
  'Optional prose'
  'comment block.*Optional'
  '"Optional" if'
)

EXIT=0
HITS=0
FILES_SCANNED=0
PATTERNS_CHECKED=0

# Strip fenced code blocks (replace with blank lines so line numbers stay
# in sync with the source file) and inline single-backtick code spans
# before scanning. Matches the convention used by other linters.
strip_code() {
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

check_invariant() {
  local invariant_id="$1" pattern="$2"
  local f match line_no content
  PATTERNS_CHECKED=$((PATTERNS_CHECKED + 1))
  for f in "${ACTIVE_DOCS[@]}"; do
    [[ -f "$f" ]] || continue
    while IFS= read -r match; do
      line_no="${match%%:*}"
      content="${match#*:}"
      printf '%s:%s [Invariant %s] forbidden phrase matched "%s": %s\n' \
        "$f" "$line_no" "$invariant_id" "$pattern" "$content" >&2
      HITS=$((HITS + 1))
      EXIT=1
    done < <(strip_code "$f" | grep -nE "$pattern" 2>/dev/null || true)
  done
}

# Count active docs that exist.
for f in "${ACTIVE_DOCS[@]}"; do
  [[ -f "$f" ]] && FILES_SCANNED=$((FILES_SCANNED + 1))
done

# Run Invariant A patterns.
for pattern in "${INV_A_PATTERNS[@]}"; do
  check_invariant "A" "$pattern"
done

if [[ $EXIT -eq 0 ]]; then
  echo "OK: no forbidden phrases found in ${FILES_SCANNED} active docs (${PATTERNS_CHECKED} invariant patterns checked)."
else
  echo "FAIL: ${HITS} forbidden phrase occurrence(s) across ${FILES_SCANNED} active docs (${PATTERNS_CHECKED} invariant patterns checked)." >&2
fi

exit $EXIT
