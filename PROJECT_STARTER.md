# Project Starter

**Template version:** v1.9.1
**Last updated:** 2026-05-18

A reusable bootstrap kit for new software projects worked on with Claude Code. Captures the workflow, file structure, conventions, and decision framework so each new project starts from a known-good baseline instead of re-deriving them.

**Current shipped scope: a Python/uv/FastAPI/VPS starter.** The process layer (bootstrap checklist, `gogogo!` gate, 5-step workflow, spec-block format, Karpathy standing rules, reviewer-agnostic PR rubric) is **stack-agnostic** and works for any project. The language-preset layer (Makefile, CI workflow, deploy script, `.env.example` validators, `pyproject.toml` once shipped, `src/<package>/`) is **Python-only today**. Multi-preset support (Node/pnpm, Go, no-runtime) is roadmap per D-009 — see §0.1.

The companion [`templates/`](templates/) directory holds copy-paste-ready file scaffolds (scripts, doc skeletons, config). Each new project copies the relevant template files in §4, customizes the placeholders, and answers §5's decision bank before writing code.

---

## 0. How to use this document

### 0.1 Current scope

The repo ships two layers with different scopes:

| Layer | Scope | What it contains |
|---|---|---|
| **Process** (stack-agnostic) | Any project | `gogogo!` gate convention, 5-step atomic workflow, spec-block format, Karpathy standing rules, reviewer-agnostic PR rubric, bootstrap checklist (§1 minus the language-specific bits), version-bump + CHANGELOG rules |
| **Language preset** (Python-only today) | Python/uv/FastAPI/VPS | `templates/Makefile`, `templates/.github/workflows/ci.yml`, `templates/scripts/deploy.sh`, `templates/.env.example` validators, expected `pyproject.toml` + `src/<package>/` + `tests/` layout |

If you're starting a project in a **different stack** today, you can still adopt the process layer manually (read §2, copy `templates/CLAUDE.md` + `templates/CONTRIBUTING.md` + `templates/docs/`, customize) but the language-preset files will need stack-appropriate substitutes you write yourself. Multi-preset support (Node, Go, no-runtime) is on the roadmap (D-009) but not shipped — when it lands, this section flips.

### 0.2 Reading order

1. **Read §1 once** — the bootstrap checklist, zero to first commit.
2. **Read §2 once** — the binding workflow you'll follow on every change.
3. **Skim §3** — file/folder layout you'll be reproducing.
4. **Use §4 as a reference** — copy the listed templates into the new project, replace placeholders.
5. **Answer §5 in chat with Claude** before writing any feature code — these are the decisions that shape everything.
6. **Customize §6 if deploying to a VPS**, otherwise replace it with your platform's deploy procedure.
7. **§7–§10 are reference material** — read when relevant.

When this document changes (template version bump), update the template version at the top and add a row to its own changelog at the bottom.

---

## 1. Bootstrap checklist (zero → first commit)

This is a one-time procedure, run when creating a new project. Follow in order; each step is small.

### 1.1 Pick names + directory

Pick:
- **Project slug** (kebab-case, lowercase, ASCII): e.g. `widget-tracker`. This is the local directory name and the GitHub repo name.
- **Package/module name** (snake_case for Python, camelCase for JS, etc.): e.g. `widget_tracker`. This is the import name in code.

```sh
PROJECT_SLUG=widget-tracker
PACKAGE_NAME=widget_tracker
mkdir -p ~/github/$PROJECT_SLUG
cd ~/github/$PROJECT_SLUG
```

### 1.2 Initialize git

```sh
git init -b main
```

The default branch must be `main` (not `master`). Branch protection rules in §1.6 reference `main`.

### 1.3 Copy templates

**Quick path (recommended).** From the source-of-truth repo, run the export script to produce a portable archive, then unpack it into the new project:

```sh
# In the source-of-truth repo (one-time per export)
cd ~/github/<source-project>
./scripts/export-starter.sh    # writes ~/Downloads/project-starter-v<version>-<date>.tar.gz (and .zip if `zip` is installed; on minimal Linux installs you may only get the .tar.gz)

# In the new project's empty directory
cd ~/github/<PROJECT_SLUG>
tar -xzf ~/Downloads/project-starter-v*.tar.gz --strip-components=1
chmod +x scripts/*.sh
```

The `--strip-components=1` flag drops the leading `project-starter-v.../` directory so contents land directly at the project root.

**Alternative — direct file copy.** If both repos are on the same machine:

```sh
SOURCE=~/github/<source-project>
cp -r $SOURCE/templates/* ./
cp $SOURCE/templates/.gitignore ./
cp $SOURCE/templates/.python-version ./   # adjust if non-Python
cp -r $SOURCE/templates/.claude ./
cp -r $SOURCE/templates/.github ./
cp $SOURCE/templates/CHANGELOG.md ./
chmod +x scripts/*.sh
```

Then customize: search for `<PROJECT_NAME>`, `<PACKAGE_NAME>`, `<PROJECT_DESCRIPTION>`, `<HOST>`, `<DOMAIN>` and similar placeholders. The README, CLAUDE.md, CONTRIBUTING.md, and docs/* skeletons are the main customization targets.

### 1.4 Initial VERSION

```sh
echo "0.1.0" > VERSION
```

The version-bump rule (§2) applies on every subsequent change.

### 1.5 GitHub repo

Create the repo (use `--private` unless you know it should be public):

```sh
gh repo create denisbalon/$PROJECT_SLUG --private --source=. --remote=origin --description "<short description>"
```

If the repo already exists (created via the GitHub UI), skip the `gh repo create` and instead:

```sh
git remote add origin git@github.com:denisbalon/$PROJECT_SLUG.git
```

### 1.6 Branch protection on `main`

In **GitHub → Settings → Branches → Add classic branch protection rule** for `main`:

- ✅ Require a pull request before merging
- ✅ Require linear history
- ❌ Allow force pushes
- ❌ Allow deletions
- ✅ Do not allow bypassing the above settings

Don't tick "Require approvals" (you're solo). Don't tick status checks until CI lands.

### 1.7 Repo merge settings

In **GitHub → Settings → General → Pull Requests**:

- ❌ Allow merge commits — **untick**
- ❌ Allow squash merging — **untick**
- ✅ Allow rebase merging — **leave ticked** (this is the canonical merge path with branch protection)
- ✅ Always suggest updating pull request branches
- ✅ Automatically delete head branches

This forces all PRs to merge as rebase, producing linear history.

### 1.8 Auto-memory seed

Create the project's auto-memory directory (path is computed by Claude Code; usually `~/.claude/projects/<sanitized-cwd>/memory/`). On the first Claude Code session in the new project's directory, ask Claude to write seed memory entries — see §10 for the recommended set.

### 1.9 First commit

```sh
git add -A
git status   # review what you're staging
git commit -m "$(cat <<'EOF'
chore: scaffold project skeleton v0.1.0

Initial project bootstrap from PROJECT_STARTER template v1.0.0. Adopts the
gogogo! gate, 5-step workflow, rebase-merge strategy, version-bump rule.
No source code yet.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
git push -u origin main
```

This is the **only direct push to `main`** the project will ever do. Branch protection blocks all subsequent direct pushes; everything else goes through PRs.

### 1.10 Verify

```sh
git log --oneline -1                 # should show your initial commit
gh repo view --json visibility,url   # should show your repo
gh api /repos/denisbalon/$PROJECT_SLUG/branches/main/protection 2>&1 | head  # should NOT be 404
```

Bootstrap complete. From here on, all work follows §2.

---

## 2. The process (workflow + gate)

This section is **binding** for every change. The same text is mirrored verbatim into each project's `CONTRIBUTING.md` so it travels with the repo.

### 2.1 The `gogogo!` passphrase — hard gate

**Do NOT take any state-mutating action unless the user's CURRENT message contains the literal substring `gogogo!`.**

`gogogo!` is the **execute trigger**. It must be preceded by an **action verb** in the same message — the verb specifies *what* to execute. `gogogo!` is the signature; the verb is the contract.

#### Action verb → workflow

| Phrase | Action | Workflow |
|---|---|---|
| `code gogogo!` · `feat gogogo!` · `fix gogogo!` · `chore gogogo!` · `docs gogogo!` · `refactor gogogo!` · `test gogogo!` · `perf gogogo!` · `ship gogogo!` | Full feature change | 5-step (§2.2): spec → bump+CHANGELOG → code → commit+push → deploy |
| `commit gogogo!` | Commit current work + push (still bumps version + CHANGELOG; skips deploy) | §2.5 only |
| `PR gogogo!` · `ready gogogo!` · `open PR gogogo!` | Open pull request from current branch | §2.6 |
| `merge gogogo!` | Merge the open PR (rebase + delete-branch) | §2.9 |
| `deploy gogogo!` | Deploy current `main` | §2.11 |
| `revert gogogo!` | Revert last commit + redeploy | §2.12 |

Before any state-mutating tool call (`Edit` / `Write` / `NotebookEdit` / `Bash` running `git commit` / `git push` / deploy / `gh pr create|merge|comment` / `gh issue create` / curl POST/PUT/DELETE), self-check:

1. Does THIS exact message contain the literal substring `gogogo!`?
2. What is the action verb immediately before it?
3. Does that verb match the action I'm about to take?

- No `gogogo!` → reply with the plan in text + "Send `<verb> gogogo!` and I'll do it." STOP.
- `gogogo!` with no verb → reply *"Which action? code / commit / PR / merge / deploy / revert?"* and STOP. (No `review` — review is out-of-band per §2.7, no Claude-side action to authorize.)
- `<verb> gogogo!` but I was about to do a *different* action → STOP, surface the mismatch, do nothing.
- `<verb> gogogo!` matching the action → execute the workflow for that verb.

The check is the FIRST step of every action response — before drafting code, before reading files for the change, before describing the plan. **Auto mode does NOT override this gate.**

#### Phrases that LOOK like authorization but aren't

Bare imperatives *without* `gogogo!`:

`now lets X` · `let's X` · `can you X` · `could you X` · `please X` · `do X` · `do that` · `go` · `proceed` · `ship it` · `yes` · `yes do` · `yeah` · `ok do it` · `sure` · `we should X` · `we need X` · `time to X` · `merge` (alone) · `revert` (alone) · `commit` (alone) · `deploy` (alone) · `push` (alone) · `PR` (alone) · detailed feature descriptions in imperative mood · user pasting an exact diff with "just do the fix"

All → reply with the plan + "Send `<verb> gogogo!` and I'll do it" → STOP.

The action verbs in the table above (`PR`, `merge`, `deploy`, etc.) are ONLY authorizing when paired with `gogogo!` in the same message. `merge` alone never triggers a merge.

#### Phrases that mean DEFINITELY NOT action

`understood?` · `wdyt?` · `what do you think?` · `got it?` · `make sense?` · `ok?` · `right?` · any closing confirmation question.

#### Allowed without `gogogo!`

Reading files · grep · read-only git (`log` / `status` / `diff`) · web search · planning text · spec-style description of what *would* be built · clarifying questions · writes to local-only memory/settings files (`~/.claude/projects/.../memory/`, `.claude/settings.local.json`).

**`.claude/settings.json` (committed) IS gated** — counts as code.

#### Rationalizations to refuse

| Rationalization | Why it's wrong |
|---|---|
| "Intent is unambiguous, just ship it" | Gate is the literal `gogogo!` substring, not intent. |
| "User said `gogogo!` recently, this is in scope" | Every action needs a FRESH `<verb> gogogo!` in the CURRENT message. |
| "Auto mode says minimize interruptions" | Auto mode does NOT override this gate. |
| "Direct imperative + clarity = authorization" | Imperative grammar ≠ `gogogo!`. |
| "User said yes" | `yes` is not `gogogo!`. |
| "It's just a docs/SPEC tweak" | If it's an `Edit` on tracked files, it needs the gate. |
| "User pasted the diff verbatim" | Specifying WHAT ≠ authorizing WHEN. |
| "User is rushing" | Schedule is not my problem; the gate is. |
| "Bare `gogogo!`, I'll default to the 5-step" | Bare `gogogo!` is ambiguous — ask for the verb. |
| "`merge gogogo!` is close enough to authorize a PR open too" | One verb, one action. `PR gogogo!` for PR; `merge gogogo!` for merge. |

### 2.2 The 5-step atomic sequence (on `gogogo!`)

Atomic. Missing or reordering any step is a failure.

1. **Update the spec** — `docs/spec.md` reflects the change BEFORE any code is written. Spec-first keeps intent explicit. For architectural decisions, also add an entry to the **Decision log** section in `docs/spec.md` (oldest first; format: `D-NNN (YYYY-MM-DD) <title>` with Chose / Considered / Why / Implemented in lines). Decisions live forever in the repo; chat history that produced them does not.
2. **Bump versions + add CHANGELOG entry** — bump `VERSION` (and any language-specific markers — see §10 for what each project tracks), then add a `CHANGELOG.md` entry under the new version heading with the user-facing summary. Format: `## v<X.Y.Z> — YYYY-MM-DD` followed by bullets, optionally grouped by area. The CHANGELOG entry rides in the same commit, so the commit subject can reference `v<X.Y.Z>` with full context.
3. **Write the code** — touch implementation files now and only now.
4. **Commit + push** — single commit per concern, subject ends with `v<X.Y.Z>`. HEREDOC for the message. Push to origin in the same turn. No `--no-verify`. No `--amend` unless explicit.
5. **Deploy** — run the project's deploy command. If pre-MVP / no deployable yet, step 5 is a no-op; resume on every commit to `main` once deployable. Surface deploy errors loudly; do NOT silently skip.

**The sequence ENDS at step 5.** Do not auto-open a PR. Do not auto-merge. Stay on the topic branch. The next user message will either be another `gogogo!` (more commits), or a PR/merge trigger (separate phase).

If a step fails (spec unclear, deploy errors, push rejected), stop and surface — do not fake-complete the sequence.

### 2.3 Version-bump rule

ANY change → bump. Not "meaningful" change. ANY. Don't rationalize "same-version rebuild." **Never overwrite a version number with different content under it.**

Initial version: `0.1.0`. The bump rule applies on every `gogogo!` after that.

Increment policy:
- **patch** (`0.1.0 → 0.1.1`): default for typical changes
- **minor** (`0.1.0 → 0.2.0`): notable features, schema changes
- **major** (`0.x.x → 1.0.0`): first production release; subsequently breaking changes

### 2.4 Branching

- **Never commit to `main`.** Every change lives on a feature branch. `main` only receives explicit fast-forward merges via PR.
- Topic branches use kebab-case prefix per type — `feat/`, `fix/`, `chore/`, `docs/`, `refactor/`, `test/`, `perf/`. Example: `feat/click-receiver`, `fix/capi-retry-401`.
- Branch from `main`, push immediately on `git checkout -b`, deleted after merge. No `develop`, `release/*`, environment-named branches.
- **Never `git checkout` / `git switch` without explicit instruction.** "Check the latest stuff" ≠ checkout — fetch + report, then ask.
- **Topic branches accumulate many commits.** A single branch normally hosts dozens of `gogogo!`s before a PR is opened. Don't open a new branch per `gogogo!`. Don't open a PR after each commit.

### 2.5 Commits

#### Mechanics

- **Push after every commit.** Local-only commits are not allowed. Spec, docs, and version bumps must always be on origin.
- Subject: `<type>: <imperative summary> v<X.Y.Z>` — types: `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `perf`. ≤72 chars.
- Stage **specific files** (`git add path/to/file ...`), not `git add -A` / `git add .` (avoids accidentally picking up secrets, build artifacts, large binaries).
- HEREDOC for messages so formatting survives.
- Trailers: `Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>` when Claude assisted.
- No `--no-verify`. No `--amend` unless explicit.
- One concern per commit. Split commits that span concerns.

#### Commit message quality (be super clear)

A reviewer reading the commit log six months from now should understand **what changed and why without opening the diff**.

- **Subject line** is the *result* in active voice with a concrete object. The subject says what changed and to what.
  - ❌ Bad: `fix bug`, `update docs`, `various changes`, `WIP`, `tweaks`, `address feedback`, `bump version`.
  - ✅ Good: `fix CAPI 401 retry on expired token v0.2.3`, `update spec frozen-behavior with Subscribe modes v0.1.7`, `drop phoenixbot user from runbook §4 v0.1.8`.
- **Body** explains the *why* — not what (the diff shows that), but the constraint, decision, or context that justifies the change. 1–3 sentences. ~72-col wrap. Skip the body only when the subject is fully self-explanatory.
- **Name the files/sections** in the body when the commit touches multiple. Reviewers shouldn't have to diff to know whether `runbook.md` or `setup.md` got the update.
- **Reference issue / PR / Decision-log entry** when applicable: `Refs #N`, `Closes #N`, `Implements D-NNN`. Makes the audit trail traversable.
- **No fillers.** If review feedback prompted the commit, name it: `Codex audit fix #3 — propagate D-005 to ops docs` beats `Address review`.
- **Version suffix is required** on the subject: ends with `v<X.Y.Z>` matching the bumped `VERSION`.

**The check:** read your subject + body aloud, no diff in front of you. Can you describe what changed and why? If no, it isn't clear enough.

#### Template

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

### 2.6 Pull requests

**User-triggered only.** The 5-step sequence does NOT auto-open a PR. PR opens when the user explicitly says **`PR gogogo!`** / **`ready gogogo!`** / **`open PR gogogo!`** — typically after the branch has accumulated many commits across many `<verb> gogogo!`s. The bare word "PR" without `gogogo!` does NOT authorize.

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

### 2.7 Review

**PR review is out-of-band and reviewer-agnostic.** Claude opens the PR on `PR gogogo!` and stops there. Everything after that — picking a reviewer, invoking it, addressing findings — happens in a separate session. **The project ships no Claude-side reviewer wiring:** no skill, no Makefile target, no `review gogogo!` verb. The rubric and output contract in `docs/pr_review_instructions.md` apply to whichever reviewer you point at the PR (Codex CLI, `/ultrareview`, another LLM, manual human). **Independence beats deepening:** a different model family with fresh context catches what the original missed. Reviewers run **serially**, never in parallel; one per PR.

#### The workflow after `PR gogogo!`

1. Open whichever reviewer you prefer in a separate terminal or session.
2. Point it at `docs/pr_review_instructions.md` (the rubric) and the open PR.
3. The reviewer walks `main..HEAD`, posts per-commit comments via `gh` (or its native PR-comment integration) per the output contract. If it's interactive (Codex CLI, manual review), you approve each shell call.
4. Return to Claude. Address feedback with more `<verb> gogogo!`s on the same branch.

That's it. No prereq checking from Claude. No "remind me of the command." No matrix to navigate. The user picks a reviewer and runs it — Claude's job ended at `PR gogogo!`.

#### Output contract (universal)

The deliverable is GitHub comments via `gh api` (or the reviewer's native PR-comment integration), **one per commit on the branch — including commits with no findings**. Clean commits get an explicit "no findings on `<sha>` — `<subject>`" comment so silence isn't mistaken for omission. Plus one overall summary review rolled up by severity (Block / Strong / Nit). Never a local file, never a chat-only summary, never PR-description edits. Full rules: §11 "Output contract" and `docs/pr_review_instructions.md`.

### 2.8 Address review feedback

Each round of fixes follows the full `gogogo!` workflow. New commits go on the same branch and push to origin. The PR updates automatically.

### 2.9 Merge

Only after the user explicitly says **`merge gogogo!`**. Never implicit. The bare word "merge" without `gogogo!` does NOT authorize.

With branch protection on (§1.6), the canonical merge path is `gh pr merge --rebase --delete-branch` — server-side rebase produces linear history; commits land on `main` with new SHAs. Direct `git push origin main` is blocked.

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

### 2.10 Cleanup

`gh pr merge --delete-branch` deletes the remote branch. Locally:

```sh
git branch -d <branch>      # safe -d, refuses if not merged
```

Use `-d` (safe), not `-D` (force).

### 2.11 Deploy timing

Deploy runs on every commit to `main` (i.e., immediately after the rebase-merge lands). Topic-branch commits do not deploy. If the project has separate dev/stage/live environments, document the alternative timing in the project's `CONTRIBUTING.md`.

### 2.12 After a violation

1. Apologize directly. No "but it was correct" defenses.
2. Offer to revert (`git revert <sha>` + redeploy + push). User may want the work dropped entirely even if functionally correct.
3. Do NOT propose follow-up code work in the same turn. Reverting OR keeping is the user's call alone.
4. Save any new failure-mode phrasing to the project's auto-memory so future sessions see it.

### 2.13 Phase frequency

| Phase | Frequency |
|---|---|
| §2.4 Branch creation | Once per branch (when starting a new chunk of work) |
| §2.5 Commits + push | Many times per branch — once per `gogogo!` |
| §2.6 Open PR | Once per branch, on user trigger ("PR" / "ready") |
| §2.7 Review | Once per branch, between PR open and merge |
| §2.8 Address feedback | As needed, more commits on the same branch |
| §2.9 Merge | Once per branch, on user "merge" |
| §2.10 Cleanup | Bundled with §2.9 on success |

---

## 3. Structure (file/folder layout)

Standard tree for a new project. Stack-specific files (`pyproject.toml`, `package.json`, `Cargo.toml`, etc.) replace one another based on language.

```
<project-slug>/
├── README.md                       # 30-second pitch + table of doc links
├── CLAUDE.md                       # Claude Code session conventions
├── CONTRIBUTING.md                 # process rules (gate, branching, etc.)
├── PROJECT_STARTER.md              # this template (kept for reference); update its version when modified
├── VERSION                         # plain text, e.g. "0.1.0\n"
├── CHANGELOG.md                    # per-version diary (v0.1.0 entry → v...)
├── .env.example                    # var declarations with comment-block-per-var
├── .gitignore                      # ignore .env, build artifacts, etc.
├── Makefile                        # dev / test / lint / fix / deploy targets
│
├── docs/
│   ├── setup.md                    # first-time machine setup procedure
│   ├── spec.md                     # product behavior — the contract
│   ├── architecture.md             # data flow + components + DB schema
│   ├── integration.md              # external system contracts (APIs, webhooks)
│   ├── runbook.md                  # day-2 ops: deploy, logs, incidents
│   └── pr_review_instructions.md   # for review automation / external reviewers
│
├── scripts/
│   ├── check-env.sh                # diff .env against .env.example
│   ├── bootstrap.sh                # interactive .env populator
│   └── deploy.sh                   # deploy to target host
│
├── src/<package_name>/             # source code (flat layout for v1)
│   ├── __init__.py | index.ts | mod.rs
│   ├── ...
│
├── tests/                          # one file per source module is a fine starting point
│   └── conftest.py | setup.ts
│
├── .claude/
│   ├── settings.json               # gate permissions, SessionStart hook (committed)
│   └── settings.local.json         # per-machine overrides (gitignored)
│
└── .github/
    └── workflows/
        └── ci.yml                  # lint + typecheck + test gates per PR
```

**Folder ownership:**
- `docs/` is for written-down decisions and procedures. Keep it small; one file per concern.
- `scripts/` is for shell scripts. Don't grow this; complexity belongs in source.
- `src/` is the only place runtime code lives.
- `tests/` mirrors `src/` structure.
- `.claude/` is for Claude Code harness configuration only.

---

## 4. Templates (copy-paste references)

The companion `templates/` directory holds skeleton files. When bootstrapping a new project, copy the relevant ones, then search-and-replace the `<placeholders>`.

| Template file | Purpose | Placeholders to fill |
|---|---|---|
| `templates/README.md` | Project entry point — pitch + doc-table | `<PROJECT_NAME>`, `<PROJECT_DESCRIPTION>` |
| `templates/CLAUDE.md` | Session conventions for Claude Code; auto-loaded every session | `<PROJECT_NAME>`, `<STACK>`, `<HOST>`, sensitive context |
| `templates/CONTRIBUTING.md` | Process rules — verbatim copy of §2 of this doc with project specifics filled in | `<PROJECT_NAME>`, version-marker list |
| `templates/CHANGELOG.md` | Per-version diary skeleton | initial v0.1.0 entry |
| `templates/.env.example` | Env-var declarations skeleton | category headers; vars per project |
| `templates/.gitignore` | Sensible default ignores | language-specific lines if needed |
| `templates/.python-version` | Python version pin (if Python) | `3.12` typical |
| `templates/Makefile` | Dev/test/lint/deploy targets | command bodies per stack |
| `templates/.claude/settings.json` | Permission allowlist + SessionStart hook running `check-env.sh` | absolute paths |
| `templates/.github/workflows/ci.yml` | CI pipeline: lint + typecheck + test | tool versions per stack |
| `templates/scripts/check-env.sh` | Verifies `.env` against `.env.example` | none — generic |
| `templates/scripts/bootstrap.sh` | Interactive `.env` populator with masking + validators | none — generic |
| `templates/scripts/deploy.sh` | Skeleton deploy script | `<HOST>`, `<REMOTE_DIR>` |
| `templates/docs/setup.md` | First-time setup procedure skeleton | per project |
| `templates/docs/spec.md` | Product spec skeleton with Process & versioning section | per project |
| `templates/docs/architecture.md` | Data flow + components skeleton | per project |
| `templates/docs/integration.md` | External integrations skeleton | per project |
| `templates/docs/runbook.md` | Day-2 ops skeleton | per project |
| `templates/docs/pr_review_instructions.md` | PR review checklist skeleton | per project |

---

## 5. Decisions to answer before writing feature code

Open these as a Q&A with Claude before touching `src/`. Each has options + recommended pick. Tailor to your project — some don't apply (e.g., DB choice on a CLI tool).

### 5.1 Stack

What runtime + framework? Picking sets language for `pyproject.toml`/`package.json`/`go.mod`, naming conventions, CI tools.

Common picks:
- **Python 3.12 + FastAPI + uvicorn** — async web service, excellent CAPI/Telegram tooling
- **Node 20 + Hono / Express** — when most of the team is JS-native
- **Go 1.22+** — when raw performance matters more than ecosystem

### 5.2 Process model

How does the service run on the host?

- **(a) systemd unit running as root or service-user.** Simplest. Direct file access. Great for small VPS deployments.
- **(b) Container (Podman / Docker).** Reproducible builds. Required if multi-host / orchestrated.
- **(c) Managed (Fly.io / Render / Vercel).** No server to manage. Costs more per request but zero ops.

### 5.3 Database

- **(a) SQLite** — single-instance, zero ops, fits up to millions of rows.
- **(b) Postgres** — multi-instance, real concurrency. Costs ops complexity.
- **(c) Managed Postgres** (Neon / Supabase / RDS) — best of both at $$.
- **(d) None** — ephemeral or stateless service.

### 5.4 Hosting

- **(a) VPS** (Hetzner / OVH / DigitalOcean / your-existing-box) — cheapest, full control.
- **(b) PaaS** (Fly.io / Render / Railway) — push-to-deploy, less ops.
- **(c) Serverless** (Lambda / Cloud Run / Workers) — pay-per-request, ephemeral.

### 5.5 Backups

- **(a) Local snapshots only** — nightly `.backup` to disk, manual scp-down.
- **(b) Off-site object storage** — daily push to R2 / S3 / B2.
- **(c) Managed DB backup** — included with managed Postgres.
- **(d) None** — accept loss; only valid if data is reproducible.

### 5.6 Module layout (within `src/`)

- **(a) Flat** — ~10 files at package root. Best for v1. Refactor when files exceed ~300 lines.
- **(b) Grouped** — `api/`, `services/`, `clients/`, `db/` subpackages. Best when v1 already has 15+ files or layered architecture is the norm.

### 5.7 CI strategy

- **(a) Three gates** — lint, typecheck, test. Standard.
- **(b) Add coverage gate** — `--cov-fail-under=80`. Useful in established codebases, premature in v1.
- **(c) Add security scan** — `bandit`, `safety`, `trivy`. Useful for client-facing services with secrets.

### 5.8 Secrets store

- **(a) `.env` file on host** — gitignored, chmod 600. Simple, works for solo VPS.
- **(b) Cloud secret manager** (AWS / GCP / Doppler / 1Password Secrets) — better for teams or compliance.
- **(c) Hashicorp Vault** — overkill for solo dev.

### 5.9 Observability

- **(a) journald + Sentry** — minimum viable. Logs in journald, errors in Sentry.
- **(b) + Grafana / Loki** — when you need dashboards.
- **(c) + OpenTelemetry** — when you need distributed tracing across services.

### 5.10 Deploy frequency

- **(a) Deploy on every commit to main** — fastest iteration, no separate envs.
- **(b) Deploy on tag** — `git tag v0.2.0 && git push --tags` triggers deploy. Slower but auditable.
- **(c) Manual deploy** — `make deploy` from a clean main. Defaults to (a) but you skip when you want.

---

## 6. VPS deploy baseline

For projects deploying to a Linux VPS (Hetzner / OVH / DigitalOcean / similar). Skip if using PaaS or serverless.

Adapt to your VPS specifics. The procedure assumes Debian/Ubuntu/CentOS-family; commands like `useradd` / `firewall-cmd` are RHEL-family — translate as needed.

### 6.1 DNS

In your DNS provider (Cloudflare / Route 53 / etc.):
- Add an `A` record: `<subdomain>` → `<vps-ipv4>`
- Proxy/CDN setting depends on the use case:
  - **DNS-only ("gray cloud" in Cloudflare)** for Telegram webhooks (CF proxy interferes)
  - **Proxied ("orange cloud")** for general web traffic that benefits from CDN/DDoS

Verify propagation: `dig <subdomain>.<domain> +short` should return the VPS IP.

### 6.2 TLS

Pick one:
- **Caddy** — auto-issues + auto-renews via Let's Encrypt. Easiest. `caddy run` on the host, point at your service.
- **Let's Encrypt via certbot** — `certbot --nginx -d <subdomain>` once, cron-renews.
- **Existing reverse proxy** (e.g., another control panel) — use its TLS issuance flow.

### 6.3 Reverse proxy

If you already have nginx / Caddy fronting other services, add a vhost for the new subdomain that proxies to your service's loopback port:

```nginx
# /etc/nginx/conf.d/<subdomain>.conf
server {
    server_name <subdomain>.<domain>;
    listen 443 ssl;
    # ssl_certificate / ssl_certificate_key as issued in §6.2

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $remote_addr;
    }
}
```

If the VPS is fresh, install Caddy as the simplest option — `Caddyfile` syntax handles TLS + proxy in 3 lines.

### 6.4 Service user (optional)

If running the service as a dedicated user (not root):

```sh
useradd -m -s /bin/bash <service-user>
loginctl enable-linger <service-user>   # for systemd --user services to persist
```

If running as root, skip this step.

### 6.5 systemd unit

```ini
# /etc/systemd/system/<project-name>.service        (system unit, runs as root)
# OR ~/.config/systemd/user/<project-name>.service  (user unit)
[Unit]
Description=<Project description>
After=network.target

[Service]
Type=simple
WorkingDirectory=/root/<project-name>
EnvironmentFile=/root/<project-name>/.env
ExecStart=/root/.local/bin/uv run uvicorn <package_name>.app:app --host 127.0.0.1 --port 8080
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target   # for system units
# WantedBy=default.target    # for user units
```

Install + enable:

```sh
systemctl daemon-reload
systemctl enable --now <project-name>
journalctl -u <project-name> -n 50 -f   # tail logs
```

### 6.6 Firewall

For RHEL-family with firewalld:

```sh
firewall-cmd --list-all   # check current
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --reload
```

For Debian/Ubuntu with ufw:

```sh
ufw allow 80/tcp
ufw allow 443/tcp
```

---

## 7. CI/CD baseline

GitHub Actions, three gates per PR. Configure these to pass before allowing merge by ticking "Require status checks to pass" in branch protection (§1.6) once the workflow exists.

`.github/workflows/ci.yml` template — adapt the tools to your stack:

```yaml
name: ci
on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: astral-sh/setup-uv@v3
      - run: uv run ruff check .

  typecheck:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: astral-sh/setup-uv@v3
      - run: uv run mypy src

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: astral-sh/setup-uv@v3
      - run: uv run pytest
```

Auto-deploy: leave for a separate workflow once staging exists. Manual deploy via `make deploy` from a clean `main` is fine for v1.

---

## 8. Audit trail

How to keep history of decisions + commits + PRs traceable.

### 8.1 Commit-to-PR mapping

With rebase-merge (the canonical merge path under branch protection), commit subjects do **not** automatically include the PR number — `gh pr merge --rebase` preserves original commits verbatim. To trace a commit back to its PR, two options:

- **Manual:** include `Refs #<PR-number>` in the commit body once the PR is open. Requires `git commit --amend` + `git push --force-with-lease` on the feature branch (allowed; never on main).
- **GitHub API:** `gh pr list --state merged --search "<commit-sha>"` finds the PR for any merged commit.

Document the chosen approach in `CONTRIBUTING.md`.

### 8.2 CHANGELOG.md

Per-version human-readable diary. One section per `VERSION` bump:

```md
# Changelog

## v0.2.0 — 2026-05-15

- Add Telegram webhook receiver — PR #12
- Update spec §5.4 for delayed Subscribe mode — PR #11

## v0.1.0 — 2026-05-04

Initial scaffold.
```

Update as part of the same `gogogo!` that bumps `VERSION` (ride-along; not a separate commit).

### 8.3 Decision log

The spec (`docs/spec.md`) holds the *what* and *why* of every design decision. When a decision is made, add an entry to a "Decision log" subsection in `docs/spec.md`:

```md
## Decision log

### D-001 (2026-05-04) Multi-pixel routing — option B
**Chose:** `pixels` table from day 1, single seed row.
**Considered:** (a) hardcode single pixel, (c) full admin UX for managing pixels.
**Why:** Future TikTok-Spain campaign + backup-pixel failover scenario; ~10 LoC overhead now vs. refactor later.
**Implemented in:** PR #4
```

Decisions live forever in the repo; the chat history that produced them does not.

### 8.4 Memory (Claude-specific, user-local by default)

Auto-memory at `~/.claude/projects/<sanitized-cwd>/memory/` captures:
- Project-level facts (overview, infra pointers, spec location)
- User preferences (working style, tolerance for ceremony, repeated-warning preferences)
- Harness quirks observed
- Process rules (the `gogogo!` gate workflow itself)

Memory is **user-local by default** — not in the repo. If a project requires shared memory across collaborators, set `autoMemoryDirectory` in `~/.claude/settings.json` to point at `<repo>/.claude/memory/` and commit that directory.

---

## 9. Conventions

### 9.1 Environment variables (`.env.example` format)

Each var has a comment block above it explaining where to find or generate the value. The block includes "Optional" if the var is not required (the bootstrap script uses this to decide whether to demand a non-empty answer).

```sh
# === Section ===

# Description of what this var is for.
# Where to find it: <source — e.g. "BotFather → /newbot">
# How to generate: <command — e.g. "openssl rand -hex 32">
VAR_NAME=

# Optional: only set when <condition>.
OPTIONAL_VAR=
```

### 9.2 Sensitive value handling

Variables matching `TOKEN | SECRET | KEY | DSN | PASSWORD` are treated as sensitive by `bootstrap.sh`. When redisplayed they show `(set, N chars, ends …xy7z)` instead of the cleartext. Don't log sensitive values; use the masking pattern in any internal logs the bot writes.

### 9.3 Naming

- **Branches:** `<type>/<kebab-case-slug>` — e.g. `feat/click-receiver`
- **Commits:** `<type>: <imperative summary> v<X.Y.Z>`
- **Files:** snake_case for Python/Ruby/Go, kebab-case for shell scripts and docs, PascalCase for class files in JS/TS/Java
- **Branch protection bypass:** never

### 9.4 Comments in code

- **Default to no comments.** Identifiers carry the *what*.
- Add a comment only when the *why* is non-obvious — a hidden constraint, a workaround for a specific bug, a contract that's not visible from the function signature.
- Never comment out code "just in case." Delete it; git remembers.
- Multi-line block comments at top of files are reserved for licenses or long-running invariants. Don't write summaries.

### 9.5 Document boundary

Three docs cover three audiences. Don't mix:

| Doc | Audience | Content |
|---|---|---|
| `docs/spec.md` | Implementers | What the system does + frozen behavior + decision log |
| `CONTRIBUTING.md` | Contributors / reviewers / Claude | How to author + review + ship changes |
| `CLAUDE.md` | Claude Code session bootstrap | Session conventions, sensitive context, gate header |

`docs/architecture.md` is for *implementers* describing the *implementation* (data flow, schema, components). `docs/runbook.md` is for *operators* describing day-2 actions.

---

## 10. Recommended auto-memory seed

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

## 11. PR review heuristics

Project-agnostic rubric for reviewing PRs. **Reviewer-agnostic** — applies to whichever reviewer the user runs (Codex CLI, `/ultrareview`, another LLM, manual). Each project's `docs/pr_review_instructions.md` extends this with project-specific concerns. Review is out-of-band — see §2.7 for the workflow.

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
- **`allowed_updates` / event filters:** explicitly listed in setWebhook calls; defaults often exclude the events you need (e.g., Telegram's default omits `chat_join_request`).
- **Currency / value defaults:** `0` for free conversions; faking value distorts upstream optimization (FB's bid algorithm, etc.).

---

## 12. Claude Code harness quirks

Operational gotchas observed during real use. Save future-you the discovery cost.

### Permissions / file write gating

- **`.claude/settings.json` write blocked when authorizing a yet-uncreated script.** The harness treats "self-granting permission to a path that doesn't exist on disk" as a privilege-escalation pattern. Workaround: create the script first (so the path is real), then write `settings.json` referencing it. The reverse order fails.
- **Self-granting permissions** (writing `permissions.allow` for new tools) is gated as privilege escalation even when scripts exist. Surface the proposed rule to the user; let them either approve via `/permissions` UI or paste the JSON themselves.

### SSH / production interactions

- **Ad-hoc `ssh root@host '<arbitrary command>'` is gated** as "production reconnaissance" requiring explicit user approval, even with key auth working. Workaround: wrap read-only operations in a reviewable script (e.g. `scripts/<service>-inspect.sh`) and add it to `.claude/settings.json` `permissions.allow`. Don't try wildcard SSH allow rules.
- **Mutating commands on production** (creating users, restarting services, modifying config) need user `!`-prefix execution unless wrapped in a similarly-reviewable script.

### TTY-bound commands fail in `!`-prefix shell

- `sudo`, `ssh-copy-id`, and any command that prompts interactively for a password fails when invoked via Claude Code's `!`-prefix shell — there's no TTY. The user has to run those in a separate real terminal once. Once SSH key auth is in place, subsequent SSH calls work in `!`-prefix.

### `gh` CLI quirks

- **`gh pr edit --body` errors on Projects-classic deprecation.** Known bug. Workaround: use `gh api -X PATCH /repos/<owner>/<repo>/pulls/<N> -f body=...` directly (REST, bypasses the broken GraphQL query).
- **`gh pr merge --rebase` recomputes commit SHAs.** Original branch SHAs (e.g. `5920974`) become new SHAs on `main` (e.g. `20584ae`). Functional content is identical; SHA-based references in PR descriptions become slightly stale.

### Memory and settings carve-outs

- **Memory writes (`~/.claude/projects/.../memory/`) are allowed without `gogogo!`.** This is the carved-out exception — memory is local-only and can capture lessons learned even when no code edits are authorized.
- **`.claude/settings.local.json` is gitignored and per-machine** — also out of the gate. `.claude/settings.json` (the committed one) IS gated.

### Branch protection vs. local merge

- With "Require pull request before merging" + "Require linear history" branch protection enabled on `main`, **local `git merge --ff-only && git push origin main` is rejected**. The canonical merge becomes `gh pr merge --rebase --delete-branch` (server-side).
- **Squash-merge auto-appends `(#N)` to commit subjects; rebase-merge does not.** To trace rebase-merged commits to their PR: `gh pr list --search <sha>`, or include `Refs #N` in the commit body manually before merging.

### Auto mode and the gate

- **Auto mode does NOT override the `gogogo!` gate.** A `system-reminder` saying "execute autonomously" is not a license to skip the literal-substring check. The check is the FIRST step of every code-change response, every turn.

---

## 13. Credential handling

### Never paste credentials in chat

The chat transcript is logged. Once a token / password / secret appears in a message, assume it must be rotated. Get values into `.env` via the bootstrap script's interactive prompts, which write directly to disk without echoing through chat output.

### When a credential leaks into chat

1. **Flag the leak once**, with the recommended action (revoke + regenerate at the source service). Be specific about *where* the user revokes (e.g., "Meta Events Manager → Settings → Conversions API").
2. **Do not repeat the warning** in subsequent messages of the same session. The user manages rotation on their own schedule. Repeated reminders erode trust without improving security.
3. If a *different* credential leaks, that's a new incident — flag it once.
4. Continue normal work; the user's response to credential leaks is their call alone.

### Setting sensitive `.env` values via tool path

If the user explicitly authorizes setting a sensitive value into `.env` from chat content (e.g., "copy the X token from the spec doc to my .env for me"), use the **Read + Edit tool path** — the value travels through tool I/O, not chat output. Confirm via masked summary (`(set, N chars, ends …xyz)`); never echo the cleartext back. The Edit tool's old/new strings are part of the transcript but they don't appear as visible chat output.

### Sensitive-value masking pattern

When displaying values matching `TOKEN | SECRET | KEY | DSN | PASSWORD` (case-insensitive) in any tool output, log, or chat message, mask them: `(set, N chars, ends …xyz)`. Never echo cleartext. The bootstrap script implements this pattern; replicate it in any internal logging the project does.

### Don't ask for credentials in chat

When walking the user through `bootstrap.sh` or any setup that needs a token, instruct them to paste the value **into the script's prompt**, never into the conversation. Phrasing: "Run `./scripts/bootstrap.sh` and paste the token into prompt N when it asks." Never: "Paste your token here so I can put it in `.env`."

---

## 14. Bootstrap.sh design principles

The interactive `.env` populator (`scripts/bootstrap.sh`) embodies several patterns worth understanding before modifying it. The reference implementation lives in `templates/scripts/bootstrap.sh`.

### Five modes, one entry point

- **`./scripts/bootstrap.sh`** (no args) → opens an interactive menu listing every variable with current value (sensitive masked), letting the user pick by number. The default mode means non-technical contributors don't need to remember flags.
- **`./scripts/bootstrap.sh VAR_NAME`** → edits one variable and exits. Fast for typo fixes.
- **`./scripts/bootstrap.sh --all`** → walks every variable in order. Best for fresh setup.
- **`./scripts/bootstrap.sh --export [path]`** → writes a portable snapshot of the current creds (same `KEY=VALUE` shape as `.env.example`, comments preserved) to `path`, or to `/tmp/<reponame>-creds-<YYYYMMDD-HHMMSS>.env` if no path is given. `chmod 600`. Prints the path on stdout so callers can capture it (`f=$(./scripts/bootstrap.sh --export)`). Status messages go to stderr — stdout is path-only.
- **`./scripts/bootstrap.sh --import <path>`** → reads `KEY=VALUE` pairs from `path` and writes them into `.env` for every var the importing repo recognizes (i.e., present in its `.env.example`). Vars in the file but absent from `.env.example` are skipped with a warning. Validators do not block import — the source file is trusted.

After every edit (any mode), the menu re-renders and saves to `.env` immediately.

### Migration via `--export` / `--import`

The export/import pair is the primary mechanism for moving credentials between machines (dev box → VPS, machine A → machine B) without typing each value twice. The flow:

1. On the source host: `f=$(./scripts/bootstrap.sh --export)` — yields a `chmod 600` file under `/tmp`.
2. Transfer it: `scp "$f" user@target:/tmp/` (or any other secure channel).
3. On the target host: `./scripts/bootstrap.sh --import /tmp/<file>` — populates `.env` and runs `check-env.sh`.
4. Delete the transferred file on both ends.

The export file has the same shape as `.env`, so it can also be hand-edited or diffed before import.

The interactive menu also has `e` (export, prints the path) and `i` (import, prompts for a path) so a contributor walking through `bootstrap.sh` for the first time can do the migration without leaving the TUI or remembering flag spelling.

On WSL hosts, the export additionally prints the Windows-style path (via `wslpath -w`) so Windows-side tooling (Explorer, scp.exe, WinSCP) can pick the file up directly without the user having to translate `\\wsl.localhost\<distro>\tmp\...` by hand. On macOS and native Linux the POSIX path is already the local path, so nothing extra is printed.

### Comment-block-per-variable

Every var in `.env.example` has a comment block above it explaining where to find or generate the value. The bootstrap script reads `.env.example` as the source of truth: it parses the comment block, the variable name, and the default value, and uses them in prompts.

To add a new var: edit `.env.example` only; the script picks it up automatically.

### Optional vs required

Vars whose preceding comment block contains the literal word "Optional" (case-insensitive) are not required. Required vars demand a non-empty answer; optional vars accept empty input or `-` to clear an existing value.

### Sensitive-value masking on redisplay

When showing a current value (during edit or in the menu list), variables matching `TOKEN | SECRET | KEY | DSN | PASSWORD` display as `(set, N chars, ends …xyz)` instead of cleartext. Protects against shoulder-surfing during paired sessions and screen sharing.

### Format validators with override

Each known var name maps to a regex (e.g., bot tokens match `^[0-9]{8,12}:[A-Za-z0-9_-]{30,}$`, hex secrets match `^[A-Za-z0-9_-]{8,256}$`). Mismatches warn the user with "Use anyway? [y/N]" — they can override when they're sure but they're forced to look at it. Catches typos at input time without being rigid.

### Input normalization

Pasted values get their leading/trailing whitespace stripped, surrounding quotes (single or double) removed, and control characters dropped. Most paste artifacts (terminal-border characters, leading spaces, accidental quotes) get cleaned silently; pathological cases get caught by the format validator.

### Atomic save per edit

Each edit commits to `.env` immediately on Enter (writes to a tempfile + rename, chmod 600). No batched "save at end" — if the user Ctrl-Cs halfway through, what they've entered so far is preserved.

### Why no GUI

A TUI-style menu in pure bash works in any terminal (SSH, WSL, mosh, tmux), survives interruptions cleanly, and has zero deps. A GUI would require platform-specific tools and break the "this works on the VPS too" promise.

---

## Template changelog

Update the **Template version** at the top of this document and add a row here whenever this file changes.

| Version | Date | Notes |
|---|---|---|
| 1.9.1 | 2026-05-18 | Patch — fix `templates/scripts/deploy.sh` cleanliness check (Codex Phase 1.3). Previous `git diff --quiet` only caught unstaged changes; now also blocks on staged-but-uncommitted edits (`git diff --cached --quiet`) and untracked files (`git ls-files --others --exclude-standard`, respecting `.gitignore`). Each scenario is reported separately on failure. `--dirty` override unchanged. Script header documents the policy. |
| 1.9.0 | 2026-05-18 | Ship the minimal runnable Python/uv/FastAPI preset (Codex Phase 1.2 + existing open item #6 — both resolved). New files in `templates/`: `pyproject.toml` (FastAPI + uvicorn runtime; pytest/httpx/ruff/mypy dev via PEP 735 `[dependency-groups]` so the existing `uv sync --frozen` CI step picks them up without flags; hatchling build-backend; tool config for ruff/mypy/pytest), `src/<package_name>/{__init__.py,app.py}` (FastAPI app exposing `/healthz` — matches `scripts/deploy.sh`'s post-deploy curl), `tests/{__init__.py,test_smoke.py}` (`TestClient` smoke test for `/healthz`), `LICENSE` (MIT with `<COPYRIGHT_HOLDER>` + `<YEAR>` placeholders). Single `<package_name>` placeholder convention across everything (including the `src/<package_name>/` directory name); bootstrap substitution is one mv + one sed (documented in the v1.9.0 CHANGELOG entry; auto-substitution in `scripts/bootstrap.sh` is a follow-up open item). Spec: B-012 added; open item #6 closed. |
| 1.8.0 | 2026-05-18 | Declare product identity (D-009): this template is a **Python/uv/FastAPI/VPS starter today**; multi-preset is roadmap, not current fact. Drops the "this document is project-agnostic" claim from §0 and replaces it with an honest paragraph naming current shipped scope; adds `§0.1 Current scope` making the stack-agnostic vs. Python-only boundary explicit. No templates change; no code change; only framing. Spec: D-009 added; "Open project-level decisions" tags stack-agnostic-restructure as "roadmap per D-009". Triggered by Codex's `codex improvement plan.md` (Phase 2 + Phase 12). |
| 1.7.1 | 2026-05-18 | Patch — three doc-consistency fixes surfaced by Codex's review of PR #1 (first dogfood of the v1.7.0 flow). (a) `templates/docs/pr_review_instructions.md` hardcoded `gh api` as the only transport; updated to match B-010's two-path rule (gh + native PR integration). (b) `templates/CONTRIBUTING.md §4` had snuck in "or by the user copy-pasting" as a third path; removed — B-010 doesn't sanction it. (c) `PROJECT_STARTER.md §2.7` told reviewers on this meta-repo to open `docs/pr_review_instructions.md`, but the repo only ships `templates/docs/pr_review_instructions.md`; added a one-line pointer file at `docs/pr_review_instructions.md` so the self-review path resolves. No behavior change; no spec change — three Codex findings (Block/Block/Strong) addressed by aligning surfaces to the already-canonical B-010. |
| 1.7.0 | 2026-05-18 | Remove all Claude-side reviewer wiring. The v1.6.0 local-CLI skill + Makefile target + `review gogogo!` verb are all deleted; `templates/docs/pr_review_instructions.md` preamble rewritten as reviewer-agnostic with no default reviewer named; §2.7 in this doc and §4 in `templates/CONTRIBUTING.md` rewritten as a short paragraph saying review is out-of-band. After `PR gogogo!`, the user opens any reviewer they prefer in a separate session, points it at the open PR and the rubric, and the reviewer posts comments via `gh` directly. Resolves the [P1] Codex flagged on the v1.6.0 branch (stdout-only skill couldn't satisfy the per-commit comment contract) by removing the contradiction at its source — Claude no longer claims a contract it can't satisfy. Spec: B-006/B-007/B-009 superseded by B-010 + B-011; D-005/D-007 superseded by D-008. |
| 1.6.0 | 2026-05-18 | Pivot `request-codex-review` skill + Makefile target from GitHub-App PR-comment (`gh pr comment @codex`) to **local CLI** (`codex review --base main`). Original design assumed a Codex GitHub App that doesn't exist on the user's account; the CLI has a purpose-built `review` subcommand that works synchronously and found three real bugs on its first dry run. §2.7 in this doc and §4 in `templates/CONTRIBUTING.md` updated with the new invocation flow and an output-format note (`[P1]/[P2]/[P3]`, not `Block/Strong/Nit` — `--base` is mutually exclusive with custom prompts in the CLI). GitHub App path documented as a fallback for accounts that have one. Spec: B-008 superseded by B-009; D-006 superseded by D-007 (with an honest "why it was wrong" note). |
| 1.5.1 | 2026-05-18 | Patch fixing three bugs surfaced by the first Codex CLI review (`codex review --base main`): (a) `docs/spec.md` prose hardcoded a version number that drifted past VERSION bumps — replaced with a pure VERSION reference; (b) `make request-codex-review` posted to closed/merged PRs without checking `.state` — now requires `state == OPEN`; (c) B-001's test pointer used a too-broad `grep -r 'code!' .` that would false-fail because CHANGELOG and Decision log retain historical mentions — narrowed to active gate-doc files only. |
| 1.5.0 | 2026-05-18 | §2.7 Codex invocation gains a **one-command shortcut**: the `request-codex-review` skill (`templates/.claude/skills/request-codex-review/SKILL.md`) and the matching `make request-codex-review` Makefile target. Both post the canonical PR-comment body that names `docs/pr_review_instructions.md` explicitly (load-bearing for Codex to use the project's rubric). Skill is async-and-done: posts one comment, confirms, stops; does not poll for results. Implements D-006 (this repo's `docs/spec.md`). |
| 1.4.0 | 2026-05-18 | §2.7 PR review reframed as **reviewer-agnostic**: same rubric + output contract for Codex / `/ultrareview` / other LLMs / manual. **Default reviewer: Codex** (cheap, independent, different model family). Adds reviewer matrix (cost / independence / when-to-use), Codex invocation steps (GitHub App install + PR-comment naming the rubric explicitly), and the "reviewers run serially, not in parallel" rule. `templates/docs/pr_review_instructions.md` gains a reviewer-agnostic preamble. `templates/CONTRIBUTING.md` §4 rewritten to match. The `review gogogo!` verb mapping intentionally unchanged — branch-owner triggers review out-of-session when the branch is finished. Implements D-005 (this repo's `docs/spec.md`). |
| 1.3.0 | 2026-05-17 | §2.1 gate rewrite: `gogogo!` is now the execute trigger only; it must be preceded by an action verb in the same message specifying *what* to execute. Adds verb→workflow table covering `code/feat/fix/... gogogo!` (full 5-step), `commit gogogo!`, `PR gogogo!`, `review gogogo!`, `merge gogogo!`, `deploy gogogo!`, `revert gogogo!`. Bare `gogogo!` is ambiguous and triggers a clarification question. §2.6 and §2.9 updated to reference the new explicit phrases. Same convention propagated to `templates/CLAUDE.md` and `templates/CONTRIBUTING.md` (cheat-sheet + TL;DR + gate section). Two new rationalizations added to the refuse-list. Implements D-004 (this repo's `docs/spec.md`). |
| 1.2.0 | 2026-05-17 | Rename gate passphrase `code!` → `gogogo!` (universal, stack-agnostic — not just for code edits). Add Karpathy's four LLM-coding pitfalls as standing rules in `templates/CLAUDE.md` and a full reference at `templates/docs/karpathy-claude-rules.md`. Add `spec-block` skill (`templates/.claude/skills/spec-block/SKILL.md`) plus a fixed Block format (`B-NNN` with Rule / Rationale / Test / Status / Decision) in `templates/docs/spec.md` to make the spec atomic and navigable. |
| 1.1.8 | 2026-05-07 | §11 + §2.7: explicit "Output contract" — every PR review must post per-commit GitHub comments via `gh api`, including a "no findings on `<sha>`" comment for clean commits. Local files, chat-only summaries, and PR-description edits are explicitly forbidden as substitutes. Closes the "was this commit reviewed and clean, or skipped by accident?" ambiguity in the prior wording. Template review skeleton (`templates/docs/pr_review_instructions.md`) and `templates/CONTRIBUTING.md` §4 carry the same contract. |
| 1.1.7 | 2026-05-07 | §14: `bootstrap.sh --export` on WSL also prints the Windows-translated path (via `wslpath`) so Windows-side tooling can pick the file up directly. macOS / native Linux unchanged — POSIX path is already the local path. |
| 1.1.6 | 2026-05-07 | §14: `bootstrap.sh` interactive menu gains `e` / `i` shortcuts for export/import (TUI parity with the `--export` / `--import` flags). |
| 1.1.5 | 2026-05-07 | §14 expanded: `bootstrap.sh` gains `--export [path]` and `--import <path>` for portable cred snapshots. Documents the migration flow (export → scp → import) as the primary cross-host credential transfer mechanism. |
| 1.1.4 | 2026-05-04 | §2.5 expanded with explicit "Commit message quality" subsection: bad/good subject examples, "explain the why in the body" rule, file/section-naming rule, `Refs #N` / `Implements D-NNN` references, no-fillers rule, the read-aloud-without-diff self-check, version-suffix requirement. |
| 1.1.3 | 2026-05-04 | §1.3 export-starter caveat: tar.gz always; .zip only if `zip` is installed (matches script's actual behavior on minimal Linux installs). |
| 1.1.2 | 2026-05-04 | Align workflow wording across all docs (Codex-audit fix): standardize merge path on `gh pr merge --rebase --delete-branch` (live `CONTRIBUTING.md` had stale `git merge --ff-only` in cheat-sheet, principles, TL;DR, §6); standardize 5-step step 2 wording on "bump versions + CHANGELOG entry" (TL;DR step 3 in `CONTRIBUTING.md` and §1.9 example commit message in this doc both said just "bump versions"). |
| 1.1.1 | 2026-05-04 | Add §1.3 "Quick path" pointing at `scripts/export-starter.sh` (one-command portable export of PROJECT_STARTER.md + templates/ as tar.gz + zip). |
| 1.1.0 | 2026-05-04 | Add §11 PR review heuristics, §12 Harness quirks, §13 Credential handling, §14 Bootstrap.sh design principles. Update §2.2 5-step to fold CHANGELOG entry into step 2 and Decision log entries into step 1. |
| 1.0.0 | 2026-05-04 | Initial extraction from phoenixtgstat_bot. Captures the `gogogo!` gate, 5-step workflow, push-every-commit, ff-only/rebase-merge strategy, multi-commit-per-branch, version-bump rule, branch protection setup, decision bank, audit-trail conventions, memory seed. |
