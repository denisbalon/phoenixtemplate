# Changelog

All notable changes per `VERSION` bump. Per the `gogogo!` 5-step workflow, every change bumps `VERSION` and adds an entry here in the same commit.

Format: `## v<X.Y.Z> — YYYY-MM-DD` followed by bullets, optionally grouped by area.

---

## v1.7.1 — 2026-05-18

Mirrors `PROJECT_STARTER.md` template v1.7.1. Patch — three doc-consistency fixes surfaced by Codex's review of PR #1 (the first real exercise of the v1.7.0 reviewer-agnostic flow, dogfooded on this very branch).

### Fixes

- **`templates/docs/pr_review_instructions.md` hardcoded `gh api` as the only transport.** The output-contract section said "posted via `gh api`" and gave `gh api -X POST` as the only examples, but `PROJECT_STARTER.md §11`, `templates/CONTRIBUTING.md §4`, and the canonical rule in B-010 all describe two paths (gh + native PR integration). Updated the rubric file to match: posted via `gh api` (or the reviewer's native PR-comment integration), with the `gh api` commands re-framed as concrete examples for that path rather than the only valid mechanism. (Codex Block on commit `0e4bcf3` — finding still surviving in the v1.7.0 final state.)
- **`templates/CONTRIBUTING.md §4` allowed a third transport path B-010 doesn't sanction.** v1.7.0 added "or by the user copy-pasting" to the contract phrasing — but B-010 freezes the path as "the reviewer posts comments via `gh` (or its native PR integration) directly." Copy-paste isn't on the sanctioned list; removed. Three doc sources now describe the transport identically. (Codex Block on commit `bbe9013`.)
- **Self-review rubric path was ambiguous on this meta-repo.** `PROJECT_STARTER.md §2.7` tells reviewers to "point it at `docs/pr_review_instructions.md`" — works for consuming projects (where the template gets copied into `docs/`), but this repo ships the rubric only at `templates/docs/pr_review_instructions.md`. Added a one-line pointer file at `docs/pr_review_instructions.md` (repo root) so the self-review path resolves correctly without duplicating content. (Codex Strong on commit `bbe9013`.)

### Process win

Second end-to-end test of the local Codex CLI review path — this time against the v1.7.0 branch with the reviewer-agnostic flow live. Codex posted 7 per-commit comments (clean commits explicitly tagged "No findings on `<sha>`") + 1 overall summary, exactly per the contract `docs/pr_review_instructions.md` mandates. Found three real inconsistencies on the first run — same pattern as the v1.5.0 → v1.5.1 cycle. The flow works.

## v1.7.0 — 2026-05-18

Mirrors `PROJECT_STARTER.md` template v1.7.0.

### Pivot: PR review is out-of-band and reviewer-agnostic

The v1.6.0 local-CLI skill resolved the GitHub-App-doesn't-exist problem but kept Claude in the reviewer-dispatch business — and Codex's own review of that branch flagged the contradiction at [P1]: the skill ran stdout-only, so it couldn't satisfy the per-commit PR-comment contract `templates/docs/pr_review_instructions.md` requires. Plan to switch to an interactive-TUI launcher was rejected by user feedback as more overcomplication of a user-side action ("no make, no nothing. I go to different terminal, start codex …", then "instructions should be agnostic to reviewer").

This release removes all Claude-side reviewer wiring. Claude opens the PR on `PR gogogo!`; everything after that is the user's job in a separate session with any reviewer they prefer.

- **`templates/.claude/skills/request-codex-review/SKILL.md`** deleted (skill removed entirely; parent directory removed).
- **`templates/Makefile`** — `request-codex-review` target, its `.PHONY` entry, and its help comment all removed.
- **`review gogogo!` verb removed everywhere** — `templates/CLAUDE.md` verb table, `templates/CONTRIBUTING.md` verb table + cheat-sheet + TL;DR, `PROJECT_STARTER.md` §2.1 verb table, `docs/spec.md` verb table (inside the now-superseded B-006). Bare-`gogogo!` clarification prompt no longer offers `review` as a choice.
- **`templates/docs/pr_review_instructions.md` preamble rewritten** — no default reviewer named; rubric is presented as the file any reviewer reads (Codex, `/ultrareview`, another LLM, manual). Output contract preserved verbatim — it's reviewer-agnostic, and whichever reviewer the user runs interactively can now satisfy it directly.
- **`templates/CONTRIBUTING.md` §4** rewritten as a short paragraph: review is out-of-band; user runs any reviewer in a separate session against `docs/pr_review_instructions.md` and the open PR. Reviewer matrix, Codex install/invocation steps, GitHub-App fallback all removed.
- **`PROJECT_STARTER.md` §2.7 + §11** rewritten the same way. §11 retains the rubric and output contract (reviewer-agnostic) but drops the `/ultrareview`-vs-Codex framing.

### Spec changes

- **B-007** (Codex-as-default) flipped to `superseded` by B-010. Reviewer-agnostic principle survives in B-010; Codex-as-default and the GitHub-App invocation are removed.
- **B-009** (`codex review --base main` skill) flipped to `superseded` by B-010. Skill + Makefile target + verb all removed.
- **B-006** (verb table with `review gogogo!`) flipped to `superseded` by B-011.
- **B-010** added: PR review is out-of-band and reviewer-agnostic. Project provides no Claude-side reviewer trigger.
- **B-011** added: verb table without `review`. The verb gated nothing Claude does after B-010.
- **D-005** (Codex-as-default) flipped to `superseded` by D-008. Reviewer-agnostic survives in B-010; default-reviewer specification is removed.
- **D-007** (local-CLI skill pivot) flipped to `superseded` by D-008. The whole skill was removed; the "local CLI works" finding still stands but is no longer relevant to what the project ships.
- **D-008** added: captures the rationale for removing all Claude-side reviewer wiring.

## v1.6.0 — 2026-05-18

Mirrors `PROJECT_STARTER.md` template v1.6.0.

### Pivot: `request-codex-review` uses local CLI, not GitHub App

The v1.5.0 skill posted `@codex review` PR comments expecting a Codex GitHub App to pick them up. A read-only probe confirmed the user has **no Apps installed** on their GitHub account — so the skill targeted nothing. The local `codex` CLI is installed (v0.130.0) and has a purpose-built `codex review --base <branch>` subcommand. A dry run against the v1.5.0 branch found three real bugs (fixed in v1.5.1).

This release pivots the skill + Makefile target to use the CLI path that actually works on the user's setup.

- **`templates/.claude/skills/request-codex-review/SKILL.md`** rewritten: verifies prereqs (CLI installed, branch ahead of main), runs `codex review --base main`, surfaces findings, stops. Synchronous. No GitHub interaction.
- **`templates/Makefile` `request-codex-review` target** rewritten: same prereq checks + CLI invocation. Dropped `gh pr comment` / `jq` / PR-state machinery.
- **`PROJECT_STARTER.md` §2.7** and **`templates/CONTRIBUTING.md` §4** updated: Codex invocation procedure now describes the CLI flow. Output-format note: Codex CLI uses `[P1] / [P2] / [P3]`, not `Block / Strong / Nit` — the `--base` flag is mutually exclusive with custom prompts. P1≈Block, P2≈Strong, P3≈Nit when triaging. `codex exec` remains the escape hatch for strict rubric compliance.
- **GitHub App path** is documented as a fallback that only applies if the user ever installs a Codex App. Not the default.

### Spec changes

- **B-008** flipped to `superseded` by B-009 (the rule survives — Codex is the default reviewer — only the mechanism changed).
- **B-009** added: `codex review --base main` is the canonical invocation.
- **D-006** flipped to `superseded` by D-007 with an honest "why it was wrong" note (the original framing called local-CLI "duplicates the GitHub App" without checking whether the App existed or what the CLI could do — both were knowable in 30 seconds).
- **D-007** added: captures the pivot rationale.

## v1.5.1 — 2026-05-18

Mirrors `PROJECT_STARTER.md` template v1.5.1. Patch — three bug fixes surfaced by a Codex CLI review of the v1.5.0 branch (`codex review --base main`).

### Fixes

- **`docs/spec.md:15` version drift.** The prose hardcoded `Current version: 1.2.0` even after VERSION bumps to 1.3/1.4/1.5. Replaced with a pure reference: *"Current version lives in `VERSION` — single source of truth, never duplicated in prose."* Eliminates drift by construction. (Codex P2)
- **`templates/Makefile` `request-codex-review` posted to closed/merged PRs.** The target only queried `.number` from `gh pr view`, so a stale PR resolved cleanly and the command claimed success. Now queries `.number,.state`, requires `state == OPEN`, errors with the actual state otherwise. Matches the guardrail the SKILL.md already documented. (Codex P2)
- **`docs/spec.md` B-001 test pointer wrong.** Said `grep -r 'code!' .` should return 0 — but `CHANGELOG.md` and the Decision log contain historical `code!` references. Updated to grep only the active gate-documentation files (`PROJECT_STARTER.md`, `templates/CLAUDE.md`, `templates/CONTRIBUTING.md`, `templates/docs/spec.md`, `templates/README.md`) and note that audit-trail mentions are intentional. (Codex P3)

### Process win

First end-to-end test of the local Codex CLI review path (the actual one, after v1.5.0's GitHub-App path turned out to target nothing because no App is installed on this account). Found three real bugs on the first run. v1.6.0 will pivot the skill + Makefile target to use `codex review --base main` directly.

## v1.5.0 — 2026-05-18

Mirrors `PROJECT_STARTER.md` template v1.5.0.

### Codex review automation

- Add `templates/.claude/skills/request-codex-review/SKILL.md` — one-command path to trigger Codex review of the current branch's PR. Detects PR number via `gh pr view`, composes a canonical invocation comment that names `docs/pr_review_instructions.md` explicitly (so Codex reads the rubric), posts via `gh pr comment`, confirms, stops. Does NOT poll for results — Codex posts back to the PR async.
- Add `make request-codex-review` Makefile target — wraps the same canonical comment for one-shot terminal invocation outside Claude sessions.
- Documents the re-review pattern (post a second comment naming "addressed prior findings, N new commits") and the no-mid-branch / no-state-mutation-beyond-comment guardrails.

Implements D-006. Adds B-008.

## v1.4.0 — 2026-05-18

Mirrors `PROJECT_STARTER.md` template v1.4.0.

### PR review (reviewer-agnostic + Codex default)

- Reframe `templates/docs/pr_review_instructions.md` with a reviewer-agnostic preamble: rubric + output contract apply to any reviewer (Codex, `/ultrareview`, other LLMs, manual). Independence beats deepening — a different model with fresh context catches what the original missed.
- Rewrite `PROJECT_STARTER.md` §2.7 and `templates/CONTRIBUTING.md` §4: introduce a reviewer matrix (Codex / `/ultrareview` / other LLM / manual) with cost/independence trade-offs. **Default: Codex** via its GitHub App.
- Codex invocation subsection: install GitHub App (one-time); PR comment names the rubric explicitly (`@codex review — follow docs/pr_review_instructions.md ...`); reviewers run serially, not in parallel.
- Output contract preserved verbatim and made universal: per-commit comments via `gh api` (or reviewer's native PR-comment integration), explicit "no findings on `<sha>`" on clean commits, severity-grouped summary at end.
- The `review gogogo!` verb mapping intentionally unchanged — user does PR review separately when the branch is finished; no in-session reviewer dispatch needed.

Implements D-005. Adds B-007.

## v1.3.0 — 2026-05-17

Mirrors `PROJECT_STARTER.md` template v1.3.0.

### Gate convention

- `gogogo!` is now the **execute trigger**; it must be preceded by an **action verb** in the same message specifying *what* to execute. Bare `gogogo!` (no verb) is ambiguous — Claude asks "Which action?" and stops. (`PROJECT_STARTER.md` §2.1, `templates/CLAUDE.md`, `templates/CONTRIBUTING.md`)
- New verb → workflow table covers: `code/feat/fix/... gogogo!` (full 5-step), `commit gogogo!`, `PR gogogo!`, `review gogogo!`, `merge gogogo!`, `deploy gogogo!`, `revert gogogo!`.
- §2.6 (PR) and §2.9 (merge) updated to reference the new explicit phrases (`PR gogogo!`, `merge gogogo!`) instead of bare imperatives.
- Cheat-sheet and TL;DR in `templates/CONTRIBUTING.md` updated to match.
- Two new rationalizations added to the refuse-list: "bare `gogogo!` → default to 5-step" and "verb-A `gogogo!` is close enough to authorize action B".

Implements D-004 (`docs/spec.md`). Adds B-006.

## v1.2.0 — 2026-05-17

Mirrors `PROJECT_STARTER.md` template v1.2.0. First release of this repo as a standalone template kit; previously imported as `project-starter-v1.1.8-2026-05-07.tar.gz`.

### Gate

- Rename the work-authorization passphrase `code!` → `gogogo!` across all template files. Universal across stacks and action types, not just code edits. (PROJECT_STARTER.md §2.1, templates/CLAUDE.md, templates/CONTRIBUTING.md, templates/docs/spec.md, templates/CHANGELOG.md, templates/README.md, ~50 sites)
- Memory-seed file rename: `code_gate_workflow.md` → `gogogo_gate_workflow.md` (PROJECT_STARTER.md §10)

### Karpathy's four pitfalls

- Add `templates/docs/karpathy-claude-rules.md` — full write-up of the four LLM-coding failure modes (unexamined assumptions, overengineering, collateral changes, no verification) with counter-rules, attribution, and how they fit the 5-step workflow.
- Add a condensed `## Coding pitfalls to avoid (Karpathy's four)` section in `templates/CLAUDE.md` so the rules load every session, not just when someone reads `docs/`.
- Link the new doc from `templates/README.md`'s doc table.

### Spec-blocks

- Add `templates/.claude/skills/spec-block/SKILL.md` — interactive skill that walks through writing one Block at a time (Title / Rule / Rationale / Test / Status / Decision), finds the next free `B-NNN`, and inserts in `docs/spec.md` without committing.
- Replace the placeholder bullet-list `## Frozen behavior` in `templates/docs/spec.md` with the fixed Block format + editing rules + a seed `B-001` placeholder.

### This repo

- Adopt the workflow on this repo: add `VERSION`, `CHANGELOG.md`, and `docs/spec.md` (written in the new Block format — eating our own dog food).

## v0.1.0 — 2026-05-17 (implicit)

Initial import of `project-starter-v1.1.8-2026-05-07.tar.gz` to `main` as a single commit (no VERSION file at the time). v1.2.0 is the first release with the workflow fully applied to this repo.
