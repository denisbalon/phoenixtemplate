# Claude Code session guidance

**Canonical scope (per B-021 in `docs/spec.md`):** this file is the **session-facing summary the AI loads every session**. The rule statements below (gate clause, proposal format, bare-gogogo handling) are **inline and verbatim** — not pointers — because the AI needs them in working context to apply them. Stripping these to pointers was observed historically to make the AI miss the rules. The full rationale (*why* the gate is `gogogo!`, *why* propose-and-confirm replaced verbs, alternatives considered) lives canonically in `WORKFLOW.md`. The per-project operational doc with project-specific commands and sequences is `CONTRIBUTING.md`. All three tiers carry the rule statements as deliberate AI-safety redundancy — the C4 consistency linter (`scripts/check-rule-consistency.sh`) keeps them mechanically in sync. **Editing any rule here means editing it in `CONTRIBUTING.md` + `WORKFLOW.md` too, in the same commit.**

## `gogogo!` passphrase — read this first (HARD GATE)

<!-- C4:gate-clause:start -->
**Do NOT take any state-mutating action unless: (a) Claude's immediately preceding message contained a concrete proposal (specific files/commands/commits, not vague phrasing) ending with one of the canonical invitation lines, classifying each numbered option as `[change]` (state-mutating: tracked-file Edit/Write/NotebookEdit, git commit/push, gh pr create/merge/comment, deploy, external POST/PUT/DELETE) or `[info]` (read-only / research / discussion / navigation / memory writes); AND (b) the user's CURRENT message contains the literal substring `gogogo!`, optionally preceded by one or more whitespace-separated digits selecting `[change]` options — single `N gogogo!` for one `[change]`, multi-digit `N1 N2 ... gogogo!` for multiple `[change]` items in a "Choose any (in order):" list (multi-select against "Choose one:" remains invalid). Picking an `[info]` option needs only bare `N` — no `gogogo!`; state-mutating actions never happen in `[info]` paths. Mid-execution deviation requires a new proposal, including if an option classified `[info]` turns out to need state mutation.**
<!-- C4:gate-clause:end -->

Reading files, grepping, planning in chat, clarifying questions, surfacing proposals, and writes to local-only memory/settings (`~/.claude/projects/.../memory/`, `.claude/settings.local.json`) are fine without the gate. Tracked-file `Edit`/`Write`/`NotebookEdit`, `git commit` / `push`, `gh pr` actions, and deploys are all gated.

`gogogo!` confirms a concrete proposal Claude surfaced. There are no verbs — the proposal carries the action description in plain English, and `gogogo!` (or `N gogogo!` for a single pick, or `N1 N2 ... gogogo!` for multi-select against a "Choose any" list) is the authorization signal. The action executed is exactly what the proposal described. **Every assistant message ends with a concrete proposal** — never leave the user without something to `gogogo!`; clarification turns end with "continue with [next queued item] or describe a different direction."

### Proposal format

<!-- C4:proposal-format:start -->
**Proposal format.** Every assistant message ends with a concrete proposal *when there's an action or navigation path to surface*. Pure discussion / clarification turns where no list-of-paths fits naturally can end without a trailing proposal — the no-round-trip property holds because `[info]`-class options never require `gogogo!`, so navigation is single-keystroke when it does apply.

Each numbered option in a list is prefixed `**[change]**` or `**[info]**`:

- `[change]` — state-mutating (tracked-file Edit/Write/NotebookEdit, git commit/push, gh pr create/merge/comment, deploy, external POST/PUT/DELETE). Authorization requires `gogogo!`.
- `[info]` — read-only, research, discussion, navigation, planning text, or memory writes. Picked with bare `N`; no `gogogo!` needed.

Three invitation forms:

- **Single suggestion** — bold "Proposed: <action>" header + concrete plan (specific files / commands / commits). If state-mutating: ends with `Type \`gogogo!\` to proceed.` If pure info-only: ends naturally with no trailing invitation.
- **Choose one** — bold "Choose one:" header + mutually exclusive numbered options (each prefixed `[change]` or `[info]`) + final line specifying the gate per option: e.g. `Type \`1 gogogo!\` for the [change] option, or \`2\` / \`3\` for the [info] options.` Multi-digit `N M gogogo!` against this form is invalid → re-prompt.
- **Choose any (in order)** — bold "Choose any (in order):" header + independent numbered options (each prefixed) + final line accepting `N` (single info pick), `N gogogo!` (single change), `N1 N2 ... gogogo!` (multi-select; one `gogogo!` covers all `[change]` items in the typed sequence; `[info]` items proceed in the same message without separate authorization). Skipping is fine.

Concrete means specific files, specific commands, specific commits — not "commit the changes." For multi-step actions (5-step feature work), enumerate every step in the proposal. The user's authorization signal applies exactly to the proposed plan; mid-execution deviation requires a new proposal. If an option classified `[info]` turns out to need state mutation, STOP and re-propose with the option re-classified as `[change]`.
<!-- C4:proposal-format:end -->

<!-- C4:bare-gogogo:start -->
**Bare `gogogo!` with no preceding proposal** → reply *"I haven't proposed anything concrete yet. Describe what you'd like and I'll surface options."* and STOP.
<!-- C4:bare-gogogo:end -->

**Review is out-of-band.** Review happens in a separate session with whatever reviewer the user prefers, pointed at `docs/pr_review_instructions.md` and the open PR. Claude does not dispatch or prepare reviewers — no proposal flow for review exists Claude-side.
**Imperatives without `gogogo!` do not authorize** → "do that", "merge it", "ship it" etc. never trigger anything on their own. Respond with a concrete proposal + invitation line.
**Mid-execution deviation from the proposal** → STOP and re-propose. The original `gogogo!` only authorized the original plan.
**Conversation drift** → if my last message was clarification rather than a fresh proposal, re-propose before acting.

When the proposed action is a 5-step feature workflow, the atomic sequence is: spec (incl. decision log if architectural) → bump versions + CHANGELOG entry → code → commit (push immediately) → deploy. Subject ends `v<X.Y.Z>`. Every change bumps `VERSION` AND adds a `CHANGELOG.md` entry. Every commit is pushed to origin in the same turn — no local-only commits.

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

## Env-metadata contract

<!-- C4:env-metadata-contract:start -->
**`.env.example` env-metadata contract (per B-020):** Each var's metadata is declared via `@directive` comments — `@description` · `@required` · `@optional` · `@default` · `@validator` · `@sensitive`. Both `bootstrap.sh` and `check-env.sh` read the same shared parser (`templates/scripts/_env-schema-parse.sh`); the directives are the contract, not the prose. Free-text comments without `@` are shown in bootstrap prompts but not parsed as metadata. Default-if-neither-given is `@required`. Full vocabulary + parsing rules in B-020.
<!-- C4:env-metadata-contract:end -->

## When the user asks a question that's already documented

Point them at the doc instead of re-deriving. The docs are the source of truth and re-answering creates drift.
