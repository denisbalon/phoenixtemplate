#!/usr/bin/env bash
# Adoption-journal linter (B-050, v1.51.0).
#
# Enforces B-047's standing obligation: a change to a file under templates/
# that consuming projects must mirror obliges an ADOPTION.md entry in the
# same PR. Nothing checked that until now — B-047 stated the rule and left
# it to review. The very next templates/ change after B-047 froze omitted
# its entry and was caught only by a reviewer on PR #16, which is what
# motivated this script (D-031 option (e), deferred there, closed here).
#
# What it does: compares HEAD against the merge-base with the base branch.
# If any tracked file under templates/ changed, ADOPTION.md must also have
# gained at least one new "## A-NNN" heading.
#
# Deliberate limits, so the check stays honest rather than merely strict:
#
#   - It cannot judge whether a templates/ change is consumer-relevant.
#     A typo fix in a template comment needs no entry; the script cannot
#     tell it from a rule change. Hence ADOPTION_SKIP below, which records
#     the judgement in the commit rather than skipping silently.
#   - It checks that an entry was ADDED, not that the entry is correct.
#     Whether A-NNN names the right files, or its Check actually works, is
#     review's job — PR #17 had exactly that failure and a linter would not
#     have caught it. Pretending otherwise would give false confidence.
#   - On the base branch itself, or with no base to compare against, it
#     passes. There is nothing to diff.
#
# Exit codes: 0 = satisfied or not applicable, 1 = templates/ changed with
# no new adoption entry.
#
# Override: ADOPTION_SKIP=1 ./scripts/check-adoption-journal.sh
#   For a templates/ change consumers genuinely need not mirror. Use it in
#   the commit that needs it and say why in the commit message — an
#   unexplained override is the failure mode this script exists to prevent.

set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

BASE="${ADOPTION_BASE:-main}"
JOURNAL="ADOPTION.md"

if [[ -n "${ADOPTION_SKIP:-}" ]]; then
  echo "SKIP: adoption-journal check overridden (ADOPTION_SKIP set)."
  echo "      State in the commit message why this templates/ change needs no entry."
  exit 0
fi

if ! git rev-parse --verify --quiet "$BASE" >/dev/null; then
  echo "OK: no '$BASE' ref to compare against — nothing to check."
  exit 0
fi

if [[ "$(git rev-parse HEAD)" == "$(git rev-parse "$BASE")" ]]; then
  echo "OK: on '$BASE' itself — nothing to check."
  exit 0
fi

MERGE_BASE="$(git merge-base HEAD "$BASE" 2>/dev/null || true)"
if [[ -z "$MERGE_BASE" ]]; then
  echo "OK: no merge-base with '$BASE' — nothing to check."
  exit 0
fi

CHANGED="$(git diff --name-only "$MERGE_BASE"...HEAD -- templates/ || true)"
if [[ -z "$CHANGED" ]]; then
  echo "OK: no templates/ changes on this branch — no adoption entry required."
  exit 0
fi

before="$(git show "$MERGE_BASE:$JOURNAL" 2>/dev/null | grep -c '^## A-' || true)"
after="$(grep -c '^## A-' "$JOURNAL" 2>/dev/null || true)"
before="${before:-0}"
after="${after:-0}"
added=$(( after - before ))
nfiles="$(printf '%s\n' "$CHANGED" | wc -l | tr -d ' ')"

if (( added > 0 )); then
  echo "OK: $added new adoption entry/entries for $nfiles changed templates/ file(s)."
  exit 0
fi

{
  echo "FAIL: templates/ changed but $JOURNAL gained no entry (B-047)."
  echo
  echo "Changed under templates/:"
  printf '%s\n' "$CHANGED" | sed 's/^/  /'
  echo
  echo "$JOURNAL has $before entry/entries at the merge-base and $after now."
  echo
  echo "B-047: a change consuming projects must mirror obliges an adoption-journal"
  echo "entry in the SAME PR. Add one, or — if consumers genuinely need not mirror"
  echo "this change — re-run with ADOPTION_SKIP=1 and say why in the commit message."
} >&2
exit 1
