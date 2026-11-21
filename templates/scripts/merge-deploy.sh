#!/usr/bin/env bash
# merge-deploy.sh — the executable merge -> deploy node (B-060).
#
# The full suite is the MANDATORY FIRST STEP of merging. This script is the
# single sanctioned path from a green-reviewed PR to a deployed `main`: it runs
# the full suite against the PR's live reviewed head and, ONLY if that is
# green, merges (bound to that exact head) and deploys — synchronously, inline,
# right here. A red suite halts the script before any merge and prints the
# failing output for the caller to propose fixes against (B-049); nothing is
# merged.
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
# Usage: scripts/merge-deploy.sh <PR#>
# Exit codes: 0 merged+deployed · 2 full suite red (not merged) · 3 head moved
set -euo pipefail

PR="${1:?usage: scripts/merge-deploy.sh <PR#>}"
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

# 1. Resolve the PR's LIVE reviewed head (B-053/B-056) — never a SHA from the
#    transcript or a stale local branch. `review-post!` covers every open PR,
#    so for any PR but the current branch the local checkout is the wrong code.
HEAD="$(gh pr view "$PR" --json headRefOid -q .headRefOid)"
echo "-> PR #$PR reviewed head: $HEAD"

# 2. Run the full suite against THAT head in a throwaway worktree, so the right
#    code is tested and the dispatcher's own branch is untouched.
git fetch -q origin
WT="$(mktemp -d)"
git worktree add -q --detach "$WT" "$HEAD"
echo "-> running full suite against $HEAD"
if ! ( cd "$WT" && uv sync --frozen >/dev/null 2>&1 && full_suite ); then
  git worktree remove --force "$WT"
  echo "x full suite RED on $HEAD — NOT merging. Fix, push, re-run." >&2
  exit 2
fi
git worktree remove --force "$WT"
echo "ok full suite green on $HEAD"

# 3. Re-query the head: a push during the suite makes the green verdict stale
#    (B-056). A moved head halts — re-review the new head; never merge code the
#    suite did not cover.
HEAD_NOW="$(gh pr view "$PR" --json headRefOid -q .headRefOid)"
if [[ "$HEAD_NOW" != "$HEAD" ]]; then
  echo "x head moved $HEAD -> $HEAD_NOW during the suite — halt, re-review." >&2
  exit 3
fi

# 4. Merge, BOUND to the verified SHA — GitHub rejects the merge if the head
#    moved in the final window, closing the TOCTOU gap (B-054 / kit v1.59.2).
echo "-> merging #$PR at $HEAD"
gh pr merge --rebase --delete-branch --match-head-commit "$HEAD" "$PR"

# 5. Sync main and deploy — synchronous, inline.
git checkout -q main
git pull --ff-only -q origin main
echo "-> deploying"
"$ROOT/scripts/deploy.sh"
echo "ok merged + deployed #$PR"
