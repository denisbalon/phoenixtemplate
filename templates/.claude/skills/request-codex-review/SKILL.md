---
name: request-codex-review
description: Post a PR comment that triggers Codex (via its GitHub App) to review the current PR using the project's docs/pr_review_instructions.md rubric. Use when the user says "ask Codex to review", "send to Codex", "codex review this", or invokes /request-codex-review. The skill detects the current branch's open PR, composes a canonical invocation comment naming the rubric file explicitly, posts it via `gh pr comment`, and confirms. Does NOT poll for results — Codex posts back to the PR async; the user reads it there.
---

# request-codex-review — trigger Codex review of the current PR

This skill is the one-command path to the project's default reviewer (Codex). It exists because the user's habit is to open Codex locally and (a) ask it to look around, (b) ask it to read `docs/pr_review_instructions.md`, (c) ask it to review the latest PR. This skill collapses that ritual into a single PR comment that names the rubric file explicitly — Codex picks it up via its GitHub App and posts findings back to the PR.

## When to use

- User says "ask Codex to review", "send to Codex", "request Codex review", "codex review this PR", "codex this"
- User invokes `/request-codex-review`

## Prerequisites

- Codex GitHub App is installed on the repo (one-time setup; see `CONTRIBUTING.md` §4 "Codex invocation")
- The current branch has an open PR

## Procedure

1. **Detect the current PR number:**

   ```sh
   gh pr view --json number,url,headRefName,state
   ```

   - No open PR for current branch → say: *"No open PR for this branch. Open one first (`PR gogogo!`)."* Stop.
   - PR is `CLOSED` or `MERGED` → say so; do not post on a closed PR. Stop.

2. **Compose the canonical comment body.** The rubric file is named explicitly — this is the project's habit and ensures Codex reads it:

   ```
   @codex review

   Please follow the PR review rubric in `docs/pr_review_instructions.md`:
   - Severity: Block / Strong / Nit
   - Per-commit comments — walk every commit `main..HEAD` in order
   - On clean commits, post an explicit "no findings on <sha> — <subject>" comment
   - One overall summary review at the end, rolled up by severity

   Look around the repo (spec, architecture, recent changes) before diving into the diff if useful.
   ```

3. **Post the comment via `gh`:**

   ```sh
   gh pr comment <PR#> --body "$(cat <<'BODY'
   @codex review

   Please follow the PR review rubric in `docs/pr_review_instructions.md`:
   - Severity: Block / Strong / Nit
   - Per-commit comments — walk every commit `main..HEAD` in order
   - On clean commits, post an explicit "no findings on <sha> — <subject>" comment
   - One overall summary review at the end, rolled up by severity

   Look around the repo (spec, architecture, recent changes) before diving into the diff if useful.
   BODY
   )"
   ```

   HEREDOC keeps formatting intact. The `Makefile` target `make request-codex-review` wraps this same command for one-shot invocation from a terminal.

4. **Confirm to the user:**

   ```
   ✓ Codex notified on PR #<N> — check the PR in a few minutes. Codex posts comments async; this session does not poll.
   ```

5. **Stop.** Do NOT poll for results. Do NOT open the PR page. Do NOT propose follow-up work in the same turn. The user will check the PR and come back with feedback when ready.

## When NOT to use this skill

- **Mid-branch.** The user reviews at the end of a branch, not mid-stream. If invoked during active development, ask: *"Open the PR first (`PR gogogo!`) before sending to Codex?"*
- **Other reviewers.** For `/ultrareview`, use the canonical `/ultrareview <PR#>` slash command directly. For manual review, walk `docs/pr_review_instructions.md` yourself and post via `gh api`.
- **State-mutating actions beyond the comment.** This skill posts ONE comment. It does not merge, close, label, or modify the PR.

## Re-review after addressing feedback

Same skill, different body. After the user pushes fixes addressing prior Codex findings:

```
@codex re-review — addressed prior findings, N new commits since last review.

Same rubric (`docs/pr_review_instructions.md`).
```

## Edge cases

- **Multiple open PRs from the same branch:** `gh pr view` returns the most recent — that's the one to target. Surface the PR number/URL in the confirmation so the user can correct if it's the wrong one.
- **Repo doesn't have Codex installed:** Codex won't respond. The comment still posts cleanly. If no response in ~5 minutes, tell the user to install the GitHub App per `CONTRIBUTING.md` §4.
- **Gate interaction:** posting a PR comment IS a state-mutating action via `gh`. This skill should only run when the user's CURRENT message contains `<verb> gogogo!` (typically `review gogogo!`). The skill itself is just instructions — the gate check happens at the harness level before any `gh pr comment` call.
