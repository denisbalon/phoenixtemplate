# phoenixprojecttemplate — spec

The product is a **template kit**: a reusable bootstrap for new software projects worked on with Claude Code. The deliverable is the contents of `templates/` plus `PROJECT_STARTER.md`, copied verbatim into each new project.

## Summary

Two surfaces:
1. **`PROJECT_STARTER.md`** — the authoritative process doc. ~1000 lines covering bootstrap checklist, the `gogogo!` gate, the 5-step workflow, file layout, decision bank, VPS deploy baseline, CI/CD baseline, audit trail, conventions, PR review heuristics, harness quirks, credential handling, `bootstrap.sh` design.
2. **`templates/`** — copy-paste-ready files (`README.md`, `CLAUDE.md`, `CONTRIBUTING.md`, `Makefile`, `.env.example`, `.gitignore`, `.python-version`, `.claude/`, `.github/`, `scripts/`, `docs/`). Customize placeholders (`<PROJECT_NAME>`, `<PACKAGE_NAME>`, `<HOST>`, etc.) per project.

The kit is currently Python+uv+FastAPI+VPS-shaped; making it stack-agnostic is an open item.

## Process & versioning

This repo follows its own published workflow. The `gogogo!` passphrase gate + 5-step atomic workflow (spec → bump+CHANGELOG → code → commit → deploy) is binding here too. Process rules live in `templates/CONTRIBUTING.md`. Current version lives in [`VERSION`](../VERSION) — single source of truth, never duplicated in prose. Per-version diary: [`CHANGELOG.md`](../CHANGELOG.md). The template version inside `PROJECT_STARTER.md` mirrors `VERSION` — they bump together.

## Frozen behavior

Binding behavior of this template kit, written as **Blocks**. Format defined in `templates/docs/spec.md`. Use the `spec-block` skill (`/spec-block`) when adding new ones.

### Block B-001: gate passphrase is `gogogo!`

**Rule:** No state-mutating action (Edit / Write / NotebookEdit, git commit/push, gh pr create/merge/comment, deploy) proceeds unless the user's current message contains the literal substring `gogogo!`.
**Rationale:** Universal authorization token, stack-agnostic, distinctive. Replaces the prior `code!` (too narrow — implied code-only). Renamed in v1.2.0.
**Test:** manual — read §2.1 of `PROJECT_STARTER.md`, the gate section at the top of `templates/CLAUDE.md`, and the gate sections of `templates/CONTRIBUTING.md` (cheat-sheet, TL;DR, hard-gate). All three name `gogogo!` as the active passphrase. Historical references to the prior `code!` passphrase in `CHANGELOG.md`, the Decision log, and template-changelog tables are intentional audit trail and do not violate the rule.
**Status:** frozen
**Decision:** —

### Block B-002: template version in `PROJECT_STARTER.md` mirrors repo `VERSION`

**Rule:** When `VERSION` is bumped, the `**Template version:**` line at the top of `PROJECT_STARTER.md` and its Template changelog table at the bottom are bumped in the same commit.
**Rationale:** Single source of truth. Two version numbers that drift apart are worse than one. The PROJECT_STARTER doc IS this project's primary artifact.
**Test:** manual — read `VERSION` and grep `Template version:` in PROJECT_STARTER.md; they match.
**Status:** frozen
**Decision:** —

### Block B-003: Karpathy's four pitfalls apply to every session

**Rule:** The four LLM-coding failure patterns (unexamined assumptions, overengineering, collateral changes, no verification) and their counter-rules are loaded into every Claude Code session via `templates/CLAUDE.md`'s standing-rules section.
**Rationale:** Auto-loading beats docs-folder rules because the latter only fire when someone reads them. Full reference at `templates/docs/karpathy-claude-rules.md` with attribution.
**Test:** manual — `templates/CLAUDE.md` contains the `## Coding pitfalls to avoid (Karpathy's four)` section.
**Status:** frozen
**Decision:** —

### Block B-004: spec is authored in Blocks, not bullet lists

**Rule:** `docs/spec.md` (both this repo's and every project bootstrapped from this template) uses the fixed `### Block B-NNN: <Title>` format with Rule / Rationale / Test / Status / Decision fields. New Blocks added via the `spec-block` skill (`/spec-block`).
**Rationale:** Atomic, numbered, addressable from PRs / decisions / tests. Avoids the wall-of-bullets drift that kills navigability as specs grow. Format frozen — don't invent new fields per block.
**Test:** manual — this very spec.md uses the format; `templates/docs/spec.md` documents it.
**Status:** frozen
**Decision:** —

### Block B-005: deploy step is a no-op for this repo

**Rule:** Step 5 of the `gogogo!` workflow (deploy) is a no-op for `phoenixprojecttemplate`. There is no deployable artifact; the "release" is `main` being up to date.
**Rationale:** This is a doc + scaffold kit, not a running service. Consumers pull updates by re-cloning or re-fetching templates manually.
**Test:** manual — no `make deploy`, no `scripts/deploy.sh` at this repo's root (only inside `templates/`).
**Status:** frozen
**Decision:** —

### Block B-009: `request-codex-review` skill runs `codex review --base main` locally

**Rule:** When the user asks Claude to send the current branch to Codex for review (or invokes `/request-codex-review`), Claude runs the `request-codex-review` skill at `templates/.claude/skills/request-codex-review/SKILL.md`. The skill verifies prereqs (`codex` CLI installed, current branch is not `main`, branch has commits ahead of `main`), runs `codex review --base main` synchronously, captures and surfaces the final review block to the user, and stops. Does NOT post to GitHub, does NOT auto-fix, does NOT mutate any state beyond the local CLI invocation. A `make request-codex-review` Makefile target wraps the same checks + invocation for terminal use outside Claude sessions.
**Rationale:** Codex is the project's default reviewer. The local CLI path matches the user's actual setup (codex installed locally; no GitHub App) and matches their established habit of running codex from the project folder. Synchronous output lets findings be triaged in the same session that ran the review. Supersedes B-008 (`gh pr comment @codex` → GitHub App), which targeted a path the user's account doesn't have.
**Test:** manual — `codex review --help` shows the `--base` flag; `make -C templates -n request-codex-review` dry-runs the new invocation cleanly (no `gh pr comment`).
**Status:** superseded by B-010 (v1.7.0). Reason: skill, Makefile target, and verb all removed; review is out-of-band and reviewer-agnostic — user runs any reviewer in a separate session per B-010.
**Decision:** D-007 (superseded by D-008)

### Block B-008: `request-codex-review` skill is the one-command Codex trigger

**Rule:** When the user asks Claude to send the current branch to Codex for review (or invokes `/request-codex-review`), Claude runs the `request-codex-review` skill at `templates/.claude/skills/request-codex-review/SKILL.md`. The skill posts a single PR comment via `gh pr comment` that explicitly names the rubric file (`docs/pr_review_instructions.md`), then stops. It does NOT poll for Codex's response, does NOT take any state-mutating action beyond the comment, and does NOT run mid-branch — only when the branch is finished and has an open PR. A `make request-codex-review` Makefile target wraps the same canonical body for terminal use outside Claude sessions.
**Rationale:** The user's manual ritual is open-Codex-locally → ask-it-to-look-around → ask-it-to-read-the-rubric → ask-it-to-review-the-PR. The skill collapses (b)+(c)+(d) into a single PR comment that Codex's GitHub App picks up. Naming the rubric file in the comment is load-bearing — the user's habit, and the way Codex reliably uses the project's conventions. Async-and-done (no polling) keeps the Claude session free to do other work; the user reads results on the PR page.
**Test:** manual — `ls templates/.claude/skills/request-codex-review/SKILL.md` exists; `grep -E '^request-codex-review:' templates/Makefile` finds the target.
**Status:** superseded by B-009 (v1.6.0). Reason: assumed a Codex GitHub App that doesn't exist on the user's account; pivoted to local CLI.
**Decision:** D-006 (superseded by D-007)

### Block B-007: PR review is reviewer-agnostic; Codex is the default

**Rule:** The rubric and output contract in `templates/docs/pr_review_instructions.md` apply to whichever reviewer runs (Codex, `/ultrareview`, another LLM, or manual human). **Codex is the default reviewer** via its GitHub App; `@codex review — follow docs/pr_review_instructions.md (Block / Strong / Nit, per-commit comments, "no findings" on clean commits, summary at end)` is the canonical invocation. Reviewers run serially — never in parallel.
**Rationale:** Independence beats deepening. A different model with fresh context catches what the original model missed. Codex is cheap, independent (different model family), and integrated into GitHub PRs natively. `/ultrareview` (still Claude under the hood) shares blind spots with the author and is billed; reserve for high-stakes second opinions. The output contract is reviewer-agnostic because the PR is the audit trail regardless of who wrote the comments.
**Test:** manual — `grep -A5 'Default reviewer' templates/CONTRIBUTING.md` shows Codex; `grep -i 'codex' templates/docs/pr_review_instructions.md` returns a match in the preamble.
**Status:** superseded by B-010 (v1.7.0). Reason: project no longer ships a default reviewer; the reviewer-agnostic principle survives but Codex-as-default and the GitHub-App invocation are removed.
**Decision:** D-005 (superseded by D-008)

### Block B-006: `gogogo!` must be preceded by an action verb

**Rule:** `gogogo!` is the execute trigger only. The action it executes is named by an **action verb** that must appear in the same message, immediately before `gogogo!`. Bare `gogogo!` (no verb) is ambiguous and triggers a clarification question, not an action. Recognized verbs and their workflows:

| Phrase | Action |
|---|---|
| `code gogogo!` · `feat gogogo!` · `fix gogogo!` · `chore gogogo!` · `docs gogogo!` · `refactor gogogo!` · `test gogogo!` · `perf gogogo!` · `ship gogogo!` | Full 5-step (spec → bump+CHANGELOG → code → commit+push → deploy) |
| `commit gogogo!` | Commit current work + push (still bumps version + CHANGELOG; skips deploy) |
| `PR gogogo!` · `ready gogogo!` · `open PR gogogo!` | Open pull request from current branch |
| `review gogogo!` | Run `/ultrareview` (or manual review) |
| `merge gogogo!` | `gh pr merge --rebase --delete-branch` |
| `deploy gogogo!` | Run the project's deploy command |
| `revert gogogo!` | Revert last commit + redeploy |

**Rationale:** Pairing `gogogo!` with a verb makes the gate explicit about *what* is being authorized, not just *that* something is. Avoids the failure mode where the agent picks a default action (open a PR, run a merge) on bare `gogogo!`. The verb is the contract; `gogogo!` is the signature.
**Test:** manual — `grep -A20 '2.1 The .gogogo' PROJECT_STARTER.md` shows the verb table; `grep 'gogogo!' templates/CLAUDE.md` shows the convention.
**Status:** superseded by B-011 (v1.7.0). Reason: `review gogogo!` row removed; with B-010 in force, the verb had no Claude-driven action left to gate.
**Decision:** D-004 (refined by D-008)

### Block B-010: PR review is out-of-band and reviewer-agnostic

**Rule:** PR review is a user-initiated action that runs in a separate session, not a Claude workflow step. The project ships no Claude-side reviewer trigger — no skill, no Makefile target, no verb, no reminder. `templates/docs/pr_review_instructions.md` is a reviewer-agnostic rubric and names no default reviewer. After `PR gogogo!`, the user opens whichever reviewer they prefer (Codex CLI, `/ultrareview`, another LLM, manual) in a separate terminal or session, points it at the open PR and the rubric, and the reviewer posts comments via `gh` (or its native PR integration) directly. Claude does not dispatch, prepare, remind about, or wrap any reviewer flow.
**Rationale:** Every prior attempt to wire Claude to a reviewer (B-007 Codex-via-GitHub-App default, B-008 PR-comment skill, B-009 local-CLI skill) was Claude doing a job the user was already doing better in a separate window. Reviewer choice is the user's; the same rubric works for all reviewers. Removing the wiring also resolves the [P1] Codex flagged on the v1.6.0 branch (the local-CLI skill couldn't satisfy the per-commit PR-comment contract because it ran stdout-only). With review out-of-band, whichever reviewer the user runs interactively can satisfy the contract directly — and the project stops claiming a contract it can't keep. Supersedes B-007, B-009.
**Test:** manual — `templates/docs/pr_review_instructions.md` preamble names no default reviewer; `templates/.claude/skills/` does not contain a `request-codex-review/` directory; `grep -E '^request-codex-review:' templates/Makefile` returns nothing.
**Status:** frozen
**Decision:** D-008

### Block B-011: action-verb table (no `review` verb)

**Rule:** The recognized action verbs that pair with `gogogo!` are: `code` · `feat` · `fix` · `chore` · `docs` · `refactor` · `test` · `perf` · `ship` (full 5-step); `commit` (commit + push, no deploy); `PR` · `ready` · `open PR` (open pull request); `merge` (`gh pr merge --rebase --delete-branch`); `deploy` (run project deploy); `revert` (revert last commit + redeploy). There is no `review gogogo!` verb — review is out-of-band per B-010, so the verb would gate nothing Claude does.
**Rationale:** A `gogogo!` verb authorizes a state-mutating action Claude takes. After B-010 made review fully user-side, `review gogogo!` had no Claude action left to authorize. Keeping the verb would either be a no-op or a misleading "Claude is preparing your review" reminder. Removing it keeps the verb table honest. Bare-`gogogo!` clarification prompt no longer offers `review` as a choice. Supersedes B-006.
**Test:** manual — `grep -nE '^\| \`review gogogo' templates/CLAUDE.md templates/CONTRIBUTING.md PROJECT_STARTER.md docs/spec.md` returns nothing on the active rule rows (historical mentions in superseded blocks / changelogs are intentional audit trail).
**Status:** frozen
**Decision:** D-008

## Decision log

One entry per architectural decision. Decisions live forever; chat history that produced them does not.

### D-001 (2026-05-17) Rename gate passphrase `code!` → `gogogo!`

**Chose:** `gogogo!` as the universal authorization token.
**Considered:** keep `code!` (narrow, code-only implication); `ship!` (overloaded with merge/deploy semantics); `go!` (too short, false-positive risk in normal English).
**Why:** The gate authorizes *any* state-mutating action — code edits, commits, deploys, PR ops. `code!` implied a code-only scope and was the wrong word for the broader contract. `gogogo!` is distinctive, energetic, and rare enough in normal conversation to be a reliable literal-substring check.
**Implemented in:** v1.2.0 (this repo).

### D-002 (2026-05-17) Adopt Block format for `docs/spec.md`

**Chose:** Fixed `B-NNN` block format with five named fields (Rule / Rationale / Test / Status / Decision).
**Considered:** (a) keep bullet-list frozen rules (current template), (b) free-form prose sections, (c) the Block format.
**Why:** Bullet lists drift into walls of text as specs grow. Free-form prose isn't addressable from PRs or tests. Blocks are atomic, numbered, and link directly to a verifying test and (optionally) a Decision-log entry. Authored via the `spec-block` skill so the format stays consistent across contributors and sessions.
**Implemented in:** v1.2.0 (this repo + `templates/docs/spec.md`).

### D-003 (2026-05-17) Adopt Karpathy's four pitfalls in CLAUDE.md (not just docs/)

**Chose:** Fold the four rules into `templates/CLAUDE.md`'s standing rules; full reference doc at `templates/docs/karpathy-claude-rules.md`.
**Considered:** (a) doc-only (in `docs/`), (b) standing rules only (in `CLAUDE.md`), (c) both.
**Why:** Doc-only loses because docs only apply when someone reads them. Rules-only loses the audit trail and the why. Both gets the auto-load benefit (rules apply every session) AND the reference (full text + attribution + how-it-fits when needed).
**Implemented in:** v1.2.0.

### D-009 (2026-05-18) Product identity: Python/uv/FastAPI/VPS starter now; multi-preset later as roadmap

**Chose:** Declare `phoenixprojecttemplate` a **Python/uv/FastAPI/VPS-shaped starter** in its current form. The bootstrap process, `gogogo!` gate convention, 5-step workflow, spec-block format, Karpathy standing rules, and reviewer-agnostic PR-review rubric are stack-agnostic and apply to any project. The language-preset scaffolding (`Makefile`, CI workflow, `scripts/deploy.sh`, `templates/.env.example` validators) is Python-only today. Multi-preset support (Node/pnpm, Go, no-runtime) is **roadmap**, not current fact.
**Considered:** (a) ship Python-only and frame the repo accurately as a Python starter now (this option); (b) build multi-preset support (`templates/_common/` + `presets/python-uv/`, `presets/node-pnpm/`, etc.) *before* the next release so the agnostic claim becomes true; (c) keep claiming "project-agnostic" everywhere and hope the gap doesn't bite consumers.
**Why:** (a) is the honest near-term framing. Codex's improvement plan flagged the gap directly: top-level docs say "project-agnostic" but `templates/Makefile` invokes `uv run uvicorn`, CI assumes `pyproject.toml` and `src/<package>/`, and `scripts/deploy.sh` is VPS-shaped. (b) is the right long-term direction but is multi-week work — building presets before declaring identity puts a strategic decision on the critical path of weeks of scaffolding. (c) is the status quo and is dishonest by construction. The reframe is one commit; multi-preset can land later when the architecture is designed (see open item: "Stack-agnostic restructure — roadmap per D-009"). Until then, "Python/uv/FastAPI/VPS starter" matches what consumers actually get.
**Implemented in:** v1.8.0. Triggered by Codex's improvement-plan review (`codex improvement plan.md`) flagging the agnostic/Python mismatch as Phase 2 + Phase 12 work. Reframes PROJECT_STARTER.md top section + adds a Current Scope subsection. Does not change templates or shipped code — only the framing.

### D-008 (2026-05-18) Remove all Claude-side reviewer wiring; review is out-of-band and reviewer-agnostic

**Chose:** Delete the `request-codex-review` skill, the `make request-codex-review` Makefile target, and the `review gogogo!` verb. Rewrite `templates/docs/pr_review_instructions.md` as a reviewer-agnostic rubric that names no default reviewer. After `PR gogogo!`, the user opens any reviewer they prefer in a separate session, points it at the open PR and the rubric, and the reviewer posts comments via `gh` directly. Claude is out of the review business entirely.
**Considered:** (a) keep the v1.6.0 local-CLI skill and add a posting step so it satisfies the per-commit-comment contract; (b) switch to an interactive Codex TUI launcher (Makefile + reminder skill that prints the command in Claude); (c) remove all Claude-side wiring and make review fully out-of-band, reviewer-agnostic (this option).
**Why:** (a) keeps Claude in the reviewer-dispatch business and continues the pattern of assuming a specific external tool (Codex CLI, GitHub App) is the canonical path. (b) was the planned v1.7.0 path until the user explicitly rejected it — "no make, no nothing. I go to different terminal, start codex, ask him to look around and look at pr review instructions, then review latest pr" — followed by "instructions should be agnostic to reviewer." (c) is the honest scope: Claude opens the PR (`PR gogogo!`); review is whatever the user does in a separate terminal with any reviewer they prefer. The rubric stays because it's reviewer-agnostic — but the wiring and the verb both go. Resolves the [P1] Codex flagged on the v1.6.0 branch by removing the contradiction (Claude no longer claims a per-commit-comment contract it can't satisfy from a stdout-only skill). Supersedes D-005 (Codex-as-default) and D-007 (local-CLI skill); D-006 was already superseded by D-007 in v1.6.0, retained as audit trail.
**Implemented in:** v1.7.0. Triggered by user feedback that v1.6.0's skill — and the v1.7.0 launcher I'd planned in its place — were both Claude-side wiring for a user-side action. The rubric file is the only artifact the project needs to ship; the reviewer is whoever the user runs.

### D-007 (2026-05-18) Pivot `request-codex-review` from GitHub App to local CLI

**Status:** Superseded by D-008 on 2026-05-18 (same day). The whole `request-codex-review` skill + Makefile target it shipped was removed in v1.7.0; review is now out-of-band and the project ships no reviewer wiring at all. The "local CLI works and finds real issues" finding still stands — it's just no longer relevant to what the project ships, because the project ships no invocation path for any reviewer.

**Chose:** Reimplement the `request-codex-review` skill + Makefile target around `codex review --base main` (local CLI). Drop the GitHub-App-comment path as the default; document it as a fallback that only applies if the user installs a Codex App later.
**Considered:** (a) keep the GitHub App skill (B-008) and add a parallel CLI skill, (b) supersede B-008 entirely with the CLI path, (c) build a `codex exec` wrapper instead of `codex review` so we can pass our exact rubric.
**Why:** (a) leaves an inert skill that can't fire on this user's account — confusing for future readers. (b) is honest: the user doesn't have an App, codex IS installed locally, and the CLI has a purpose-built `review` subcommand that found three real bugs on its first run (the v1.5.0 → v1.5.1 patch). (c) is a real option for strict rubric compliance but adds complexity; `codex review`'s built-in `P1/P2/P3` format maps cleanly to our `Block/Strong/Nit` and is good enough for the default path. (c) stays documented as the escape hatch when rubric compliance matters.
**Implemented in:** v1.6.0. Triggered by discovering (via a read-only `gh api` probe) that no Codex GitHub App is installed on the user's account, plus the v1.5.0-branch dry run that proved `codex review --base main` works and finds real issues.

### D-006 (2026-05-18) One-command Codex trigger via PR-comment skill (not local CLI) — SUPERSEDED

**Status:** Superseded by D-007 on 2026-05-18 (same day). The premise — that a Codex GitHub App existed on the user's account to pick up `@codex` PR comments — turned out to be wrong; no App is installed. The local CLI has a purpose-built `codex review` subcommand the original analysis missed. D-007 captures the corrected design.

**Chose:** Build a `request-codex-review` skill + `make request-codex-review` Makefile target that post a canonical PR comment via `gh pr comment` (Path 1 + Path 3 from the design discussion). The GitHub App picks up the comment and Codex posts findings back to the PR.
**Considered:** (a) just use `gh pr comment` manually each time (status quo), (b) wrap the local Codex CLI (`codex --prompt "review PR #N ..."`) so reviews run synchronously in the same terminal, (c) skill + Makefile wrapper around `gh pr comment` (this option), (d) full background-agent dispatch with polling.
**Why:** (a) loses the canonical comment body — easy to forget naming the rubric file, which is load-bearing for Codex behavior. (b) duplicates the GitHub App for no added value: same Codex, but burns the user's OpenAI quota, serializes work in the local terminal, and adds setup overhead. (d) over-engineers an async workflow the user has explicitly said they prefer fire-and-check. (c) is minimal: zero new deps, matches the user's existing habit of triggering Codex out-of-session, makes the rubric reference mechanically guaranteed.

**Why it was wrong:** my framing of option (b) was incorrect — I called it "duplicates the GitHub App for no added value" without checking whether the App actually existed on the user's account (it doesn't) or what the local CLI's capabilities were (it has `codex review --base <branch>` purpose-built for exactly this). Both were knowable from a 30-second probe. See D-007.

**Implemented in:** v1.5.0. Reverted in v1.6.0 per D-007.

### D-005 (2026-05-18) Codex as default PR reviewer; rubric is reviewer-agnostic

**Status:** Superseded by D-008 (v1.7.0). The reviewer-agnostic principle survives in B-010; the Codex-as-default and GitHub-App-invocation parts are removed — project no longer specifies a default reviewer.

**Chose:** Make `templates/docs/pr_review_instructions.md` reviewer-agnostic (preamble names Codex / `/ultrareview` / other LLMs / manual as equally valid paths against the same rubric). Default reviewer is **Codex**, invoked via the GitHub App with a comment that explicitly references the rubric file. Reviewers run serially.
**Considered:** (a) keep `/ultrareview` as Path A / manual as Path B (current state — reviewer-locked), (b) Codex-default + rubric stays universal, (c) multi-reviewer in parallel (Codex + `/ultrareview` both run), (d) expand the `review gogogo!` verb to take a reviewer flavor.
**Why:** (a) privileges a Claude-family reviewer that shares the author's blind spots. (c) wastes budget for typical PRs; the user does manual review separately when a branch is finished, so parallel automation is redundant. (d) was explicitly rejected by the user — review is done out-of-session against a finished branch, not dispatched mid-branch from Claude. (b) wins: same rubric, cheaper + independent reviewer by default, no verb-mapping churn.
**Implemented in:** v1.4.0.

### D-004 (2026-05-17) `gogogo!` requires an action-verb prefix

**Chose:** Treat `gogogo!` as the execute trigger only; require an action verb immediately before it specifying *what* to execute. Bare `gogogo!` triggers a clarification question.
**Considered:** (a) keep `gogogo!` as bare authorization that defaults to the 5-step code workflow, (b) require an explicit verb, (c) hybrid — bare allowed with implicit default.
**Why:** (a) opens a failure mode where the agent picks the wrong workflow on ambiguous bare `gogogo!` (e.g. opening a PR when the user meant "commit current work"). (c) is (a) with extra steps — the implicit default is still implicit. (b) makes the contract explicit: one verb per action, no defaults. Trades one extra word of typing for zero ambiguity at the gate. Verb table includes `PR`, `merge`, `deploy`, `commit`, `review`, `revert`, plus the conventional commit types (`feat/fix/chore/docs/refactor/test/perf`) that map to the full 5-step.
**Implemented in:** v1.3.0.

## Open project-level decisions

Resolve as they come up. Move resolved entries to the Decision log above.

- [ ] **De-personalize the template.** `bootstrap.sh` hardcodes `phoenixtgstat_bot` in its menu header and bakes in Telegram/Meta/Keitaro VALIDATORS. Should be derived from the consuming project, not hardcoded. (PROJECT_STARTER.md item A1–A3)
- [ ] **Stack-agnostic restructure** — *roadmap per D-009.* Today the templates assume Python+uv+FastAPI+VPS. Multi-preset support (`templates/_common/` + `presets/python-uv/`, `presets/node-pnpm/`, `presets/go/`, `presets/none/`) is deferred to a later release. Until shipped, this repo is honestly framed as a Python/uv/FastAPI/VPS starter. (Item C10–C12)
- [ ] **One-shot project bootstrap script.** `scripts/new-project.sh <slug> <package>` doing §1.1–§1.10 of PROJECT_STARTER.md in a single command — including `gh repo create`, branch protection via `gh api`, merge settings via `gh api`. (Item D13)
- [ ] **Build the missing `scripts/export-starter.sh`.** Referenced in §1.3 but never shipped. Keep for offline-transfer use case. (Item B4)
- [ ] **Implement `bootstrap.sh --export` / `--import` / `e` / `i` / WSL `wslpath` translation.** Documented in PROJECT_STARTER.md §14 but the script doesn't have them. (Item B5)
- [ ] **Add language-preset skeletons.** Missing `pyproject.toml`, `src/<package>/`, `tests/`, `LICENSE`. CI assumes they exist. (Item B6–B9)
- [ ] **Split PROJECT_STARTER.md** into focused docs (`BOOTSTRAP.md`, `WORKFLOW.md`, `CONVENTIONS.md`, `HARNESS_QUIRKS.md`) with PROJECT_STARTER.md as the index. ~1000 lines is hard to navigate. (Item F22)
- [ ] **Decide PROJECT_STARTER.md role in cloned projects.** Snapshot-at-bootstrap (current — drifts) vs. thin pointer + version reference (won't drift). (Item F23)
