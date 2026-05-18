---
name: request-codex-review
description: Run a local Codex CLI review of the current branch against main using `codex review --base main`. Use when the user says "ask Codex to review", "send to Codex", "codex review this", or invokes /request-codex-review. Synchronous, runs locally, uses the user's local Codex auth and OpenAI quota. Surfaces the final review findings inline. Does NOT post to GitHub, does NOT auto-fix.
---

# request-codex-review — local Codex CLI review of the current branch

Runs `codex review --base main` from inside the project directory. Codex reads the diff between the current branch and `main`, looks around the repo as it sees fit, and produces a review with priority-tagged findings. Output is synchronous: the review streams to the terminal (or to a persisted-output file in long-running Claude sessions), and the final findings appear at the end of a verbose exec trace.

## Why local CLI (not GitHub App)

The project's default reviewer is Codex. Two paths exist to reach it:

- **Local CLI (this skill, default since v1.6.0):** `codex review --base main`. Requires only that the user has the `codex` CLI installed and logged in. No GitHub App. Synchronous output.
- **GitHub App (deprecated):** `@codex review` PR comment triggering a Codex GitHub App. Only works if such an App is installed on the repo. Most accounts don't have one — confirming this on the user's account was what motivated the v1.6.0 pivot.

The CLI path is the default because (a) `codex` is already installed locally, (b) no third-party App or webhook dance is required, (c) output streams here in the session so the next step (which findings to fix) is immediate.

## Prerequisites

- `codex` CLI installed and on `PATH` (`command -v codex` returns a path)
- User logged into Codex (`codex login` once; credentials persist in `~/.codex/`)
- Current branch is **not** `main` (nothing to review against itself)
- Current branch has commits ahead of `main` (`git log main..HEAD --oneline` is non-empty)

## Procedure

1. **Verify prerequisites.** Run each check and stop with a specific message if any fails:

   ```sh
   command -v codex >/dev/null 2>&1 || { echo "✗ codex CLI not in PATH. Install per https://github.com/openai/codex."; exit 1; }
   BR=$(git branch --show-current)
   [ "$BR" != "main" ] || { echo "✗ On main; nothing to review."; exit 1; }
   [ -n "$(git log main..HEAD --oneline 2>/dev/null)" ] || { echo "✗ No commits ahead of main on $BR."; exit 1; }
   ```

2. **Run the review:**

   ```sh
   codex review --base main
   ```

   Note: `--base <BRANCH>` and the optional `[PROMPT]` argument are mutually exclusive in the codex CLI. The review uses Codex's built-in review prompt; we don't customize it here. For strict rubric compliance with custom prompts, use `codex exec` instead.

3. **Surface findings.** Output is verbose (the exec trace, including diff dumps, often runs to 100KB+). The actual review starts after the last `exec` line in the trace, prefixed with `codex`. Show the user the final review block (~last 50 lines of output is usually enough). If a persisted-output file path is returned by the harness, point at it so the user can `tail` for context.

4. **Stop.** Do NOT auto-fix. The user reads the findings and decides which to act on. Each fix is a separate `fix gogogo!` cycle.

## Output format Codex uses

The local-CLI review uses Codex's built-in format: **`[P1] / [P2] / [P3]` priority tags** with line/file references. This is not the project's `Block / Strong / Nit` rubric — the CLI can't accept a custom rubric while scoped with `--base`. Treat priorities as equivalent severities (P1 ≈ Block, P2 ≈ Strong, P3 ≈ Nit) when triaging.

If the project requires strict `Block / Strong / Nit` output, use `codex exec` with a prompt that pipes in `docs/pr_review_instructions.md`. That path trades CLI ergonomics for rubric compliance.

## Makefile target

`make request-codex-review` wraps the same invocation for terminal use outside Claude sessions. Identical prereq checks; identical output.

## When NOT to use

- **Mid-branch (no commits yet ahead of main):** nothing to review. Say so, stop.
- **On `main`:** branch off first.
- **For non-Claude review:** a human reading the diff with `docs/pr_review_instructions.md` open is always valid.
- **State-mutating actions beyond running the CLI:** this skill runs `codex review`, captures output, surfaces it. It does NOT commit, push, comment, or modify anything.

## Cost note

`codex review` makes paid OpenAI API calls billed to the user's account. Cost scales with diff size — typical branches (≤ a few hundred lines) cost cents.

## Re-review after fixes

Same skill, run again. Codex sees the updated diff against `main`. No special handling needed.
