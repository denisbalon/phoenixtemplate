# Claude Code session guidance

## `gogogo!` passphrase — read this first (HARD GATE)

**Never take any state-mutating action unless the user's CURRENT message contains the literal substring `gogogo!`.** Reading files, grepping, planning in chat, clarifying questions, and writes to local-only memory/settings (`~/.claude/projects/.../memory/`, `.claude/settings.local.json`) are fine without the gate. Tracked-file `Edit`/`Write`/`NotebookEdit`, `git commit` / `push`, `gh pr` actions, and deploys are all gated.

`gogogo!` is the **execute trigger**. It must be preceded by an **action verb** in the same message — the verb specifies *what* to execute.

### Verb → action

| Phrase | Action |
|---|---|
| `code gogogo!` · `feat gogogo!` · `fix gogogo!` · `chore gogogo!` · `docs gogogo!` · `refactor gogogo!` · `test gogogo!` · `perf gogogo!` · `ship gogogo!` | Full 5-step workflow (spec → bump+CHANGELOG → code → commit+push → deploy) |
| `commit gogogo!` | Commit current work + push (still bumps version + CHANGELOG; skips deploy) |
| `PR gogogo!` · `ready gogogo!` · `open PR gogogo!` | Open pull request |
| `merge gogogo!` | `gh pr merge --rebase --delete-branch` |
| `deploy gogogo!` | Run the project's deploy command |
| `revert gogogo!` | Revert last commit + redeploy |

**Bare `gogogo!` (no verb) is ambiguous** → reply *"Which action? code / commit / PR / merge / deploy / revert?"* and STOP.

**Review is out-of-band.** No `review gogogo!` verb, no skill, no Makefile target — review happens in a separate session with whatever reviewer the user prefers, pointed at `docs/pr_review_instructions.md` and the open PR. Claude does not dispatch or prepare reviewers.
**Verb without `gogogo!` does not authorize** → `merge` alone, `PR` alone, etc. never trigger anything. Plan-text + "Send `<verb> gogogo!`".
**`<verb-A> gogogo!` doesn't authorize action B** → one verb, one action.

When the verb maps to the 5-step workflow, the atomic sequence is: spec (incl. decision log if architectural) → bump versions + CHANGELOG entry → code → commit (push immediately) → deploy. Subject ends `v<X.Y.Z>`. Every change bumps `VERSION` AND adds a `CHANGELOG.md` entry. Every commit is pushed to origin in the same turn — no local-only commits.

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

## Coding pitfalls to avoid (Karpathy's four)

Standing rules for every session. Full text + sources in [docs/karpathy-claude-rules.md](docs/karpathy-claude-rules.md).

1. **Think before coding.** State assumptions explicitly; surface alternatives when ambiguous; verify load-bearing facts (file, signature, schema) before depending on them.
2. **Simplicity first.** Implement only what was asked. No speculative scaffolding, no "while I was here" cleanup, no premature abstractions. Three similar lines beats a wrong factory.
3. **Surgical changes.** Touch only what the task requires. Match existing style. Don't bundle drive-by refactors into the diff — mention them in chat instead.
4. **Goal-driven execution.** Define the success criterion *before* writing code, then actually run the check (test, endpoint, browser). "Types pass" ≠ "works."

Slogan: *don't tell the agent what to do — give it success criteria and watch it go.*

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
