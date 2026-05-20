# Workflow + Gate

The canonical source for this project's process: the `gogogo!` propose-and-confirm gate, the 5-step atomic release sequence, branching/commit/PR/merge/deploy mechanics, conventions, the recommended auto-memory seed, and the PR review rubric. Extracted from `PROJECT_STARTER.md` §2 + §9 + §10 + §11 in v1.25.0 as part of the doc split (Codex Phase 4 #2). Read this when you need to know how this project's process works.

**Canonical scope (per B-021):** this file is the canonical source for the **core workflow + rationale** — gate semantics, propose-and-confirm contract, 5-step structure, version-bump rule, branching, PR/merge/review flow, plus the *why* behind each. `templates/CONTRIBUTING.md` carries the per-project operational concretization (commands, sequences, project-specific bits) and references this file for rationale. `templates/CLAUDE.md` carries the session-facing summary the AI needs in working context (rule statements inline, not pointers). **Rule statements** (gate clause, proposal format, bare-gogogo prompt, allowed-without-gate list, refuse-list) are **deliberately duplicated** across all three tiers — defensive AI-safety redundancy that earned its keep historically. Editing any duplicated rule means editing it in all three places; the C4 consistency linter (`scripts/check-rule-consistency.sh`) catches drift automatically.

This file is **binding** for every change.

---

## The `gogogo!` passphrase — hard gate

<!-- C4:gate-clause:start -->
**Do NOT take any state-mutating action unless: (a) Claude's immediately preceding message contained a concrete proposal (specific files/commands/commits, not vague phrasing) ending with one of the canonical invitation lines, classifying each numbered option as `[change]` (state-mutating: tracked-file Edit/Write/NotebookEdit, git commit/push, gh pr create/merge/comment, deploy, external POST/PUT/DELETE) or `[info]` (read-only / research / discussion / navigation / memory writes); AND (b) the user's CURRENT message contains the literal substring `gogogo!`, optionally preceded by one or more whitespace-separated digits selecting `[change]` options — single `N gogogo!` for one `[change]`, multi-digit `N1 N2 ... gogogo!` for multiple `[change]` items in a "Choose any (in order):" list (multi-select against "Choose one:" remains invalid). Picking an `[info]` option needs only bare `N` — no `gogogo!`; state-mutating actions never happen in `[info]` paths. Mid-execution deviation requires a new proposal, including if an option classified `[info]` turns out to need state mutation. A direct natural-language instruction to perform a `[change]` action — e.g. "create the PR", "commit this", "push it", "delete X" — does NOT by itself satisfy (a) or (b); it is a request to be restated as a concrete proposal and confirmed with `gogogo!`. The literal token is the only authorization channel for state mutation; confidence that the instruction was understood never substitutes for it (B-040).**
<!-- C4:gate-clause:end -->

`gogogo!` confirms a concrete proposal Claude surfaced. The proposal IS the contract — what file gets edited, what commit gets pushed, what command runs. The action Claude executes is exactly what the proposal described. There are no verbs; proposals carry the action description in plain English, and `gogogo!` (or `N gogogo!` for a single pick, or `N1 N2 ... gogogo!` for multi-select against a "Choose any" list) is the authorization signal. Multi-select is a strict extension of single-pick: each selected option was a concrete proposal Claude already surfaced and the user inspected, so safety is preserved — multi-select doesn't pre-authorize unknown future proposals, it batches known ones.

### Proposal format

<!-- C4:proposal-format:start -->
**Proposal format.** Every assistant message ends with a concrete proposal *when there's an action or navigation path to surface*. Pure discussion / clarification turns where no list-of-paths fits naturally can end without a trailing proposal — the no-round-trip property holds because `[info]`-class options never require `gogogo!`, so navigation is single-keystroke when it does apply.

Each numbered option in a list is prefixed `✏️ **[change]**` or `👀 **[info]**`:

- `✏️ [change]` — state-mutating (tracked-file Edit/Write/NotebookEdit, git commit/push, gh pr create/merge/comment, deploy, external POST/PUT/DELETE). Authorization requires `gogogo!`.
- `👀 [info]` — read-only, research, discussion, navigation, planning text, or memory writes. Picked with bare `N`; no `gogogo!` needed.

Three invitation forms:

- **Single suggestion** — bold "Proposed: <action>" header + concrete plan (specific files / commands / commits). If state-mutating: ends with `Type \`gogogo!\` to proceed.` If pure info-only: ends naturally with no trailing invitation.
- **Choose one** — bold "Choose one:" header + mutually exclusive numbered options (each prefixed `[change]` or `[info]`) + final line specifying the gate per option: e.g. `Type \`1 gogogo!\` for the [change] option, or \`2\` / \`3\` for the [info] options.` Multi-digit `N M gogogo!` against this form is invalid → re-prompt.
- **Choose any (in order)** — bold "Choose any (in order):" header + independent numbered options (each prefixed) + final line accepting `N` (single info pick), `N gogogo!` (single change), `N1 N2 ... gogogo!` (multi-select; one `gogogo!` covers all `[change]` items in the typed sequence; `[info]` items proceed in the same message without separate authorization). Skipping is fine.

Concrete means specific files, specific commands, specific commits — not "commit the changes." **Every option must represent a real action** — code change, information lookup, navigation, or continued discussion. Null-action options ("stop here," "wait," "pick up later," "wrap up," "do nothing") are forbidden; the user can simply not respond. Null options dilute the gate signal and add visual clutter without surfacing real choice. An option to continue discussion or surface more information IS a real action and stays. For multi-step actions (5-step feature work), enumerate every step in the proposal. The user's authorization signal applies exactly to the proposed plan; mid-execution deviation requires a new proposal. If an option classified `[info]` turns out to need state mutation, STOP and re-propose with the option re-classified as `[change]`.
<!-- C4:proposal-format:end -->

<!-- C4:bare-gogogo:start -->
**Bare `gogogo!` with no preceding proposal** → reply *"I haven't proposed anything concrete yet. Describe what you'd like and I'll surface options."* and STOP.
<!-- C4:bare-gogogo:end -->

### Self-check before any state-mutating action

Before any state-mutating tool call (`Edit` / `Write` / `NotebookEdit` / `Bash` running `git commit` / `git push` / deploy / `gh pr create|merge|comment` / `gh issue create` / curl POST/PUT/DELETE):

1. Did MY IMMEDIATELY-PRECEDING assistant message contain a concrete proposal (specific files/commands/commits) ending with one of the canonical invitation lines? Were the numbered options classified `[change]` or `[info]`?
2. Is the user picking a `[change]` option? If so: does THE USER'S CURRENT message contain the literal substring `gogogo!`?
3. Is the user picking an `[info]` option? If so: bare `N` is sufficient — no `gogogo!` required.
4. If a numbered choice was offered: did the user select with `N`, `N gogogo!` (single pick), or `N1 N2 ... gogogo!` (multi-select)? Does each N match my numbered list?
5. If multi-select was used: was my proposal a "Choose any (in order):" form (multi-select valid; one `gogogo!` covers all `[change]` items in the sequence) or "Choose one:" form (multi-select invalid → re-prompt, don't execute)?
6. Am I about to do exactly what the proposal described, or has something deviated — including: an option I classified `[info]` actually needs state mutation?

- No prior proposal → propose now. Don't execute.
- Vague prior proposal ("commit the changes") → re-propose concretely. Don't execute.
- Prior proposal but conversation drifted (questions, clarifications, no re-proposal in my last message) → re-propose before acting.
- User picked a `[change]` option without `gogogo!` → re-prompt: "Option N is `[change]` — type `N gogogo!` to authorize."
- Bare `gogogo!` without prior proposal → see the canonical prompt above.
- `N` against an `[info]` option → proceed with option N (no `gogogo!` needed; the action is non-state-mutating).
- `N gogogo!` against a `[change]` option → execute option N exactly as described.
- `N1 N2 ... gogogo!` against a "Choose any (in order):" list → execute `[change]` items as authorized + run `[info]` items in the same message; each one exactly as described.
- `N1 N2 ... gogogo!` against a "Choose one:" list → invalid; re-prompt and don't execute.
- Mid-execution deviation, including `[info]` → `[change]` re-classification → STOP and re-propose.

**Auto mode does NOT override this gate.** The check is the FIRST step of every action response — before writing code, before reading files for the change.

### Phrases that LOOK like authorization but aren't

Bare imperatives *without* `gogogo!`:

`now lets X` · `let's X` · `can you X` · `could you X` · `please X` · `do X` · `do that` · `go` · `proceed` · `ship it` · `yes` · `yes do` · `yeah` · `ok do it` · `sure` · `we should X` · `we need X` · `time to X` · detailed feature descriptions in imperative mood · user pasting an exact diff with "just do the fix"

All → respond with a concrete proposal + invitation line → STOP.

### Phrases that mean DEFINITELY NOT action

`understood?` · `wdyt?` · `what do you think?` · `got it?` · `make sense?` · `ok?` · `right?` · any closing confirmation question.

### Allowed without `gogogo!`

Reading files · grep · read-only git (`log` / `status` / `diff`) · web search · planning text · proposing (the propose-then-wait pattern itself never requires `gogogo!`) · spec-style description of what *would* be built · clarifying questions · writes to local-only memory/settings files (`~/.claude/projects/.../memory/`, `.claude/settings.local.json`).

**`.claude/settings.json` (committed) IS gated** — counts as code.

### Rationalizations to refuse

| Rationalization | Why it's wrong |
|---|---|
| "Intent is unambiguous, just ship it" | Gate is `gogogo!` after a concrete proposal, not intent. |
| "User said `gogogo!` recently, this scope counts" | Each `gogogo!` authorizes one specific proposal. New action = new proposal. |
| "Auto mode says minimize interruptions" | Auto mode does NOT override this gate. |
| "Direct imperative + clarity = authorization" | Imperative grammar ≠ `gogogo!`. |
| "User said yes" | `yes` is not `gogogo!`. |
| "It's just a docs/SPEC tweak" | If it's an `Edit` on tracked files, it needs a proposal + `gogogo!`. |
| "User pasted the diff verbatim" | Specifying WHAT ≠ authorizing WHEN. |
| "User is rushing" | Schedule is not my problem; the gate is. |
| "Bare `gogogo!`, I'll default to whatever feels right" | Bare `gogogo!` without a prior proposal is invalid — ask for clarification. |
| "Reality deviated from my proposal mid-action; close enough" | STOP and re-propose. The original `gogogo!` only authorized the original plan. |
| "I proposed concretely several messages ago, the user is following up now" | The proposal must be in the IMMEDIATELY-PRECEDING message. Conversation drift → re-propose. |
| "User multi-selected against my Choose-one list; running both is close enough" | `Choose one:` means mutually exclusive. Multi-select is invalid → re-prompt. |
| "I should force a proposal at the end of this pure discussion turn" | B-028 refined B-027: ends-with-proposal binds only when there's an action or navigation path to surface. Pure discussion turns can end naturally. |
| "User typed bare `N` against a `[change]` option — close enough, just do it" | `[change]` options ALWAYS need `gogogo!`. Bare `N` against `[change]` is invalid → re-prompt. Conversely, `gogogo!` against an `[info]` option is harmless overhead — proceed normally. |
| "Reality made this `[info]` option need a state change, but it's small — just do it" | Re-classification is a deviation. STOP and re-propose with the option marked `[change]`. |

---

## The 5-step atomic sequence (on `gogogo!`)

Atomic. Missing or reordering any step is a failure.

1. **Update the spec** — `docs/spec.md` reflects the change BEFORE any code is written. Spec-first keeps intent explicit. For architectural decisions, also add an entry to the **Decision log** section in `docs/spec.md` (oldest first; format: `D-NNN (YYYY-MM-DD) <title>` with Chose / Considered / Why / Implemented in lines). Decisions live forever in the repo; chat history that produced them does not.
2. **Bump versions + add CHANGELOG entry** — bump `VERSION` (and any language-specific markers — see "Recommended auto-memory seed" below for what each project tracks), then add a `CHANGELOG.md` entry under the new version heading with the user-facing summary. Format: `## v<X.Y.Z> — YYYY-MM-DD` followed by bullets, optionally grouped by area. The CHANGELOG entry rides in the same commit, so the commit subject can reference `v<X.Y.Z>` with full context.
3. **Write the code** — touch implementation files now and only now.
4. **Commit + push** — single commit per concern, subject ends with `v<X.Y.Z>`. HEREDOC for the message. Push to origin in the same turn. No `--no-verify`. No `--amend` unless explicit.
5. **Deploy** — run the project's deploy command. If pre-MVP / no deployable yet, step 5 is a no-op; resume on every commit to `main` once deployable. Surface deploy errors loudly; do NOT silently skip.

**The sequence ENDS at step 5.** Do not auto-open a PR. Do not auto-merge. Stay on the topic branch. The next user message will either be another `gogogo!` (more commits), or a PR/merge trigger (separate phase).

If a step fails (spec unclear, deploy errors, push rejected), stop and surface — do not fake-complete the sequence.

---

## Version-bump rule

ANY change → bump. Not "meaningful" change. ANY. Don't rationalize "same-version rebuild." **Never overwrite a version number with different content under it.**

Initial version: `0.1.0`. The bump rule applies on every `gogogo!` after that.

Increment policy:
- **patch** (`0.1.0 → 0.1.1`): default for typical changes
- **minor** (`0.1.0 → 0.2.0`): notable features, schema changes
- **major** (`0.x.x → 1.0.0`): first production release; subsequently breaking changes

---

## Branching

- **Never commit to `main`.** Every change lives on a feature branch. `main` only receives explicit fast-forward merges via PR.
- Topic branches use kebab-case prefix per type — `feat/`, `fix/`, `chore/`, `docs/`, `refactor/`, `test/`, `perf/`. Example: `feat/api-handler`, `fix/auth-retry-401`.
- Branch from `main`, push immediately on `git checkout -b`, deleted after merge. No `develop`, `release/*`, environment-named branches.
- **Never `git checkout` / `git switch` without explicit instruction.** "Check the latest stuff" ≠ checkout — fetch + report, then ask.
- **Topic branches accumulate many commits.** A single branch normally hosts dozens of `gogogo!`s before a PR is opened. Don't open a new branch per `gogogo!`. Don't open a PR after each commit.

---

## Commits

### Mechanics

- **Push after every commit.** Local-only commits are not allowed. Spec, docs, and version bumps must always be on origin.
- Subject: `<type>: <imperative summary> v<X.Y.Z>` — types: `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `perf`. ≤72 chars.
- Stage **specific files** (`git add path/to/file ...`), not `git add -A` / `git add .` (avoids accidentally picking up secrets, build artifacts, large binaries).
- HEREDOC for messages so formatting survives.
- Trailers: `Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>` when Claude assisted.
- No `--no-verify`. No `--amend` unless explicit.
- One concern per commit. Split commits that span concerns.

### Commit message quality (be super clear)

A reviewer reading the commit log six months from now should understand **what changed and why without opening the diff**.

- **Subject line** is the *result* in active voice with a concrete object. The subject says what changed and to what.
  - ❌ Bad: `fix bug`, `update docs`, `various changes`, `WIP`, `tweaks`, `address feedback`, `bump version`.
  - ✅ Good: `fix auth 401 retry on expired token v0.2.3`, `update spec frozen-behavior with new subscription modes v0.1.7`, `drop legacy admin user from runbook §4 v0.1.8`.
- **Body** explains the *why* — not what (the diff shows that), but the constraint, decision, or context that justifies the change. 1–3 sentences. ~72-col wrap. Skip the body only when the subject is fully self-explanatory.
- **Name the files/sections** in the body when the commit touches multiple. Reviewers shouldn't have to diff to know whether `runbook.md` or `setup.md` got the update.
- **Reference issue / PR / Decision-log entry** when applicable: `Refs #N`, `Closes #N`, `Implements D-NNN`. Makes the audit trail traversable.
- **No fillers.** If review feedback prompted the commit, name it: `Codex audit fix #3 — propagate D-005 to ops docs` beats `Address review`.
- **Version suffix is required** on the subject: ends with `v<X.Y.Z>` matching the bumped `VERSION`.

**The check:** read your subject + body aloud, no diff in front of you. Can you describe what changed and why? If no, it isn't clear enough.

### Template

```sh
git add path/to/file.py docs/spec.md CHANGELOG.md VERSION
git commit -m "$(cat <<'MSG'
<type>: <concrete result> v<X.Y.Z>

<1–3 sentences explaining the WHY: the constraint, decision, or context.
Name the affected files or sections if the commit spans more than one.
Reference Refs #N / Closes #N / Implements D-NNN if applicable.>

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
MSG
)"
git push origin <branch>
```

If a push is rejected (rebase needed, etc.), surface it loudly — never `--force` on shared branches without explicit user authorization.

---

## Pull requests

**User-triggered only.** The 5-step sequence does NOT auto-open a PR. PR opens when the user `gogogo!`s a PR-open proposal Claude surfaced — typically after the branch has accumulated many commits across many `gogogo!`s. The bare word "PR" without `gogogo!` does NOT authorize, and Claude surfacing a proposal does NOT authorize either — both halves must be present.

Generate the title + body from the actual commit log. Group commits by area; call out reverts.

```sh
gh pr create --base main --head <branch> --title "<concise title under 70 chars>" --body "$(cat <<'BODY'
## Summary
<2–4 bullets — what landed and why. Reference version range if many bumps.>

### <Area 1>
- <Commit description> (vX.Y.Z)

### Performance / reverts (if any)
- vX.Y.Z added <thing> → reverted vX.Y.Z+1 (reason)

## Test plan
- [ ] <concrete check 1>
BODY
)"
```

---

## Review

**PR review is out-of-band and reviewer-agnostic.** Claude opens the PR after a `gogogo!`-authorized PR proposal and stops there. Everything after that — picking a reviewer, invoking it, addressing findings — happens in a separate session. **The project ships no Claude-side reviewer wiring:** no skill, no Makefile target, no review-specific proposal flow. The rubric and output contract in `docs/pr_review_instructions.md` apply to whichever reviewer you point at the PR (Codex CLI, `/ultrareview`, another LLM, manual human). **Independence beats deepening:** a different model family with fresh context catches what the original missed. Reviewers run **serially**, never in parallel; one per PR.

### The workflow after a PR is opened

1. Open whichever reviewer you prefer in a separate terminal or session.
2. Point it at `docs/pr_review_instructions.md` (the rubric) and the open PR.
3. The reviewer walks `main..HEAD`, posts per-commit comments via `gh` (or its native PR-comment integration) per the output contract. If it's interactive (Codex CLI, manual review), you approve each shell call.
4. Return to Claude. Address feedback with more `gogogo!`-authorized commits on the same branch.

That's it. No prereq checking from Claude. No "remind me of the command." No matrix to navigate. The user picks a reviewer and runs it — Claude's job ended at the PR open.

### Output contract (universal)

The deliverable is GitHub comments via `gh api` (or the reviewer's native PR-comment integration), **one per commit on the branch — including commits with no findings**. Clean commits get an explicit "no findings on `<sha>` — `<subject>`" comment so silence isn't mistaken for omission. Plus one overall summary review rolled up by severity (Block / Strong / Nit). Never a local file, never a chat-only summary, never PR-description edits. Full rules: "PR review heuristics" below and `docs/pr_review_instructions.md`.

---

## Address review feedback

Each round of fixes follows the full `gogogo!` workflow. New commits go on the same branch and push to origin. The PR updates automatically.

---

## Merge

Only after the user `gogogo!`s a merge proposal Claude surfaced. Never implicit. The bare word "merge" without `gogogo!` does NOT authorize, and a proposal without `gogogo!` doesn't either.

With branch protection on (set up per [`BOOTSTRAP.md` → "Branch protection on `main`"](BOOTSTRAP.md#branch-protection-on-main)), the canonical merge path is `gh pr merge --rebase --delete-branch` — server-side rebase produces linear history; commits land on `main` with new SHAs. Direct `git push origin main` is blocked.

```sh
gh pr merge <PR#> --rebase --delete-branch
git fetch origin
git checkout main
git pull --ff-only origin main
git fetch --prune
```

If `--rebase` refuses (because main advanced and the branch needs rebasing first):

```sh
git checkout <branch>
git rebase origin/main
git push --force-with-lease origin <branch>   # only on feature branch, never on main
```

Then retry the merge.

---

## Cleanup

`gh pr merge --delete-branch` deletes the remote branch. Locally:

```sh
git branch -d <branch>      # safe -d, refuses if not merged
```

Use `-d` (safe), not `-D` (force).

---

## Deploy timing

Deploy runs on every commit to `main` (i.e., immediately after the rebase-merge lands). Topic-branch commits do not deploy. If the project has separate dev/stage/live environments, document the alternative timing in the project's `CONTRIBUTING.md`.

---

## After a violation

1. Apologize directly. No "but it was correct" defenses.
2. Offer to revert (`git revert <sha>` + redeploy + push). User may want the work dropped entirely even if functionally correct.
3. Do NOT propose follow-up code work in the same turn. Reverting OR keeping is the user's call alone.
4. Save any new failure-mode phrasing to the project's auto-memory so future sessions see it.

---

## Phase frequency

| Phase | Frequency |
|---|---|
| Branch creation | Once per branch (when starting a new chunk of work) |
| Commits + push | Many times per branch — once per `gogogo!` |
| Open PR | Once per branch, on user trigger ("PR" / "ready") |
| Review | Once per branch, between PR open and merge |
| Address feedback | As needed, more commits on the same branch |
| Merge | Once per branch, on user "merge" |
| Cleanup | Bundled with Merge on success |

---

## Conventions

### Environment variables (`.env.example` format)

<!-- C4:env-metadata-contract:start -->
**`.env.example` env-metadata contract (per B-020):** Each var's metadata is declared via `@directive` comments — `@description` · `@required` · `@optional` · `@default` · `@validator` · `@sensitive`. Both `bootstrap.sh` and `check-env.sh` read the same shared parser (`templates/scripts/_env-schema-parse.sh`); the directives are the contract, not the prose. Free-text comments without `@` are shown in bootstrap prompts but not parsed as metadata. Default-if-neither-given is `@required`. Full vocabulary + parsing rules in B-020.
<!-- C4:env-metadata-contract:end -->

Example:

```sh
# === Section ===

# @description: Brief one-line description used in bootstrap prompts.
# @required
# Where to find it: <source — e.g. "service admin console → API keys">
# How to generate: <command — e.g. "openssl rand -hex 32">
VAR_NAME=

# @description: Set when <condition>; service falls back to a default if unset.
# @optional
# @validator: ^[a-z0-9-]+$
OPTIONAL_VAR=
```

### Sensitive value handling

Variables matching `TOKEN | SECRET | KEY | DSN | PASSWORD` are treated as sensitive by `bootstrap.sh`. When redisplayed they show `(set, N chars, ends …xy7z)` instead of the cleartext. Don't log sensitive values; use the masking pattern in any internal logs the bot writes.

### Naming

- **Branches:** `<type>/<kebab-case-slug>` — e.g. `feat/click-receiver`
- **Commits:** `<type>: <imperative summary> v<X.Y.Z>`
- **Files:** snake_case for Python/Ruby/Go, kebab-case for shell scripts and docs, PascalCase for class files in JS/TS/Java
- **Branch protection bypass:** never

### Comments in code

- **Default to no comments.** Identifiers carry the *what*.
- Add a comment only when the *why* is non-obvious — a hidden constraint, a workaround for a specific bug, a contract that's not visible from the function signature.
- Never comment out code "just in case." Delete it; git remembers.
- Multi-line block comments at top of files are reserved for licenses or long-running invariants. Don't write summaries.

### Document boundary

Three docs cover three audiences. Don't mix:

| Doc | Audience | Content |
|---|---|---|
| `docs/spec.md` | Implementers | What the system does + frozen behavior + decision log |
| `CONTRIBUTING.md` | Contributors / reviewers / Claude | How to author + review + ship changes |
| `CLAUDE.md` | Claude Code session bootstrap | Session conventions, sensitive context, gate header |

`docs/architecture.md` is for *implementers* describing the *implementation* (data flow, schema, components). `docs/runbook.md` is for *operators* describing day-2 actions.

---

## Recommended auto-memory seed

When Claude Code first opens a new project, ask it to write these memory entries. They establish the scaffolding that future sessions read on load.

| File | Type | Purpose |
|---|---|---|
| `MEMORY.md` | (index, no frontmatter) | One-line pointers to each memory file. Auto-loaded into every session — keep under 200 lines. |
| `project_overview.md` | project | What the project is, what it replaces, core flow, volume baseline |
| `architecture_decisions.md` | project | Stack chosen for v1, why; open architecture questions still pending |
| `existing_infra.md` | reference | Pointers to existing systems (URLs, IPs, repos) — credential-free |
| `gogogo_gate_workflow.md` | feedback | The `gogogo!` passphrase gate + 5-step workflow rules |
| `harness_quirks.md` | feedback | Operational gotchas about the Claude Code harness's permission/write rules |
| `user_preferences.md` | feedback | How to collaborate with this user — tolerance for ceremony, doc preferences, credential-rotation cadence, etc. |

Memory format (file frontmatter):

```md
---
name: Short title
description: One-line description used to decide relevance in future conversations
type: user | feedback | project | reference
---

Memory body. Lead with the rule/fact. For feedback/project entries include
**Why:** and **How to apply:** lines.
```

When in doubt about whether to save: save it. The user can always say "delete that memory."

---

## PR review heuristics

Project-agnostic rubric for reviewing PRs. **Reviewer-agnostic** — applies to whichever reviewer the user runs (Codex CLI, `/ultrareview`, another LLM, manual). Each project's `docs/pr_review_instructions.md` extends this with project-specific concerns. Review is out-of-band — see "Review" above for the workflow.

### Output contract — read this before the rubric

**The deliverable of every review is GitHub comments, posted via `gh api` (or the reviewer's native PR-comment integration), one per commit on the branch — including commits with no findings.** Applies to every reviewer regardless of model or invocation path. The rubric below tells you *what* to look for; this section pins down *where the output goes*.

1. **Per-commit coverage.** Walk every commit `main..HEAD` in order. Each gets at least one comment on the PR — inline on specific lines (`gh api -X POST repos/<owner>/<repo>/pulls/<N>/comments ...`) or a commit-level review (`.../pulls/<N>/reviews -F commit_id=<sha> ...`).
2. **Clean commits get an explicit "no findings" comment.** Format: `No findings on <sha> — <subject>. Reviewed against <relevant Block / Strong items>.` Silence is indistinguishable from "the reviewer forgot this commit"; the explicit comment closes that gap.
3. **Plus one overall summary review at the end** with findings grouped by severity (Block / Strong / Nit). Use those exact words — they map to the rubric below.
4. **Never instead of comments:** local files (don't even draft `review.md` locally), chat-only summaries (ephemeral, not auditable), Slack/email/PR-description edits (the description belongs to the author).

Interactive reviewers (Codex CLI, manual human at the keyboard) naturally satisfy this contract one comment at a time. CI-driven reviewers and slash-command reviewers must do it deliberately. **The "no findings" comment on clean commits is the part most easily skipped — and the part that breaks the audit trail when it is.**

### Block (must fix before merge)

1. **Spec violation.** Behavior frozen in `docs/spec.md` is binding. Deviations require updating the spec section in the same PR with an explicit "why" and (for substantial changes) a Decision log entry.
2. **Missing retry/persist on a money-path or external-system call.** Every external HTTP/RPC call must time out, retry per project policy, and land in a `pending_*` queue on exhaustion. No silent drops.
3. **Idempotency hole.** Webhooks, message queues, and any upstream that may redeliver must produce identical results on replay. Common gates: UNIQUE constraints, dedup keys, conditional inserts.
4. **Untrusted client input.** Receivers/handlers parse only documented params; everything else gets silently dropped. Real client IP comes from the trusted forwarded-IP header configured for the deployment, never `X-Forwarded-For` blindly when there's a CDN in between.
5. **Secrets in code, fixtures, or commit messages.** All secrets via env. No hardcoded fallbacks. No tokens in tests.
6. **Schema change without migration.** Schema changes need a migration. Down-migrations for additive changes; destructive ones need explicit approval in the PR.
7. **Missing version bump.** ANY change to tracked files needs `VERSION` bumped. PR with no bump = block.
8. **Missing CHANGELOG entry.** Each version bump needs a CHANGELOG entry. Missing = block.
9. **Bot-identity / handler partitioning hole** (when multiple bots/handlers share an event source). The handler must filter to its own events (e.g. by `creator.id == self.bot.id`). Skipping the filter is a correctness bug, not a nit.

### Strong (should fix)

- Observability gap on a failure path (no log line, no Sentry capture, no metric).
- New external call without a timeout.
- New env var not added to `.env.example` with a comment block describing its source.
- Dead code, commented-out blocks, leftover `print`/`console.log`/`dbg!`.
- Tests that mock the entire money path (full happy-path coverage with all collaborators mocked is barely a test — replace with a recorded HTTP cassette or an in-memory fake).
- Comment that restates code instead of explaining the *why*.

### Nit (mention, don't block)

- Naming, formatting, single-line refactor opportunities.
- Variable that could be `const`/`final`/`readonly`.
- Suggestion-only architectural improvements.

### Don't flag

- Missing tests for trivial glue (config loaders, plain models).
- Lack of comments where identifiers are clear — the project's coding convention is no-comments-by-default.
- Single-worker deploy / single-instance DB / single-channel design — these are intentional v1 simplifications unless contradicted by the spec.

### Cross-cutting concerns to always check

- **Time semantics:** event_time is when the event *occurred*, not when it was processed. Easy to get wrong on async retries.
- **Hashing inputs:** verify hashing is on the right field (e.g., source ID, not internal DB ID), with the right normalization (lowercase, trim).
- **Persistence vs. computation:** the URL the user actually hit is *persisted at receiver time*, not derived/reconstructed downstream.
- **Auth headers:** webhook receivers verify the secret token; mismatch = 401, never silent accept.
- **Event/update filters on webhook subscriptions:** explicitly listed in registration calls; defaults often exclude the events you need. *Example (Telegram bots):* `setWebhook`'s default `allowed_updates` omits `chat_join_request` — you must list it explicitly to receive those events.
- **Currency / value defaults on conversion-tracking integrations:** `0` for free conversions; faking value distorts upstream optimization (most ads-platform bid algorithms use the value field as a signal).
