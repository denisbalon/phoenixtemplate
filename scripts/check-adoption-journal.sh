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
#   - On the base branch itself it passes: there is nothing to diff. But a
#     branch with no base ref or no merge-base is NOT a pass — it is a check
#     that could not run, and says so as WARN on stderr. That distinction
#     exists because the first CI run of this script passed vacuously: the
#     default shallow checkout has no 'main' ref, so it reported green while
#     verifying nothing. A check that cannot run must never look like one
#     that ran and found nothing.
#
# Exit codes: 0 = satisfied or not applicable, 1 = templates/ changed with
# no new adoption entry.
#
# Override: an `Adoption-Skip: <reason>` trailer in any commit message on
# the branch. For a templates/ change consumers genuinely need not mirror —
# e.g. registering a meta-only script in templates/manifest.yaml, which is
# never exported to consumers.
#
#   The trailer, not an environment variable, is the mechanism on purpose.
#   The first version of this script used ADOPTION_SKIP=1, which CI cannot
#   see: the override worked locally and the build failed anyway. A trailer
#   travels with the commit, is visible to CI, and puts the justification in
#   permanent history instead of a shell invocation nobody can audit later.
#   ADOPTION_SKIP=1 still works for a local one-off run, but it does NOT
#   satisfy CI — use the trailer for anything that needs to merge.

set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

BASE="${ADOPTION_BASE:-main}"
JOURNAL="ADOPTION.md"

if [[ -n "${ADOPTION_SKIP:-}" ]]; then
  echo "SKIP: overridden locally via ADOPTION_SKIP."
  echo "      NOTE: CI cannot see this. Use an 'Adoption-Skip: <reason>' commit"
  echo "      trailer for anything that needs to merge."
  exit 0
fi

# Resolve the base ref. A CI checkout has full history under fetch-depth: 0
# but creates no local branch for the base — only origin/<base> exists. The
# first CI run after fetch-depth: 0 landed still warned for exactly that
# reason, so try the remote-tracking ref before giving up.
if git rev-parse --verify --quiet "$BASE" >/dev/null; then
  BASE_REF="$BASE"
elif git rev-parse --verify --quiet "origin/$BASE" >/dev/null; then
  BASE_REF="origin/$BASE"
else
  echo "WARN: cannot verify — neither '$BASE' nor 'origin/$BASE' resolves." >&2
  echo "      This is NOT a pass; the check did not run. In CI this usually" >&2
  echo "      means a shallow checkout — set 'fetch-depth: 0' on actions/checkout." >&2
  exit 0
fi

if [[ "$(git rev-parse HEAD)" == "$(git rev-parse "$BASE_REF")" ]]; then
  echo "OK: on '$BASE_REF' itself — nothing to check."
  exit 0
fi

MERGE_BASE="$(git merge-base HEAD "$BASE_REF" 2>/dev/null || true)"
if [[ -z "$MERGE_BASE" ]]; then
  echo "WARN: cannot verify — no merge-base with '$BASE_REF'." >&2
  echo "      This is NOT a pass; the check did not run. Usually a shallow clone." >&2
  exit 0
fi

# An Adoption-Skip trailer justifies the templates/ files in ITS OWN COMMIT,
# never the whole branch. The first version accepted any trailer anywhere in
# merge-base..HEAD and skipped everything: a harmless meta-only commit could
# carry a justified trailer, and a later consumer-facing change on the same
# branch would then bypass the journal entirely. A one-commit justification
# must not become a branch-wide exemption.
declare -a UNJUSTIFIED=()
SKIPPED_ANY=""
while read -r sha; do
  [[ -z "$sha" ]] && continue
  files="$(git show --name-only --format= "$sha" -- templates/ || true)"
  [[ -z "$files" ]] && continue
  reason="$(git log -1 --format=%B "$sha" | sed -n 's/^Adoption-Skip:[[:space:]]*//p' | head -1 || true)"
  if [[ -n "$reason" ]]; then
    echo "SKIP: ${sha:0:7} — $reason"
    SKIPPED_ANY=1
  else
    while read -r f; do [[ -n "$f" ]] && UNJUSTIFIED+=("$f"); done <<< "$files"
  fi
done < <(git rev-list "$MERGE_BASE"..HEAD)

if [[ ${#UNJUSTIFIED[@]} -eq 0 ]]; then
  if [[ -n "$SKIPPED_ANY" ]]; then
    echo "OK: every templates/ change on this branch is covered by a scoped Adoption-Skip trailer."
  else
    echo "OK: no templates/ changes on this branch — no adoption entry required."
  fi
  exit 0
fi

CHANGED="$(printf '%s\n' "${UNJUSTIFIED[@]}" | sort -u)"
if [[ -z "$CHANGED" ]]; then
  echo "OK: no templates/ changes on this branch — no adoption entry required."
  exit 0
fi

nfiles="$(printf '%s\n' "$CHANGED" | wc -l | tr -d ' ')"

# A new "## A-NNN" heading is the common case, but B-047 is per adoptable
# CHANGE, not per commit — a correction to an already-shipped change amends
# its existing entry instead. This repo has done exactly that (A-003 gained
# the timeout note in v1.48.2), and an earlier version of this script would
# have rejected that commit while its author could not honestly claim the
# change was consumer-irrelevant. So: accept either a new heading, or a
# substantive edit to the body of an existing entry.
#
# "Substantive" excludes whitespace-only churn deliberately — otherwise
# re-wrapping a paragraph would satisfy the obligation.
before_headings="$(git show "$MERGE_BASE:$JOURNAL" 2>/dev/null | grep -c '^## A-' || true)"
after_headings="$(grep -c '^## A-' "$JOURNAL" 2>/dev/null || true)"
added=$(( ${after_headings:-0} - ${before_headings:-0} ))

if (( added > 0 )); then
  echo "OK: $added new adoption entry/entries for $nfiles changed templates/ file(s)."
  exit 0
fi

# No new heading — did an existing entry change substantively?
journal_edit="$(git diff --ignore-all-space --ignore-blank-lines \
  "$MERGE_BASE"...HEAD -- "$JOURNAL" | grep -cE '^[+-][^+-]' || true)"
if (( ${journal_edit:-0} > 0 )); then
  echo "OK: existing adoption entry amended for $nfiles changed templates/ file(s)."
  echo "    (no new A-NNN heading; B-047 is per adoptable change, so a correction"
  echo "     to an already-shipped change amends its entry rather than adding one)"
  exit 0
fi

{
  echo "FAIL: templates/ changed but $JOURNAL gained no entry (B-047)."
  echo
  echo "Changed under templates/:"
  printf '%s\n' "$CHANGED" | sed 's/^/  /'
  echo
  echo "$JOURNAL has ${before_headings:-0} entry/entries at the merge-base and ${after_headings:-0} now,"
  echo "and no substantive edit to an existing entry."
  echo
  echo "B-047: a change consuming projects must mirror obliges an adoption-journal"
  echo "entry in the SAME PR. Add one, or — if consumers genuinely need not mirror"
  echo "this change — add an 'Adoption-Skip: <reason>' trailer to a commit on"
  echo "this branch. The trailer is visible to CI and lands in permanent history;"
  echo "the ADOPTION_SKIP env var is local-only and will not make CI pass."
} >&2
exit 1
