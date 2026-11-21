#!/usr/bin/env bash
# merge-deploy.sh — the executable merge -> deploy node (B-060).
#
# The full suite is the MANDATORY FIRST STEP of merging. This script is the
# single sanctioned path from a green-reviewed PR to a deployed `main`: it runs
# the full suite against the PR's CLEAN-REVIEWED head and, ONLY if that is
# green, merges (bound to that exact head) and deploys — synchronously, inline,
# right here. A red suite halts the script before any merge and prints the
# failing output for the caller to propose fixes against (B-049); nothing is
# merged.
#
# It merges ONLY the head the CALLER has already verified clean-reviewed
# (B-054: zero findings at every severity, per-commit coverage, the latest
# overall review bound to the tip). That verified SHA is a REQUIRED argument —
# the script does not re-derive the clean-review predicate (that is the review
# skill's job, and reviewer-shaped). It resolves the PR's live head and REFUSES
# to run the suite or merge if the live head differs from the verified SHA: a
# push that landed after the review cleared, or an invocation on a head that was
# never reviewed, would otherwise let an UNREVIEWED head be tested and merged
# (`--match-head-commit` only rejects a push that lands LATER, during the final
# window — it does not establish that the starting head was reviewed at all).
#
# This is a LOCAL EXECUTABLE gate, not a server-side required status check: a
# human merging through the GitHub UI bypasses it. That residual bypass is the
# accepted trade-off for keeping merge -> deploy SYNCHRONOUS (D-043) — GitHub's
# only server-side "run the suite at merge" mechanism is the merge queue, which
# makes merges ASYNCHRONOUS and breaks this inline `merge -> git pull -> deploy`
# flow. The companion guard is the `protect-main` ruleset (require-PR, block
# direct push — B-055). (An earlier `merge-queue.yml`, kit v1.62.0 / A-018, took
# the server-side route; it was withdrawn for exactly this incompatibility.)
#
# DEPLOY IS THE NODE'S OPTIONAL TAIL (D-044). The full suite gates the MERGE,
# not the deploy, so the two are separable: pass --no-deploy to merge + sync
# `main` and STOP before `scripts/deploy.sh` -- for a docs change, or to hold /
# batch the deploy and run `scripts/deploy.sh` yourself later. The mandatory
# part -- suite -> head-binding -> merge -> pull -- is IDENTICAL either way;
# only the final deploy is skipped. It is an EXPLICIT flag, never diff-
# detection: "this is docs" and "I want to wait" are caller intent, not
# readable off the diff, and guessing would skip a wanted deploy (or run an
# unwanted one). The B-054 clean-review auto-advance stays deploy-on -- there
# is no human in that path to hold it; --no-deploy is for a hand-run merge you
# mean to hold.
#
# Usage: scripts/merge-deploy.sh <PR#> <reviewed-head-sha> [--no-deploy]
#   <reviewed-head-sha> is the SHA the caller established as clean-reviewed
#   (the review skill passes the headRefOid its B-054 clean verdict was bound
#   to). The script merges that SHA and no other.
#   --no-deploy  merge + sync main, but SKIP scripts/deploy.sh (hold the deploy).
# Exit codes: 0 merged (and deployed unless --no-deploy) · 2 full suite red
#             (not merged) · 3 live head is not the reviewed SHA (stale/
#             unreviewed, or moved during the suite) -- re-review, nothing
#             merged · 64 bad usage (unknown argument)
set -euo pipefail

PR="${1:?usage: scripts/merge-deploy.sh <PR#> <reviewed-head-sha> [--no-deploy]}"
REVIEWED="${2:?usage: scripts/merge-deploy.sh <PR#> <reviewed-head-sha> [--no-deploy] (SHA the caller verified clean-reviewed)}"
shift 2
# Optional flags. --no-deploy holds the deploy: merge + sync main, then stop
# before scripts/deploy.sh (docs work, or a deploy you mean to run later). The
# suite + merge are unaffected -- deploy is the node's separable tail (D-044).
DEPLOY=1
for arg in "$@"; do
  case "$arg" in
    --no-deploy) DEPLOY=0 ;;
    *) echo "x unknown argument: $arg" >&2
       echo "  usage: scripts/merge-deploy.sh <PR#> <reviewed-head-sha> [--no-deploy]" >&2
       exit 64 ;;
  esac
done
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# --- the full suite -------------------------------------------------------
# The single pre-merge net — edit this to your stack. For a code project it is
# the whole test suite + the diff-wide linters; for a docs-only repo it is all
# linters + the smoke test. It runs against a clean checkout of the reviewed
# head (below), NEVER the dispatcher's working tree.
full_suite() {
  TEST_DATABASE_URL="${TEST_DATABASE_URL:-}" uv run pytest -q
  uv run ruff check .
  uv run mypy src
}

# 1. Bind to the CALLER-VERIFIED clean-reviewed SHA. Resolve the PR's live head
#    (B-053/B-056 — never a transcript SHA or a stale local branch) and REFUSE
#    if it is not the verified SHA: that means a push landed after the review
#    cleared, or this PR was never reviewed at $REVIEWED. Do this BEFORE the
#    suite — an unreviewed head must not even be tested-then-merged here.
HEAD="$(gh pr view "$PR" --json headRefOid -q .headRefOid)"
if [[ "$HEAD" != "$REVIEWED" ]]; then
  echo "x PR #$PR live head $HEAD != reviewed $REVIEWED." >&2
  echo "  The reviewed head is stale or this PR was not reviewed at that SHA." >&2
  echo "  Re-review the live head; NOT merging." >&2
  exit 3
fi
echo "-> PR #$PR clean-reviewed head: $REVIEWED"

# 2. Run the full suite against the reviewed head in a throwaway worktree, so
#    the right code is tested and the dispatcher's own branch is untouched.
git fetch -q origin
WT="$(mktemp -d)"
git worktree add -q --detach "$WT" "$REVIEWED"
echo "-> running full suite against $REVIEWED"
if ! ( cd "$WT" && uv sync --frozen >/dev/null 2>&1 && full_suite ); then
  git worktree remove --force "$WT"
  echo "x full suite RED on $REVIEWED — NOT merging. Fix, push, re-review, re-run." >&2
  exit 2
fi
git worktree remove --force "$WT"
echo "ok full suite green on $REVIEWED"

# 3. Re-query the head: a push during the suite makes the green verdict AND the
#    clean review stale (B-056). A moved head halts — re-review the new head;
#    never merge code the suite + review did not cover.
HEAD_NOW="$(gh pr view "$PR" --json headRefOid -q .headRefOid)"
if [[ "$HEAD_NOW" != "$REVIEWED" ]]; then
  echo "x head moved $REVIEWED -> $HEAD_NOW during the suite — halt, re-review." >&2
  exit 3
fi

# 4. Merge, BOUND to the verified SHA — GitHub also rejects the merge if the
#    head moves in the final window, closing the TOCTOU gap (B-054 / v1.59.2).
echo "-> merging #$PR at $REVIEWED"
gh pr merge --rebase --delete-branch --match-head-commit "$REVIEWED" "$PR"

# 5. Sync main, then deploy -- synchronous, inline. Deploy is the node's
#    OPTIONAL tail (D-044): --no-deploy merges + syncs main but holds the
#    deploy, to run scripts/deploy.sh yourself later. The merge above already
#    happened; only this final step is conditional.
git checkout -q main
git pull --ff-only -q origin main
if [[ "$DEPLOY" -eq 1 ]]; then
  echo "-> deploying"
  "$ROOT/scripts/deploy.sh"
  echo "ok merged + deployed #$PR"
else
  echo "ok merged #$PR -- deploy HELD (--no-deploy); run scripts/deploy.sh when ready"
fi
