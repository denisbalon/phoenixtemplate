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
# If any tracked file under templates/ changed — excluding
# templates/manifest.yaml, see below — ADOPTION.md must also have gained a
# new "## A-NNN" heading or a substantive edit to an existing entry.
#
# Deliberate limits, so the check stays honest rather than merely strict:
#
#   - It cannot judge whether a templates/ change is consumer-relevant.
#     A typo fix in a template comment needs no action from consumers; the
#     script cannot tell it from a rule change. It does not try — it asks
#     for an entry either way, and the entry says "no action required".
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
# There is deliberately NO exemption mechanism — no way to wave a change
# through from a commit message or the environment. One file is excluded by
# name (templates/manifest.yaml, a derived inventory; see below), which is a
# fixed property of the script rather than a per-change judgement.
#
# Three exemption mechanisms were tried and each leaked:
#
#   branch-wide trailer  — a meta-only commit's justified trailer covered a
#                          later consumer-facing change on the same branch.
#   per-commit trailer   — closed that, but an earlier untrailered commit
#                          could then only be justified by rewriting pushed
#                          history; it blocked its own branch.
#   per-file trailer     — closed that, but a skip carried forward forever:
#                          a typo exemption on templates/CLAUDE.md silently
#                          covered a rule change to the same file later.
#
# Every leak was found by review, not by design, and each fix moved the hole
# rather than closing it — so there is no mechanism at all. A templates/
# change that consumers need not act on is still consumer-facing content and
# still gets an entry; there is no way to declare otherwise per-change.

set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

BASE="${ADOPTION_BASE:-main}"
JOURNAL="ADOPTION.md"

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

# templates/manifest.yaml is an INVENTORY of the kit, not kit content. It
# changes because something else changed — adding a file, renaming one,
# correcting a purpose line — so it never independently obliges an entry.
# Consumers do receive it (exported_by_starter: true), but a manifest row for
# a meta-only script they never get is not something they can act on.
#
# This is an exclusion of a derived file, NOT an exemption mechanism. Three
# of those were tried and each leaked (see the header). The distinction that
# matters: this is a fixed property of one file, visible in the script and
# unchangeable from a commit message — not a per-change judgement anyone can
# invoke. A real templates/ change alongside a manifest edit still fails,
# because the other file is still counted.
CHANGED="$(git diff --name-only "$MERGE_BASE"...HEAD -- templates/ \
  | grep -v '^templates/manifest\.yaml$' || true)"
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
  echo "B-047: a templates/ change obliges an adoption-journal entry in the SAME PR."
  echo "There is no exemption mechanism — three were tried and each leaked, so a"
  echo "change cannot be waved through from a commit message or the environment."
  echo
  echo "templates/manifest.yaml is excluded by name as a derived inventory file"
  echo "and is never listed above; every other templates/ file needs an entry."
} >&2
exit 1
