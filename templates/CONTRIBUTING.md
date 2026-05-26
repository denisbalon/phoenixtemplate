# Contributing to <PROJECT_NAME>

Binding process document. Read once; revisit when conventions feel off.

**Canonical scope (per B-021 in `docs/spec.md`):** this file is the canonical source for the **per-project operational workflow** — exact commands, sequences, project-specific paths, deploy specifics, version markers per stack. The **core workflow rules + rationale** (the *why* behind the gate, the propose-and-confirm semantics, the on-branch 6-step structure) live canonically in `WORKFLOW.md` — this file references them rather than re-deriving them. The **session-facing AI summary** is `CLAUDE.md`. Rule statements (gate clause, proposal format, bare-gogogo prompt, allowed-without-gate list, refuse-list) are deliberately duplicated here, in `CLAUDE.md`, and in `WORKFLOW.md` — that's defensive AI-safety redundancy, not debt. Editing any duplicated rule means editing it in all three places; the C4 consistency linter (`scripts/check-rule-consistency.sh`) catches drift automatically.

## Quick rules cheat-sheet

| Situation | Action |
|---|---|
| Need to start fresh work | Step 1 of the on-branch 6-step `gogogo!` — new branch `<type>/<slug>-v<X.Y.Z>` off `main` |
| First commit on a fresh branch | Bundled with `gh pr create` (no `--draft`) in the same `gogogo!` — step 5 + step 6 |
| Made a commit | Push to origin same turn — no exceptions; never to `main` (pre-push hook blocks it) |
| Touched any tracked `.md` | Commit it AND push (machine-swap survival) |
| Address-review fixes | Standard `gogogo!` on the existing branch — skip steps 1 + 6 (branch + PR already exist) |
| User `gogogo!`s a merge proposal | Atomic over `gh pr merge <PR#> --rebase --delete-branch` → `git pull --ff-only` → deploy |
| `--rebase` refuses | Rebase the feature branch with `--force-with-lease`, retry merge |
| Anything ambiguous | Ask. Never `--force` without explicit OK. |

## Principles

- **Never commit to `main`.** Every change lives on a feature branch. `main` only receives explicit fast-forward merges via PR. Direct pushes to `main` are blocked by the local `.githooks/pre-push` hook (and by server-side branch protection where available).
- **Push after every commit.** Local-only commits are not allowed. Spec, docs, and version bumps must always be on origin.
- **One PR per branch, opened with the first commit.** PR opens in step 6 of the on-branch 6-step `gogogo!` sequence — bundled with the first commit on a fresh branch. Subsequent commits (review-feedback fixes) push to the existing branch.
- **Merge is user-triggered.** Review happens out-of-band; merge fires only on a separate merge `gogogo!`. The merge `gogogo!` is atomic over `gh pr merge --rebase --delete-branch` → `git pull --ff-only` → deploy.
- **Merge with rebase to preserve linear history.** `gh pr merge --rebase --delete-branch` is the canonical merge under branch protection.
- **Delete branches after successful merge** (bundled with `--delete-branch`).
- **Never `git checkout` / `git switch` without explicit instruction.** "Check the latest stuff" ≠ checkout.
- **Memory stays user-local.** The auto-memory dir at `~/.claude/projects/<sanitized>/memory/` is the single source.

## Phase frequency

| Phase | Frequency |
|---|---|
| §1 Set up branch | Step 1 of the on-branch 6-step `gogogo!` — once per branch |
| §2 Commits + push | Many per branch — once per `gogogo!` (step 5 of the sequence); address-review iterations stay on the same branch |
| §3 Open PR | Step 6 of the on-branch 6-step `gogogo!` — bundled with the first commit |
| §4 Review | Out-of-band, between PR open and merge |
| §5 Address feedback | As needed, more commits on the same branch (skip steps 1 + 6) |
| §6 Merge + deploy | One merge `gogogo!` — atomic over `gh pr merge` + `git pull` + deploy |
| §7 Cleanup | Bundled with §6 (`--delete-branch`) |

## TL;DR

1. Feature branch from `main` named `<type>/<slug>-v<X.Y.Z>`. Created as step 1 of the on-branch 6-step `gogogo!` sequence — not in advance.
2. **No state-mutating action unless Claude's immediately preceding message contained a concrete proposal AND the user's current message contains `gogogo!` (or `N gogogo!` for a numbered choice).** The proposal IS the contract — specific files, specific commands, specific commits. Bare `gogogo!` without a preceding proposal is invalid — Claude must ask for clarification.
3. When the user `gogogo!`s a fresh-work feature proposal, the on-branch 6-step atomic sequence is: **branch → spec → bump+CHANGELOG → code → commit+push (to feature branch) → open PR**. Push after every commit, to the feature branch — never to `main`. The proposal enumerates each step upfront so one `gogogo!` authorizes the whole sequence.
4. Every change bumps `VERSION`. ANY change. Address-review iterations bump too (each round = one VERSION + one CHANGELOG entry on the same branch).
5. PR opens **ready** (not draft) in step 6 of the on-branch 6-step sequence — bundled with the first commit. Body uses `## Summary` + `## Test plan`.
6. Review happens **out-of-band** in a separate session — user runs any reviewer (Codex, `/ultrareview`, another LLM, manual) against `docs/pr_review_instructions.md` and the open PR. Claude does not dispatch reviewers from the authoring session; if Claude is the reviewer in the separate review session, it prepares the exact GitHub comments/review and offers to post them as a separate gated action. Address feedback with more `gogogo!`-authorized commits on the same branch (skipping steps 1 + 6).
7. When the user `gogogo!`s a merge proposal, the merge `gogogo!` is **atomic over three sub-steps**: `gh pr merge --rebase --delete-branch` → `git pull --ff-only origin main` → deploy. The deploy step must NOT be surfaced as a separate `gogogo!` after the merge.
8. **Deploy is bundled with merge** — fires once per merged PR as the third sub-step of the merge `gogogo!`. Topic-branch commits do not deploy. For meta-repos that ship docs only, the deploy sub-step is documented-as-no-op (still named in the merge proposal).

---

## 1. Set up the feature branch

```sh
git fetch origin
git checkout main
git pull --ff-only origin main
git checkout -b <type>/<slug>-v<X.Y.Z>
```

Branch naming: kebab-case `<type>/<slug>-v<X.Y.Z>` where `<type>` is one of `feat`/`fix`/`chore`/`docs`/`refactor`/`test`/`perf`. The `-v<X.Y.Z>` suffix names the version this branch first ships. The branch is created locally in step 1 and pushed in step 5 with the first commit (no need for an upfront empty `git push -u`); the PR opens in step 6 of the same `gogogo!` sequence. Direct pushes to `main` are blocked by `.githooks/pre-push` (activated via `make install-hooks`).

## 2. Commits

### Mechanics

- Subject: `<type>: <imperative summary> v<X.Y.Z>` — types: `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `perf`. ≤72 chars.
- Stage **specific files**, not `git add -A` / `.`
- HEREDOC for messages.
- Trailers: `Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>` when Claude assisted.
- No `--no-verify`. No `--amend` unless explicit.
- One concern per commit.

### Commit message quality (be super clear)

A reviewer reading the commit log six months from now should understand **what changed and why without opening the diff**.

- **Subject line** is the *result* in active voice with a concrete object.
  - ❌ Bad: `fix bug`, `update docs`, `various changes`, `WIP`, `tweaks`, `address feedback`, `bump version`.
  - ✅ Good: `fix <module> <bug> v<X.Y.Z>`, `update spec <section> with <change> v<X.Y.Z>`.
- **Body** explains the *why* — not what (diff shows that), but the constraint or decision. 1–3 sentences. Skip only when the subject is fully self-explanatory.
- **Name the files/sections** when a commit touches multiple.
- **Reference issue / PR / Decision-log entry** when applicable: `Refs #N`, `Closes #N`, `Implements D-NNN`.
- **No fillers.** If review feedback prompted the commit, name it specifically.
- **Version suffix is required** on the subject: ends with `v<X.Y.Z>`.

**The check:** read subject + body aloud without the diff. Can you describe what changed and why? If no, it isn't clear enough.

### Template

```sh
git add path/to/file.ext docs/spec.md CHANGELOG.md VERSION
git commit -m "$(cat <<'MSG'
<type>: <concrete result> v<X.Y.Z>

<1–3 sentences on the WHY. Name affected files/sections when multiple.
Reference Refs #N / Closes #N / Implements D-NNN if applicable.>

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
MSG
)"
git push origin <branch>
```

## 3. Open the pull request

**Bundled with the first commit** — step 6 of the on-branch 6-step `gogogo!` sequence. PR opens **ready** (no `--draft` flag). Generate title + body from the actual commit log.

```sh
gh pr create --base main --head <branch> --title "<concise title under 70 chars>" --body "$(cat <<'BODY'
## Summary
<2–4 bullets — what landed and why.>

### <Area 1>
- <Commit description> (vX.Y.Z)

## Test plan
- [ ] <concrete check 1>
BODY
)"
```

## 4. Review

**PR review is out-of-band.** Claude opens the PR after a `gogogo!`-authorized PR-open proposal; everything after that happens in a separate reviewer session with whatever reviewer the user picks. The project ships no reviewer-specific wiring — no skill, no Makefile target, no default reviewer, no auto-dispatch. The rubric and output contract in [`docs/pr_review_instructions.md`](docs/pr_review_instructions.md) are **reviewer-agnostic**: same rubric whether the reviewer is Codex CLI, `/ultrareview`, another LLM, or a human reading the diff.

Workflow after the PR is opened:

1. Open whichever reviewer you prefer in a separate terminal/session.
2. Point it at `docs/pr_review_instructions.md` and the open PR.
3. Reviewer prepares the per-commit comments + overall summary review per the output contract and posts them via `gh` (or its native PR-comment integration). If the reviewer is interactive, it should first show the exact prepared GitHub review package in-session and then offer a separate posting action. You approve each shell call if the reviewer asks (interactive reviewers like Codex CLI do; CI-driven ones don't).
4. Return to Claude. Address feedback with more `gogogo!`-authorized commits on the same branch.

**Independence beats deepening.** A reviewer with fresh context and ideally a different model family catches what the original missed. Pick reviewers accordingly; run them serially, not in parallel.

### Output contract (reviewer-agnostic)

Whichever reviewer runs, the deliverable is GitHub comments — posted via `gh api` (or the reviewer's native PR-comment integration) — **one per commit on the branch, including commits with no findings**:

- **In interactive reviewer sessions, first prepare the exact GitHub review package** in final postable wording, then offer a separate posting action.
- **Walk every commit** `main..HEAD` in order. Each gets at least one comment on the PR (inline on specific lines, or a commit-level review).
- **Clean commits get an explicit "no findings on `<sha>` — `<subject>`" comment.** Silence is indistinguishable from "the reviewer forgot this commit." The explicit comment closes that gap and makes the audit trail complete.
- **Plus one overall summary review** at the end with findings rolled up by severity (Block / Strong / Nit per `docs/pr_review_instructions.md`).
- **Never** a local file (`review.md`, `findings.txt`, etc.), a chat-only summary, or PR-description edits in place of comments. The PR is the audit trail; comments are the unit.

## 5. Address review feedback

Each round of fixes follows the full `gogogo!` workflow. New commits go on the same branch.

## 6. Merge + deploy

Only after the user `gogogo!`s a merge proposal. Never implicit. **The merge `gogogo!` is atomic over three sub-steps** — `gh pr merge --rebase --delete-branch` → `git pull --ff-only origin main` → deploy. The deploy step must NOT be surfaced as a separate `gogogo!` after the merge; one merge `gogogo!` covers all three.

```sh
gh pr merge <PR#> --rebase --delete-branch
git fetch origin
git checkout main
git pull --ff-only origin main
git fetch --prune
make deploy   # project's deploy command; no-op for pre-MVP or docs-only meta-repos
```

If `--rebase` refuses (because main advanced):

```sh
git checkout <branch>
git rebase origin/main
git push --force-with-lease origin <branch>   # only on feature branch, never on main
```

Then retry the merge.

## 7. Cleanup

`--delete-branch` deletes the remote branch. Locally:

```sh
git branch -d <branch>
```

## 8. Verify

```sh
git log --oneline -5
git branch -a
gh pr view <PR#> --json state    # MERGED
```

---

# `gogogo!` passphrase — hard gate + propose-and-confirm convention

## The hard gate

<!-- C4:gate-clause:start -->
**Do NOT take any state-mutating action unless: (a) Claude's immediately preceding message contained a concrete proposal (specific files/commands/commits, not vague phrasing) ending with one of the canonical invitation lines, classifying each numbered option as `[change]` (state-mutating: tracked-file Edit/Write/NotebookEdit, git commit/push, gh pr create/merge/comment, deploy, external POST/PUT/DELETE) or `[info]` (read-only / research / discussion / navigation / memory writes); AND (b) the user's CURRENT message contains the literal substring `gogogo!`, optionally preceded by one or more whitespace-separated digits selecting `[change]` options — single `N gogogo!` for one `[change]`, multi-digit `N1 N2 ... gogogo!` for multiple `[change]` items in a "Choose any (in order):" list (multi-select against "Choose one:" remains invalid). Picking an `[info]` option needs only bare `N` — no `gogogo!`; state-mutating actions never happen in `[info]` paths. Mid-execution deviation requires a new proposal, including if an option classified `[info]` turns out to need state mutation. A direct natural-language instruction to perform a `[change]` action — e.g. "create the PR", "commit this", "push it", "delete X" — does NOT by itself satisfy (a) or (b); it is a request to be restated as a concrete proposal and confirmed with `gogogo!`. The literal token is the only authorization channel for state mutation; confidence that the instruction was understood never substitutes for it (B-040).**
<!-- C4:gate-clause:end -->

`gogogo!` confirms a concrete proposal Claude surfaced. The proposal IS the contract — what file gets edited, what commit gets pushed, what command runs. The action Claude executes is exactly what the proposal described. Multi-select (`N1 N2 ... gogogo!`) batches known proposals from a "Choose any (in order):" list; each item was already surfaced and inspected, so safety is preserved.

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

Concrete means specific files, specific commands, specific commits — not "commit the changes." **Every option must represent a real action** — code change, information lookup, navigation, or continued discussion. Null-action options ("stop here," "wait," "pick up later," "wrap up," "do nothing") are forbidden; the user can simply not respond. Null options dilute the gate signal and add visual clutter without surfacing real choice. An option to continue discussion or surface more information IS a real action and stays. For multi-step actions, enumerate every step in the proposal — specifically: **the on-branch feature workflow is 6 steps: branch → spec → bump+CHANGELOG → code → commit+push (to feature branch) → open PR**, all six must appear as explicit items in the proposal when starting fresh work. One `gogogo!` authorizes the entire on-branch sequence end-to-end. **Direct pushes to `main` are forbidden** (rule + local `.githooks/pre-push` hook block them; server-side branch protection is deferred — requires GitHub Pro on private repos); every change goes via a `<type>/<slug>-v<X.Y.Z>` branch. PR review is **out-of-band** — after the PR is open, the user points their chosen reviewer at it via `docs/pr_review_instructions.md` in a separate session. When Claude itself is that reviewer, it first prepares the exact GitHub comments/review it would post, shows that package in chat, and offers a separate gated `[change]` action to publish it; it does not post review comments automatically. **Merge is a separate proposal + `gogogo!`**, authorized only after review has cleared. The merge `gogogo!` is atomic over three sub-steps: `gh pr merge --rebase --delete-branch <PR#>` → `git checkout main && git pull --ff-only origin main` → deploy; the deploy step must NOT be surfaced as a separate `gogogo!` after the merge. Address-review iterations (more commits on the same branch after findings) follow the standard `gogogo!` flow but skip steps 1 (branch already exists) and 6 (PR already open). The user's authorization signal applies exactly to the proposed plan; mid-execution deviation requires a new proposal. If an option classified `[info]` turns out to need state mutation, STOP and re-propose with the option re-classified as `[change]`. The `✏️`/`👀` markers appear ONLY at the start of numbered options — never on status lines, section headers, the invitation line, single-suggestion proposals, or running prose that references a type. Classifying each option is Claude's job; when in doubt, default to `✏️ [change]` (the conservative, gated side). If the user picks a bare `N` for a `✏️ [change]` option, re-prompt ("Option N is [change] — type `N gogogo!` to authorize") — never let a bare digit execute a state change.
<!-- C4:proposal-format:end -->

<!-- C4:bare-gogogo:start -->
**Bare `gogogo!` with no preceding proposal** → reply *"I haven't proposed anything concrete yet. Describe what you'd like and I'll surface options."* and STOP.
<!-- C4:bare-gogogo:end -->

Self-check before any state-mutating tool call:

1. Did MY IMMEDIATELY-PRECEDING assistant message contain a concrete proposal (specific files/commands/commits) ending with one of the canonical invitation lines? Were the numbered options classified `[change]` or `[info]`?
2. Is the user picking a `[change]` option? If so: does THE USER'S CURRENT message contain the literal substring `gogogo!`?
3. Is the user picking an `[info]` option? If so: bare `N` is sufficient — no `gogogo!` required.
4. If multi-select was used: was my proposal a "Choose any (in order):" form (valid; one `gogogo!` covers all `[change]` items) or "Choose one:" form (multi-select invalid → re-prompt)?
5. Am I about to do exactly what the proposal described, or has something deviated — including: an option I classified `[info]` actually needs state mutation?

- No prior proposal → propose now. Don't execute.
- User picked a `[change]` option without `gogogo!` → re-prompt: "Option N is `[change]` — type `N gogogo!` to authorize."
- Bare `gogogo!` without prior proposal → see the canonical prompt above.
- `N` against an `[info]` option → proceed (no `gogogo!` needed).
- `N gogogo!` against a `[change]` option → execute option N exactly as described.
- `N1 N2 ... gogogo!` against a "Choose any (in order):" list → execute `[change]` items as authorized + run `[info]` items in the same message; each one exactly as described.
- `N1 N2 ... gogogo!` against a "Choose one:" list → invalid; re-prompt.
- Mid-execution deviation (including `[info]` → `[change]` re-classification) → STOP and re-propose.

The check is the FIRST step of every action response. **Auto mode does NOT override this gate.**

## Phrases that LOOK like authorization but aren't

Bare imperatives *without* `gogogo!`:

`now lets X` · `let's X` · `can you X` · `please X` · `do X` · `go` · `proceed` · `ship it` · `yes` · `yeah` · `ok do it` · `sure` · `we should X` · detailed feature descriptions in imperative mood · user pasting an exact diff with "just do the fix"

All → respond with a concrete proposal + invitation line → STOP. The user must then `gogogo!` (or `N gogogo!`) the proposal.

## Phrases that mean DEFINITELY NOT action

`understood?` · `wdyt?` · `make sense?` · `ok?` · any closing confirmation question.

## Allowed without `gogogo!`

Reading files · grep · read-only git · web search · planning text · proposing (the propose-then-wait pattern itself never requires `gogogo!`) · clarifying questions · writes to local-only memory/settings (`~/.claude/projects/.../memory/`, `.claude/settings.local.json`).

`.claude/settings.json` (committed) IS gated.

## Rationalizations to refuse

**Canonical list lives in [`WORKFLOW.md` → "Rationalizations to refuse"](WORKFLOW.md#rationalizations-to-refuse).** This file does not duplicate the table — the list evolves per observed failure mode (rows added as new rationalizations surface during sessions), making byte-exact cross-file duplication high-churn for low marginal AI-safety value. The C4-anchored regions in this file (gate-clause / proposal-format / bare-gogogo / env-metadata-contract) cover the load-bearing rule statements; the refuse-list is a teaching aid that lives canonically in WORKFLOW.md. `templates/CLAUDE.md` similarly doesn't carry the table.

## Mandatory on-branch 6-step sequence on a `gogogo!`-authorized feature proposal

Atomic. Runs when the user `gogogo!`s a proposal Claude surfaced for a state-mutating feature change (per B-026 / B-028 / B-042; see also [WORKFLOW.md → "The on-branch 6-step atomic sequence"](WORKFLOW.md#the-on-branch-6-step-atomic-sequence-on-gogogo)). Address-review iterations on an existing branch skip steps 1 and 6 and keep steps 2–5.

1. **Create the feature branch** — `git checkout main && git pull --ff-only origin main && git checkout -b <type>/<slug>-v<X.Y.Z>`. Direct pushes to `main` are blocked by `.githooks/pre-push` (activated via `make install-hooks`).
2. **Update the spec** — `docs/spec.md` reflects the change BEFORE any code is written. For architectural decisions, also add a Decision log entry in `docs/spec.md` (`D-NNN (YYYY-MM-DD) <title>` with Chose / Considered / Why / Implemented in).
3. **Bump versions + CHANGELOG** — bump `VERSION` (and language-specific markers) and add a `CHANGELOG.md` entry under the new version. Markers for this project: <LIST_PROJECT_VERSION_MARKERS — e.g. `VERSION` at root, `pyproject.toml` `version`, `__version__` in `src/.../__init__.py`>.
4. **Write the code.**
5. **Commit + push to the feature branch** — single commit per concern, subject ends with `v<X.Y.Z>`. Push to origin in the same turn (to the feature branch — never to `main`).
6. **Open the PR ready** — `gh pr create --base main --head <branch> --title "..." --body "..."`. **No `--draft` flag.** Claude stops here.

**The sequence ENDS at step 6.** Do not auto-merge. The next user message is either a fix `gogogo!` (address-review iteration — skips steps 1 + 6) or a separate merge `gogogo!` (atomic over `gh pr merge --rebase --delete-branch` → `git pull --ff-only` → deploy).

If a step fails, surface — do not fake-complete.

## Version-bump rule

ANY change → bump. Never overwrite a version with different content under it.

## Deploy timing

**Deploy is bundled with merge** — fires once per merged PR as the third sub-step of the merge `gogogo!` (atomic over `gh pr merge --rebase --delete-branch` → `git pull --ff-only` → deploy). Topic-branch commits do not deploy. <PROJECT-SPECIFIC: e.g. "Single live environment; no separate dev/stage during this phase." Add project-specific timing if dev/stage/live exist.>

## After a violation

1. Apologize directly.
2. Offer to revert (`git revert <sha>` + redeploy + push).
3. Do NOT propose follow-up code work in the same turn.
4. Save the new failure-mode phrasing to project auto-memory.

## Env-metadata contract

<!-- C4:env-metadata-contract:start -->
**`.env.example` env-metadata contract (per B-020):** Each var's metadata is declared via `@directive` comments — `@description` · `@required` · `@optional` · `@default` · `@validator` · `@sensitive`. Both `bootstrap.sh` and `check-env.sh` read the same shared parser (`templates/scripts/_env-schema-parse.sh`); the directives are the contract, not the prose. Free-text comments without `@` are shown in bootstrap prompts but not parsed as metadata. Default-if-neither-given is `@required`. Full vocabulary + parsing rules in B-020.
<!-- C4:env-metadata-contract:end -->
