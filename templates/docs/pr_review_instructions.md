# PR review instructions

**Reviewer-agnostic.** This document is the rubric + output contract for whatever reviewer is running against this PR:

- **Codex** via its GitHub App (the project default — branch owner posts `@codex review — follow docs/pr_review_instructions.md ...` on the PR)
- **`/ultrareview <PR#>`** in Claude Code (second-opinion path for high-stakes changes)
- **Another LLM** (Cursor, Gemini CLI, GPT-5 via a CI runner, etc.) pointed at this file
- **A human** reading the diff with this file open

The rubric is the same regardless of who's running it. The wiring (how the reviewer gets invoked) lives in `CONTRIBUTING.md` §4. This file is **not** for the dev session — that's [`CLAUDE.md`](../CLAUDE.md).

## Output contract — read this before anything else

**The deliverable of every review is GitHub comments, posted via `gh api`, one per commit on the branch — including commits with no findings.**

1. **Per-commit coverage is mandatory.** Walk every commit `main..HEAD` in order. Each commit gets at least one comment on GitHub:
   - inline comments on specific lines (`gh api -X POST repos/<owner>/<repo>/pulls/<N>/comments -f path=... -F line=... -F commit_id=<sha> -f body=...`),
   - or a commit-level review (`gh api -X POST repos/<owner>/<repo>/pulls/<N>/reviews -F commit_id=<sha> -f event=COMMENT -f body=... -F 'comments[]=...'`),
   - or — for a clean commit — an explicit "no findings on `<sha>` — `<subject>`" comment (see 2).
2. **Clean commits are NOT silently skipped.** A commit with no findings still gets a comment that says so explicitly. Silence is indistinguishable from "the reviewer forgot this commit"; the explicit "no findings" comment closes that gap and makes the audit trail complete.
3. **Plus one overall summary review at the end** with findings rolled up by severity (Block / Strong / Nit per the rubric below).
4. **Never produce instead of comments:** local files (`review.md`, `findings.txt`, etc. — don't even draft them locally), chat-only summaries (ephemeral), Slack/email/PR-description edits (the description belongs to the author).

The rest of this document is the rubric for *what* to look for. The contract above is *where the output goes* — non-negotiable, applies to both `/ultrareview` and any manual or AI-assisted review run against this repo.

## Block (must fix before merge)

1. **Spec violation.** Product behavior is frozen in [docs/spec.md](spec.md). Deviations require updating the spec section in the same PR.
2. **Missing retry/persist on a money-path call.** Every external API call must time out, retry per spec policy, and land in `pending_*` on exhaustion. No silent drops.
3. **Idempotency hole.** Webhooks/upstream events may be redelivered. Handlers must tolerate replay.
4. **Untrusted client input.** Receiver accepts only documented params. Read real client IP from the trusted header configured for this deploy.
5. **Secrets in code, fixtures, or commit messages.** All secrets via env. No hardcoded fallbacks.
6. **Schema change without migration.** Schema changes need a migration. Down-migrations for additive changes; destructive ones need explicit approval in the PR.

## Strong (should fix)

- Observability gap on a failure path (no log, no Sentry capture).
- New external call without timeout.
- New env var not added to `.env.example` with a comment block.
- Dead code, commented-out blocks, leftover prints.
- Tests that mock the entire money path.

## Nit (mention, don't block)

- Naming, formatting, single-line refactor opportunities.
- Comments that restate code.

## Don't flag

- Missing tests for trivial glue (config loaders, plain models).
- Lack of comments where identifiers are clear.
- Project-specific patterns (call out in this section).

## Cross-cutting concerns

- <PROJECT_SPECIFIC: list of high-leverage things to always check, e.g. "event_time semantics", "hashing input correctness", "secret_token header verification">.
