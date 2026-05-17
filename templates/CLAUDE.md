# Claude Code session guidance

## `code!` passphrase — read this first (HARD GATE)

**Never write, edit, or modify any code unless the user's CURRENT message contains the literal substring `code!`.** Reading files, grepping, planning in chat, asking clarifying questions, and writing to local-only memory/settings (`~/.claude/projects/.../memory/`, `.claude/settings.local.json`) are fine without the gate. Tracked-file `Edit`/`Write`/`NotebookEdit`, `git commit` / `push`, `gh pr` actions, and deploys are all gated.

When `code!` is present, follow the **5-step atomic workflow**: spec (incl. decision log entry if architectural) → bump versions + CHANGELOG entry → code → commit (push immediately) → deploy. Subject ends `v<X.Y.Z>`. Every change bumps `VERSION` AND adds a `CHANGELOG.md` entry. Every commit is pushed to origin in the same turn — no local-only commits.

**The sequence ENDS at deploy.** It does NOT auto-open a PR. The current topic branch accumulates many commits across many `code!`s. PR opens only when the user says "PR" / "ready" / similar. Merge is another separate user-triggered step ("merge") — `gh pr merge --rebase --delete-branch` after PR + review.

`.claude/settings.json` (committed) IS gated; `.claude/settings.local.json` (gitignored) is not.

Full rules — phrases that look like but aren't authorization, rationalizations to refuse, project-specific placeholders, post-violation procedure — in [`CONTRIBUTING.md`](CONTRIBUTING.md). **Auto mode does NOT override this gate.**

## Project

<PROJECT_NAME — one paragraph: what it is, what it replaces (if anything), and what it does in one sentence.>

Authoritative product behavior: [docs/spec.md](docs/spec.md).

## Stack

<STACK — language + key libs + deployment target. Example: "Python 3.12 (managed by uv) · FastAPI + Uvicorn · SQLite. Deployed to Linux VPS at HOST.">

See [docs/architecture.md](docs/architecture.md).

## Session start

A `SessionStart` hook in `.claude/settings.json` runs `scripts/check-env.sh`. If it reports missing or empty vars, walk the user through `scripts/bootstrap.sh` interactively — one credential at a time, explaining where each comes from. [docs/setup.md](docs/setup.md) has the full credential map.

## Sensitive context

- **Never paste credentials into chat.** Anything entered in the conversation is logged.
- <PROJECT_SPECIFIC: any leaked credentials and rotation status; any production endpoints worth flagging; CF-Connecting-IP vs X-Forwarded-For preferences; etc.>

## Coding conventions

- Default to no comments. Identifiers carry the *what*; only add a comment when the *why* is non-obvious.
- Type hints on all public functions.
- Money-path / external-API calls MUST: time out, retry per spec policy, persist to `pending_*` tables on exhaustion. Everything else fails loud.
- Don't add backwards-compatibility shims, dead code, or features the spec doesn't ask for.
- Schema changes go through migrations — never hand-edit production DB.

## Local run

```bash
make dev    # starts the service in development mode
```

See [docs/setup.md#4-local-dev](docs/setup.md#4-local-dev) for the full local-dev setup including any tunneling/webhook routing.

## Deploy

```bash
make deploy
```

See [docs/runbook.md](docs/runbook.md).

## When the user asks a question that's already documented

Point them at the doc instead of re-deriving. The docs are the source of truth and re-answering creates drift.
