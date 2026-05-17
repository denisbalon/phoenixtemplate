# Contributing to <PROJECT_NAME>

Binding process document. Read once; revisit when conventions feel off.

## Quick rules cheat-sheet

| Situation | Action |
|---|---|
| Need to start work | New branch off `main`, push branch immediately |
| Made a commit | Push to origin same turn — no exceptions |
| Touched any tracked `.md` | Commit it AND push (machine-swap survival) |
| Ready for review | `gh pr create` with HEREDOC body |
| `/ultrareview` failed | Fall back to `docs/pr_review_instructions.md` manual path |
| User says "merge" | `gh pr merge <PR#> --rebase --delete-branch` |
| `--rebase` refuses | Rebase the feature branch with `--force-with-lease`, retry merge |
| Anything ambiguous | Ask. Never `--force` without explicit OK. |

## Principles

- **Never commit to `main`.** Every change lives on a feature branch. `main` only receives explicit fast-forward merges via PR.
- **Push after every commit.** Local-only commits are not allowed. Spec, docs, and version bumps must always be on origin.
- **Topic branches accumulate many commits.** A single branch normally hosts dozens of `code!`s before a PR is opened. Don't open a new branch per `code!`. Don't open a PR after each commit.
- **PR is user-triggered.** The `code!` 5-step sequence ENDS at step 5 (deploy). It does NOT auto-open a PR.
- **Merge with rebase to preserve linear history.** `gh pr merge --rebase --delete-branch` is the canonical merge under branch protection.
- **Delete branches after successful merge** (bundled with `--delete-branch`).
- **Never `git checkout` / `git switch` without explicit instruction.** "Check the latest stuff" ≠ checkout.
- **Memory stays user-local.** The auto-memory dir at `~/.claude/projects/<sanitized>/memory/` is the single source.

## Phase frequency

| Phase | Frequency |
|---|---|
| §1 Set up branch | Once per branch |
| §2 Commits + push | Many per branch — once per `code!` |
| §3 Open PR | Once per branch, on user trigger |
| §4 Review | Once per branch, between PR open and merge |
| §5 Address feedback | As needed, more commits on the same branch |
| §6 Merge | Once per branch, on user "merge" |
| §7 Cleanup | Bundled with §6 on success |

## TL;DR

1. Topic branch from `main`. Push branch immediately on `git checkout -b`. Branch persists across many `code!`s.
2. **No code edits without the literal `code!` in the current user message.**
3. On `code!`, atomic 5-step: **spec → bump+CHANGELOG → code → commit → deploy**. Push after every commit.
4. Every change bumps `VERSION`. ANY change.
5. PR opens only on user trigger ("PR" / "ready"). Body uses `## Summary` + `## Test plan`.
6. Review (ultrareview or manual). Address feedback with more `code!`s on the same branch.
7. On user "merge": `gh pr merge --rebase --delete-branch`.
8. Deploy on every commit to `main` (no separate dev/stage/live during this phase).

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

Path A — `/ultrareview <PR#>` (preferred when working).
Path B — manual review per `docs/pr_review_instructions.md`.

### Output contract (both paths)

Whichever path runs, the **deliverable is GitHub comments, posted via `gh api`, one per commit on the branch — including commits with no findings**:

- **Walk every commit** `main..HEAD` in order. Each gets at least one comment on the PR (inline on specific lines, or a commit-level review).
- **Clean commits get an explicit "no findings on `<sha>` — `<subject>`" comment.** Silence is indistinguishable from "the reviewer forgot this commit." The explicit comment closes that gap and makes the audit trail complete.
- **Plus one overall summary review** at the end with findings rolled up by severity (Block / Strong / Nit per `docs/pr_review_instructions.md`).
- **Never** a local file (`review.md`, `findings.txt`, etc.), a chat-only summary, or PR-description edits in place of comments. The PR is the audit trail; comments are the unit.

## 5. Address review feedback

Each round of fixes follows the full `code!` workflow. New commits go on the same branch.

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

# `code!` passphrase — hard gate + mandatory workflow

## The hard gate

**Do NOT write, edit, or modify any code unless the user's CURRENT message contains the literal substring `code!`.**

Before any state-mutating tool call, self-check: *"Does THIS exact message from the user contain the literal substring `code!`?"*

- Absent → reply with the plan + "Send `code!` and I'll do it." STOP.
- Present → execute the 5-step sequence below.

The check is the FIRST step of every code-change response. **Auto mode does NOT override this gate.**

## Phrases that LOOK like authorization but aren't

`now lets X` · `let's X` · `can you X` · `please X` · `do X` · `go` · `proceed` · `ship it` · `yes` · `yeah` · `ok do it` · `sure` · `we should X` · imperatives like `merge` / `revert` / `commit` / `deploy` / `push` · detailed feature descriptions in imperative mood · user pasting an exact diff with "just do the fix"

All → reply with the plan + "Send `code!` and I'll do it" → STOP.

## Phrases that mean DEFINITELY NOT code

`understood?` · `wdyt?` · `make sense?` · `ok?` · any closing confirmation question.

## Allowed without `code!`

Reading files · grep · read-only git · web search · planning text · clarifying questions · writes to local-only memory/settings (`~/.claude/projects/.../memory/`, `.claude/settings.local.json`).

`.claude/settings.json` (committed) IS gated.

## Rationalizations to refuse

| Rationalization | Why it's wrong |
|---|---|
| "Intent is unambiguous, just ship it" | Gate is the literal `code!` substring, not intent. |
| "User said `code!` recently, this is in scope" | Every code change needs a FRESH `code!`. |
| "Auto mode says minimize interruptions" | Auto mode does NOT override this gate. |
| "Direct imperative + clarity = authorization" | Imperative grammar ≠ `code!`. |
| "User said yes" | `yes` is not `code!`. |
| "It's just a docs/SPEC tweak" | Tracked-file edits need the gate. |
| "User pasted the diff verbatim" | WHAT ≠ WHEN. |
| "User is rushing" | Schedule is not my problem; the gate is. |

## Mandatory 5-step sequence on `code!`

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
