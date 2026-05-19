# Contributing to <PROJECT_NAME>

Binding process document. Read once; revisit when conventions feel off.

**Canonical scope (per B-021 in `docs/spec.md`):** this file is the canonical source for the **per-project operational workflow** — exact commands, sequences, project-specific paths, deploy specifics, version markers per stack. The **core workflow rules + rationale** (the *why* behind the gate, the propose-and-confirm semantics, the 5-step structure) live canonically in `PROJECT_STARTER.md §2` — this file references them rather than re-deriving them. The **session-facing AI summary** is `CLAUDE.md`. Rule statements (gate clause, proposal format, bare-gogogo prompt, allowed-without-gate list, refuse-list) are deliberately duplicated here, in `CLAUDE.md`, and in `PROJECT_STARTER.md §2` — that's defensive AI-safety redundancy, not debt. Editing any duplicated rule means editing it in all three places; the C4 consistency linter (`scripts/check-rule-consistency.sh`) catches drift automatically.

## Quick rules cheat-sheet

| Situation | Action |
|---|---|
| Need to start work | New branch off `main`, push branch immediately |
| Made a commit | Push to origin same turn — no exceptions |
| Touched any tracked `.md` | Commit it AND push (machine-swap survival) |
| User `gogogo!`s a PR-open proposal | `gh pr create` with HEREDOC body |
| User `gogogo!`s a merge proposal | `gh pr merge <PR#> --rebase --delete-branch` |
| `--rebase` refuses | Rebase the feature branch with `--force-with-lease`, retry merge |
| Anything ambiguous | Ask. Never `--force` without explicit OK. |

## Principles

- **Never commit to `main`.** Every change lives on a feature branch. `main` only receives explicit fast-forward merges via PR.
- **Push after every commit.** Local-only commits are not allowed. Spec, docs, and version bumps must always be on origin.
- **Topic branches accumulate many commits.** A single branch normally hosts dozens of `gogogo!`s before a PR is opened. Don't open a new branch per `gogogo!`. Don't open a PR after each commit.
- **PR is user-triggered.** The `gogogo!` 5-step sequence ENDS at step 5 (deploy). It does NOT auto-open a PR.
- **Merge with rebase to preserve linear history.** `gh pr merge --rebase --delete-branch` is the canonical merge under branch protection.
- **Delete branches after successful merge** (bundled with `--delete-branch`).
- **Never `git checkout` / `git switch` without explicit instruction.** "Check the latest stuff" ≠ checkout.
- **Memory stays user-local.** The auto-memory dir at `~/.claude/projects/<sanitized>/memory/` is the single source.

## Phase frequency

| Phase | Frequency |
|---|---|
| §1 Set up branch | Once per branch |
| §2 Commits + push | Many per branch — once per `gogogo!` |
| §3 Open PR | Once per branch, on user trigger |
| §4 Review | Once per branch, between PR open and merge |
| §5 Address feedback | As needed, more commits on the same branch |
| §6 Merge | Once per branch, on user "merge" |
| §7 Cleanup | Bundled with §6 on success |

## TL;DR

1. Topic branch from `main`. Push branch immediately on `git checkout -b`. Branch persists across many `gogogo!`s.
2. **No state-mutating action unless Claude's immediately preceding message contained a concrete proposal AND the user's current message contains `gogogo!` (or `N gogogo!` for a numbered choice).** The proposal IS the contract — specific files, specific commands, specific commits. Bare `gogogo!` without a preceding proposal is invalid — Claude must ask for clarification.
3. When the user `gogogo!`s a 5-step feature proposal, the atomic sequence is: **spec → bump+CHANGELOG → code → commit → deploy**. Push after every commit. The proposal enumerates each step upfront so one `gogogo!` authorizes the whole sequence.
4. Every change bumps `VERSION`. ANY change.
5. PR opens only when the user `gogogo!`s a PR-open proposal. Body uses `## Summary` + `## Test plan`.
6. Review happens **out-of-band** in a separate session — user runs any reviewer (Codex, `/ultrareview`, another LLM, manual) against `docs/pr_review_instructions.md` and the open PR. Claude does not dispatch reviewers. Address feedback with more `gogogo!`-authorized commits on the same branch.
7. When the user `gogogo!`s a merge proposal: `gh pr merge --rebase --delete-branch`.
8. Deploy on every commit to `main` (or as part of a deploy proposal the user explicitly `gogogo!`s).

---

## 1. Set up the feature branch

```sh
git fetch origin
git checkout main
git pull --ff-only origin main
git checkout -b <type>/<slug>
git push -u origin <type>/<slug>
```

Branch naming: kebab-case prefix per type — `feat/`, `fix/`, `chore/`, `docs/`, `refactor/`, `test/`, `perf/`. The branch is pushed to origin immediately on creation; further commits are pushed individually.

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

**User-triggered only.** Generate title + body from the actual commit log.

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

**PR review is out-of-band.** Claude opens the PR after a `gogogo!`-authorized PR-open proposal; everything after that happens in a separate session with whatever reviewer the user picks. The project ships no reviewer-specific wiring — no skill, no Makefile target, no review proposal flow. The rubric and output contract in [`docs/pr_review_instructions.md`](docs/pr_review_instructions.md) are **reviewer-agnostic**: same rubric whether the reviewer is Codex CLI, `/ultrareview`, another LLM, or a human reading the diff.

Workflow after the PR is opened:

1. Open whichever reviewer you prefer in a separate terminal/session.
2. Point it at `docs/pr_review_instructions.md` and the open PR.
3. Reviewer posts per-commit comments via `gh` (or its native PR-comment integration). You approve each shell call if the reviewer asks (interactive reviewers like Codex CLI do; CI-driven ones don't).
4. Return to Claude. Address feedback with more `gogogo!`-authorized commits on the same branch.

**Independence beats deepening.** A reviewer with fresh context and ideally a different model family catches what the original missed. Pick reviewers accordingly; run them serially, not in parallel.

### Output contract (reviewer-agnostic)

Whichever reviewer runs, the deliverable is GitHub comments — posted via `gh api` (or the reviewer's native PR-comment integration) — **one per commit on the branch, including commits with no findings**:

- **Walk every commit** `main..HEAD` in order. Each gets at least one comment on the PR (inline on specific lines, or a commit-level review).
- **Clean commits get an explicit "no findings on `<sha>` — `<subject>`" comment.** Silence is indistinguishable from "the reviewer forgot this commit." The explicit comment closes that gap and makes the audit trail complete.
- **Plus one overall summary review** at the end with findings rolled up by severity (Block / Strong / Nit per `docs/pr_review_instructions.md`).
- **Never** a local file (`review.md`, `findings.txt`, etc.), a chat-only summary, or PR-description edits in place of comments. The PR is the audit trail; comments are the unit.

## 5. Address review feedback

Each round of fixes follows the full `gogogo!` workflow. New commits go on the same branch.

## 6. Merge

Only after the user explicitly says "merge". Never implicit.

```sh
gh pr merge <PR#> --rebase --delete-branch
git fetch origin
git checkout main
git pull --ff-only origin main
git fetch --prune
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
**Do NOT take any state-mutating action unless: (a) Claude's immediately preceding message contained a concrete proposal (specific files/commands/commits, not vague phrasing) ending with one of the canonical invitation lines, AND (b) the user's CURRENT message contains the literal substring `gogogo!`, optionally preceded by one or more whitespace-separated digits — single `N gogogo!` selects option N from a numbered choice; multi-digit `N1 N2 ... gogogo!` authorizes multiple options in the typed order (only valid against a "Choose any (in order):" proposal, never a "Choose one:" proposal).**
<!-- C4:gate-clause:end -->

`gogogo!` confirms a concrete proposal Claude surfaced. The proposal IS the contract — what file gets edited, what commit gets pushed, what command runs. The action Claude executes is exactly what the proposal described. Multi-select (`N1 N2 ... gogogo!`) batches known proposals from a "Choose any (in order):" list; each item was already surfaced and inspected, so safety is preserved.

### Proposal format

<!-- C4:proposal-format:start -->
**Proposal format.** Every assistant message ends with a concrete proposal. There are three invitation forms:

- **Single suggestion** — a bold "Proposed: <action>" header, a concrete plan (specific files / commands / commits), and a final line inviting `gogogo!` to proceed.
- **Choose one** — a bold "Choose one:" header, numbered options that are mutually exclusive (alternatives), and a final line inviting `N gogogo!` to pick option N. Multi-digit `N M gogogo!` against this form is invalid → re-prompt.
- **Choose any (in order)** — a bold "Choose any (in order):" header, numbered options that can run independently or as a batch, and a final line inviting `N gogogo!` for one option or `N1 N2 ... gogogo!` to authorize multiple in the typed order. Skipping is fine (`1 2 4 5 gogogo!` skips option 3).

Concrete means specific files, specific commands, specific commits — not "commit the changes." For multi-step actions (5-step feature work), enumerate every step in the proposal. The user's `gogogo!` (or `N gogogo!` / multi-digit) authorizes exactly the proposed plan; mid-execution deviation requires a new proposal. The "every assistant message ends with a proposal" rule applies even for clarification turns — the trailing proposal can be "continue with the next queued item, or describe a different direction"; never leave the user without something to `gogogo!`.
<!-- C4:proposal-format:end -->

<!-- C4:bare-gogogo:start -->
**Bare `gogogo!` with no preceding proposal** → reply *"I haven't proposed anything concrete yet. Describe what you'd like and I'll surface options."* and STOP.
<!-- C4:bare-gogogo:end -->

Self-check before any state-mutating tool call:

1. Did MY IMMEDIATELY-PRECEDING assistant message contain a concrete proposal (specific files/commands/commits) ending with one of the canonical invitation lines?
2. Does THE USER'S CURRENT message contain the literal substring `gogogo!`?
3. If a numbered choice was offered: did the user select with `N gogogo!` (single pick) or `N1 N2 ... gogogo!` (multi-select)? Does each N match my numbered list?
4. If multi-select was used: was my proposal a "Choose any (in order):" form (multi-select valid) or "Choose one:" form (multi-select invalid → re-prompt, don't execute)?
5. Am I about to do exactly what the proposal described, or has something deviated?

- No prior proposal → propose now. Don't execute.
- Prior proposal but conversation drifted (questions, clarifications, no re-proposal in my last message) → re-propose before acting.
- No `gogogo!` in current message → respond with a concrete proposal + invitation line. STOP.
- Bare `gogogo!` without prior proposal → see the canonical prompt above.
- `N gogogo!` selecting from a list I offered → execute option N exactly as described.
- `N1 N2 ... gogogo!` against a "Choose any (in order):" list → execute the listed options in the typed order, each one exactly as described in the proposal.
- `N1 N2 ... gogogo!` against a "Choose one:" list → invalid; re-prompt and don't execute.
- Mid-execution deviation from the proposal → STOP and re-propose.

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

| Rationalization | Why it's wrong |
|---|---|
| "Intent is unambiguous, just ship it" | Gate is `gogogo!` after a concrete proposal, not intent. |
| "User said `gogogo!` recently, this scope counts" | Each `gogogo!` authorizes one specific proposal. New action = new proposal. |
| "Auto mode says minimize interruptions" | Auto mode does NOT override this gate. |
| "Direct imperative + clarity = authorization" | Imperative grammar ≠ `gogogo!`. |
| "User said yes" | `yes` is not `gogogo!`. |
| "It's just a docs/SPEC tweak" | Tracked-file edits need a proposal + `gogogo!`. |
| "User pasted the diff verbatim" | WHAT ≠ WHEN. |
| "User is rushing" | Schedule is not my problem; the gate is. |
| "Bare `gogogo!`, I'll default to whatever feels right" | Bare `gogogo!` without a prior proposal is invalid — ask for clarification. |
| "Reality deviated from my proposal mid-action; close enough" | STOP and re-propose. The original `gogogo!` only authorized the original plan. |
| "I proposed concretely several messages ago, the user is following up now" | The proposal must be in the IMMEDIATELY-PRECEDING message. Conversation drift → re-propose. |

## Mandatory 5-step sequence on `<feature-verb> gogogo!`

Atomic.

1. **Update the spec** — `docs/spec.md` reflects the change BEFORE any code is written. For architectural decisions, also add a Decision log entry in `docs/spec.md` (`D-NNN (YYYY-MM-DD) <title>` with Chose / Considered / Why / Implemented in).
2. **Bump versions + CHANGELOG** — bump `VERSION` (and language-specific markers) and add a `CHANGELOG.md` entry under the new version. Markers for this project: <LIST_PROJECT_VERSION_MARKERS — e.g. `VERSION` at root, `pyproject.toml` `version`, `__version__` in `src/.../__init__.py`>.
3. **Write the code.**
4. **Commit + push** — single commit per concern, subject ends with `v<X.Y.Z>`. Push in same turn.
5. **Deploy** — <DEPLOY_CMD>. <PRE_MVP_CAVEAT_OR_OMIT>.

**The sequence ENDS at step 5.** Do not auto-open a PR. Do not auto-merge. Stay on the topic branch.

If a step fails, surface — do not fake-complete.

## Version-bump rule

ANY change → bump. Never overwrite a version with different content under it.

## Deploy timing

<PROJECT-SPECIFIC: e.g. "Deploy fires on every commit to main (no separate dev/stage/live during this phase). Topic-branch commits do not deploy.">

## After a violation

1. Apologize directly.
2. Offer to revert (`git revert <sha>` + redeploy + push).
3. Do NOT propose follow-up code work in the same turn.
4. Save the new failure-mode phrasing to project auto-memory.
