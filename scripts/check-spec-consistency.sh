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
#   B — canonical-source for workflow lives in WORKFLOW.md, not PROJECT_STARTER.md.
#       Added v1.29.1 as structural prevention (no shipped regression of this
#       exact class yet — but Phase 2.1 audit found that PROJECT_STARTER.md's
#       canonical-source role was reassigned to WORKFLOW.md in v1.25.0, and
#       this invariant prevents future drift). Forbidden phrases:
#         - 'PROJECT_STARTER\.md is the canonical'
#         - 'PROJECT_STARTER\.md is canonical for'
#         - 'PROJECT_STARTER\.md §2.{0,30}canonical' (present-tense; the
#           audit-trail form "was PROJECT_STARTER.md §2 before v1.25.0"
#           doesn't match because "canonical" doesn't appear within 30 chars)
#         - 'canonical source.{0,30}PROJECT_STARTER\.md'
#       Reason: B-025 (v1.22.0) split the workflow content into WORKFLOW.md
#       in v1.25.0; D-012 (v1.27.1) settled PROJECT_STARTER.md as a permanent
#       thin-index — these claims would contradict both.
#
#   C — verb-prefix gate model (per B-001+B-011+D-004, superseded v1.23.0).
#       Added v1.29.1 as structural prevention. The propose-and-confirm gate
#       (B-026) replaced verb-prefix in v1.23.0; any active-doc claim that
#       still describes the verb-prefix model as current is a regression.
#       Forbidden phrases:
#         - 'verb-prefix gate'  (as a current claim; historical mentions in
#           spec.md decision-log are out of scope per active-doc filter)
#         - 'verb table (per|in|of) (the )?(active|current)'  (specific
#           current-assertion phrasing)
#         - 'action verb (per|in|of) (the )?(active|current)'  (same)
#       Reason: B-001+B-011 are in the historical-superseded section of
#       docs/spec.md; D-004 superseded by D-010+D-011. Their language must
#       not reappear in active docs as current claims.
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

# Invariant B — canonical-source for workflow lives in WORKFLOW.md.
INV_B_PATTERNS=(
  'PROJECT_STARTER\.md is the canonical'
  'PROJECT_STARTER\.md is canonical for'
  'PROJECT_STARTER\.md §2.{0,30}canonical'
  'canonical source.{0,30}PROJECT_STARTER\.md'
)

# Invariant C — verb-prefix gate model is superseded.
INV_C_PATTERNS=(
  'verb-prefix gate'
  'verb table (per|in|of) (the )?(active|current)'
  'action verb (per|in|of) (the )?(active|current)'
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

# Run Invariant B patterns.
for pattern in "${INV_B_PATTERNS[@]}"; do
  check_invariant "B" "$pattern"
done

# Run Invariant C patterns.
for pattern in "${INV_C_PATTERNS[@]}"; do
  check_invariant "C" "$pattern"
done

if [[ $EXIT -eq 0 ]]; then
  echo "OK: no forbidden phrases found in ${FILES_SCANNED} active docs (${PATTERNS_CHECKED} invariant patterns checked)."
else
  echo "FAIL: ${HITS} forbidden phrase occurrence(s) across ${FILES_SCANNED} active docs (${PATTERNS_CHECKED} invariant patterns checked)." >&2
fi

exit $EXIT
