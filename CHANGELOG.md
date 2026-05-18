# Changelog

All notable changes per `VERSION` bump. Per the `gogogo!` 5-step workflow, every change bumps `VERSION` and adds an entry here in the same commit.

Format: `## v<X.Y.Z> — YYYY-MM-DD` followed by bullets, optionally grouped by area.

---

## v1.12.0 — 2026-05-18

Mirrors `PROJECT_STARTER.md` template v1.12.0.

### Strip vendor validators from `bootstrap.sh` core; ship `validators.sh` sidecar

Codex improvement-plan Phase 1.2 — second item of Package B / Phase 1 (de-personalize). `templates/scripts/bootstrap.sh` previously hardcoded eight validators in its `VALIDATORS` associative array, six of which were vendor-specific bake-ins from the source project: `TELEGRAM_BOT_TOKEN`, `TELEGRAM_WEBHOOK_SECRET`, `TELEGRAM_CHANNEL_ID`, `META_DEFAULT_PIXEL_ID`, `META_CAPI_TOKEN`, `KEITARO_POSTBACK_BASE`, `KEITARO_POSTBACK_KEY`, plus an application-shaped `WEBHOOK_BASE_URL`. A generic template that knows about Telegram tokens by default isn't actually generic — Codex Phase 1.2's acceptance criterion: "Project-specific validators live in a deliberate, documented layer."

**Approach (Option A from the design menu, plus the required extension point):** strip all vendor-specific entries from the core; ship a sourced sidecar at `templates/scripts/validators.sh` as the deliberate extension point.

- **`templates/scripts/bootstrap.sh` `VALIDATORS` array** now contains only `LOG_LEVEL` (log-level enum) and `DEV_MODE` (boolean) — both truly generic across any project.
- **`templates/scripts/validators.sh`** (new, ships as skeleton): consumers add their own project-specific validators here. The file is sourced from inside `bootstrap.sh`'s scope, so `VALIDATORS[FOO]='regex'` Just Works without modifying core. Ships with an explanatory header + commented-out example entries (`TELEGRAM_BOT_TOKEN`, `STRIPE_API_KEY`, `DATABASE_URL`) for guidance, plus an intentionally-empty active section. Consumers uncomment what applies to their project or add their own.
- **`templates/scripts/bootstrap.sh`** now `source`s `$ROOT/scripts/validators.sh` if it exists, immediately after declaring the generic `VALIDATORS` array. Sidecar mutations take effect for the rest of the script run.

**Breaking change.** Any consumer who relied on the hardcoded TELEGRAM/META/KEITARO validators will see them disappear; their `validators.sh` skeleton has the same patterns commented out — uncomment to restore. Compliant with the v1.8.0 product-identity decision (D-009): we're a Python/uv/FastAPI/VPS starter; vendor-specific validators were the wrong default.

### Spec

- **B-018** added: bootstrap.sh validators — generic core + project-specific sidecar. Frozen. Names the file, the sourcing mechanism, the contents of each layer.
- **Open project-level decisions** — de-personalize item updated: validators sub-item resolved; doc-residue audit (Codex Phase 1.3) still pending.

## v1.11.2 — 2026-05-18

Mirrors `PROJECT_STARTER.md` template v1.11.2. Patch — first item of Package B / Codex Phase 1 (de-personalize). Removes the most visible source-project leftover in the generic template.

### Fix

- **`templates/scripts/bootstrap.sh:200` menu header hardcoded `phoenixtgstat_bot`.** A consumer running the script saw the source-project's name in the credential-setup banner. Replaced with a derived value: `PROJECT_NAME=$(basename "$ROOT")` near the top of the script; menu header now reads `"  $PROJECT_NAME — credential setup"`. The header now correctly shows the consumer's actual project directory name.

### Spec

- **B-017** added: generic `templates/scripts/*` derive project context from `basename "$ROOT"` / env / placeholder; never hardcode source-project names. Frozen. Future C4 consistency linter (Codex Phase 5.3) makes this testable automatically. Audit-trail mentions of the source project's name in `CHANGELOG.md` / `PROJECT_STARTER.md` template-changelog are intentional provenance — excluded from the rule.
- **Open project-level decisions** — de-personalize item split into two sub-items: menu-header (resolved in this commit) + service-specific validators (Telegram/Meta/Keitaro regexes, still hardcoded — needs a design call before Phase 1.2 work begins).

## v1.11.1 — 2026-05-18

Mirrors `PROJECT_STARTER.md` template v1.11.1. Patch — A5 audit (Codex Phase 1.4) of every command / file path / filename mentioned across `PROJECT_STARTER.md`, `templates/README.md`, `templates/CONTRIBUTING.md`, `templates/CLAUDE.md`, `templates/docs/*.md` against the shipped tree.

### Audit findings

Surprisingly thin — most drift had already been caught by v1.7.1 (rubric-path fix), v1.9.0–v1.11.0 (shipping the missing preset + export-starter + smoke test which catches runtime breakage automatically). The systematic sweep surfaced **one real gap**, plus two items that belong to other packages.

### Real gap fixed

- **Missing `uv lock` step in PROJECT_STARTER §1 bootstrap.** CI (`templates/.github/workflows/ci.yml`, three jobs) and deploy (`templates/scripts/deploy.sh`) both use `uv sync --frozen`, which requires `uv.lock` to exist in the consumer's repo. But §1 never told the consumer to generate one. First push to a fresh repo → CI failure with "no lockfile" error. Fix: added a final sub-step to PROJECT_STARTER §1.3 (immediately after the placeholder-substitution paragraph): `uv lock && git add uv.lock` so the first commit includes a real lockfile. Placement matters — must happen AFTER substitution (otherwise the lockfile bakes in `<package_name>`) and BEFORE the first commit (so CI's `--frozen` succeeds on the very first push).

### Not gaps (verified intentional)

- All `request-codex-review` mentions are in the PROJECT_STARTER template-changelog table for v1.5.0/v1.5.1/v1.6.0 — historical audit trail per the supersede pattern, intentional.
- `docs/SPEC` in two rationalization tables (`templates/CONTRIBUTING.md`, `PROJECT_STARTER.md`) is informal English ("It's just a docs/SPEC tweak"), not a path.
- Memory-seed filenames (`architecture_decisions.md`, `gogogo_gate_workflow.md`, etc.) are prescriptive recommendations for the user's local `.claude/memory/` dir, not paths to shipped files.
- `findings.txt`, `review.md`, `Cargo.toml`, `package.json` are explicit illustrative examples (negative-example list / non-Python stack pointers).
- All `templates/scripts/*`, `templates/docs/*`, `templates/.claude/skills/spec-block/SKILL.md` paths resolve to shipped files.

### Deferred to other packages

- **`denisbalon/$PROJECT_SLUG` hardcoded** in PROJECT_STARTER §1.5 + §1.6 (3 places). Real personalization gap; belongs to Package B (Codex Phase 3 / open item #1 de-personalize).
- **`<package_name>` requires manual `mv` + `sed` substitution** until `scripts/bootstrap.sh` automates it. Belongs to Package B (bootstrap-substitution piece that pairs with B1/B2).

### Spec

- **B-016** added: invariant — every live doc reference resolves to a shipped file or is an explicit example. Frozen. Test is manual today; the future C2 doc-reference linter (Codex Phase 8.2) automates it. Smoke test (B-014) already catches the runtime subset of this invariant.

## v1.11.0 — 2026-05-18

Mirrors `PROJECT_STARTER.md` template v1.11.0.

### Template self-tests on CI (Codex Phase 8 — highest leverage after Phase 1)

The repo now proves end-to-end that the template instantiates and runs. Every push and PR against `main` exercises the full consumer flow: export-starter → tar extract → placeholder substitution → `uv sync` → `pytest` + `ruff check` + `mypy src`. Any breakage in template files, scripts, CI assumptions, or doc claims now fails CI and blocks the PR. Codex's improvement plan called this out as the single biggest leverage point: "Everything else gets easier once the template can prove it works."

- **`scripts/smoke-test.sh`** (new, repo root, executable): instantiates the template end-to-end into a tempdir. Substitutes the `<package_name>` placeholder via one `mv` + one `sed`. Runs the four tool checks (`uv sync`, `pytest`, `ruff check .`, `mypy src`) from the synthesized project. Fails loud on any step. Tempdir cleanup via `trap`. `PKG` env var overrides the default package name (`smoketest`).
- **`.github/workflows/template-self-test.yml`** (new — meta-repo's first CI workflow; consumer projects already have their own `templates/.github/workflows/ci.yml`): ubuntu-latest, `astral-sh/setup-uv@v3`, runs `./scripts/smoke-test.sh` on push + PR.

### Fix: `scripts/export-starter.sh` archive layout

The smoke test caught a real bug on its very first run: v1.10.0's `export-starter.sh` kept `templates/` nested as a subdirectory inside the archive. After `tar -xzf --strip-components=1`, the consumer ended up with `<root>/templates/scripts/` instead of `<root>/scripts/`, so PROJECT_STARTER.md §1.3's `chmod +x scripts/*.sh` immediately following the extract would fail. Fixed by changing `cp -R templates` to `cp -R templates/.` (trailing `/.` promotes contents instead of preserving the parent directory name). Same-day fix surfaced by the same-commit smoke test — exactly the drift-catching loop Codex's Phase 8 promises.

### Spec

- **B-014** added: template self-tests on every push + PR via meta-repo CI. Names `scripts/smoke-test.sh` + `.github/workflows/template-self-test.yml` + the four tool checks. Frozen.
- **B-015** added: corrected archive layout — `templates/` contents promoted to the archive root level (not kept nested). Supersedes B-013 with full rationale ("the full templates/ tree" wording was ambiguous; smoke test caught the gap). Frozen.
- **B-013** flipped to superseded by B-015.

## v1.10.0 — 2026-05-18

Mirrors `PROJECT_STARTER.md` template v1.10.0.

### Ship `scripts/export-starter.sh`

Codex's improvement-plan Phase 1.1 (and existing open item #4 / inventory item B4) — `PROJECT_STARTER.md §1.3` has recommended `./scripts/export-starter.sh` as "the quick path" since v1.1.1 (May 4), but the script never shipped. Running the recommended command produced "No such file or directory." The doc lied for two weeks.

This commit ships the script:

- **`scripts/export-starter.sh`** (new, repo root — meta-script, not a consumer template). Reads `VERSION`. Writes `~/Downloads/project-starter-v<VERSION>-<YYYY-MM-DD>.tar.gz` (always) and `~/Downloads/project-starter-v<VERSION>-<YYYY-MM-DD>.zip` (only when `zip` is installed — graceful skip with a message otherwise, matching the v1.1.3 caveat already documented in the template-changelog table). Archive contains a top-level `project-starter-v<VERSION>-<YYYY-MM-DD>/` directory with `PROJECT_STARTER.md` + the full `templates/` tree, so consumers can `tar -xzf ... --strip-components=1` directly into a new project per §1.3. Output dir overridable via `OUT_DIR` env var (default `~/Downloads`, auto-created). Fails loud if source artifacts are missing; cleans up tempdir on exit via `trap`.

Verified by running the script during this commit cycle: produced a 25KB tar.gz containing the expected file tree.

### Spec

- **B-013** added: names the script's contract (output path, archive layout, optional zip, OUT_DIR override, failure semantics). Frozen. No D entry — the script's existence was always planned; this just makes the doc honest.
- **Open project-level decisions** — item #4 (the missing export script) **resolved** by this commit.

## v1.9.1 — 2026-05-18

Mirrors `PROJECT_STARTER.md` template v1.9.1. Patch — fixes the deploy cleanliness check Codex flagged at improvement-plan Phase 1.3.

### Fix

- **`templates/scripts/deploy.sh` cleanliness check was incomplete.** The previous `git diff --quiet --exit-code` only detected unstaged changes against the working tree. It missed: (a) staged-but-uncommitted edits (`git diff --cached`), and (b) untracked files (`git ls-files --others --exclude-standard`). Either could ship a surprise — a half-staged refactor not yet committed, or a brand-new module the dev forgot to `git add`. Replaced the single check with three checks (unstaged, staged, untracked), each reported separately when the tree is dirty. The `--dirty` override still works. Untracked is intentionally part of the gate (catches forgotten-to-add files in `src/`) but respects `.gitignore` via `--exclude-standard` so locally ignored paths like `.env` don't block. Script header comment now documents the policy explicitly.

## v1.9.0 — 2026-05-18

Mirrors `PROJECT_STARTER.md` template v1.9.0.

### Ship the minimal runnable Python/uv/FastAPI preset

Codex's improvement-plan Phase 1.2 (and existing open item #6) flagged that `templates/Makefile` references `<package_name>.app:app`, CI runs `mypy src`, and `scripts/deploy.sh` rsyncs `src/` + curls `/healthz` — but none of those files ship in `templates/`. The template claimed to be runnable; in practice the consumer had to invent the scaffolding themselves. This release closes that gap.

Files added under `templates/`:

- **`pyproject.toml`** — FastAPI + uvicorn runtime; pytest + httpx + ruff + mypy dev via PEP 735 `[dependency-groups]` so default `uv sync --frozen` picks them up (matches the existing CI workflow as-is); hatchling build-backend; tool config for ruff (`E,F,W,I,B,UP,RUF`, line 100, py312), mypy (`strict`, `files = ["src"]`), pytest (`testpaths = ["tests"]`).
- **`src/<package_name>/__init__.py`** — package init with `__version__ = "0.1.0"`.
- **`src/<package_name>/app.py`** — minimal FastAPI app exposing `/healthz` (the endpoint `scripts/deploy.sh` already curls for its post-deploy healthcheck).
- **`tests/__init__.py`** — empty package marker.
- **`tests/test_smoke.py`** — FastAPI `TestClient` smoke test asserting `/healthz` returns 200 / `{"status": "ok"}`.
- **`LICENSE`** — MIT with `<COPYRIGHT_HOLDER>` + `<YEAR>` placeholders.

### Placeholder convention

Single `<package_name>` literal everywhere — including the `src/<package_name>/` directory name itself. Bootstrap substitution is one mv + one sed:

```sh
mv templates/src/<package_name> templates/src/<actual_name>
find templates -type f \( -name '*.py' -o -name '*.toml' -o -name 'Makefile' -o -name '*.yml' -o -name '*.sh' -o -name '*.example' \) -exec sed -i 's/<package_name>/<actual_name>/g' {} +
```

(Today this is manual; automating it in `scripts/bootstrap.sh` is a follow-up open item that pairs with B1/B2 of the Codex plan.)

### Spec

- **B-012** added: `templates/` ships a minimal runnable Python/uv/FastAPI preset. Names the shipped files + the substitution convention + the healthcheck/import-path alignment with Makefile/CI/deploy.sh. Frozen. Decision: D-009.
- **Open project-level decisions** — item 6 ("Add language-preset skeletons. Missing pyproject.toml, src/<package>/, tests/, LICENSE. CI assumes they exist.") is now **resolved** by this commit; removing from the open list and noting in CHANGELOG.

## v1.8.0 — 2026-05-18

Mirrors `PROJECT_STARTER.md` template v1.8.0.

### Declare product identity: Python/uv/FastAPI/VPS starter (now) + multi-preset (roadmap)

Codex's `codex improvement plan.md` flagged the gap at Phase 2/12: top-level docs claim "project-agnostic" but `templates/Makefile` invokes `uv run uvicorn`, CI assumes `pyproject.toml` + `src/<package>/`, `scripts/deploy.sh` is VPS-shaped. Claiming agnostic without shipping presets is dishonest by construction.

This release picks the honest near-term framing (Codex's Phase 12 Option A): **this repo is a Python/uv/FastAPI/VPS starter today.** The stack-agnostic parts (bootstrap process, `gogogo!` gate, 5-step workflow, spec-block format, Karpathy rules, reviewer-agnostic PR rubric) apply to any project. The Python-shaped parts (language preset, Makefile, CI, deploy) are honestly named. Multi-preset support is on the roadmap (D-009) — when it lands, the agnostic claim becomes true and gets re-asserted.

No templates change. No shipped code changes. Only framing.

- **`PROJECT_STARTER.md`** top section reframed: drop the "This document is project-agnostic" line; replace with an honest paragraph naming the current shipped scope (Python/uv/FastAPI/VPS) and what's stack-agnostic vs. Python-specific. New `### 0.1 Current scope` subsection makes the boundary explicit.
- **`docs/spec.md`** — new D-009 captures the decision and the considered alternatives (ship Python-only honest; build multi-preset before next release; keep claiming agnostic).
- **"Open project-level decisions"** — stack-agnostic-restructure item tagged "roadmap per D-009" so it stays on radar but is no longer treated as a near-term gap.

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
