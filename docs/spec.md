# phoenixtemplate — spec

The product is a **template kit**: a reusable bootstrap for new software projects worked on with Claude Code. The deliverable is the contents of `templates/` plus `PROJECT_STARTER.md`, copied verbatim into each new project.

## Summary

Two surfaces:
1. **`PROJECT_STARTER.md`** + its **companion split docs at meta-repo root** (as of v1.22.0): `TEMPLATE_INVENTORY.md` (file layout + templates reference), `DEPLOY_BASELINE.md` (VPS deploy + CI/CD baseline + credential handling), `HARNESS_QUIRKS.md` (Claude Code harness gotchas + `bootstrap.sh` design). PROJECT_STARTER.md remains the entry-point index — bootstrap checklist (§1), the `gogogo!` gate + 5-step workflow (§2), decision bank (§5), conventions (§9), memory seed (§10), PR review heuristics (§11), audit trail (§8). Further splits planned: `WORKFLOW.md` (extracts §2 + §9 + §10 + §11, v1.22.1) and `BOOTSTRAP.md` (extracts §0 + §1 + §5, v1.22.2).
2. **`templates/`** — copy-paste-ready files (`README.md`, `CLAUDE.md`, `CONTRIBUTING.md`, `Makefile`, `.env.example`, `.gitignore`, `.python-version`, `.claude/`, `.github/`, `scripts/`, `docs/`). Customize placeholders (`<PROJECT_NAME>`, `<PACKAGE_NAME>`, `<HOST>`, etc.) per project.

The kit is currently Python+uv+FastAPI+VPS-shaped; making it stack-agnostic is an open item. The export script (`scripts/export-starter.sh`) flattens all four root docs + the contents of `templates/` into a single archive directory so consumers `tar -xzf --strip-components=1` directly into their project root.

## Process & versioning

This repo follows its own published workflow. The `gogogo!` passphrase gate + 5-step atomic workflow (spec → bump+CHANGELOG → code → commit → deploy) is binding here too. Process rules live in `templates/CONTRIBUTING.md`. Current version lives in [`VERSION`](../VERSION) — single source of truth, never duplicated in prose. Per-version diary: [`CHANGELOG.md`](../CHANGELOG.md). The template version inside `PROJECT_STARTER.md` mirrors `VERSION` — they bump together.

## Frozen behavior

Binding behavior of this template kit, written as **Blocks**. Format defined in `templates/docs/spec.md`. Use the `spec-block` skill (`/spec-block`) when adding new ones.

**Section organization (since v1.17.0):** active blocks (`proposed`/`draft`/`frozen`) live in this section in numerical order. Superseded blocks have been moved to the [Historical blocks](#historical-blocks-superseded) appendix at the bottom of this file. The split keeps the current rule set readable without losing audit trail.

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

**Rule:** Step 5 of the `gogogo!` workflow (deploy) is a no-op for `phoenixtemplate`. There is no deployable artifact; the "release" is `main` being up to date.
**Rationale:** This is a doc + scaffold kit, not a running service. Consumers pull updates by re-cloning or re-fetching templates manually.
**Test:** manual — no `make deploy`, no `scripts/deploy.sh` at this repo's root (only inside `templates/`).
**Status:** frozen
**Decision:** —

### Block B-010: PR review is out-of-band and reviewer-agnostic

**Rule:** PR review is a user-initiated action that runs in a separate session, not a Claude workflow step. The project ships no Claude-side reviewer trigger — no skill, no Makefile target, no review-specific proposal flow, no reminder. `templates/docs/pr_review_instructions.md` is a reviewer-agnostic rubric and names no default reviewer. After Claude opens the PR (per a `gogogo!`-authorized PR-open proposal), the user opens whichever reviewer they prefer (Codex CLI, `/ultrareview`, another LLM, manual) in a separate terminal or session, points it at the open PR and the rubric, and the reviewer posts comments via `gh` (or its native PR integration) directly. Claude does not dispatch, prepare, remind about, or wrap any reviewer flow.
**Rationale:** Every prior attempt to wire Claude to a reviewer (B-007 Codex-via-GitHub-App default, B-008 PR-comment skill, B-009 local-CLI skill) was Claude doing a job the user was already doing better in a separate window. Reviewer choice is the user's; the same rubric works for all reviewers. Removing the wiring also resolves the [P1] Codex flagged on the v1.6.0 branch (the local-CLI skill couldn't satisfy the per-commit PR-comment contract because it ran stdout-only). With review out-of-band, whichever reviewer the user runs interactively can satisfy the contract directly — and the project stops claiming a contract it can't keep. Supersedes B-007, B-009.
**Test:** manual — `templates/docs/pr_review_instructions.md` preamble names no default reviewer; `templates/.claude/skills/` does not contain a `request-codex-review/` directory; `grep -E '^request-codex-review:' templates/Makefile` returns nothing.
**Status:** frozen
**Decision:** D-008

### Block B-012: `templates/` ships a minimal runnable Python/uv/FastAPI preset

**Rule:** `templates/` includes the complete language-preset scaffolding the Makefile + CI + deploy.sh assume: `templates/pyproject.toml` (FastAPI + uvicorn runtime; pytest + httpx + ruff + mypy dev via PEP 735 `[dependency-groups]`; hatchling build-backend; tool config for ruff/mypy/pytest), `templates/src/<package_name>/__init__.py` + `templates/src/<package_name>/app.py` (minimal FastAPI app exposing the `/healthz` endpoint `templates/scripts/deploy.sh` curls), `templates/tests/__init__.py` + `templates/tests/test_smoke.py` (TestClient smoke test asserting `/healthz` returns 200 / `{"status": "ok"}`), and `templates/LICENSE` (MIT with `<COPYRIGHT_HOLDER>` + `<YEAR>` placeholders). The shipped preset is consistent with `templates/Makefile` (`uv run uvicorn <package_name>.app:app`, `uv run pytest`, `uv run ruff check .`, `uv run mypy src`) and `templates/.github/workflows/ci.yml` (`uv sync --frozen`, `ruff check`, `mypy src`, `pytest`). All placeholders use the single `<package_name>` literal — including the `src/<package_name>/` directory name — so one mv (`src/<package_name>` → `src/<actual>`) plus one sed (`<package_name>` → `<actual>` across .py / .toml / Makefile / .yml / .sh / .env.example) substitutes everything.
**Rationale:** Closes the trust-break Codex flagged at improvement-plan Phase 1.2: `templates/Makefile` references `<package_name>.app:app`, CI runs `mypy src`, `scripts/deploy.sh` rsyncs `src/` and curls `/healthz` — but none of those files ship in `templates/`. Without the preset, the template is documentation, not a template. With it, a consumer who runs the substitution (today manual; auto-bootstrap is a follow-up open item) gets a project where `uv sync && make test && make lint && make dev` all work end-to-end. Concrete instantiation of D-009's "Python/uv/FastAPI/VPS starter" identity claim.
**Test:** manual — `ls templates/pyproject.toml templates/src/<package_name>/{__init__.py,app.py} templates/tests/{__init__.py,test_smoke.py} templates/LICENSE` succeeds; `grep -E '/healthz' templates/src/<package_name>/app.py templates/scripts/deploy.sh templates/tests/test_smoke.py` shows the endpoint name aligned across app, deploy healthcheck, and test; `grep -E '<package_name>' templates/pyproject.toml templates/Makefile templates/src/<package_name>/app.py templates/tests/test_smoke.py` shows the single placeholder convention used uniformly.
**Status:** frozen
**Decision:** D-009

### Block B-014: template self-tests on every push + PR via meta-repo CI

**Rule:** `scripts/smoke-test.sh` (repo root, executable) instantiates the template end-to-end and proves the resulting project's core tooling runs: (1) invokes `scripts/export-starter.sh` against the current working tree to produce a portable archive (so the test exercises the exact archive a consumer would receive), (2) extracts the archive into a tempdir, (3) substitutes the `<package_name>` placeholder with a literal value (`PKG` env var, default `smoketest`) via one `mv` (`src/<package_name>` → `src/<PKG>`) plus one `sed` across `.py` / `.toml` / `Makefile` / `.yml` / `.sh` / `.example` files, (4) runs `uv sync`, `uv run pytest`, `uv run ruff check .`, and `uv run mypy src` inside the extracted project. Fails loud (`set -euo pipefail`) on any step. Cleans up tempdir on exit. `.github/workflows/template-self-test.yml` runs the smoke test on every `push` and `pull_request` against `main` (ubuntu-latest runner, `astral-sh/setup-uv@v3` provides uv + Python).
**Rationale:** Codex improvement-plan Phase 8 — "make the template self-testing" as the highest-leverage move after Phase 1. Without CI proving the template works, every doc/template change can introduce a runnable-only-in-theory gap that a careful human reviewer might miss but a smoke test would catch immediately. First execution of the smoke test caught B-013's archive-layout bug end-to-end (which led to B-015 superseding it in the same commit). Going forward, any change that breaks instantiation, substitution, dependency resolution, test discovery, lint, or typecheck fails CI and blocks the PR.
**Test:** manual — `./scripts/smoke-test.sh` exits 0 and prints `✓ template self-test passed`; `.github/workflows/template-self-test.yml` exists and CI runs green on PRs.
**Status:** frozen
**Decision:** —

### Block B-015: `scripts/export-starter.sh` archive layout — contents promoted to root

**Rule:** Running `./scripts/export-starter.sh` from the repo root writes `$OUT_DIR/project-starter-v<VERSION>-<YYYY-MM-DD>.tar.gz` (always) and `.zip` (only when `zip` is installed — graceful skip otherwise). The archive contains a single top-level `project-starter-v<VERSION>-<YYYY-MM-DD>/` directory; under that directory: the script's `ROOT_DOCS` array (as of v1.22.0: `PROJECT_STARTER.md`, `TEMPLATE_INVENTORY.md`, `DEPLOY_BASELINE.md`, `HARNESS_QUIRKS.md`) plus the **contents** of `templates/` promoted one level (so `Makefile`, `CLAUDE.md`, `CONTRIBUTING.md`, `README.md`, `pyproject.toml`, `LICENSE`, `src/<package_name>/...`, `tests/...`, `scripts/`, `.github/`, `.claude/`, `docs/`, `.gitignore`, `.env.example`, `.python-version`, `CHANGELOG.md` all sit at archive top level alongside the root docs). This matches PROJECT_STARTER.md §1.3's quick-path flow: after `tar -xzf ... --strip-components=1` the consumer has the project files directly at their project root, and the immediately-following `chmod +x scripts/*.sh` finds `scripts/` where it expects. All PROJECT_STARTER.md cross-links to its companion docs (added in v1.22.0 by B-025) resolve in the extracted layout because every entry in `ROOT_DOCS` is exported alongside `PROJECT_STARTER.md`. `OUT_DIR` defaults to `~/Downloads`, overridable via env. Script reads VERSION, fails loud (`set -euo pipefail`) if any `ROOT_DOCS` file or `templates/` is missing, cleans up its tempdir on exit (`trap`). Adding a new root-doc requires appending to `ROOT_DOCS` in the script AND `VIRTUAL_TEMPLATES_FILES` in `scripts/check-doc-references.sh` (B-023) in the same commit. Supersedes B-013, which left `templates/` nested as a subdirectory inside the archive — the resulting layout broke §1.3's chmod line because `scripts/` ended up at `<root>/templates/scripts/`, not `<root>/scripts/`. Updated in v1.22.0 to add three companion docs to `ROOT_DOCS`; pre-v1.22.0 archives shipped `PROJECT_STARTER.md` only at root.
**Rationale:** B-013's wording ("the full templates/ tree") was ambiguous about whether `templates/` itself was preserved as a directory or its contents were promoted. The implementation kept it nested. The smoke test (B-014) caught the gap end-to-end on the first run. Correct layout puts templates content at root level so consumers can `chmod +x scripts/*.sh` immediately, matching the §1.3 contract that's existed since v1.1.1.
**Test:** manual — `./scripts/export-starter.sh && tar -tzf ~/Downloads/project-starter-v$(cat VERSION)-$(date +%F).tar.gz | head -20` shows entries like `project-starter-v<X>-<DATE>/Makefile`, `project-starter-v<X>-<DATE>/scripts/...`, `project-starter-v<X>-<DATE>/src/<package_name>/...` (NOT `project-starter-v<X>-<DATE>/templates/Makefile`); and the smoke test (`./scripts/smoke-test.sh`) passes end-to-end including `chmod +x scripts/*.sh` semantics implicit in the consumer-flow simulation.
**Status:** frozen
**Decision:** —

### Block B-016: every live doc reference resolves to a shipped file or is an explicit example

**Rule:** Every command, file path, and filename mentioned in active docs (`PROJECT_STARTER.md`, `templates/README.md`, `templates/CONTRIBUTING.md`, `templates/CLAUDE.md`, `templates/docs/*.md`) either (a) points at a file that ships in this repo, (b) is a literal placeholder marked by angle brackets like `<package_name>` / `<PROJECT_NAME>` / `<HOST>`, (c) is an illustrative example (e.g. `findings.txt` and `review.md` shown as forbidden alternatives in the output contract; `Cargo.toml` / `package.json` shown as non-Python stack examples), or (d) is a prescriptive recommendation for a user-local file the project doesn't ship (memory-seed filenames like `architecture_decisions.md` that consumers create in their own `.claude/memory/` dir). Historical mentions of removed files (e.g. `request-codex-review` skill in template-changelog tables for v1.5.0–v1.6.0) are intentional audit trail in changelog history and superseded spec blocks, not live references.
**Rationale:** Doc drift — recommending files that don't exist, paths that no longer work, commands that fail on first use — is the trust-break Codex flagged repeatedly (Phase 1.1 export-starter, Phase 1.2 missing preset, Phase 1.4 broader path audit). Once the template is meant to be consumed by other people, every broken reference is "the docs lied to me on day one." This block is the invariant; the future C2 doc-reference linter (Codex Phase 8.2) makes it testable automatically. Until then: manual audit on every release-prep, plus the v1.11.0 smoke test catches the runtime consequences (missing files break `uv sync` / `make test` / `make lint`).
**Test:** automated (Markdown link subset) via `scripts/check-doc-references.sh` (B-023) — runs on every push/PR in `template-self-test.yml`. Manual backup for the sub-categories no machine check covers: explicit examples (b), placeholders (c), and prescriptive user-local file recommendations (d). Smoke test (B-014) catches the runtime subset (commands and paths actually invoked by `Makefile` / `scripts/deploy.sh` / `scripts/ci.yml`).
**Status:** frozen
**Decision:** —

### Block B-017: generic `templates/scripts/*` derive project context, don't hardcode source-project names

**Rule:** Scripts that ship in `templates/scripts/` and present any project-identifying display string (menu headers, banners, status output, etc.) MUST derive it from the consumer's project context — `basename "$ROOT"` (repo directory name), an environment variable, or an explicit `<PROJECT_NAME>`-style placeholder for the consumer to fill — NEVER hardcode a name from the project this template was extracted from. Specifically: `bootstrap.sh`'s interactive menu header derives the display name via `PROJECT_NAME=$(basename "$ROOT")` where `$ROOT` is the script's enclosing project root. Audit-trail mentions of the source project's name in `CHANGELOG.md` (e.g. "Initial extraction from phoenixtgstat_bot" in `PROJECT_STARTER.md` template-changelog) are intentional provenance and do not violate this rule.
**Rationale:** A generic template that prints source-project branding is dishonest by construction — a consumer running the script sees another project's name and either concludes (a) the template is for that specific project rather than theirs, or (b) the template is sloppy with leftovers. Codex improvement-plan Phase 1.1 flagged the `bootstrap.sh` case explicitly. Establishing the rule formally lets the future C4 workflow-consistency linter (Codex Phase 5.3) test for it automatically and prevents regression as new generic scripts are added.
**Test:** manual — `grep -nE 'phoenix[a-z]*_bot' templates/scripts/*.sh` returns nothing (only audit-trail mentions in `CHANGELOG.md` template-changelog and the Codex plan itself remain, which are intentional).
**Status:** frozen
**Decision:** —

### Block B-019: active docs are vendor-neutral by default; vendor-specific guidance is labeled

**Rule:** Active documentation surfaces (`PROJECT_STARTER.md`, `templates/README.md`, `templates/CONTRIBUTING.md`, `templates/CLAUDE.md`, `templates/docs/*.md`) describe generic concepts with generic examples by default. When concrete examples make a point clearer, vendor-neutral choices are preferred (`api-handler` branch name beats `click-receiver`; `auth 401 retry` commit message beats `CAPI 401 retry`; `<GITHUB_USER>/$PROJECT_SLUG` placeholder beats a literal username). When a vendor-specific detail is genuinely instructive (e.g. Telegram's webhook `allowed_updates` default omits `chat_join_request` — an exact behavior that catches real bugs), it MUST be explicitly labeled as a vendor example (`**Example (Telegram bots):**`) rather than presented as universal truth. Shipped script env var names follow the same rule: `SERVICE_URL` beats `WEBHOOK_BASE_URL` because the latter assumes the service is a webhook receiver. Historical/audit-trail mentions of the source project's vendors in `CHANGELOG.md` and superseded spec blocks remain intentional provenance.
**Rationale:** A generic template that uses Telegram bot terminology in its supposedly-stack-agnostic examples isn't actually generic — readers conclude (rightly) that the template is for that specific vendor. Codex improvement-plan Phase 1.3 — the broader companion to Phase 1.1 (`B-017` script-display names) and Phase 1.2 (`B-018` validator bake-ins). Together these three blocks complete the de-personalization of the template per D-009's "Python/uv/FastAPI/VPS starter" identity claim: the stack-agnostic *process* layer is genuinely stack-agnostic, and the Python-preset *language* layer is honestly named.
**Test:** manual — `grep -niE 'telegram|meta|facebook|keitaro|capi' PROJECT_STARTER.md templates/README.md templates/CONTRIBUTING.md templates/CLAUDE.md templates/docs/*.md` returns either (a) nothing in active prose, or (b) only explicitly-labeled vendor examples, or (c) audit-trail mentions in changelog tables / superseded spec blocks. The future C4 consistency linter (Codex Phase 5.3) makes this testable automatically.
**Status:** frozen
**Decision:** —

### Block B-021: three-tier doc-canonical model with deliberate AI-safety redundancy

**Rule:** Workflow rules live across three doc tiers, each with an explicit canonical scope:

| Tier | File | Canonical for | What it carries |
|---|---|---|---|
| Meta / rationale | `WORKFLOW.md` (was `PROJECT_STARTER.md` §2 before v1.25.0) | Core workflow rules + rationale + alternatives considered + design philosophy. | Full explanations, history, "why this and not that," edge-case discussion. |
| Per-project operational | `templates/CONTRIBUTING.md` | Per-project operational concretization — commands, sequences, project-specific bits, version markers per stack, deploy specifics. | Operational how-to. References the meta tier for *why*; carries rule statements inline as defensive redundancy. |
| Session-facing | `templates/CLAUDE.md` | The minimum set of rules the AI needs in working context every session. | Gate clause, proposal format, bare-gogogo prompt, env-metadata contract (per B-020), allowed-without-gate list, refuse-list. Inline rule statements (not pointers) because the AI needs them in context to apply them. |

Each file has an explicit `**Canonical scope:**` header marker declaring what it owns and pointing at the canonical sources for other tiers. **Rule statements** (the gate clause, the proposal format, the bare-gogogo clarification prompt, the refuse-list, the allowed-without-gate list) are **deliberately duplicated** across all three files — this is defensive AI-safety redundancy, not architecture debt. Stripping any of those rule statements from CLAUDE.md (the session-facing tier) was observed historically to make the AI miss the rules. The C4 rule-consistency linter (B-022) checks the byte-exact match of the canonical regions (`gate-clause`, `proposal-format`, `bare-gogogo` as of v1.23.0; previously `gate-clause`, `verb-table`, `bare-gogogo` before B-026's gate-model rewrite). **Rationale and "why" content** lives canonically in the meta tier and is NOT duplicated — slimmer files in the operational + session tiers.

**Rationale:** Earlier in this repo's history, single-source rule layouts caused observed AI failures (missing gate, wrong workflow on bare authorization, etc.). The original triple-source layout was defensive redundancy added empirically after each failure. The risk of a clean-architecture refactor was reintroducing the same failures by removing the protective duplication. This three-tier model splits the problem: rationale + design context are duplication-prone debt (clean to dedupe to one canonical source), but rule statements are load-bearing safety equipment (deliberately duplicated, enforced by mechanical sync via B-022). Codex Phase 1 #1 framing was "one canonical source"; the refined framing (per user feedback: "we had 3 places to hold the rules, just because you were constantly missing them") is "one canonical source per concern, with deliberate redundancy for AI safety." The three-region set updates as the gate model evolves — v1.19.0 froze `gate-clause` / `verb-table` / `bare-gogogo`; v1.23.0's B-026 gate rewrite swaps `verb-table` for `proposal-format` (verbs are gone).
**Test:** automated via the C4 rule-consistency linter (B-022) — `./scripts/check-rule-consistency.sh` exits 0 when the three named regions appear byte-exact across all three files; CI runs it on every push/PR. Manual: confirm each file's `**Canonical scope:**` header marker declares its tier and points at the others.
**Status:** frozen
**Decision:** —

### Block B-022: C4 rule-consistency linter enforces three-tier doc match

**Rule:** `scripts/check-rule-consistency.sh` verifies that named "rule regions" appear byte-for-byte identically across the three canonical doc tiers named by B-021 (`WORKFLOW.md`, `templates/CONTRIBUTING.md`, `templates/CLAUDE.md` — the first tier was `PROJECT_STARTER.md` §2 before v1.25.0's extraction into `WORKFLOW.md`). Each region is bracketed in each file by HTML-comment anchors `<!-- C4:<region>:start -->` and `<!-- C4:<region>:end -->`. The script extracts content between matching anchors in each file, diffs every pair against the first file as reference, and exits non-zero on any drift or missing region (printing a unified diff identifying the drift). The regions as of v1.27.0 are: (i) `gate-clause` — the two-conditions rule "Do NOT take any state-mutating action unless (a) Claude's immediately preceding message contained a concrete proposal AND (b) the user's CURRENT message contains `gogogo!` (optionally preceded by a digit)"; (ii) `proposal-format` — the canonical shape every proposal must follow (single suggestion, "Choose one:", or "Choose any (in order):" with the matching invitation line); (iii) `bare-gogogo` — the bare-`gogogo!`-with-no-preceding-proposal clarification prompt; (iv) `env-metadata-contract` — the single-paragraph `.env.example` `@directive` contract (added v1.27.0 to close the regression class v1.26.1 surfaced: a doc-trio-canonical rule statement that drifted from frozen B-020 because no mechanical check existed; now duplicated byte-exact across the trio and enforced). The `verb-table` region was retired in v1.23.0 when B-026 replaced the verb-prefix gate model with propose-and-confirm. The script is wired into `.github/workflows/template-self-test.yml` as a job step that runs before the smoke test on every push and PR to `main`. Adding a region in a future version: add the anchored region (verbatim text) to all three files in the same commit and append the region name to the script's `REGIONS` array. Removing a region: drop from the array and remove the anchor pair from all three files in the same commit (as was done with `verb-table` in v1.23.0).

**Rationale:** B-021 (v1.18.0) made the three-tier doc redundancy load-bearing — rule statements are deliberately duplicated across the three files as defensive AI-safety equipment. Enforcement was manual until this block, so one careless edit could silently drift the copies and reopen the exact failure mode B-021 was designed to prevent (missed gate, wrong verb mapping, ignored bare-`gogogo!` handling). Codex improvement plan: "Add a consistency linter for canonical workflow phrases" (Phase 8 #4 in `codex improvement plan.md`). HTML-comment anchors were chosen over text-pattern detection because (a) they survive arbitrary edits to surrounding prose without breaking the linter, (b) markdown renderers ignore HTML comments so source layout stays clean, (c) the linter is trivial `bash` + `awk` + `diff` with no parser. Byte-exact match (not normalized) was chosen over fuzzy match so stylistic drift (capitalization, punctuation, whitespace) is caught too — these are load-bearing rules, not prose to be freely rephrased. The pre-linter alignment commit (same v1.19.0) normalizes the three files' wording so byte-exact match holds at baseline; in particular `templates/CLAUDE.md`'s gate clause was "**Never take...**", aligned to the canonical "**Do NOT take...**" that already matched `PROJECT_STARTER.md` and `templates/CONTRIBUTING.md`; the verb table in `PROJECT_STARTER.md` was simplified from three columns (Phrase / Action / Workflow) to the two-column form (Phrase / Action) shared with the other two tiers, with the dropped Workflow column's section-reference content moved to a prose sentence below the table; the bare-`gogogo!` prompt was unified to a single standalone bold paragraph in each file with the trailing "Review is out-of-band — no verb for it." sentence. Resolves the "Test: manual until C4 linter ships" caveat in B-021.

**Test:** automated — `./scripts/check-rule-consistency.sh` exits 0 on a clean checkout and prints `OK: canonical rule regions match across 3 files.`; tampering with any anchored region in any of the three files (e.g. `sed -i '/C4:gate-clause:start/,/C4:gate-clause:end/s/Do NOT/Never/' templates/CLAUDE.md`) makes the script exit 1 with a unified diff naming the drifted region and the two files that disagree; the `template-self-test` CI job runs the linter on every push and PR to `main` before the existing smoke test, so drift fails the build.

**Status:** frozen

**Decision:** —

### Block B-023: C2 doc-reference linter verifies Markdown link targets resolve

**Rule:** `scripts/check-doc-references.sh` walks every `*.md` file in the repo (excluding `.git/`), extracts Markdown link targets of the form `[label](target)`, and fails non-zero if any target points to a missing file or directory on disk. Scope is deliberately narrow: only Markdown link syntax (not backtick-quoted paths in prose). Fenced code blocks (triple-backtick) are skipped entirely and inline code spans (single-backtick) are stripped before scanning, so documentation showing the literal `[label](target)` syntax inside backticks doesn't false-trigger. Skipped target patterns: URLs (`http://`, `https://`, `mailto:`, `tel:`, `data:`, `ftp://`), anchor-only links (`#section`), and autolinks (`<...>`). For each non-skipped target: optional Markdown link title (`"Title"`) and trailing `#anchor` / `?query` are stripped, relative paths resolve from the linking file's directory, absolute paths (`/...`) from the repo root, then `realpath -m --relative-to="$REPO_ROOT"` normalizes the path. Existence is checked with `[ -e ]` so directory targets pass. The script understands the export layout: links inside `templates/` that resolve to `templates/<f>` for any `<f>` in `VIRTUAL_TEMPLATES_FILES` (currently `PROJECT_STARTER.md`) are accepted as long as `<f>` exists at meta-repo root, because `scripts/export-starter.sh` flattens templates contents alongside `PROJECT_STARTER.md` in the archive. Output: clean runs print `OK: <N> Markdown link targets resolved across <M> files.`; failed runs print one `<file>:<line> -> <target>  (resolved: <normalized>)` line per broken link to stderr followed by a `FAIL: <N> broken doc reference(s) across <M> files (<scanned> links scanned).` summary. Wired into `.github/workflows/template-self-test.yml` as a step between `check-rule-consistency` (B-022) and the smoke test (B-014). Updating the export script to promote additional meta-repo-root files into the archive requires appending those filenames to `VIRTUAL_TEMPLATES_FILES`.

**Rationale:** B-016 (v1.11.1) named the invariant that every live doc reference resolves to a shipped file (or is an explicit placeholder / example / prescriptive recommendation for a user-local file). Enforcement was manual audit on each release-prep — every rename or removal (e.g. `request-codex-review` skill in v1.7.0, `validators.sh` sidecar in v1.15.0, `WEBHOOK_BASE_URL` env var in v1.13.0) was one missed `grep` away from leaving a dangling `[..](..)` link in the docs. Codex improvement-plan Phase 8 #2 named the linter explicitly; B-016 itself ended with "the future C2 doc-reference linter (Codex Phase 8.2) makes it testable automatically." Markdown link syntax was chosen as the scope (rather than backtick paths) because `[..](..)` carries explicit semantic intent ("this is a navigable reference") while backtick paths in prose frequently describe the consumer's layout (`src/<package_name>/...`) or illustrative examples rather than files actually shipped here — a backtick scan would false-positive heavily on legitimate prose. The export-layout fallback was driven by two real false-positives caught on the first run (`templates/README.md:19 → PROJECT_STARTER.md` and `templates/docs/spec.md:13 → ../PROJECT_STARTER.md`); rather than fixing those by adding a symlink (which would propagate through the archive in unclear ways) the linter models the export script's flattening directly. As of v1.22.0 the `VIRTUAL_TEMPLATES_FILES` set tracks `scripts/export-starter.sh`'s `ROOT_DOCS` array — `PROJECT_STARTER.md`, `TEMPLATE_INVENTORY.md`, `DEPLOY_BASELINE.md`, `HARNESS_QUIRKS.md` — so future templates-side links into any of the companion docs would also pass the export-layout check. Resolves the "Future C2 linter will automate the doc-reference subset" caveat in B-016.

**Test:** automated — `./scripts/check-doc-references.sh` exits 0 on a clean checkout and prints `OK: 50 Markdown link targets resolved across 19 files.`; planting a broken target (e.g. `sed -i 's|](docs/spec.md)|](docs/spec-NONEXISTENT.md)|' README.md`) makes the script exit 1 with one diagnostic per occurrence; the `template-self-test` CI job runs the linter on every push and PR to `main` between the rule-consistency check (B-022) and the smoke test (B-014), so drift fails the build before the smoke test even starts.

**Status:** frozen

**Decision:** —

### Block B-024: C3 placeholder linter forbids canonical placeholders in meta-repo plain prose

**Rule:** `scripts/check-placeholders.sh` walks meta-repo `*.md` files (excluding `templates/` and `codex improvement plan.md`), strips fenced code blocks (lines starting with three backticks toggle the fence state) and inline single-backtick code spans, and fails non-zero if any canonical substitution placeholder appears in the remaining plain prose. The canonical placeholder set is exactly: `<package_name>` (lowercase, Python package import name), `<PACKAGE_NAME>`, `<PROJECT_NAME>`, `<PROJECT_SLUG>`, `<GITHUB_USER>`, `<HOST>`, `<DOMAIN>`, `<PROJECT_DESCRIPTION>`, `<COPYRIGHT_HOLDER>`, `<YEAR>` (the strings consumers `sed` during bootstrap per `PROJECT_STARTER.md §1` + `scripts/smoke-test.sh`). Generic angle-bracket meta-syntax used elsewhere in prose (`<verb>`, `<file>`, `<region>`, `<X.Y.Z>`, etc.) is NOT in the canonical set and not flagged — the repo uses `<X>` as a general convention for many documentation purposes. Scope is `*.md` only; meta-repo `*.sh` / `*.py` / `*.toml` files may legitimately mention canonical placeholder strings in comments or docstrings (those don't render to users). Wired into `.github/workflows/template-self-test.yml` as a step between `check-doc-references` (B-023) and the smoke test (B-014). Output: clean runs print `OK: no canonical placeholders found in plain prose across <N> meta-repo files.`; failures print one `<file>:<line> -> <placeholder>` line per occurrence on stderr followed by a `FAIL: <N> canonical placeholder occurrence(s) leaked into plain prose across <M> meta-repo files.` summary. Updating the canonical set requires editing the `PLACEHOLDERS` array in the script.

**Rationale:** The template's bootstrap surface defines a canonical placeholder set consumers substitute on first commit. Those placeholders belong in `templates/` files (load-bearing — they get `sed`'d) and in meta-repo docs only inside backticks (referencing the placeholder concept). If one leaks into plain prose of a meta-repo doc, the resulting user-facing surface reads as if it shipped with unresolved TODO markers — the same trust-break category as B-016's broken doc references. Until this block enforcement was review-attention only, easy to regress as docs are edited. Codex improvement-plan Phase 8 #3 named the linter explicitly. Scope was narrowed to canonical-set-only (rather than "any `<X>`-shaped pattern") after a survey of all angle-bracket usage in the repo turned up ~60 distinct patterns, most of which are legitimate documentation meta-syntax (`<verb>`, `<file>`, `<branch>`, `<sha>`, `<X.Y.Z>`, etc.); a broader linter would have a false-positive rate near 100%. The code-span/fenced-block stripping reuses the proven approach from B-023's doc-reference linter — Markdown placeholders never live inside code, so stripping code before scanning eliminates the entire class of "docs showing the literal placeholder syntax in backticks." Scope of meta-repo `*.md` only (rather than all meta-repo files) was chosen because non-Markdown files (`.sh` / `.py` / `.toml`) contain placeholder strings only in comments / docstrings — they don't render to a user-facing surface and the comments are legitimate documentation of what the file references. Completes the linter trio (B-022 rule consistency + B-023 doc references + this block) that mechanically guards canonical-doc invariants before the upcoming `PROJECT_STARTER.md` split (Codex Phase 4 #2).

**Test:** automated — `./scripts/check-placeholders.sh` exits 0 on a clean checkout and prints `OK: no canonical placeholders found in plain prose across 6 meta-repo files.`; planting a leak (e.g. appending `Your project uses <package_name> which gets replaced.` to `README.md`) makes the script exit 1 with one diagnostic per occurrence; the `template-self-test` CI job runs the linter on every push and PR to `main` between the doc-reference linter (B-023) and the smoke test (B-014).

**Status:** frozen

**Decision:** —

### Block B-025: PROJECT_STARTER.md split into companion files at meta-repo root

**Rule:** As of v1.26.0 (long-term role settled per D-012), the meta-repo root ships `PROJECT_STARTER.md` (a permanent thin ~40-line index) plus five companion docs that own subsets of what was previously a single 1100-line file: `TEMPLATE_INVENTORY.md` (file/folder layout + `templates/` reference — was §3 + §4 of PROJECT_STARTER.md, extracted v1.22.0), `DEPLOY_BASELINE.md` (VPS deploy + CI/CD baseline + credential handling — was §6 + §7 + §13, extracted v1.22.0), `HARNESS_QUIRKS.md` (Claude Code harness gotchas + `bootstrap.sh` design — was §12 + §14, extracted v1.22.0), `WORKFLOW.md` (gate + propose-and-confirm contract + 5-step + branching/commits/PR/merge/deploy + conventions + auto-memory seed + PR review heuristics — was §2 + §9 + §10 + §11, extracted v1.25.0; this is now the canonical first tier of B-021's three-tier doc model), `BOOTSTRAP.md` (zero-to-first-commit bootstrap checklist + current-scope statement + reading order + decisions-to-answer-before-feature-code — was §0 + §1 + §5, extracted v1.26.0). PROJECT_STARTER.md retains only the entry-point index (title + template version + intro paragraph + docs table) plus the Template changelog tail (the per-version diary of THIS doc itself per B-002). §8 (Audit trail) content was dropped in v1.26.0 — Decision log already lives in `docs/spec.md`, CHANGELOG already documents version diary, and the `gh pr list --search <sha>` commit-to-PR mapping tip is recoverable from git history (specifically pre-v1.26.0 PROJECT_STARTER.md §8.1) if needed. The earlier intermediate-state stubs in PROJECT_STARTER.md (`## N. <title>` headings with `**Moved to [X.md](X.md).**` pointers) served their purpose during the split but are gone as of v1.26.0 — PROJECT_STARTER.md is now a clean thin index with a docs table replacing the §-numbered navigation. All six root docs (PROJECT_STARTER.md + the five companions) ship in the export archive (`scripts/export-starter.sh` `ROOT_DOCS` array) so the cross-links resolve in the extracted layout; `VIRTUAL_TEMPLATES_FILES` in `scripts/check-doc-references.sh` (B-023) is the parallel allowlist used by the doc-reference linter to recognize the same export model. Version numbers note: v1.22.1 and v1.22.2 in earlier roadmap notes were renumbered to v1.25.0 and v1.26.0 once v1.23.x / v1.24.x intervening releases shipped — VERSION is monotonically increasing.

**Rationale:** PROJECT_STARTER.md grew past 1100 lines as the canonical authoring source for bootstrap, workflow, file layout, deploy, conventions, harness quirks, and credential rules. README's Known Limitations called this out; Codex improvement plan Phase 4 #2 named the split explicitly. Three considerations shaped the split shape:

- **Stage in three commits, not one.** A single commit splitting 1100 lines five ways is hard to review and easy to silently drop content in. The trio of linters (B-022 / B-023 / B-024) shipped in v1.19.0–v1.21.0 was the prerequisite — they mechanically catch the kinds of drift a careless surgical move would otherwise introduce. v1.22.0 handled the three "safe" extractions that don't touch the C4-linter anchored regions (those were in §2). v1.25.0 handled WORKFLOW.md and the coordinated B-022 linter retarget (FILES array's first entry shifted from `PROJECT_STARTER.md` to `WORKFLOW.md`). v1.26.0 finished with BOOTSTRAP.md and the thin-index reduction. Split sequence complete.

- **Stub-with-pointer over silent removal.** Leaving `## 3. Structure...` as a header with a one-line "Moved to X.md" pointer preserves readers' mental anchors (someone searching for "§3 file layout" finds the explanation), keeps numeric section stability across intermediate states, and gives `git log -p` a clean signal about what moved. The stubs all get removed in v1.22.2's thin-index reduction.

- **Export-layout coherence.** PROJECT_STARTER.md's pointers (`[TEMPLATE_INVENTORY.md](TEMPLATE_INVENTORY.md)`, etc.) must resolve in the consumer's extracted archive, not just in the meta-repo. So `scripts/export-starter.sh` was updated in the same commit to copy all four root docs (via the new `ROOT_DOCS` array) into the archive stage, and `scripts/check-doc-references.sh`'s `VIRTUAL_TEMPLATES_FILES` was extended to match — the two arrays are kept in sync. Without this coordination, a consumer extracting the v1.22.0 archive would find PROJECT_STARTER.md with broken local links.

The split commits are tracked as separate B blocks in the same numerical range: this block (B-025) captures v1.22.0; B-021 (v1.18.0 three-tier canonical model) anticipates the WORKFLOW.md split via its `(post-split: WORKFLOW.md)` parenthetical, which v1.22.1 will resolve; B-022's linter `FILES` array will be updated in v1.22.1 to point at `WORKFLOW.md` instead of `PROJECT_STARTER.md`.

**Test:** automated — (a) the doc-reference linter (B-023) passes, proving all PROJECT_STARTER.md → companion-doc links resolve in the meta-repo; (b) `./scripts/export-starter.sh` produces an archive containing all root docs at the staged root level (verifiable via `tar -tzf <archive> | grep -E 'project-starter-v[^/]+/(PROJECT_STARTER|TEMPLATE_INVENTORY|DEPLOY_BASELINE|HARNESS_QUIRKS|WORKFLOW|BOOTSTRAP)\.md$'` showing six matches as of v1.26.0); (c) the smoke test (B-014) passes on the archive (template instantiation still works end-to-end); (d) `wc -l PROJECT_STARTER.md` is ~75 as of v1.26.0 (down from 1121 pre-split; the thin index is ~28 user-visible content lines plus the 47-row Template changelog table); (e) the C4 rule-consistency linter (B-022) passes with `WORKFLOW.md` as the first FILES entry.

**Status:** frozen (v1.26.0 — all five planned companion files shipped: TEMPLATE_INVENTORY, DEPLOY_BASELINE, HARNESS_QUIRKS, WORKFLOW, BOOTSTRAP). The PROJECT_STARTER.md split sequence is complete.

**Decision:** —

### Block B-026: gate is propose-and-confirm, not verb-prefix

**Rule:** No state-mutating action proceeds unless ALL of: (a) Claude's immediately preceding assistant message contained a concrete proposal — single suggestion, "Choose one:" list, or "Choose any (in order):" list — with specific files / commands / commits named, not vague phrasing, ending with one of the canonical invitation lines; (b) the user's CURRENT message contains the literal substring `gogogo!`, optionally preceded by one or more whitespace-separated digits — single `N gogogo!` selects option N from a numbered choice; multi-digit `N1 N2 ... gogogo!` (e.g. `1 2 4 5 gogogo!`) authorizes multiple options in the typed order, but ONLY against a "Choose any (in order):" proposal — multi-select against a "Choose one:" proposal is invalid and triggers a re-prompt; (c) the action Claude takes is exactly what the proposal described — mid-execution deviation requires a new proposal. The canonical proposal format is byte-exact-matched across the doc trio by C4 linter region `proposal-format` (B-022): every proposal is its own assistant message, ends with one of the three invitation forms, and contains a concrete plan (files / commands / commits). There are no action verbs; the action description lives in the proposal in plain English. Every assistant message ends with a concrete proposal (B-027) — even clarification turns get a trailing proposal so the user can always `gogogo!` forward motion without an extra round-trip. Bare `gogogo!` without a preceding proposal is invalid → reply with the canonical bare-gogogo prompt asking the user to describe what they'd like. Conversation drift (user asked a question, Claude answered without re-proposing) → Claude must re-propose before any action even if user `gogogo!`s next; the proposal must live in the IMMEDIATELY-PRECEDING assistant message. Memory writes (`~/.claude/projects/.../memory/`) and `.claude/settings.local.json` remain carved out — these need no `gogogo!` per the original carve-out preserved from B-001.

**Rationale:** The verb-prefix model (B-001 + B-011 + D-004) traded one extra typed word for "zero ambiguity at the gate." In practice the ambiguity shifted to the user, not Claude: the user had to remember nine verbs and which mapped to which workflow, while Claude could still pick the wrong files / wrong scope / wrong commit message under a correctly-formed verb. Verbs only encoded action TYPE (commit-only vs 5-step), not action SCOPE. The propose-and-confirm model inverts the burden: Claude must surface a concrete proposal (files, commands, commits) BEFORE any state-mutating action, and the user's `gogogo!` confirms that exact proposal — encoding everything the verb encoded plus the file-and-scope detail that was previously implicit. The D-004 failure mode it was designed to prevent ("agent picks wrong workflow on bare authorization") is preserved: bare `gogogo!` is still invalid; the difference is the corrective proposal now lives in Claude's message, not in a user-typed verb. A NEW failure mode the propose model PREVENTS is "agent picks wrong file/scope under a correctly-formed verb" — verbs simply didn't constrain that. A NEW failure mode the propose model could INTRODUCE is "Claude proposes vaguely (`commit the changes`), user `gogogo!`s, Claude executes wrong scope" — mitigated by condition (a)'s explicit "concrete" requirement: vague proposals don't satisfy the gate, and the canonical proposal-format region (B-022) makes "concrete" mechanically inspectable. Another NEW failure mode it could INTRODUCE is "user `gogogo!`s after long Q&A drift expecting an old proposal still valid" — mitigated by the "immediately preceding message" constraint in condition (a): drift → Claude must re-propose. Supersedes B-001 and B-011: B-001's literal-substring-`gogogo!` check survives as condition (b); B-011's verb table is removed entirely. Refined in v1.24.0 by D-011 (three additions: multi-digit `N1 N2 ... gogogo!` syntax for multi-select against "Choose any (in order):" lists; explicit distinction between "Choose one:" and "Choose any (in order):" header forms; and the always-end-with-a-proposal requirement formalized as B-027). Multi-select is a STRICT EXTENSION, not a weakening: each authorized item was a concrete proposal Claude already surfaced and the user inspected. This is the key difference from pre-auth-of-N-unknown-proposals shapes that were rejected during the v1.24.0 design — pre-auth weakens safety; multi-select-of-already-surfaced-items doesn't. User feedback explicitly named the safety property the new model encodes: "always re-ask users, so he confirms your understanding" — the proposal IS the re-ask.

**Test:** automated via the C4 rule-consistency linter (B-022) — the three regions `gate-clause`, `proposal-format`, `bare-gogogo` appear byte-exact in `PROJECT_STARTER.md` §2 / `templates/CONTRIBUTING.md` / `templates/CLAUDE.md`. Manual session checks: (i) ask Claude to commit without proposing first → it must propose; (ii) `gogogo!` after a vague proposal ("commit the changes") → Claude must re-propose concretely; (iii) conversation drift after a proposal (user asks clarifying question, Claude answers without re-proposing) → next `gogogo!` must trigger re-propose, not action; (iv) `gogogo!` after a single concrete proposal → action executes exactly what proposal described; (v) `N gogogo!` after a numbered list → option N executes exactly as described; (vi) mid-execution deviation → Claude stops and re-proposes; (vii) `N1 N2 ... gogogo!` against a "Choose any (in order):" list → options execute in typed order, each exactly as described, skipping omitted indices; (viii) `N1 N2 ... gogogo!` against a "Choose one:" list → Claude re-prompts rather than executing conflicting options; (ix) Claude's response to any user message ends with one of the three canonical invitation lines (the always-propose check from B-027). Memory carve-out preserved: writes under `~/.claude/projects/.../memory/` and to `.claude/settings.local.json` proceed without `gogogo!`.

**Status:** frozen

**Decision:** D-010

### Block B-027: every assistant message ends with a concrete proposal *when there's a path to surface*

**Rule:** Every assistant message ends with a concrete proposal — one of the three forms in the C4 `proposal-format` region (Single suggestion / Choose one / Choose any (in order)) — **when there's an action or navigation path to surface**. Pure discussion / clarification turns where no list-of-paths fits naturally (e.g. genuine meta-design conversations, free-text Q&A) MAY end without a trailing proposal; the no-round-trip property B-027 originally protected is preserved by B-028, which makes `[info]`-class options single-keystroke (no `gogogo!`), so navigation back into execution mode is one bare `N` away when the user is ready. The trailing proposal, when present, MUST end with one of the canonical invitation lines (per-option gate scope per B-028). Refined v1.28.0 by D-013.

**Rationale:** B-027's original v1.24.0 framing required EVERY assistant message to end with a proposal — driven by user feedback that "ALWAYS end with a proposal, don't make user ask for it" eliminates a costly round-trip in execution mode. In practice, applying that to pure discussion turns (design talks, meta-conversations, info queries) created ceremony without safety benefit: every turn ended with a `gogogo!` invitation even when no state mutation was pending, diluting `gogogo!`'s deliberate-state-change signal. User pushback in v1.28.0 surfaced this dilution explicitly. The refinement preserves B-027's intent (no execution-mode round-trips) while removing the ceremony (no forced proposals in pure discussion). Mechanism: B-028's `[change]` vs `[info]` option classification makes per-option gate scope proportional to actual state-mutation risk — `[info]` picks are bare `N`, so even when proposals appear in discussion turns, they don't impose `gogogo!` ceremony for navigation. The "always" of B-027 becomes a soft default that yields when there's genuinely nothing to surface.

**Test:** manual — review of assistant messages in this repo's session transcripts. Messages that DO surface a proposal must end with a canonical invitation line classified per B-028. Pure discussion turns may end naturally; failure mode is forcing a `gogogo!` invitation when no path-list applies (ceremony) OR ending without a proposal when there IS an action or navigation path the user could pick from (round-trip cost). Caught at review/audit time; the C4 linter enforces only the canonical proposal-format region's text, not the at-message-end usage.

**Status:** frozen (refined v1.28.0 — was "every message must propose" in v1.24.0; now "every message proposes when there's a path to surface").

**Decision:** D-011 (original framing); refined by D-013.

### Block B-028: `[change]` / `[info]` option classification + per-option gate scope

**Rule:** Numbered options in a "Choose one:" or "Choose any (in order):" proposal are each prefixed with exactly one of two markers: **`[change]`** (state-mutating: tracked-file `Edit`/`Write`/`NotebookEdit`, `git commit`/`push`, `gh pr create|merge|comment`, deploy, external POST/PUT/DELETE) or **`[info]`** (read-only / research / discussion / navigation / memory writes / `.claude/settings.local.json` writes). The gate scope is per-option: `[change]` options require `gogogo!` to authorize (`N gogogo!` for single pick; one `gogogo!` in a multi-digit message covers all `[change]` items in the typed sequence against a "Choose any (in order):" list); `[info]` options need only bare `N` (no `gogogo!`). For single-suggestion proposals (not numbered), the same classification applies to the suggestion as a whole: state-mutating single suggestions end with `Type \`gogogo!\` to proceed.`; pure-info single suggestions end naturally without a trailing invitation line. Classification is Claude's responsibility per proposal; conservative default is `[change]` if in doubt. Mid-execution re-classification (an option labeled `[info]` turns out to need state mutation) → STOP and re-propose with the option marked `[change]`.

**Rationale:** Before B-028 (v1.24.0 through v1.27.1), every numbered option in every proposal required `gogogo!` to select, regardless of whether the option was state-mutating. The same ceremony fired for "open PR" (state-mutating) and "show me the diff" (read-only). User pushback in v1.28.0: this dilutes `gogogo!` from a deliberate state-change signal into procedural ceremony. The refinement preserves the safety property B-026 was designed for (literal `gogogo!` substring required before state-mutating actions) while removing ceremony for navigation. Per-option classification works because it shifts the cognitive load from the user ("remember to type `gogogo!` for everything") to Claude ("classify each option correctly when proposing"). Failure modes:

- **User picks bare `N` against a `[change]` option** (typo or habit) → Claude re-prompts: "Option N is `[change]` — type `N gogogo!` to authorize." Bare digit doesn't slip a state change through. The conservative-default-`[change]` rule means borderline cases stay gated.
- **Claude mis-classifies an option** as `[info]` when reality reveals it needs state mutation → mid-execution deviation; STOP and re-propose. Caught at execution time, not at proposal time.
- **Claude mis-classifies an option** as `[change]` when it's actually info-only → harmless overhead; user types unnecessary `gogogo!` but nothing wrong happens.
- **Multi-select against "Choose one:"** remains invalid (per B-026's original constraint); the `[change]`/`[info]` markers don't change that.
- **Mixed multi-select** in "Choose any (in order):" — e.g. `1 2 3 gogogo!` where 1 and 3 are `[change]`, 2 is `[info]` — single `gogogo!` covers `[change]` items in the sequence; `[info]` items proceed in the same message. One authorization signal per user turn; preserves simplicity.

The threshold for `[change]` is "any state mutation outside the gate carve-outs B-001 established (memory + local-only settings)." Tracked-file edits, git ops, gh PR ops, deploy, external mutating HTTP calls — all `[change]`. Reading files, grepping, planning text, web search, clarifying questions, memory writes — all `[info]`. Borderline cases (planning text that's intended as a draft for future commit; research output that includes file edits) → `[change]` by conservative default; downgrade only when Claude is certain the action stays read-only.

**Test:** manual — review of assistant messages in this repo's session transcripts. Every numbered option in a "Choose one:" or "Choose any (in order):" proposal is prefixed `**[change]**` or `**[info]**`. The invitation line correctly specifies gate per option (e.g., "Type `1 gogogo!` for the [change] option, or `2` for the [info] option"). Failure modes: (a) unclassified options → re-prompt; (b) bare `N` against `[change]` → re-prompt; (c) mid-execution `[info]` → `[change]` realization → STOP and re-propose. The C4 `proposal-format` region documents the markers byte-exact across the doc trio; the C4 linter (B-022) catches drift in the format-spec text but not in actual usage at message time.

**Status:** frozen

**Decision:** D-013

### Block B-029: URL-fragment validation + spec-consistency linter

**Rule:** Two complementary automation surfaces guard against semantic drift between active docs and frozen spec behavior in `docs/spec.md`:

**(a) URL-fragment validation** — `scripts/check-doc-references.sh` (originally B-023) was extended in v1.29.0 to validate the `#anchor` portion of every Markdown link target. After file existence is confirmed (real or virtual-export-fallback), if the target contains a `#fragment`, the linter extracts all headings from the resolved file (skipping fenced code blocks), computes GitHub-style auto-anchor slugs (lowercase, drop punctuation outside `[a-z0-9 _-]`, replace whitespace runs with single hyphen, trim leading/trailing hyphens), and verifies the fragment matches at least one heading slug. Failures print `<file>:<line> -> <target>  (broken URL fragment: #<frag> in <resolved>)`. Closes the regression class v1.26.2 caught (WORKFLOW.md linked to `PROJECT_STARTER.md#16-branch-protection-on-main` after §1.6 had moved to BOOTSTRAP.md in v1.26.0; the file-level link still resolved but the anchor was dead).

**(b) Spec-consistency linter** — new `scripts/check-spec-consistency.sh`. Narrow forbidden-phrase checker scoped to the 5 active root docs (README.md, BOOTSTRAP.md, WORKFLOW.md, templates/CONTRIBUTING.md, templates/CLAUDE.md). Strips fenced code blocks + inline code spans before scanning (matching the convention of the other linters); fails on any forbidden phrase match. Invariants are POSIX ERE patterns, case-sensitive, deliberately conservative. **Invariant A (v1.29.0)** — env-metadata `@directive` contract (B-020): forbidden phrases `Optional prose` / `comment block.*Optional` / `"Optional" if`. Catches the regression class v1.26.1 fixed (WORKFLOW.md described requiredness via "Optional" prose while B-020 froze `@directive` metadata as the contract). **Invariant B (v1.29.1)** — canonical-source for workflow lives in `WORKFLOW.md`, not `PROJECT_STARTER.md`: forbidden phrases `PROJECT_STARTER\.md is the canonical` / `PROJECT_STARTER\.md is canonical for` / `PROJECT_STARTER\.md §2.{0,30}canonical` / `canonical source.{0,30}PROJECT_STARTER\.md`. Structural prevention added v1.29.1 — no shipped regression of this exact class yet, but B-025 + D-012 settled that PROJECT_STARTER.md is a permanent thin-index post-v1.26.0; these patterns guard against drift back to the pre-v1.25.0 canonical-source-is-PROJECT_STARTER claim. The audit-trail form (`was \`PROJECT_STARTER.md §2\` before v1.25.0`) doesn't match because "canonical" doesn't appear within 30 chars. **Invariant C (v1.29.1)** — verb-prefix gate model is superseded (B-001+B-011+D-004 → B-026 in v1.23.0): forbidden phrases `verb-prefix gate` / `verb table (per|in|of) (the )?(active|current)` / `action verb (per|in|of) (the )?(active|current)`. Structural prevention; the v1.23.1 prose sweep + later cleanups left zero current matches, this invariant locks it in. The invariant list is extensible — add new entries as new regression classes surface, OR as structural-prevention additions when a regression-class boundary is settled by a B block/D entry. PROJECT_STARTER.md / CHANGELOG.md / docs/spec.md are intentionally OUT of scope (their changelog tails + historical-superseded sections have legitimate audit-trail mentions of pre-supersession state).

Both checks are wired into `.github/workflows/template-self-test.yml` between the placeholder linter (B-024) and the smoke test (B-014). Together they close the doc-reference gap (B-023 only verified file existence; not anchor presence) and the semantic-drift gap (no other linter caught content-of-doc-vs-content-of-spec mismatches).

**Rationale:** The v1.26.1 + v1.26.2 regression pair surfaced two distinct failure modes the existing linter trio (B-022/B-023/B-024) didn't catch:

- v1.26.1: WORKFLOW.md's `Environment variables` section was extracted verbatim from PROJECT_STARTER.md §9.1 in v1.25.0, carrying stale pre-`@directive` "Optional prose" wording that B-020 had superseded in v1.14.1. Manual review caught it; no mechanical check existed. This is *semantic drift* — the doc says X, the spec says Y, and B-023 (file-level) / B-024 (placeholder) / B-022 (byte-exact regions) don't compare doc-content against spec-content.
- v1.26.2: WORKFLOW.md's `Merge` section linked to `PROJECT_STARTER.md#16-branch-protection-on-main` — valid in v1.25.0, dead in v1.26.0 after BOOTSTRAP.md absorbed §1.6. The file existed (PROJECT_STARTER.md) so B-023 passed; the anchor was the missing piece.

Both are doc-vs-reality drift the v1.19.0 linter trio specifically didn't cover. Phase 3.2 of the Codex improvement plan named these gaps; B-029 closes them. The narrow forbidden-phrase approach for invariant checks was chosen over broader semantic analysis (e.g., NLP-based assertion-matching) for the same reason B-022 and B-024 are conservative: false-positive rate at zero is the only sustainable bar. New invariants get added when new regression classes surface — not speculatively. Per D-014's rationale, the bar for adding an invariant is "we've shipped this exact bug already." The URL-fragment check has zero ambiguity (anchor either matches a real heading or doesn't); the semantic check leverages backtick / code-fence stripping (proven safe in B-023 / B-024) to avoid matching legitimate code-example references.

**Test:** automated — (a) `./scripts/check-doc-references.sh` exits 0 on a clean checkout and prints `OK: <N> Markdown link targets resolved across <M> files (<F> URL fragments validated).`; planting a broken anchor (e.g. `[label](BOOTSTRAP.md#nonexistent)` in any *.md) exits 1 with `(broken URL fragment: #nonexistent in BOOTSTRAP.md)`. (b) `./scripts/check-spec-consistency.sh` exits 0 on clean state; planting `comment block contains Optional` in any active doc's plain prose exits 1 with `[Invariant A] forbidden phrase matched "comment block.*Optional": <line>`. The `template-self-test` CI job runs both on every push and PR.

**Status:** frozen

**Decision:** D-014

### Block B-031: smoke-test pre-flight integrity checks (B-014 extension)

**Rule:** `scripts/smoke-test.sh` runs two pre-flight integrity checks before the template-instantiation flow (B-014). Both target known past failure modes and run on the meta-repo files (not on the exported archive).

- **Check 0a — env-schema parses cleanly.** Sources `templates/scripts/_env-schema-parse.sh` with `EXAMPLE=templates/.env.example` and verifies the `VARS` array is populated with at least one entry. Catches: malformed `.env.example` that doesn't parse (e.g., orphan directive without var declaration; var-name regex mismatch; syntax error). The parser is the load-bearing contract for B-020; a malformed schema source would silently break `bootstrap.sh` + `check-env.sh` in consumer projects.
- **Check 0b — C4 trio regions carry substantive content (≥100 non-blank chars per region per file).** For each region in `C4_REGIONS=(gate-clause proposal-format bare-gogogo env-metadata-contract)` and each file in `C4_FILES=(WORKFLOW.md templates/CONTRIBUTING.md templates/CLAUDE.md)`, extract content between the `<!-- C4:<region>:start -->` and `<!-- C4:<region>:end -->` anchors, strip whitespace, count remaining characters. Fail if any region in any file has < 100 non-blank chars. Catches: a region that's been gutted to whitespace-only or near-empty content but where the anchors remain — the existing C4 rule-consistency linter (B-022) only errors on zero-byte regions via `[[ ! -s ]]`, so it would pass a region containing only whitespace.

Both checks run before the existing 7-phase smoke-test flow (export → extract → substitute → uv sync → pytest → ruff → mypy). Pre-flight failures abort the smoke test before any export work begins. Wired into CI via `.github/workflows/template-self-test.yml`'s existing `template-self-test / smoke` job (no separate step needed — same script).

**Rationale:** Phase 3.3 of the Codex improvement plan called for "expand smoke coverage where it closes a real past failure mode" — explicitly cautioning against broad smoke inflation. Two narrow checks were chosen:

- **0a (env-schema parse)** addresses a near-miss class: the `@directive` parser is consumed by both `bootstrap.sh` and `check-env.sh`; a syntax error in `templates/.env.example` would break consumer setup at first run, with no current automated check between the source file and the parser. The B-020 spec describes the contract; no test verifies the source actually conforms. v1.14.x parser-swap commits could have shipped a parsing regression; nothing caught it at the template level. This check closes that gap.

- **0b (C4 region content)** addresses a vandalism / accidental-emptying class. The B-022 linter ensures byte-exact match across the trio, but matches between three empty regions would pass — a silent loss of rule content. The `[[ ! -s ]]` check catches zero-byte but not whitespace-only or near-empty. The 100-char threshold is conservative (current regions average several hundred chars); near-empty content is a real warning signal.

The bar set by B-014 + B-029 ("driven by known failure modes, not broad coverage") is preserved: these two specific checks have specific failure modes they prevent, and the check-list won't grow speculatively. New checks added per shipped regression.

**Test:** automated — `./scripts/smoke-test.sh` runs both pre-flight checks and prints `✓ parsed N vars from templates/.env.example` + `✓ all 4 C4 regions ≥ 100 non-blank chars across 3 trio files` before continuing to phase 1. Planting a violation (e.g. `EXAMPLE=/tmp/nonexistent` for 0a; emptying a C4 region anchor body for 0b) fails the smoke test with the specific check name + the violating file / region / char count. CI runs the smoke test on every push and PR.

**Status:** frozen

**Decision:** — (no new D entry; B-031 is execution of Phase 3.3 under the framework set by B-014 + B-029)

### Block B-032: machine-readable template manifest

**Rule:** `templates/manifest.yaml` (repo root, ships in `templates/`) declares every file the kit either exports to a consumer project or maintains in the meta-repo. Each entry is a YAML map under the top-level `files:` sequence with these fields:

| Field | Type | Required | Purpose |
|---|---|---|---|
| `path` | string | yes | Path relative to the meta-repo root. |
| `purpose` | string | yes | One-line description of what the file is for. |
| `tier` | enum | yes | One of `common` (stack-agnostic; lands in future `_common/` per B-030), `python-preset` (stack-specific to Python/uv/FastAPI/VPS; lands in future `presets/python-uv/`), or `meta-only` (lives only in the meta-repo — linters, smoke-test, export-starter — and never ships to a consumer project). |
| `placeholders` | list[string] | yes | Canonical placeholder names (B-024 set: `package_name`, `PACKAGE_NAME`, `PROJECT_NAME`, `PROJECT_SLUG`, `GITHUB_USER`, `HOST`, `DOMAIN`, `PROJECT_DESCRIPTION`, `COPYRIGHT_HOLDER`, `YEAR`) that appear in the file as `<NAME>` and are substituted by consumers at bootstrap. Listed without angle brackets. Empty list if the file consumes none. Illustrative angle-bracket syntax in prose (`<METHOD>`, `<N>`, `<CMD>`, `<DEPLOY_CMD>`, etc. — anything outside the B-024 set) is intentionally NOT tracked; the placeholder-leak linter (B-024) already enforces that distinction. |
| `exported_by_starter` | bool | yes | `true` if `scripts/export-starter.sh` includes the file in the portable archive (all `templates/` contents plus the `ROOT_DOCS` array); `false` for `meta-only` entries. |

The manifest covers three categories: (a) the six root docs in `scripts/export-starter.sh`'s `ROOT_DOCS` array (PROJECT_STARTER.md, WORKFLOW.md, BOOTSTRAP.md, TEMPLATE_INVENTORY.md, DEPLOY_BASELINE.md, HARNESS_QUIRKS.md), (b) every file under `templates/`, and (c) every meta-only script under `scripts/` (the linter set + export-starter + smoke-test). Adding a new file in any of these locations requires appending an entry to the manifest in the same commit; the B-033 linter fails otherwise. The manifest format itself is intentionally simple — no nested structures beyond inline lists — so a bash `awk` parser is enough; no YAML library dependency.

**Rationale:** Phase 4.1 + 4.2 of the Codex improvement plan. `TEMPLATE_INVENTORY.md`'s human-prose table is the existing source of truth for "what ships and why," but it has three gaps: it's not machine-checkable (CI can't diff the actual file tree against the documented inventory), it doesn't carry the per-file tier classification that the future `_common/` + `presets/python-uv/` move (B-030) will need to be mechanical, and it doesn't make the placeholder consumption per file explicit. A YAML manifest with `path` + `tier` + `placeholders` + `exported_by_starter` per entry closes all three gaps in one artifact. Tier vocabulary matches B-030's layer model directly so when the file move ships, the manifest IS the move plan — each `common` entry moves to `_common/`, each `python-preset` entry moves to `presets/python-uv/`, `meta-only` stays put. Placeholder tracking enables the B-033 linter to enforce that every canonical placeholder in a file is declared in its manifest entry (catches drift where a file gains a `<PROJECT_NAME>` without manifest update). The format is YAML so humans can read it, but the schema is flat enough that a bash awk parser works — keeps the dependency story zero in line with every other check-script.

**Test:** manual (this commit) — `templates/manifest.yaml` exists and parses as YAML (round-trip via `python -c "import yaml; yaml.safe_load(open('templates/manifest.yaml'))"` succeeds); every entry has the five required fields; every `path` resolves to an existing file. Automated test ships in v1.31.1 with B-033's `scripts/check-manifest.sh`.

**Status:** frozen

**Decision:** —

### Block B-033: manifest linter — orphan / stale / placeholder-match enforcement

**Rule:** `scripts/check-manifest.sh` (repo root, executable) verifies `templates/manifest.yaml` (B-032) against the actual file tree, enforcing three invariants:

1. **No orphans.** Every regular file under `templates/` must have a manifest entry. Adding a file to `templates/` without updating the manifest fails CI. Scope is intentionally limited to `templates/` — meta-only scripts under `scripts/` are listed in the manifest for completeness but not enforced as orphans (adding a new linter shouldn't force a manifest edit in the same commit just to keep CI green; this is a future-tightening opportunity once meta-script churn settles).
2. **No stale entries.** Every `path` in the manifest must resolve to an existing file on disk. Covers all three tiers (`common` / `python-preset` / `meta-only`). Renaming or deleting a tracked file without updating the manifest fails CI.
3. **Placeholders match.** For each manifest entry under `templates/` (except the self-referential `templates/manifest.yaml`), the declared `placeholders` list must equal the set of B-024 canonical placeholders (`<package_name>`, `<PACKAGE_NAME>`, `<PROJECT_NAME>`, `<PROJECT_SLUG>`, `<GITHUB_USER>`, `<HOST>`, `<DOMAIN>`, `<PROJECT_DESCRIPTION>`, `<COPYRIGHT_HOLDER>`, `<YEAR>`) that actually appear in the file's content. Illustrative angle-bracket syntax in prose (`<METHOD>`, `<N>`, `<CMD>`, `<DEPLOY_CMD>`, etc.) is intentionally NOT tracked — same canonical-set distinction as `scripts/check-placeholders.sh` (B-024). Placeholders that appear only in path components (e.g. the literal `<package_name>` in `templates/src/<package_name>/__init__.py`'s path) are not content placeholders for that file. Root-exported docs (PROJECT_STARTER.md etc.) and meta-only scripts are excluded from invariant 3 because they mention canonical placeholder strings as references TO the substitution targets, not as substitution targets themselves; enforcing the match on them would false-positive on every doc that explains how placeholders work.

Wired into CI as a step in `.github/workflows/template-self-test.yml` alongside the other four linters. Also invoked from `scripts/smoke-test.sh` as a pre-flight check (Phase 0c, after B-031's 0a + 0b) — belt-and-suspenders for local-dev runs where developers may invoke smoke-test directly without running each linter separately. The CI redundancy is microseconds; the local-dev safety net is real.

Manifest parsing uses awk with field-by-field extraction; placeholder set comparison uses `LC_ALL=C sort -u` for locale-stable ordering. No YAML library dependency — keeps the dependency story zero in line with every other check-script. Pipefail-safe: `grep` calls that may return 1 on no-match are wrapped `(grep ... || true)` so empty cases yield empty output instead of killing the script.

**Rationale:** B-032 created the manifest as a data artifact. Without a linter, the manifest can drift in three ways: (a) someone adds a new `templates/` file but forgets the manifest entry (orphan); (b) someone deletes/renames a tracked file but leaves the stale manifest entry; (c) someone adds a canonical placeholder to a file (e.g. introduces `<HOST>` to a deploy script) without updating the manifest's `placeholders` list. All three drift patterns would erode the manifest's value as a machine-readable source of truth — the future `_common/` + `presets/python-uv/` file move (B-030) reads the manifest as its move plan. If the manifest is wrong, the move is wrong. This linter closes the gap.

The bar set by B-029 + B-031 ("driven by known failure modes; narrow false-positive surface") is preserved: each invariant has a concrete failure pattern, and the canonical-set scoping (matches B-024's set exactly) keeps prose mentions from triggering. The `templates/manifest.yaml` self-exclusion is necessary — the manifest documents paths that contain `<package_name>`, but the YAML data itself is not substituted.

**Test:** automated — `./scripts/check-manifest.sh` exits 0 and prints `OK: manifest valid — N entries, no orphans under templates/, no stale paths, placeholders match content.` Planted-violation tests confirm each invariant fires with a specific diagnostic: (1) `touch templates/test.tmp` triggers `✗ orphan: templates/test.tmp is under templates/ but not declared in templates/manifest.yaml`; (2) appending a fake-path entry triggers `✗ stale: templates/this-does-not-exist.txt declared in templates/manifest.yaml but does not exist`; (3) adding a missing placeholder to an entry's list triggers `✗ placeholder mismatch: templates/Makefile / declared: [HOST,PROJECT_NAME,package_name] / actual: [PROJECT_NAME,package_name]`. CI runs the linter on every push/PR.

**Status:** frozen

**Decision:** —

### Block B-034: kit is consumable as a toolkit; `MIGRATION.md` is the selective-import guide

**Rule:** `phoenixtemplate` supports two adoption paths, not one: (a) **fresh-start bootstrap** — `BOOTSTRAP.md` walks a greenfield project from zero to first commit (the default and original path); (b) **selective import** — `MIGRATION.md` documents how to adopt the kit incrementally into an existing project by importing one or more of four named layers without taking the whole kit. The four layers are: **process layer** (`CONTRIBUTING.md` + `CLAUDE.md` + `.claude/settings.json` + `.claude/skills/spec-block/` + the four C4-anchored regions); **docs** (`docs/pr_review_instructions.md` + `docs/karpathy-claude-rules.md` + optionally `docs/spec.md` skeleton + `spec-block` skill); **env-bootstrap** (the four-file unit: `.env.example` + `_env-schema-parse.sh` + `bootstrap.sh` + `check-env.sh`); **linter set** (the five `scripts/check-*.sh` linters, with per-linter standalone-vs-coupled status documented). `MIGRATION.md` ships as a root-exported doc — listed in `scripts/export-starter.sh`'s `ROOT_DOCS` array, in `scripts/check-doc-references.sh`'s `VIRTUAL_TEMPLATES_FILES` (for B-023 cross-link resolution in the archive layout), and in `templates/manifest.yaml` as `tier: common` / `exported_by_starter: true`. `README.md` carries a one-paragraph pointer at the top of the Quickstart section so consumers landing on the repo home page see the toolkit path before the greenfield path.

**Rationale:** Phase 5.1 of the Codex improvement plan. Prior to v1.32.0 the kit's documentation surface assumed greenfield-only adoption — `BOOTSTRAP.md`, `README.md`'s Quickstart, and `PROJECT_STARTER.md` all describe extracting the archive into an empty directory. Real-world adoption frequently isn't greenfield: a team has an existing repo with its own `CONTRIBUTING.md`, its own `.env.example`, its own conventions, and wants to standardize on the `gogogo!` gate OR the spec-block format OR the env-bootstrap convention without rewriting everything else. Without `MIGRATION.md` this consumer had no path — they either took the whole kit (incompatible with their existing repo) or reverse-engineered which files to copy (high friction, easy to miss dependencies). `MIGRATION.md` makes the toolkit affordance first-class: each of the four selective-import paths has a stated file list, a known merge surface, a standalone-vs-coupled assessment for each piece, and a suggested adoption order if the team wants the whole kit eventually but phased across weeks rather than landed at once. The kit is consumable as conventions + linters + templates; this block makes that affordance contractual.

**Test:** manual — `MIGRATION.md` exists at meta-repo root with the six sections (when-to-use / process layer / docs / env-bootstrap / linter set / adoption order / what-this-kit-doesn't-try-to-be); `scripts/export-starter.sh` `ROOT_DOCS` includes `MIGRATION.md`; `scripts/check-doc-references.sh` `VIRTUAL_TEMPLATES_FILES` includes `MIGRATION.md`; `templates/manifest.yaml` has a `MIGRATION.md` entry with `tier: common` and `exported_by_starter: true`; `README.md` Quickstart preamble references `MIGRATION.md`. All five linters green.

**Status:** frozen

**Decision:** —

### Block B-035: `scripts/render-example.sh` produces an inspectable example instantiation

**Rule:** `scripts/render-example.sh` (repo root, executable, meta-only — not exported by `scripts/export-starter.sh`) produces a deterministic, fully-substituted instantiation of the kit so consumers can see "what does a real project look like once the placeholders are substituted" without invoking `scripts/smoke-test.sh` (which requires `uv` + Python + network for dependency resolution and runs `pytest`/`ruff`/`mypy`).

**Output:** writes to `OUT_DIR` (default `~/Downloads/phoenixproject-example/`); directory is wiped + recreated on every run for clean reruns. Override via env: `OUT_DIR=/tmp/foo ./scripts/render-example.sh`.

**Canonical substitution map** (every B-024 canonical placeholder; values chosen to be unambiguous + obviously-example):

| Placeholder | Replacement |
|---|---|
| `<PROJECT_NAME>` | `ExampleProject` |
| `<PROJECT_SLUG>` | `example-project` |
| `<PROJECT_DESCRIPTION>` | `An example project rendered from the kit.` |
| `<package_name>` | `exampleproj` |
| `<PACKAGE_NAME>` | `EXAMPLEPROJ` |
| `<GITHUB_USER>` | `example-org` |
| `<HOST>` | `example.host` |
| `<DOMAIN>` | `example.com` |
| `<COPYRIGHT_HOLDER>` | `Example Org` |
| `<YEAR>` | `$(date +%Y)` |

**Substitution-logic invariant:** the script's substitution logic matches `scripts/smoke-test.sh` phase 3 byte-for-byte — same canonical pattern (one `mv` for the package-dir rename: `src/<package_name>` → `src/exampleproj`; one `sed` across the same multi-extension file set: `*.py` / `*.toml` / `Makefile` / `*.yml` / `*.yaml` / `*.sh` / `*.example`). If the smoke-test substitution logic changes, this script changes in the same commit. The smoke test is the executable-and-tested reference; `render-example.sh` is the inspectable-by-humans companion. Additional substitution scope for the canonical-map application: extends to `*.md` and `LICENSE` (smoke-test phase 3 doesn't apply non-`<package_name>` substitutions because they don't affect tooling correctness — they're cosmetic in the smoke context; this script applies them all because the purpose is humans-reading-output, not tooling-runs-clean).

**Why not a committed `example-project/` directory?** The script-only shape satisfies Phase 5.2's "consumers can compare template form to instantiated form concretely" acceptance at materially lower maintenance cost — anyone can produce the example in one command without it needing to live in the repo. A static-committed snapshot would duplicate ~30 files in the tree and require a CI drift check; the on-demand renderer eliminates both costs while preserving the comparison affordance. Documented in `README.md` and `MIGRATION.md` so consumers know the command exists.

**Rationale:** Phase 5.2 of the Codex improvement plan. The acceptance is "consumers can compare template form to instantiated form concretely." Two shapes satisfy it: (a) static committed `example-project/` directory with CI drift check, (b) on-demand render script. The Codex plan language ("keep one tiny instantiated example or a maintained snapshot") suggests (a), but the maintenance cost of duplicating every templates/ file with placeholders filled in — plus the linter to keep them in sync — is real and recurring. Shape (b) achieves the same comparison affordance with one script + a `README.md` pointer, no committed duplication, no drift surface. The script reuses the smoke-test's substitution logic so there's exactly one canonical implementation of "how a consumer substitutes" (smoke-test is the tested reference; render-example is the human-readable companion). If shape (a) becomes wanted later — for GitHub-browsable example without running anything — adding a committed `example-project/` directory + a CI check that re-renders + diffs is a straightforward extension; the render script becomes the renderer for that CI check.

**Test:** manual — `OUT_DIR=/tmp/rx ./scripts/render-example.sh` exits 0, prints `✓ rendered N files into /tmp/rx`. Post-render, `grep -rE '<(package_name|PACKAGE_NAME|PROJECT_NAME|PROJECT_SLUG|GITHUB_USER|HOST|DOMAIN|COPYRIGHT_HOLDER|YEAR)>' /tmp/rx` returns nothing — every canonical placeholder substituted. `grep -rE '<PROJECT_DESCRIPTION>' /tmp/rx` returns nothing — the bare form substituted (the longer instructional `<PROJECT_DESCRIPTION — one or two sentences.>` meta-syntax in `templates/README.md` is intentionally untouched; instructional meta-syntax in angle brackets is not in the canonical set). `templates/src/<package_name>/` directory rendered as `src/exampleproj/`. Smoke test (`./scripts/smoke-test.sh`) still passes — substitution-logic invariant preserved.

**Status:** frozen

**Decision:** —

### Block B-036: web-search before iterate on external surfaces

**Rule:** When Claude touches any external surface — APIs, SDKs, 3rd-party services, library/framework versions — the order of operations is **search-then-iterate**, not iterate-then-search. Four concrete triggers; the `WebSearch` proposal precedes any code-side action in each:

1. **New external surface.** Before writing integration code against an unfamiliar API/SDK/service/library, propose a `WebSearch` for current documentation, version-specific behavior, or breaking changes vs. the training-data version.
2. **External error or exception.** Before attempting a code-side fix for any error/exception/unexpected behavior originating from an external surface, propose a `WebSearch` of the exact error string or symptom.
3. **N=2 trip-wire.** After 2 failed iterations of the same external-behavior fix, STOP iterating on assumptions and propose a `WebSearch` for the specific symptom. "Maybe one more code change" past N=2 is forbidden.
4. **Self-noticed guessing.** Any time Claude notices it's reasoning about external behavior without concrete documentation or test backing, STOP and propose a `WebSearch`.

The `WebSearch` proposal is `[info]`-class per B-028 (read-only; no `gogogo!` needed); the user picks bare `N` to proceed with the search. Lowest possible friction between "we should check this" and "the answer is on screen." The rule applies **even when the relevant code looks in-training-data** — APIs/SDKs/services drift between minor versions and library/framework breaking changes are routine; the training snapshot is one point in time.

Scope: extends Karpathy Pitfall #1 (`templates/docs/karpathy-claude-rules.md` §1 — "Unexamined assumptions → Think before coding") with the explicit web-search tactic. `templates/CLAUDE.md`'s "Coding pitfalls to avoid" Pitfall #1 carries the session-facing summary; the full rationale + four triggers live in `templates/docs/karpathy-claude-rules.md` as a `### Web-search before iterate on external surfaces (B-036)` subsection under §1. Not a C4 region — Karpathy standing rules are not gate-related, they live in templates/CLAUDE.md + the dedicated reference doc (the C4-anchored regions are gate-clause / proposal-format / bare-gogogo / env-metadata-contract only).

**Rationale:** Claude's training data has a cutoff (January 2026 for the current model family) and external surfaces evolve constantly. A code-side iteration cycle on an external-behavior issue that turns out to be a known upstream bug + community workaround can burn hours; a `WebSearch` for the symptom typically surfaces the workaround in seconds. Karpathy Pitfall #1 ("verify load-bearing facts before depending on them") names the principle but doesn't name `WebSearch` as the concrete tactic; this block makes the tactic explicit and adds the N=2 trip-wire so the search isn't an afterthought-on-fail. The motivating incident: real bug on one of the user's other projects, fought code-side for half a day, turned out to be a known upstream issue everyone works around. A `WebSearch` of the symptom early in that session would have surfaced the workaround in seconds. This block exists so that failure mode doesn't repeat — across this project and every project that adopts the kit.

The four-trigger shape was chosen over single-trigger alternatives because each trigger catches a real failure shape the others miss (new-surface integration vs. error-on-known-surface vs. iteration-not-converging vs. self-noticed-guessing). N=2 was chosen as the iteration threshold — tight enough to avoid offer-fatigue (Claude proposing "should I google?" on every routine API call would train the user to ignore the offers); loose enough to allow one assumption-revision attempt before forcing the search. See D-018 for the full Considered / Why / failure-mode analysis covering the placement choice (Karpathy-extension vs. new 5th rule vs. Coding-Conventions entry) and the trigger-selection.

**Test:** manual — `templates/CLAUDE.md` Pitfall #1 contains the "For external surfaces specifically: ... propose a `WebSearch` *first*" extension with all four triggers named; `templates/docs/karpathy-claude-rules.md` §1 carries the `### Web-search before iterate on external surfaces (B-036)` subsection with full rationale + the four triggers enumerated; planted-behavior test (next session): when Claude hits an external-API error and starts to draft a code-side fix, the rule fires automatically before the code edit — proposing a `WebSearch` of the error string is the first response, not the second after a failed fix attempt.

**Status:** frozen

**Decision:** D-018

### Block B-037: emoji-prefixed `[change]` / `[info]` markers in the proposal format

**Rule:** The proposal-format markers defined by B-028 (per-option `[change]` / `[info]` classification) gain a single emoji prefix each, baked into the C4-anchored `proposal-format` region across the doc trio (WORKFLOW.md + templates/CONTRIBUTING.md + templates/CLAUDE.md):

- **`✏️ [change]`** — state-mutating options. Pencil emoji (edit / modify).
- **`👀 [info]`** — read-only options. Eyes emoji (look / read).

The emojis are visual markers only; they do NOT change the semantic contract from B-028. Authorization rules, gate scope, and multi-select syntax are all unchanged — `✏️ [change]` still requires `gogogo!`; `👀 [info]` still takes bare `N`; the literal `[change]` / `[info]` text in the marker remains the formal classification token.

Scope of the emoji prefix:
- **Always applied** at the start of each numbered option in a `Choose one:` or `Choose any (in order):` list.
- **Applied at the marker definitions** in the C4 `proposal-format` region (the lines documenting what each marker means).
- **Not applied** in running prose that references the type (e.g. "Multi-select against `[change]` options" stays bare; the bare token is the type, the emoji-prefixed form is the rendered marker).
- **Not applied** to `Single suggestion` proposals (no numbered options to mark).
- **Not applied** to section headers, status indicators, or anywhere else — the markers are the only place; visual weight stays where it matters.

**Rationale:** B-028 introduced the per-option `[change]` / `[info]` classification to give the gate signal back its precision (after the always-`gogogo!`-on-every-option pattern from v1.24.0 had been diluting it). The textual markers work, but they lend a uniform visual weight to every option — a long "Choose any (in order):" list with mixed types reads as a wall of bracketed text where the eye has to parse `[c-h-a-n-g-e]` vs `[i-n-f-o]` per option. A single emoji prefix per type makes the type recognizable at a glance without changing the rule. Pair chosen (✏️ + 👀) was selected from four candidates on humble-not-loud grounds — pencil/eyes are action verbs ("editing" / "looking") that match the semantic intent without competing for visual weight; alternative pairs considered: 🔧/📖 (wrench/book), ⚙️/ℹ️ (gear/info-symbol), 🛠️/🔍 (tools/magnifier) — see D-019 for the comparison. Pair #3 (✏️/👀) chosen.

The change is in-spec (the C4 region carries the emoji) rather than presentation-layer (spec stays as `[change]`/`[info]`, render-time adds emoji). In-spec keeps one source of truth and zero drift surface; the C4 linter (B-022) still works byte-exact on the new text including the emojis. Presentation-layer would require a second contract describing what the render rules are, doubling the surface for no benefit.

**Test:** manual — the four C4-anchored `proposal-format` regions across WORKFLOW.md + templates/CONTRIBUTING.md + templates/CLAUDE.md all contain `✏️ **[change]**` / `👀 **[info]**` in the marker definition line and `✏️ [change]` / `👀 [info]` in the bullet items. C4 linter (B-022) passes — regions are byte-exact across the trio. C5 spec-consistency linter passes — no forbidden phrases triggered. Smoke test pre-flight C4-content check (B-031 §0b) still passes — region content well above the 100 non-blank-char threshold.

**Status:** frozen

**Decision:** D-019

### Block B-038: forbid null-action options in proposals

**Rule:** Every numbered option in a `Choose one:` or `Choose any (in order):` proposal must represent a real action — code change, information lookup, navigation, or continued discussion. Null-action options are forbidden. Concrete forbidden phrasings include (non-exhaustive):

- "Stop here"
- "Wait"
- "Pick up later"
- "Wrap up"
- "Do nothing"
- "Decide later"
- "Skip / handle later"
- Any option whose action is "the user takes no further action" or "the conversation ends"

If the user wants to do nothing, they can simply not respond — they don't need a numbered option for it. Null options dilute the gate signal (each option carries equal visual weight; null options claim weight without surfacing real choice) and add visual clutter.

**Carve-out:** options to continue discussion, surface more information, ask clarifying questions, or refine the plan before action ARE real actions (they're `[info]`-class — read-only, no `gogogo!` needed) and stay. The distinction is: a real action moves the conversation forward concretely; a null action just terminates without progressing. "Discuss the blast-radius question more — give me a recent example" is a real `[info]` action (continues discussion productively); "stop here for now" is a null action (terminates without producing anything).

This rule refines B-027 (every assistant message ends with a concrete proposal when there's a path to surface) and B-028 (per-option `[change]` / `[info]` classification). B-027 says proposals SHOULD end every message when there's a path; B-028 classifies the options. B-038 adds: every option in those proposals must itself be a real path, not a null filler.

**Rationale:** Observed pattern across the session ending v1.34.0: many proposals included a trailing "stop here" / "pick up later" / "leave it open" / "wrap for now" option. User flagged it as "silly and redundant" — and they're right. The option adds zero choice: the user already has the implicit option to not respond, close the terminal, or steer in a completely different direction. Making "do nothing" a numbered choice doubles the action surface for no benefit, trains the user to ignore a third of every list, and dilutes the corrective swing back to clear authorization scope that B-028 was designed to restore.

The forbidden-phrasings list is non-exhaustive deliberately — the test isn't "does the phrasing match the list" but "does this option move the conversation forward concretely or just terminate." Wording variants of "do nothing" remain forbidden whether or not they appear in the literal list.

**Test:** manual — across the next N proposals after v1.35.0 ships, no proposal contains an option whose action is "do nothing" / "wait" / "stop here" / etc. Planted-violation test (subjective): if a proposal lists 3 options and one of them is essentially "the user takes no further action," the rule fires and the option is dropped before the proposal goes out.

**Status:** frozen

**Decision:** D-020

### Block B-039: `ONBOARDING_PROMPT.md` — structured bootstrap guide for new projects

**Rule:** `ONBOARDING_PROMPT.md` (kit meta-repo root; `tier: meta-only` in `templates/manifest.yaml`; NOT exported by `scripts/export-starter.sh`) is a structured prompt-document Claude reads and follows verbatim when a new user invokes the bootstrap flow. Frozen four-step structure:

- **Step 0 — WebFetch sanity check** (only fires if Claude reached the doc via `WebFetch`). Opportunistically informs the user about `/permissions` if WebFetch is disabled, but does NOT block bootstrap on enabling it; Steps 1–4 are self-contained and complete via paste-on-demand if WebFetch is unavailable.
- **Step 1 — Greet + introduce + ask Q1.** One assistant turn: short greeting + one-paragraph kit introduction + the first of six setup questions (project description) as a `👀 [info]` proposal per B-037 / B-028.
- **Step 2 — Ask remaining 5 questions, one per turn.** Q2 display name → Q3 URL slug (validated `^[a-z0-9][a-z0-9-]*$`) → Q4 Python package name (validated `^[a-z][a-z0-9_]*$`) → Q5 GitHub repo? (`Choose one:` with 3 options) → Q6 VPS deploy? (host + domain or skip). Each as its own turn with one-line acknowledgment of the prior answer. Re-prompt on invalid input.
- **Step 3 — Propose the concrete bootstrap as `✏️ [change]`.** Single proposal listing the canonical substitution map (all 10 B-024 placeholders with the user's values) + every file created/modified (sourced from `templates/manifest.yaml` entries where `exported_by_starter: true`) + `git init` + first commit. After `gogogo!`, reuse `scripts/render-example.sh` substitution logic for the `mv` + `sed` passes. If Q5 = create-now: detect `gh auth status` and surface `gh repo create` + branch protection + push as a SEPARATE follow-up `✏️ [change]` (split keeps interactivity awkwardness contained).
- **Step 4 — Hand off to normal session conduct.** One final summary message ("project bootstrapped; what you have; next reads") + one final concrete proposal — either a `👀 [info]` to discuss the suggested first feature or a `✏️ [change]` to start spec-ing it. **No null-action options per B-038** ("stop here" / "wrap up" forbidden).

The doc lives at meta-repo root, not in `templates/`, and is intentionally **not exported by `scripts/export-starter.sh`** — it's a bootstrap-time artifact, useful only until Step 4 hands off. Manifested as `tier: meta-only` to capture the "lives in the kit, doesn't ship to consumers" semantic (same pattern as `scripts/check-*.sh` and `scripts/render-example.sh`). Claude fetches it via `WebFetch` from the meta-repo's raw URL when a user pastes the canonical bootstrap prompt (typically discovered via [phoenixtemplate.com](https://phoenixtemplate.com), see D-021).

**Rationale:** Newbie adoption surface. The kit ships a lot of doc (BOOTSTRAP.md, WORKFLOW.md, TEMPLATE_INVENTORY.md, DEPLOY_BASELINE.md, HARNESS_QUIRKS.md, MIGRATION.md, templates/CLAUDE.md, templates/CONTRIBUTING.md, docs/spec.md), and "read all this before you can start" is the failure mode for less-experienced developers (the kit's actual target audience per the user's framing). ONBOARDING_PROMPT.md collapses the first-contact surface to a single paste-into-Claude-Code action: Claude reads it, asks six questions, scaffolds the project. The user gets a working project in ~5 minutes without having to read any doc themselves first; the doc-set becomes reference material AFTER bootstrap, not the entry point.

Four-step structure chosen over single-prompt or longer step counts: single-prompt-with-six-batched-questions would overwhelm a newbie and reduce iteration quality; longer step counts (8–10 micro-steps) would add ceremony without adding clarity. Four steps map cleanly to a mental model — greet, ask, propose, hand off — and align with the kit's existing 5-step `gogogo!` workflow shape (proposal-confirm-execute-verify-handoff is the analog).

Q5 split into a three-option `Choose one:` (create-now / not-yet / never) instead of a binary yes/no because the "create-now" path triggers `gh repo create` + branch protection + push (interactive `gh auth` may be involved); the "not-yet" path is the common case for developers who want to scaffold locally and decide GitHub later; "never" exists for local-only projects (POCs, scripts, throwaways). Three options surface the real lifecycle distinction.

Q6 (VPS deploy) made optional because not every project deploys to a VPS (many projects use Vercel / Fly / fly / Cloudflare Workers / etc., or are CLI tools with no deploy at all). The current preset bundles a `deploy.sh` aimed at VPS; future presets may differ per B-030's layer model.

**Test:** manual (this commit) — `ONBOARDING_PROMPT.md` exists at meta-repo root; `templates/manifest.yaml` lists it as `tier: meta-only` / `exported_by_starter: false`; manifest linter (B-033) passes; `scripts/check-doc-references.sh` (B-023) resolves all internal links from ONBOARDING_PROMPT.md (`templates/CLAUDE.md`, `templates/manifest.yaml`, `scripts/render-example.sh`, `docs/spec.md`); kit `README.md` Quickstart section references `phoenixtemplate.com` + the canonical paste-into-Claude prompt + WebFetch troubleshooting. Live-flow test (deferred — happens after Step 2 of the website rollout): paste the canonical prompt into a fresh Claude Code session in an empty directory and verify Steps 1–4 execute as described.

**Status:** frozen

**Decision:** D-021

### Block B-040: natural-language imperatives do not discharge the gate

**Rule:** A direct natural-language instruction to perform a `[change]` (state-mutating) action — e.g. "create the PR", "commit this", "push it", "merge it", "delete X", "ship it" — does NOT by itself satisfy B-026's gate conditions (a) or (b). It is a *request*, which Claude must restate as a concrete proposal and then execute only after the user's CURRENT message contains the literal `gogogo!` token (single `N gogogo!` / multi `N1 N2 ... gogogo!` per the proposal form). The `gogogo!` token is the **only** authorization channel for state mutation. Crucially, the rule is unconditional: it holds **even when Claude is fully confident it understood the instruction** and **even when the instruction looks unambiguous**. Confidence in the interpretation never substitutes for the token, because a correct guess is indistinguishable from a lucky one until after the irreversible action has already happened — and the gate exists precisely to keep a misread cheap (words on screen) instead of expensive (an executed `gh pr create`, `git push`, `rm`, deploy).

This clause is folded into the byte-exact C4 `gate-clause` region (B-022) across the doc trio (WORKFLOW.md + templates/CONTRIBUTING.md + templates/CLAUDE.md), so it is synced and linter-enforced like the rest of the gate. It refines B-026 (the propose-and-confirm gate) by making condition (b) explicit about what *isn't* the token, and reinforces B-027 (every assistant message ends with a concrete proposal): the correct response to an imperative is to surface the proposal the imperative is implicitly asking for, then wait.

**Rationale:** Shipped failure (this session, pre-v1.38.0): the user said "create a PR for this branch and I will do review" — a bare imperative with no `gogogo!` — and Claude ran `gh pr create` directly, publishing self-authored title/body prose to GitHub (an external, indexed surface) without ever surfacing it for confirmation first. The interpretation happened to be correct, which is exactly the trap: a correct guess feels like proof the behavior is safe, when it only means the dice landed well. Next time the imperative is ambiguous and the action is `rm`, a force-push, or a code rewrite, the same behavior runs the wrong thing with no words-on-screen stage to catch it. The user's framing: "we have been building all of this to make sure misreading will not happen, and it just happened" — the whole gate apparatus is an anti-misread mechanism, and treating natural language as the token reopens the misread channel the token was designed to close.

The rule already existed in weaker form — a single line in `templates/CLAUDE.md` ("Imperatives without `gogogo!` do not authorize"), but it lived OUTSIDE every C4 region (so the B-022 linter never enforced it) and was ABSENT from WORKFLOW.md and templates/CONTRIBUTING.md (so it was never synced across the trio). It was an orphan — present in one un-enforced place, which is why it didn't hold. B-040 promotes it into the canonical C4 `gate-clause` region where it becomes byte-exact, synced, and enforced; the pre-existing one-liner at templates/CLAUDE.md stays as deliberate session-facing reinforcement (the same redundancy pattern B-021 applies to the bare-`gogogo!` and mid-execution-deviation rules, which also appear both in a C4 region and as quick-reference one-liners). The "confidence never substitutes for the token" emphasis is the load-bearing addition over the orphaned line, which the failure showed was needed: the orphaned line stated the rule but didn't defend against the "but I'm sure I understood" rationalization.

**Test:** manual — the C4 `gate-clause` region across WORKFLOW.md + templates/CONTRIBUTING.md + templates/CLAUDE.md contains the "A direct natural-language instruction to perform a `[change]` action ... does NOT by itself satisfy (a) or (b) ... confidence that the instruction was understood never substitutes for it (B-040)" sentence; C4 linter (B-022) passes byte-exact across the trio; C5 spec-consistency linter passes. Planted-behavior test (next session): when the user issues a bare imperative for a state-mutating action ("commit this", "open the PR") with no `gogogo!`, the rule fires — Claude restates it as a concrete proposal with an invitation line and STOPS, rather than executing, regardless of how confident the read is.

**Status:** frozen

**Decision:** D-023

### Block B-041: negative handlers live in the loaded C4 region, not stranded in spec blocks

**Rule:** The byte-exact C4 `proposal-format` region (B-022, synced across WORKFLOW.md + templates/CONTRIBUTING.md + templates/CLAUDE.md) must carry not just the *positive* shape of a proposal (which markers, which invitation forms) but also the *negative handlers* — the constraints describing where a rule does NOT apply and what to do on misuse. As of v1.39.0 the region carries three previously-stranded handlers:

1. **Marker placement is exclusive (consolidates B-037's negative scope).** The `✏️`/`👀` emoji markers appear ONLY at the start of numbered options — never on status lines, section headers, the invitation line, single-suggestion proposals, or running prose that references a type.
2. **Conservative classification default (consolidates B-028).** Classifying each option `[change]` vs `[info]` is Claude's job; when in doubt, default to `✏️ [change]` (the gated side).
3. **Bare-`N`-against-`[change]` re-prompt (consolidates B-028's failure-mode handler).** If the user picks a bare `N` for a `✏️ [change]` option, re-prompt ("Option N is [change] — type `N gogogo!` to authorize") — never let a bare digit execute a state change. This is the inverse of the bare-`gogogo!` handler (which was already a loaded C4 region of its own).

The general invariant this block establishes: **when a gate/proposal rule has a "never here" / "re-prompt on misuse" / "default conservatively" clause, that clause belongs in the loaded C4 region, not only in its originating spec block.** Spec blocks remain the canonical *rationale + audit* home, but any handler that must fire at proposal-time must also be in the region Claude loads each session.

**Rationale:** Two shipped failures in one session (pre-v1.39.0) shared one root cause. (i) B-040: the "imperatives don't authorize" handler lived only in a non-loaded, non-synced one-liner — Claude ran `gh pr create` on a bare imperative. (ii) The emoji-placement failure: Claude put a `👀 [info]` marker on a status line, exactly the misuse B-037's failure-mode note at this spec's own text had *predicted* ("pressure to add emojis elsewhere — section headers, status messages — is real") — but the negative-scope mitigation lived in the B-037 spec block, which Claude doesn't load each session. An audit (the work that produced this block) then found a third stranded handler: B-028's bare-`N`-against-`[change]` re-prompt, a genuine safety handler whose absence from the loaded region meant a bare digit could slip a state change through. The structural flaw: the `proposal-format` region taught Claude what to *do* (positive shape) but consistently stranded what to *refuse* (negative handlers) in spec blocks that aren't in working context. B-041 fixes the pattern, not just the instances — it pulls the three known stranded handlers into the loaded region and names the standing invariant so future rule additions don't recreate the orphan. Sits in the same family as B-040 (which promoted one orphaned handler); B-041 generalizes that one-off into a rule about where handlers must live.

**Test:** manual — the C4 `proposal-format` region across the trio contains all three handler sentences ("markers appear ONLY at the start of numbered options — never on status lines..."; "when in doubt, default to `✏️ [change]`"; "If the user picks a bare `N` for a `✏️ [change]` option, re-prompt..."); C4 linter (B-022) passes byte-exact; C5 spec-consistency linter passes. Planted-behavior tests (next sessions): (a) Claude does not put `✏️`/`👀` on a status line or header — markers only on numbered options; (b) when uncertain whether an option mutates state, Claude marks it `[change]`; (c) bare `N` against a `[change]` option triggers a re-prompt, not execution. No automated coverage of chat output is possible (proposals live in conversation, not tracked files) — like B-036 / B-040 this is a runtime-behavior rule whose only enforcement surface is the loaded region's presence in working context, which is precisely why moving the handlers into that region IS the fix.

**Status:** frozen

**Decision:** D-024

### Block B-030: preset architecture — `_common/` shared layer + `presets/<preset>/` specific layer

**Rule:** When multi-preset support actually ships (not as of v1.30.0 — design only), the meta-repo's currently-flat `templates/` directory will be reorganized into two layers: `_common/` (stack-agnostic content shared across all presets — workflow docs, gate trio with C4 anchored regions, spec-block format, review rubric, env-bootstrap core, Karpathy rules, changelog conventions, meta scaffolding) and `presets/<preset-name>/` (stack-specific content — Makefile, CI workflow, deploy script, runtime pin, project metadata file, sample source tree, sample smoke test, setup-doc prereqs). A bootstrapped project = `_common/` contents flattened with one chosen `presets/<chosen>/` contents at the project root. Constraints: (1) single preset per project — mixed-preset out of scope; (2) no file conflicts between layers — each file has exactly one owner; (3) uniform placeholders — the B-024 canonical placeholder set works the same way across all presets; (4) C4 regions live in `_common/` — the byte-exact rule statements are stack-agnostic and don't get re-declared per preset. Design doc: `presets/PRESET_ARCHITECTURE.md`. **No implementation as of v1.30.0** — `_common/` and `presets/python-uv/` directories don't exist; `templates/` is unchanged; the design is the deliverable. Future implementation commits will create the directories, move files appropriately, update `scripts/export-starter.sh` to compose by preset, and update `scripts/smoke-test.sh` to test per-preset.

**Rationale:** D-009 (v1.8.0) committed to "Python/uv/FastAPI/VPS today; multi-preset roadmap" without specifying the architecture. Phase 4.3 of the Codex improvement plan called for "define `_common` vs preset boundaries before adding more presets" — addressing the gap. Without a clear layering design, future preset additions would risk: (a) re-deriving stack-agnostic content per preset, leading to drift; (b) file conflicts between preset-specific and shared content; (c) ambiguity about whether C4 anchored regions should be per-preset or shared. The layered model addresses all three: shared content has one home; preset-specific content has its own dirs; placeholders + C4 are uniformly shared via `_common/`. The standard pattern for multi-target scaffolds (`cookiecutter`, `copier`, similar tools) uses this two-layer approach. Alternative architectures considered + rejected — see D-015 for full Considered / Why analysis: branched repos (drift risk), single-tree with Jinja conditionals (hard to reason about with 3+ stacks), inverted naming (user-facing semantics worse). The chosen design preserves the AI-safety benefit of B-021's three-tier model (C4 regions stay in one place, every preset inherits them) while letting preset-specific content evolve independently.

**Test:** manual (design doc) — `presets/PRESET_ARCHITECTURE.md` exists at meta-repo root and specifies the layer model + composition rule + 4 constraints. Future implementation commits will be tested by per-preset smoke-test runs; that test infrastructure ships when the first multi-preset implementation commit lands. No automated test as of v1.30.0 — this is design-only.

**Status:** frozen (design; implementation deferred to future commits gated by this block)

**Decision:** D-015

### Block B-020: `.env.example` schema is declared via `@directive` comments

**Rule:** Each environment variable in `templates/.env.example` (and the resulting `.env.example` in consumer projects) carries machine-readable metadata via `# @directive: value` lines preceding the var declaration. Recognized directives:

| Directive | Type | Default | Purpose |
|---|---|---|---|
| `# @description: <text>` | string | (var name) | Human-readable purpose; bootstrap.sh shows it in prompts. |
| `# @required` | flag | (this is the default if neither @required nor @optional given) | Var must be set for check-env.sh to pass. |
| `# @optional` | flag | — | Var may be empty/unset. Mutually exclusive with @required. |
| `# @default: <value>` | string | empty | Default value bootstrap.sh suggests. |
| `# @validator: <ERE>` | regex | none | bootstrap.sh checks input against pattern; warns + offers override on mismatch. |
| `# @sensitive` | flag | auto-detected by var-name substring (TOKEN/SECRET/KEY/DSN/PASSWORD) | bootstrap.sh masks the value in display. |

Free-text comments (lines starting with `#` but without `@` prefix) preceding a var are displayed in bootstrap.sh prompts but not parsed as metadata. Per-var directives apply only to the immediately-following var declaration; section headers (e.g. `# === Service ===`) and file-level header comments can contain free-text without affecting metadata of subsequent vars. Directive names are matched case-insensitively (`@Optional` and `@OPTIONAL` are equivalent to `@optional`); unknown `@`-prefixed names emit a stderr warning and are ignored (catches typos like `@requried`). Duplicate directives in the same var's block use last-wins semantics. `@required` and `@optional` are mutually exclusive — last one wins; default-if-neither-given is required. The parser is shared between `bootstrap.sh` and `check-env.sh` via `templates/scripts/_env-schema-parse.sh` (sourced, populates global arrays).
**Rationale:** Codex Phase 3.1/3.2/3.3. Previously `bootstrap.sh` + `check-env.sh` inferred required/optional from prose (case-insensitive grep for "Optional" in any preceding comment line). Fragile — rewording the prose silently broke the gate. Directives make the schema explicit, parser-friendly, and self-documenting. The same machine-readable layer drives required-checking AND validator-enforcement AND sensitive-marking. `.env.example` remains the single source of truth (Phase 3.3 answered by the format choice — no separate schema artifact, no rendering layer). Inline-annotation chosen over a separate TOML/YAML schema because it keeps the schema next to the var declaration (one file to edit per change), and the directive vocabulary is flat enough to not need a structured config format. The shared parser helper (single source of parsing truth across both scripts) replaces ~30 lines of duplicated parsing that would otherwise drift.
**Test:** manual — `bash -n templates/scripts/{_env-schema-parse,bootstrap,check-env}.sh` clean; sourcing `_env-schema-parse.sh` with `EXAMPLE=templates/.env.example` populates `VARS`, `DESCRIPTIONS`, `DEFAULTS`, `VALIDATORS`, `IS_OPTIONAL`, `IS_SENSITIVE`, `COMMENTS` arrays matching the file's directives; `IS_OPTIONAL[SENTRY_DSN]` is set, `IS_OPTIONAL` is unset for every other var; `VALIDATORS[LOG_LEVEL]` is `^(DEBUG|INFO|WARNING|ERROR)$`; `IS_SENSITIVE[SENTRY_DSN]` is set both by `@sensitive` directive AND by the `DSN` substring auto-detect rule.
**Status:** frozen (v1.14.1 — parser enforces; data + parser aligned). Was draft in v1.14.0 (data migrated; parser still on legacy prose-grep).
**Decision:** —

## Decision log

One entry per architectural decision. Decisions live forever; chat history that produced them does not. Decisions marked `Superseded` retain their original Chose/Considered/Why content for audit trail; the supersession note explains what replaced them.

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

### D-004 (2026-05-17) `gogogo!` requires an action-verb prefix

**Status:** Superseded by D-010 (v1.23.0). The verb-prefix gate model is replaced by propose-and-confirm — Claude surfaces a concrete proposal (single suggestion or numbered choice), the user's `gogogo!` confirms exactly that proposal. The failure mode this decision originally prevented (bare `gogogo!` → wrong default workflow) is preserved in the new model; the corrective surface is shifted from a user-typed verb to a Claude-surfaced concrete proposal.

**Chose:** Treat `gogogo!` as the execute trigger only; require an action verb immediately before it specifying *what* to execute. Bare `gogogo!` triggers a clarification question.
**Considered:** (a) keep `gogogo!` as bare authorization that defaults to the 5-step code workflow, (b) require an explicit verb, (c) hybrid — bare allowed with implicit default.
**Why:** (a) opens a failure mode where the agent picks the wrong workflow on ambiguous bare `gogogo!` (e.g. opening a PR when the user meant "commit current work"). (c) is (a) with extra steps — the implicit default is still implicit. (b) makes the contract explicit: one verb per action, no defaults. Trades one extra word of typing for zero ambiguity at the gate. Verb table includes `PR`, `merge`, `deploy`, `commit`, `review`, `revert`, plus the conventional commit types (`feat/fix/chore/docs/refactor/test/perf`) that map to the full 5-step.
**Implemented in:** v1.3.0. Superseded v1.23.0 by D-010.

### D-005 (2026-05-18) Codex as default PR reviewer; rubric is reviewer-agnostic

**Status:** Superseded by D-008 (v1.7.0). The reviewer-agnostic principle survives in B-010; the Codex-as-default and GitHub-App-invocation parts are removed — project no longer specifies a default reviewer.

**Chose:** Make `templates/docs/pr_review_instructions.md` reviewer-agnostic (preamble names Codex / `/ultrareview` / other LLMs / manual as equally valid paths against the same rubric). Default reviewer is **Codex**, invoked via the GitHub App with a comment that explicitly references the rubric file. Reviewers run serially.
**Considered:** (a) keep `/ultrareview` as Path A / manual as Path B (current state — reviewer-locked), (b) Codex-default + rubric stays universal, (c) multi-reviewer in parallel (Codex + `/ultrareview` both run), (d) expand the `review gogogo!` verb to take a reviewer flavor.
**Why:** (a) privileges a Claude-family reviewer that shares the author's blind spots. (c) wastes budget for typical PRs; the user does manual review separately when a branch is finished, so parallel automation is redundant. (d) was explicitly rejected by the user — review is done out-of-session against a finished branch, not dispatched mid-branch from Claude. (b) wins: same rubric, cheaper + independent reviewer by default, no verb-mapping churn.
**Implemented in:** v1.4.0.

### D-006 (2026-05-18) One-command Codex trigger via PR-comment skill (not local CLI) — SUPERSEDED

**Status:** Superseded by D-007 on 2026-05-18 (same day). The premise — that a Codex GitHub App existed on the user's account to pick up `@codex` PR comments — turned out to be wrong; no App is installed. The local CLI has a purpose-built `codex review` subcommand the original analysis missed. D-007 captures the corrected design.

**Chose:** Build a `request-codex-review` skill + `make request-codex-review` Makefile target that post a canonical PR comment via `gh pr comment` (Path 1 + Path 3 from the design discussion). The GitHub App picks up the comment and Codex posts findings back to the PR.
**Considered:** (a) just use `gh pr comment` manually each time (status quo), (b) wrap the local Codex CLI (`codex --prompt "review PR #N ..."`) so reviews run synchronously in the same terminal, (c) skill + Makefile wrapper around `gh pr comment` (this option), (d) full background-agent dispatch with polling.
**Why:** (a) loses the canonical comment body — easy to forget naming the rubric file, which is load-bearing for Codex behavior. (b) duplicates the GitHub App for no added value: same Codex, but burns the user's OpenAI quota, serializes work in the local terminal, and adds setup overhead. (d) over-engineers an async workflow the user has explicitly said they prefer fire-and-check. (c) is minimal: zero new deps, matches the user's existing habit of triggering Codex out-of-session, makes the rubric reference mechanically guaranteed.

**Why it was wrong:** my framing of option (b) was incorrect — I called it "duplicates the GitHub App for no added value" without checking whether the App actually existed on the user's account (it doesn't) or what the local CLI's capabilities were (it has `codex review --base <branch>` purpose-built for exactly this). Both were knowable from a 30-second probe. See D-007.

**Implemented in:** v1.5.0. Reverted in v1.6.0 per D-007.

### D-007 (2026-05-18) Pivot `request-codex-review` from GitHub App to local CLI

**Status:** Superseded by D-008 on 2026-05-18 (same day). The whole `request-codex-review` skill + Makefile target it shipped was removed in v1.7.0; review is now out-of-band and the project ships no reviewer wiring at all. The "local CLI works and finds real issues" finding still stands — it's just no longer relevant to what the project ships, because the project ships no invocation path for any reviewer.

**Chose:** Reimplement the `request-codex-review` skill + Makefile target around `codex review --base main` (local CLI). Drop the GitHub-App-comment path as the default; document it as a fallback that only applies if the user installs a Codex App later.
**Considered:** (a) keep the GitHub App skill (B-008) and add a parallel CLI skill, (b) supersede B-008 entirely with the CLI path, (c) build a `codex exec` wrapper instead of `codex review` so we can pass our exact rubric.
**Why:** (a) leaves an inert skill that can't fire on this user's account — confusing for future readers. (b) is honest: the user doesn't have an App, codex IS installed locally, and the CLI has a purpose-built `review` subcommand that found three real bugs on its first run (the v1.5.0 → v1.5.1 patch). (c) is a real option for strict rubric compliance but adds complexity; `codex review`'s built-in `P1/P2/P3` format maps cleanly to our `Block/Strong/Nit` and is good enough for the default path. (c) stays documented as the escape hatch when rubric compliance matters.
**Implemented in:** v1.6.0. Triggered by discovering (via a read-only `gh api` probe) that no Codex GitHub App is installed on the user's account, plus the v1.5.0-branch dry run that proved `codex review --base main` works and finds real issues.

### D-008 (2026-05-18) Remove all Claude-side reviewer wiring; review is out-of-band and reviewer-agnostic

**Chose:** Delete the `request-codex-review` skill, the `make request-codex-review` Makefile target, and the `review gogogo!` verb. Rewrite `templates/docs/pr_review_instructions.md` as a reviewer-agnostic rubric that names no default reviewer. After `PR gogogo!`, the user opens any reviewer they prefer in a separate session, points it at the open PR and the rubric, and the reviewer posts comments via `gh` directly. Claude is out of the review business entirely.
**Considered:** (a) keep the v1.6.0 local-CLI skill and add a posting step so it satisfies the per-commit-comment contract; (b) switch to an interactive Codex TUI launcher (Makefile + reminder skill that prints the command in Claude); (c) remove all Claude-side wiring and make review fully out-of-band, reviewer-agnostic (this option).
**Why:** (a) keeps Claude in the reviewer-dispatch business and continues the pattern of assuming a specific external tool (Codex CLI, GitHub App) is the canonical path. (b) was the planned v1.7.0 path until the user explicitly rejected it — "no make, no nothing. I go to different terminal, start codex, ask him to look around and look at pr review instructions, then review latest pr" — followed by "instructions should be agnostic to reviewer." (c) is the honest scope: Claude opens the PR (`PR gogogo!`); review is whatever the user does in a separate terminal with any reviewer they prefer. The rubric stays because it's reviewer-agnostic — but the wiring and the verb both go. Resolves the [P1] Codex flagged on the v1.6.0 branch by removing the contradiction (Claude no longer claims a per-commit-comment contract it can't satisfy from a stdout-only skill). Supersedes D-005 (Codex-as-default) and D-007 (local-CLI skill); D-006 was already superseded by D-007 in v1.6.0, retained as audit trail.
**Implemented in:** v1.7.0. Triggered by user feedback that v1.6.0's skill — and the v1.7.0 launcher I'd planned in its place — were both Claude-side wiring for a user-side action. The rubric file is the only artifact the project needs to ship; the reviewer is whoever the user runs.

### D-009 (2026-05-18) Product identity: Python/uv/FastAPI/VPS starter now; multi-preset later as roadmap

**Chose:** Declare `phoenixtemplate` a **Python/uv/FastAPI/VPS-shaped starter** in its current form. The bootstrap process, `gogogo!` gate convention, 5-step workflow, spec-block format, Karpathy standing rules, and reviewer-agnostic PR-review rubric are stack-agnostic and apply to any project. The language-preset scaffolding (`Makefile`, CI workflow, `scripts/deploy.sh`, `templates/.env.example` validators) is Python-only today. Multi-preset support (Node/pnpm, Go, no-runtime) is **roadmap**, not current fact.
**Considered:** (a) ship Python-only and frame the repo accurately as a Python starter now (this option); (b) build multi-preset support (`templates/_common/` + `presets/python-uv/`, `presets/node-pnpm/`, etc.) *before* the next release so the agnostic claim becomes true; (c) keep claiming "project-agnostic" everywhere and hope the gap doesn't bite consumers.
**Why:** (a) is the honest near-term framing. Codex's improvement plan flagged the gap directly: top-level docs say "project-agnostic" but `templates/Makefile` invokes `uv run uvicorn`, CI assumes `pyproject.toml` and `src/<package>/`, and `scripts/deploy.sh` is VPS-shaped. (b) is the right long-term direction but is multi-week work — building presets before declaring identity puts a strategic decision on the critical path of weeks of scaffolding. (c) is the status quo and is dishonest by construction. The reframe is one commit; multi-preset can land later when the architecture is designed (see open item: "Stack-agnostic restructure — roadmap per D-009"). Until then, "Python/uv/FastAPI/VPS starter" matches what consumers actually get.
**Implemented in:** v1.8.0. Triggered by Codex's improvement-plan review (`codex improvement plan.md`) flagging the agnostic/Python mismatch as Phase 2 + Phase 12 work. Reframes PROJECT_STARTER.md top section + adds a Current Scope subsection. Does not change templates or shipped code — only the framing.

### D-010 (2026-05-19) Gate model: propose-and-confirm replaces verb-prefix

**Chose:** Replace the verb-prefix gate model (B-001 + B-011 + D-004) with a propose-and-confirm gate. Claude must surface a concrete proposal — single suggestion or numbered choice — in its immediately preceding assistant message, naming specific files / commands / commits. The user's `gogogo!` (or `N gogogo!` for a numbered choice) authorizes exactly that proposal. There are no action verbs; the action description lives in the proposal in plain English. Bare `gogogo!` without a preceding proposal triggers a clarification prompt. Conversation drift (user asked a question, Claude answered without re-proposing) requires Claude to re-propose before any action.

**Considered:** (a) keep verb-prefix model (the v1.3.0–v1.22.0 status quo — verbs encode workflow type); (b) propose-and-confirm with re-ask before EVERY state-mutating sub-step (extremely high friction for multi-step workflows); (c) propose-and-confirm with one-message-lifetime proposals (this option — one `gogogo!` authorizes a multi-step plan I enumerate upfront, preserving current ergonomics); (d) hybrid — verbs as optional accelerators alongside propose-and-confirm (two parallel models, all the failure modes of both).

**Why:** (a) put the cognitive burden on the user (remember nine verbs, remember mapping) and only encoded action TYPE (commit-only vs 5-step), not action SCOPE — a `commit gogogo!` could commit anything Claude had staged. (b) is exhaustingly verbose for the 5-step workflow that already requires one `gogogo!` for many actions; would break current ergonomics. (c) preserves the multi-step ergonomic (one `gogogo!` for a multi-step plan) while shifting burden to Claude (propose concretely) and adding a strictly stronger safety property: the user confirms a plan that names files/commands, not just an action type. The "immediately preceding message" constraint catches conversation drift — a user `gogogo!` after Q&A back-and-forth must trigger re-propose, not action on a stale plan. (d) was tempting for users who know exactly what they want, but two parallel gate models would confuse the doc trio about which is canonical and would have all the failure modes of both.

**Failure-mode analysis:**
- D-004's original failure ("agent picks wrong workflow on bare authorization") is preserved: bare `gogogo!` without a prior proposal is still invalid. The corrective surface just moves — from a user-typed verb to a Claude-surfaced concrete proposal.
- New failure mode PREVENTED by propose-and-confirm: "agent picks wrong file/scope under a correctly-formed verb." Verbs only encoded workflow type; the proposal encodes everything.
- New failure mode it could INTRODUCE: "agent proposes vaguely ('commit the changes'), user `gogogo!`s, agent picks wrong scope." Mitigated by the explicit "concrete" requirement in B-026 condition (a) — vague proposals don't satisfy the gate. The canonical `proposal-format` C4 region (B-022) makes "concrete" mechanically inspectable in the doc trio.
- New failure mode it could INTRODUCE: "user `gogogo!`s after long Q&A drift expecting an old proposal still valid." Mitigated by the IMMEDIATELY-PRECEDING-MESSAGE constraint: drift → Claude re-proposes before acting.

User feedback explicitly named the safety property: *"always re-ask users, so he confirms your understanding"* — the proposal IS the re-ask.

Supersedes D-004.

**Implemented in:** v1.23.0. Touches: B-001 + B-011 → historical (superseded by B-026); B-026 added (frozen, the new gate rule); B-021 content (the duplicated-rule-statement list now names `gate-clause` / `proposal-format` / `bare-gogogo` instead of `gate-clause` / `verb-table` / `bare-gogogo`); B-022 content (C4 linter `REGIONS` array updated to match — `verb-table` removed, `proposal-format` added); `scripts/check-rule-consistency.sh` `REGIONS` array; full rewrite of the gate sections in `PROJECT_STARTER.md` §2, `templates/CONTRIBUTING.md`, and `templates/CLAUDE.md` (the doc trio per B-021). Refined v1.23.1 by a doc-prose sweep of remaining verb references in active surfaces (no rule changes). Refined v1.24.0 by D-011 (multi-select syntax, always-propose, keep-gogogo!) — see D-011 entry below.

### D-011 (2026-05-19) Gate refinements: keep `gogogo!`, always-propose, multi-select

**Chose:** Three refinements to the v1.23.0 propose-and-confirm gate (B-026):

1. **Keep `gogogo!` as the gate token** — rejected renaming to `go!` / `gogo!` / strict-message-only. D-001's false-positive protection (distinctive, rare in casual English) survives in the propose-and-confirm era; the ergonomics gain from 4-char `gogo!` doesn't outweigh the small additional safety margin of 7-char `gogogo!`.
2. **Always end every assistant message with a concrete proposal** (formalized as B-027). Every assistant turn ends with one of the three canonical invitation forms. Even clarification turns get a trailing proposal so the user can `gogogo!` forward motion without an extra round-trip.
3. **Multi-select syntax: `N1 N2 ... gogogo!`** against a "Choose any (in order):" proposal. From such a list, the user can authorize multiple options in one message; the digit sequence preceding `gogogo!` (whitespace-separated, walked backwards from `gogogo!` until a non-digit token) is the explicit ordered list. Skipping is fine (`1 2 4 5 gogogo!` runs options 1, 2, 4, 5 in order; skips 3). Multi-select against a "Choose one:" proposal (where options are mutually exclusive) is invalid → re-prompt. The user's insight that drove this design: each authorized item was a concrete proposal Claude already surfaced and the user inspected, so safety is preserved — multi-select doesn't pre-auth unknown future proposals, it batches known ones.

**Considered:**

For (1): renaming to `go!` (rejected — false-positive risk on natural English "let's go!" / "don't go!"); `gogo!` 4-char compromise (rejected — minor ergonomics gain, slightly higher false-positive risk than `gogogo!`); `go!` strict-message-only (rejected — restrictive, can't combine with comment).

For (2): leave implicit (rejected — leads to forced extra round-trips every clarification turn); apply only after action turns, not clarifications (rejected — clarifications without proposal are exactly where round-trips proliferate).

For (3): `gogogo!N` pre-auth of N unknown future proposals (rejected — weakens the load-bearing safety property B-026 added); `autopilot gogogo!` open-ended auto mode (rejected — same hole, unbounded); pre-auth with risky-action carve-out (rejected — band-aid on a weaker model); richer batched proposals only — no gate change (considered as the safe alternative but doesn't help when the AI discovers sub-actions mid-execution); **multi-select from already-proposed numbered lists** (chosen — strict extension of single-pick, no safety weakening).

**Why (1):** D-001's analysis is still valid: `gogogo!` is distinctive enough to never accidentally fire in natural conversation. Even with propose-and-confirm's belt-and-suspenders, casual "let's go!" appearing right after a proposal is a real risk the longer form eliminates. Ergonomics cost is small — 7 chars vs 4 chars, typed maybe 50× a day during heavy session work. Not worth the rename churn.

**Why (2):** User feedback was direct ("always REASK"). The propose-and-confirm gate's value is the user only needs to type `gogogo!` to authorize. If Claude's reply ends with a question, that benefit evaporates — user has to formulate a request, then wait for Claude to propose, then `gogogo!`. Always-propose lets the user act in one keystroke-worth even when they haven't articulated a request yet. The trailing proposal is the assistant doing the articulation work.

**Why (3):** Multi-select preserves the v1.23.0 safety property — every authorized item was a concrete proposal already surfaced. This is the key difference from the pre-auth shapes initially proposed (`gogogo!N` / autopilot), which would have authorized unknown future proposals. The user's framing made this distinction clear: pre-auth of seen items is safe; pre-auth of unseen items is not. Multi-select also handles natural workflow batches — "do tasks 1, 2, 4 from this list" — without forcing a separate `gogogo!` cycle per task. Distinguishing "Choose one:" from "Choose any (in order):" header forms makes the proposal's intent explicit (mutually exclusive alternatives vs independently-runnable batch) and the multi-select-against-choose-one failure mode mechanically detectable.

**Failure-mode analysis:**

- (1) inherits D-001's analysis unchanged.
- (2) failure mode if violated: assistant ends a turn with a question → user must re-elicit a proposal → extra round-trip. Mitigation: explicit block (B-027) makes the property part of the spec.
- (3) failure mode A: user multi-selects against a "Choose one:" proposal. Mitigation: my proposal explicitly labels the form ("Choose one:" vs "Choose any (in order):"); multi-select against "Choose one:" is invalid → I re-prompt rather than execute conflicting options.
- (3) failure mode B: I forget to label the form and it's ambiguous → user infers wrong → bug. Caught at user-inspection time; user can reject. Future improvement: extend the C4 linter to verify that any "Choose..." header in the assistant's transcripts uses one of the two canonical forms.

**Implemented in:** v1.24.0. Touches: B-026 content updated in place (gate clause condition b allows multi-digit; proposal-format description extended to three forms; always-propose property merged into the rule); B-027 added (frozen — the always-propose requirement); doc trio gate-clause + proposal-format C4 regions rewritten byte-exact; supporting prose in PROJECT_STARTER.md §2.1 / templates/CONTRIBUTING.md / templates/CLAUDE.md extended (self-check now 5 steps; refuse-list gains 2 new rows). No new linter machinery — same three C4 regions, just different content.

### D-012 (2026-05-19) PROJECT_STARTER.md remains a permanent thin-index entry-point

**Chose:** PROJECT_STARTER.md is the **permanent** thin-index entry-point for the kit. It owns the kit's title page, the Template version metadata (per B-002), the Template changelog table (per-version diary of this doc itself), and the docs-table linking the 5 companion files. Its content is **finalized** post-v1.26.0 — no further section reductions or further file restructures planned. The thin-index shape is the target end state, not a transitional one.

**Considered:** (a) Keep PROJECT_STARTER.md as a thin index permanently (this option); (b) merge PROJECT_STARTER.md into BOOTSTRAP.md and delete the file entirely (docs table would move to BOOTSTRAP.md's preamble; Template version + changelog would move to docs/spec.md or BOOTSTRAP.md; B-002 would need to be rewritten or superseded); (c) drop PROJECT_STARTER.md and use README.md as the entry-point instead.

**Why:**

- (a) — chosen. PROJECT_STARTER.md has been the entry point throughout the project's history; the name is established. The file's content post-v1.26.0 (title + Template version + intro + docs table + Template changelog tail) is genuinely the minimum viable index; no further reduction would add value. The Template changelog in particular has nowhere natural to live other than the file it describes.
- (b) — rejected. It requires rewriting B-002 (which currently binds Template version + Template changelog to PROJECT_STARTER.md). The Template changelog is per-doc state; it belongs in the file it describes, not in BOOTSTRAP.md (which describes consumer bootstrap procedure, not the kit's own evolution). Moving it would mix concerns. The "one fewer root file" win doesn't justify the B-002 rewrite churn or the concern-mixing.
- (c) — rejected. README.md is GitHub-rendered at the repo root and serves the "first contact for a visitor on github.com" purpose. PROJECT_STARTER.md serves a different purpose: in-repo navigation hub once you've cloned/exported the kit. README.md is the consumer-facing landing page; PROJECT_STARTER.md is the kit's internal index page. These are complementary, not duplicative — collapsing them would lose the distinction between "what GitHub renders to visitors" and "what consumers see at the root of their cloned kit."

PROJECT_STARTER.md's settled role:

- Owns the **Template version** line (B-002 anchor — bumped on every change).
- Owns the **Template changelog** table (per-version diary specific to this doc; a row per release; ~47 rows as of v1.27.1).
- Provides the **docs table** — single navigable index from the kit's root to the 5 companion docs (BOOTSTRAP / WORKFLOW / TEMPLATE_INVENTORY / DEPLOY_BASELINE / HARNESS_QUIRKS) without requiring the user to grep for filenames.
- Maintains the historical name for consumers carrying expectations from earlier versions.

**Implemented in:** v1.27.1. Touches: this decision entry; B-025 Rule field gains a sentence noting that PROJECT_STARTER.md's thin-index shape is permanent per D-012 (not transitional). No file restructure required — v1.26.0's structure already matches the chosen permanent state.

### D-013 (2026-05-19) Gate refinement: per-option `[change]`/`[info]` classification + scoped `gogogo!`

**Chose:** Add B-028 (per-option `[change]`/`[info]` classification + per-option gate scope) and refine B-027 (always-propose becomes "propose when there's a path to surface; pure discussion turns can end naturally"). `gogogo!` is required only for `[change]` options; `[info]` options take bare `N`. Single-suggestion proposals get the same classification: state-mutating single suggestions end with `Type \`gogogo!\` to proceed.`; pure-info single suggestions end naturally.

**Considered:** (a) Adopt B-028 + refine B-027 as described (chosen — this option); (b) drop B-027 entirely (no always-propose default; round-trip prevention becomes soft preference); (c) keep B-027 strict, just add per-option markers (no relaxation in discussion mode); (d) different marker syntax — `(action)`/`(info)`, `🔧`/`💬`, or no markers (rely on invitation-line phrasing).

**Why:**

- (a) — chosen. Preserves B-026's safety property (literal `gogogo!` for state changes) without the ceremony tax. The per-option granularity matches real-world ambiguity: a single Choose-one can mix "open PR" (state-mutating) with "pause and think" (read-only); blanket-gating both was over-gating. Refining B-027 acknowledges that always-propose was an over-correction for round-trip pain that only exists in execution mode. Together: B-027 says "propose when the user might want to act"; B-028 says "the proposal's options are per-option-gated by their state-mutation risk."

- (b) — rejected. Dropping B-027 entirely re-opens the round-trip pain in execution mode (user types something, Claude answers with a question, user has to re-elicit a proposal, then `gogogo!` — three turns for one action). The refinement option preserves the no-round-trip property without the ceremony.

- (c) — rejected. Per-option markers without relaxing B-027 still forces `gogogo!`-shaped invitations in pure discussion turns, even if some options become bare-`N`. Doesn't fully address the dilution concern.

- (d) — rejected on marker syntax. `**[change]**` / `**[info]**` is explicit text that the C4 linter can byte-exact-match; visual icons (🔧/💬) are less greppable and harder to anchor in rule regions; parenthetical `(action)`/`(info)` reads more like an annotation than a rule-load-bearing marker. The explicit-text markers also self-document for readers who haven't internalized the convention.

**Failure-mode analysis:**

- D-011's original framing of B-027 prevented round-trips by always-proposing. D-013 preserves that prevention in execution mode (where it matters) and drops it in discussion mode (where it was dilutive ceremony). Net safety: unchanged. Net ergonomics: improved for discussion turns.

- New failure mode B-028 could introduce: Claude mis-classifies an option, treating something state-mutating as `[info]`. Mitigation: conservative-default-`[change]` for borderline cases; mid-execution re-classification rule requires STOP-and-re-propose if reality reveals an `[info]` option actually mutates state. Auditable post-hoc but not preventable at proposal time. Acceptable trade-off — the more common case (user types unnecessary `gogogo!` on a misclassified-as-`[change]` option) is harmless.

- User-side failure: user types bare `N` against a `[change]` option by typo or habit. Mitigation: Claude re-prompts. State mutation requires the literal `gogogo!` substring; bare digit doesn't authorize.

- Edge case: mixed multi-select. `1 2 3 gogogo!` against a "Choose any (in order):" list where 1 and 3 are `[change]`, 2 is `[info]`. One `gogogo!` covers `[change]` items in the typed sequence; `[info]` items proceed in the same message. Maintains "one authorization signal per user turn" simplicity.

User feedback drove the design: *"i suggest we add gogogo! to only items that do code docs database and other changes. if the list has items that are for discussion or like research etc its og to just enter option number."* — the per-option classification operationalizes that intent.

Refines D-011 (which froze B-027's original "always propose" framing). B-026 (the propose-and-confirm gate proper) is unchanged in its conditions — D-013 only refines what kinds of options trigger the `gogogo!` requirement.

**Implemented in:** v1.28.0. Touches: C4 `gate-clause` region updated byte-exact across the doc trio (condition b explicitly handles `[change]` vs `[info]` selection); C4 `proposal-format` region rewritten byte-exact to describe the marker convention + per-option gate scope + discussion-mode relaxation; supporting prose in WORKFLOW.md §2.1 self-check list + refuse-list (gains rows for "force proposal in pure discussion", "bare N against [change]", "info → change re-classification"); supporting prose in `templates/CONTRIBUTING.md` self-check list updated similarly. B-027 content updated in place (status flipped from original "every message must propose" to refined framing); B-028 added (frozen). No C4 region added or removed — same 4 regions (gate-clause / proposal-format / bare-gogogo / env-metadata-contract), just different content in the first two.

### D-014 (2026-05-19) Extend B-023 + add narrow forbidden-phrase spec-consistency linter

**Chose:** Two parallel automation surfaces — (a) extend the existing `scripts/check-doc-references.sh` (B-023) with URL-fragment validation (GitHub-slug computation + match against headings in the target file); (b) add a NEW `scripts/check-spec-consistency.sh` doing narrow forbidden-phrase checks on the 5 active root docs against invariants derived from frozen spec behavior. Both are wired into CI. Invariant list starts with one entry (A — env-metadata `@directive` contract per B-020); extensible as new regression classes surface.

**Considered:** (a) extend B-023 + add forbidden-phrase linter (chosen); (b) only extend B-023 (closes URL-fragment class only, leaves semantic-drift class open); (c) broader semantic analysis (NLP-based assertion matching of doc claims against spec claims — too much false-positive risk for v1); (d) add tighter C4 rule-consistency regions across more rules instead (over-anchoring; not all spec invariants are duplicated-rule patterns); (e) defer entirely and rely on manual audit (status quo until v1.29.0; rejected because the v1.26.1 + v1.26.2 regression pair proved manual audit is insufficient).

**Why:**

- (a) — chosen. Two narrow tools each closing one well-defined gap:
  - URL-fragment validation: pure mechanical check, zero ambiguity (anchor matches a heading slug or it doesn't), low false-positive rate.
  - Forbidden-phrase invariants: conservative; each entry is an exact ERE pattern manually selected after a regression has been shipped. Bar for new invariants is "we've shipped this exact bug already." Avoids the false-positive trap of broader semantic checks.

- (b) — rejected. Would close v1.26.2's URL-fragment class but leave v1.26.1's semantic-drift class open. The two regressions are sibling failure modes; closing one without the other leaves the door open.

- (c) — rejected. Broader semantic analysis (e.g., asserting "every active doc claim about X matches the spec claim about X" via NLP / parsed AST) has unbounded false-positive surface. The narrow approach is incrementally extensible: add one specific pattern per shipped regression, no speculative coverage.

- (d) — rejected. C4 (B-022) is for *deliberately-duplicated* rule statements across the doc trio (gate-clause, proposal-format, bare-gogogo, env-metadata-contract). Adding regions for every spec invariant would over-anchor — many spec invariants aren't trio-duplicated for AI safety; they live in one canonical doc + spec. The forbidden-phrase approach handles single-source claims that contradict spec.

- (e) — rejected. Status quo failed twice in one PR cycle (v1.26.1 + v1.26.2). Manual audit catches the typical case but proven-insufficient for the regression-after-extract case.

**Failure-mode analysis:**

- New failure mode this introduces: false positive on a forbidden phrase that appears in legitimate context. Mitigation: phrases are deliberately conservative + case-sensitive + bounded by ERE specificity. The strip_code function ignores backtick code spans and fenced blocks so example mentions don't fire.

- New failure mode this introduces: invariant set grows stale (a fixed bug pattern keeps being checked long after the actual risk is gone). Mitigation: this is acceptable cost; running an extra pattern check is cheap. Patterns can be removed when proven unnecessary.

- Cannot detect: regression classes we haven't shipped yet. By design — the linter is reactive, not predictive. New patterns get added per concrete bug.

- Cannot detect: semantic drift NOT captured by a specific exact-phrase pattern. Out of scope for narrow forbidden-phrase model; would require option (c)'s broader analysis. Acceptable trade-off for v1.

Refines / extends B-016 (live doc references resolve to shipped files or are explicit examples) and B-023 (doc-reference linter validates Markdown link targets). The new fragment-validation in B-023 makes B-016's invariant strictly stronger (anchors also resolve, not just files). The new spec-consistency linter handles the orthogonal class of "doc content matches spec content" that B-016/B-023 don't address.

**Implemented in:** v1.29.0. Touches: `scripts/check-doc-references.sh` (extended with `github_slug` + `extract_headings` + `validate_fragment` functions + integration into the per-link processing loop; ~80 added lines); new `scripts/check-spec-consistency.sh` (~85 lines, narrow forbidden-phrase checker with code-span stripping); `.github/workflows/template-self-test.yml` (new step between placeholder check and smoke test); B-029 added (frozen); this D-014 entry added. No changes to other linters or C4 region machinery.

### D-015 (2026-05-19) Preset architecture — layered `_common/` + `presets/<preset>/`

**Chose:** Two-layer model for multi-preset support — `_common/` (stack-agnostic shared content) + `presets/<preset-name>/` (stack-specific). A bootstrapped project = `_common/` flattened with exactly one chosen preset. Constraints frozen by B-030: single preset per project; no file conflicts between layers; placeholders + C4 anchored regions stay in `_common/`. Design doc at `presets/PRESET_ARCHITECTURE.md`. **No implementation as of v1.30.0** — moving files into `_common/` + populating `presets/python-uv/` is separate work gated by this decision.

**Considered:** (a) two-layer composed model — `_common/` + `presets/<preset>/` (this option); (b) branched template repos — each preset is a separate repo (e.g., `phoenixtemplate-python`, `phoenixtemplate-node`); (c) single-tree with stack-conditional rendering — Jinja-style `{% if stack == 'python' %}` blocks in a unified `templates/`; (d) inverted naming — `_python-uv/` + `<core>/` (same architecture as (a) with naming swapped).

**Why:**

- **(a) chosen.** Clear ownership (each file has exactly one home); mechanically composable (no template engine; bootstrap tooling just flattens two directories); future-friendly (adding Node = `mkdir presets/node-pnpm/` + populate, no `_common/` edits unless the new preset surfaces a Python assumption to extract); migrate-friendly (existing v1.x consumers continue with their flat `templates/`-derived files; new bootstraps from the release that ships `_common/` + presets/ use the new structure; no forced upgrade); AI-safety preserved (C4-anchored rule trio stays in `_common/`, every preset inherits them, no per-preset re-derivation).

- **(b) rejected** — branched repos lead to drift between preset-specific copies of workflow/gate/spec-format content. Each preset re-derives what `_common/` would centralize, increasing maintenance cost and divergence risk over time. Loses the AI-safety benefit of B-021's three-tier model (each branch would need its own C4 regions, with no cross-branch sync mechanism). Multiple repos to keep in sync; consumer has to choose which to clone — fragmented UX.

- **(c) rejected** — Jinja-style conditionals in a single tree make "view the Python preset" a filtering operation; harder to reason about + harder to lint. Templates that mix stack-specific blocks with `{% if stack == 'python' %}` ... `{% endif %}` are notoriously hard to maintain when you have 3+ stacks. The layered model is the standard alternative — `cookiecutter` / `copier` / similar tools use it for the same reason.

- **(d) rejected on naming.** `presets/<name>/` matches `cookiecutter` / `copier` conventions; reads naturally for the variable part of the tree. `_common/` reads as "the shared layer everything depends on." Inverted naming would have `<name>/` as a top-level dir alongside `_common/`, mixing the meta-`_common` with a real-named preset. Less clear hierarchy.

**Failure-mode analysis:**

- **`_common/` accumulates over time.** Stack-agnostic content grows as workflow refinements / new C4 regions / new linters are added. `_common/` becomes large. Mitigation: it's still ONE directory; reading "what's in `_common/`" stays tractable. If it grows to where preset authors don't want to inherit ALL of it, sub-options needed — flagged for Phase 4.4 of the Codex plan (bootstrap modes: `full-python-vps` vs `python-local-only` vs `docs-only`).

- **Preset conflict with `_common/`.** A preset wants to override a file `_common/` ships (hypothetical: a no-runtime preset doesn't want the env-bootstrap core; a Go preset wants a different `.gitignore`). The composition rule says "no file conflicts": each file has exactly one owner. If a future preset legitimately needs to vary something `_common/` owns, the layer model breaks for that file. Mitigation: structure `_common/` so it owns only TRULY stack-agnostic files. If conflicts surface, either (i) move the conflict-prone file from `_common/` to all presets (each preset owns its own copy — small duplication accepted), or (ii) introduce sub-layers (`_common/core/`, `_common/env-bootstrap/`, etc.) so presets can opt out of specific sub-layers. Both options remain future work, deferred.

- **C4 regions may need preset-specific context.** Currently the 4 anchored regions (gate-clause / proposal-format / bare-gogogo / env-metadata-contract) are stack-agnostic. If a future regression motivates a preset-specific anchored rule (unlikely but possible), the C4 linter (B-022) would need per-preset `FILES` arrays. Not anticipated; flagged as a constraint to watch.

- **Smoke-test coverage multiplies by preset count.** Currently `scripts/smoke-test.sh` instantiates one Python preset. With multi-preset, CI would run the smoke flow per preset (matrix). Adds CI time linearly. Acceptable cost.

- **`scripts/export-starter.sh` needs updating** when the new structure ships — currently flattens `templates/` directly. Will need a `--preset` flag (default `python-uv` for backward compatibility) and compose `_common/` + chosen preset. Tracked as future work.

**Implemented in:** v1.30.0 (design only — no file moves, no script changes). Touches: `presets/PRESET_ARCHITECTURE.md` (new file at meta-repo root); B-030 added (frozen — layer model + composition rule); this D-015 entry (decision with Considered / Why / Failure-mode analysis). `templates/` remains unchanged; `scripts/export-starter.sh` remains unchanged. Future commits — gated by this design — will create `_common/` and `presets/python-uv/`, move files appropriately, update the export script + smoke test. Those are separate proposals.

### D-016 (2026-05-19) Bootstrap modes deferred until after multi-preset file move ships

**Chose:** Defer bootstrap modes (the candidate set `full-python-vps`, `python-local-only`, `docs-only` named in `presets/PRESET_ARCHITECTURE.md` and Phase 4.4 of the Codex improvement plan) until after the actual `_common/` + `presets/python-uv/` file move ships. The preset architecture (B-030 / D-015) is the layer that lands first; mode-selection is a separate optionality surface that we are explicitly not designing for v1 of the layered structure.

**Considered:** (a) defer bootstrap modes entirely until the file move lands (this option); (b) ship bootstrap modes alongside the `_common/` + `presets/python-uv/` file move in the same release sequence; (c) replace preset selection with bootstrap modes (modes carry an implicit preset; no separate `--preset` flag); (d) layer modes over preset selection (`--preset python-uv --mode python-local-only` as orthogonal axes).

**Why:**

- **(a) chosen.** Stacking mode-selection on top of preset-selection before the single-preset multi-tier layout (B-030) even exists doubles the optionality surface for no current consumer. The kit ships exactly one preset today (Python/uv/FastAPI/VPS) and the candidate modes (`full-python-vps`, `python-local-only`, `docs-only`) all describe subsets or variants of that one preset — meaning the mode design can't even be validated against multi-preset reality until multi-preset exists. Deferring keeps the v1 layered structure focused on one job (mechanical preset composition); the mode question can be revisited once a second preset (Node or Go) actually surfaces concrete demand for partial-bootstrap variants. No current user is blocked by the absence of modes — greenfield consumers get the full Python preset today; the `docs-only` mode is a Phase-5 adoption-UX concern (covered by Phase 5.1 migration guidance, not by mode-selection in bootstrap).

- **(b) rejected.** Bundling modes with the file move triples the scope of an already-large refactor. The file move itself (estimated 2-3 commits per `presets/PRESET_ARCHITECTURE.md`'s "Implementation order") needs careful sequencing — moving stack-agnostic files into `_common/`, then stack-specific into `presets/python-uv/`, then updating `scripts/export-starter.sh` to compose them, then updating smoke-test to matrix per preset. Adding mode-selection on top would mean ALSO designing the mode vocabulary (what does `python-local-only` exclude exactly? deploy.sh? CI? both?), updating export-starter to honor `--mode` semantics, and matrix-testing each (preset × mode) combination in CI. Concrete coupling cost without concrete benefit — neither feature blocks the other.

- **(c) rejected.** Collapsing preset and mode into one axis (so `full-python-vps` IS the preset choice) couples two orthogonal decisions: "what language stack" and "how much of the kit do I want." A Node consumer who wants the `docs-only` variant would need a `docs-only-node` mode duplicating `docs-only-python`'s exclusion logic. Doesn't scale past the first preset.

- **(d) deferred-but-not-rejected.** This is the long-term shape the mode question would likely take when it's revisited — orthogonal axes `--preset` × `--mode`. But "this is probably the right shape" is not the same as "ship it now." Without a second preset existing, the orthogonality is theoretical; the implementation work would be designing against absent data.

**Failure-mode analysis:**

- **Mode demand surfaces sooner than expected.** A consumer wants `docs-only` before multi-preset implementation lands. Mitigation: the Phase-5 migration guidance work (Codex plan Phase 5.1) covers the same use case — "import selected parts of the kit into an existing repo" achieves what `docs-only` mode would offer, just as a manual procedure rather than a flag. Migration docs are cheaper to write than mode infrastructure.

- **The deferred decision gets forgotten.** D-016 is exactly the structural-prevention surface against this: a decision-log entry with status "deferred" is durable; "tracked separately" prose in a design doc is not. Future revisits of multi-preset work see D-016 and the open question is rebound to a concrete next step (when, by whom, against what trigger).

- **Bootstrap modes turn out to be incompatible with the layered structure once it ships.** Risk: the file-move work makes assumptions that later constrain mode-selection design. Mitigation: the four constraints frozen by B-030 (single preset per project; no file conflicts between layers; uniform placeholders; C4 in `_common/`) are mode-orthogonal — none of them force a particular mode shape. The orthogonal-axes shape (option d) remains available if revived.

**Implemented in:** v1.31.2 (decision only — no infrastructure change). Touches: this D-016 entry; `presets/PRESET_ARCHITECTURE.md` "What's deferred" §updated to reference D-016 instead of inline prose; `codex improvement plan.md` Phase 4 §4 updated to record the decision. No spec block; no linter; no behavior change.

### D-017 (2026-05-19) Defer `scripts/new-project.sh`; manual bootstrap path acceptable

**Chose:** Do not ship the candidate `scripts/new-project.sh <slug> <package>` one-shot bootstrap helper named in Phase 5.3 of the Codex improvement plan. The manual bootstrap path documented in `BOOTSTRAP.md`, combined with `scripts/render-example.sh` (v1.32.1, B-035) for substitution-result inspection and `MIGRATION.md` (v1.32.0, B-034) for selective-import adoption, is the v1 bootstrap surface. Phase 5.3's acceptance is "either a clear helper is shipped, OR the repo explicitly decides the manual path is acceptable for now" — this is the second branch, explicitly chosen.

**Considered:** (a) defer the helper entirely; manual path stays (this option); (b) ship a thin helper that ONLY does placeholder substitution (calls `render-example.sh`'s substitution core with consumer-supplied values; no `gh` interactions); (c) ship a full helper covering `gh repo create` + branch-protection via `gh api` + merge-settings via `gh api` + placeholder substitution + first-commit; (d) ship the full helper but gated behind a flag so consumers opt in to the `gh`-side effects.

**Why:**

- **(a) chosen.** The friction that originally motivated the helper has been substantially reduced by adjacent work: (1) `scripts/render-example.sh` (B-035, this trio's commit 2) gives consumers a working fully-substituted example in one command, so the "what does the substitution map look like" question — previously answerable only by reading multiple docs and running `sed` manually — now has a one-line answer; (2) `MIGRATION.md` (B-034, this trio's commit 1) gives consumers a non-bootstrap path entirely, eliminating the helper's need for the selective-import use cases; (3) `templates/manifest.yaml` (B-032) makes the placeholder-set-per-file explicit and machine-readable, so consumers who want to script their own substitution have a data source; (4) `BOOTSTRAP.md` already documents the manual procedure clearly. The remaining friction — typing the `mv` and `sed` once per new project — is small relative to the cost of building, testing, and maintaining a helper that handles the various `gh` edge cases reliably.

- **(b) deferred-but-not-rejected.** A thin substitution-only helper is the smallest useful version of the script. The substitution logic already exists (in `render-example.sh`); a `new-project.sh` thin shape would just parameterize the substitution map from CLI args or interactive prompts. This is genuinely small (~30 lines), but the value-vs-cost ratio is dominated by Phase 5.2 already shipping: someone who can run `render-example.sh` to see the rendered output can copy that as a starting point and run `sed` themselves. The marginal automation is small. If a real adopter surfaces this as actual friction, this option remains the cheapest path forward — re-prioritize then.

- **(c) rejected.** The full helper's hard parts are not the substitution logic — those are easy and already in `render-example.sh`. The hard parts are the `gh repo create` + branch-protection + merge-settings flows, which are: (i) largely irreversible side effects (creating a remote repo is harder to undo than running `sed`); (ii) sensitive to the consumer's `gh` auth context, GitHub org permissions, and personal access scope; (iii) coupled to opinions about repo settings (default branch name; PR merge style; review-required count; status-check requirements) that vary per team. A generic helper that picks defaults will be wrong for many consumers and right for few. Bespoke per-team setup scripts handle this better than a generic one-size-fits-all.

- **(d) rejected on principle.** Gating the `gh` work behind a flag amounts to shipping (b) and (c) together, with (c) opt-in. But (c) is the hard part — putting it behind a flag doesn't reduce maintenance cost; it adds optionality without removing complexity. If we wouldn't ship (c) unconditionally, we shouldn't ship it conditionally either.

**Failure-mode analysis:**

- **Adoption friction surfaces from the missing helper.** A consumer abandons adoption because manual substitution is too cumbersome. Mitigation: this would be observable through GitHub issues / direct feedback. If it surfaces, reopen with option (b) (the thin substitution-only helper) as the cheapest first step — implementation cost ~30 lines + spec block + smoke-test extension. The deferral isn't permanent; D-017 is the explicit "we revisited and chose to defer" record, which means a future revisit has a starting point.

- **`render-example.sh` (B-035) becomes the de-facto bootstrap tool.** Consumers run `render-example.sh`, rename the output dir, edit a few values, and git-init. Risk: this isn't what B-035 was built for; the canonical substitution values are obviously-example and consumers would need to re-substitute. Mitigation: this is fine; if the workflow works for consumers, accept it. The fix would be exactly option (b) — a `new-project.sh` that takes the consumer's values instead of the canonical-example values. Same starting point.

- **The decision rots.** Codex Phase 5 closes with this commit; the deferral could be forgotten over time. Mitigation: D-017 is a decision-log entry with explicit "defer until [trigger]" semantics. The trigger is "adoption friction observable in the wild." Without the trigger, defer remains correct.

**Implemented in:** v1.32.2 (decision only — no infrastructure change). Touches: this D-017 entry; `codex improvement plan.md` Phase 5 §3 updated to record the decision; `codex improvement plan.md` Phase 5 header updated to reflect the phase is closed. No spec block; no script; no behavior change.

**Closes:** Phase 5 of the Codex improvement plan. With Phase 5.1 (B-034, v1.32.0) + Phase 5.2 (B-035, v1.32.1) + Phase 5.3 (this D-017, v1.32.2), all five phases of the Codex improvement plan are resolved. Future roadmap work — actual `_common/` + `presets/python-uv/` file move (gated by B-030); second language preset; new failure modes that emerge in real-world adoption — is outside the Codex plan's scope.

### D-018 (2026-05-19) Web-search-before-iterate rule placement + trigger shape (B-036)

**Chose:** (a) extend Karpathy Pitfall #1 in `templates/docs/karpathy-claude-rules.md` + the session-facing summary in `templates/CLAUDE.md`, NOT a new 5th Karpathy rule or a Coding-Conventions entry; (b) **all four triggers active** (new-surface; external-error; N=2 trip-wire; self-noticed guessing), NOT a single trigger; (c) **N=2 as the iteration threshold**; (d) `WebSearch` proposal classified `[info]` per B-028 (bare `N` proceeds, no `gogogo!`).

**Considered (placement):**
- **(a) Karpathy Pitfall #1 extension** — chosen.
- **(b) new 5th Karpathy rule** — "Verify externally before iterating." More visible (top-level rule) but breaks the "Karpathy's four" branding inherited from Karpathy's Jan 26 2026 X-post; we'd be claiming a 5th canonical rule that isn't his.
- **(c) Coding-Conventions entry in templates/CLAUDE.md** — concrete and operational but loses the "standing rule, applies-every-session" weight the Karpathy section carries.

**Considered (trigger shape):**
- **Single trigger: N=2 trip-wire only** — catches the iteration-not-converging case but misses the new-surface case (Claude writes integration code against an unfamiliar SDK without ever consulting docs) and the external-error case (Claude attempts a code-side fix for an exception that has a one-line community answer).
- **Single trigger: external-error only** — misses the N=2 iteration case where each attempt LOOKS like it might succeed and the agent keeps grinding.
- **Single trigger: self-noticed guessing only** — relies on the agent noticing, which is precisely what unexamined-assumptions failures mean it doesn't do reliably.
- **All four triggers** — chosen. Each trigger catches a real failure shape the others miss; redundancy is the point.

**Considered (N=2 threshold):**
- **N=1** (force search after first failed iteration) — too aggressive; legitimate one-off assumption-revisions get short-circuited.
- **N=2** — chosen. Tight enough to avoid the half-a-day case from the motivating incident; loose enough to allow one assumption-revision attempt before forcing the search.
- **N=3+** — too permissive; by N=3 the user has watched the agent spin its wheels for non-trivial time, which is exactly the failure mode this rule prevents.

**Considered (gate classification of WebSearch proposals):**
- **`[change]`** — would require `gogogo!` for each search proposal. Defeats the purpose; the whole point is low-friction "let me check" turns.
- **`[info]` per B-028** — chosen. Bare `N` proceeds. One keystroke between "we should check this" and "the answer is on screen."

**Why (a) wins:** Web-search is a *tactic* for Karpathy Pitfall #1 (verify load-bearing facts), not a separate principle. Putting it as a sub-bullet inside Pitfall #1 reflects the actual semantic relationship and keeps the standing-rules section coherent. The full rationale lives in the dedicated reference doc (templates/docs/karpathy-claude-rules.md §1's new B-036 subsection); the session-facing summary in templates/CLAUDE.md is the operational reminder Claude loads every session.

**Why all four triggers:** Single-trigger versions all have known failure modes (above). The marginal cost of additional triggers is zero (no implementation, just a rule statement); the marginal benefit is catching real failure shapes that would otherwise leak through. Conservative default.

**Why N=2:** Calibrated against the motivating incident — half-a-day-on-a-known-issue is the failure mode; the agent burned through many iterations before the realization. N=2 would have triggered the search hours earlier. N=1 would over-trigger on legitimate refinement; N=3+ is too late.

**Failure-mode analysis:**

- **Offer-fatigue.** Claude proposing "should I `WebSearch`?" on every routine API call trains the user to ignore the offers. Mitigation: triggers are deliberately narrow — new SURFACES (not every call), errors from EXTERNAL surfaces (not all errors), N=2 (not N=1), self-noticed GUESSING (not normal reasoning). If the rule fires too often in practice, narrow the new-surface trigger first (e.g., "only when the surface is unfamiliar," which is harder to operationalize but worth iterating on).

- **Search results are wrong or out of date.** Web content has its own staleness problems. Mitigation: not the rule's job to verify search quality; the agent reads the result, decides whether it's authoritative, and asks the user when unclear. The rule's job is forcing the search to happen; quality assessment is downstream.

- **No linter coverage.** The rule applies to AGENT BEHAVIOR at runtime; there's no static-analysis way to enforce "the agent should have searched before this code change." Adding a structural-prevention linter was considered (option 3 in the original proposal) and explicitly flagged as a possible follow-up. Deferred from this commit; if the rule gets ignored in practice, a "code-side fix to external-error symptom without preceding `WebSearch` in the same session" linter becomes the next step.

- **Rule expansion creep.** Once "search before iterate" is in place, more triggers will be tempting (every type signature lookup; every npm-package decision; etc.). Mitigation: keep the rule scoped to EXTERNAL SURFACES (APIs / SDKs / 3rd-party services / library versions). Internal reasoning about the project's own code stays on Pitfall #1's existing "verify load-bearing facts" sub-bullet without forcing a search.

**Implemented in:** v1.33.0. Touches: `templates/CLAUDE.md` (Pitfall #1 extension); `templates/docs/karpathy-claude-rules.md` (§1 gets the `### Web-search before iterate on external surfaces (B-036)` subsection with full rationale + four triggers); `docs/spec.md` (B-036 added — frozen; this D-018 entry added). No C4 region changes (Karpathy rules are not gate-related per B-021 three-tier model). No linter changes; no script changes. Standing-rule additions don't usually need a Decision-log entry, but B-036's design space had real architectural choices (placement, trigger shape, threshold, gate classification) worth recording so future revisits have a starting point.

### D-019 (2026-05-19) Emoji-prefixed `[change]` / `[info]` proposal markers (B-037)

**Chose:** (a) **kit-scope** edit (touches the C4 `proposal-format` region across the trio); (b) **in-spec** placement (emojis baked into the C4 region; one source of truth); (c) **pair #3** ✏️ + 👀 (pencil / eyes); (d) **stay binary** — keep the `[change]` / `[info]` vocabulary; do NOT add a `[risky]` or `[push]` sub-tier in this commit.

**Considered (scope):**
- **Session-only** — Claude starts using emojis in this conversation; no kit change. Ephemeral.
- **Personal global** — user's `~/.claude/CLAUDE.md` (applies to all their sessions). Doesn't propagate to other adopters of the kit.
- **Kit-level** (chosen) — extends B-028 across the C4 region so every project that adopts the kit benefits. Matches the precedent set by B-036 (v1.33.0, prior commit on this branch) which also went kit-scope.

**Considered (placement):**
- **In-spec** (chosen) — emojis appear in the C4 region itself. Pro: one source of truth; the C4 linter (B-022) still works byte-exact including the emoji characters. Con: the spec text picks up visual decoration that's strictly user-facing.
- **Presentation-layer** — C4 region stays as bare `[change]`/`[info]`; a separate "render this way" rule adds the emoji at output time. Pro: keeps the spec text plain. Con: doubles the contract surface (now there's a "specification" AND a "render rule" that both have to stay in sync); the C4 linter would only catch drift in the spec text, not in render practice.

**Considered (emoji pair):**
- **#1 — 🔧 / 📖** (wrench / book) — semantically clean (mutation / reading); slightly more "tooling-ish" weight.
- **#2 — ⚙️ / ℹ️** (gear / info-symbol) — most abstract; matched weight. ℹ️ has a literal "info" meaning. Some terminals render ℹ️ as text not glyph, which can look inconsistent.
- **#3 — ✏️ / 👀** (pencil / eyes) — chosen. Action verbs ("editing" / "looking"); both render reliably across terminals; slightly more playful than #1/#2 but still humble.
- **#4 — 🛠️ / 🔍** (tools / magnifier) — both implementational; 🔍 reads more as "search" than "read."

**Considered (vocabulary expansion):**
- **Stay binary** (chosen) — `[change]` + `[info]` cover the gate-scope distinction B-028 cares about; finer-grained risk tiers exist in the prose of each proposal (the user is expected to read what's being proposed, not rely solely on the marker for blast-radius judgment).
- **Add `[risky]`** — high-blast-radius sub-tier of `[change]` for irreversible / shared / external actions (force-push to main, deploy to prod, external POST). Pro: visual flag for high-stakes operations. Con: every `[change]` proposal now requires a sub-classification decision; risk of bikeshedding "is this `[change]` or `[risky]`?" on every proposal turn.
- **Add `[push]`** — middle-tier sub-classification between local-`[change]` and external-`[risky]`. Same con as `[risky]` doubled.

**Why (a) kit-scope:** matches the pattern set by B-036 (v1.33.0, this branch's prior commit) for standing-rule additions. The visual benefit applies in every session of every project adopting the kit, not just the user's own. The cost — one C4-region edit — is one-time.

**Why (b) in-spec:** the C4 linter (B-022) is byte-exact; running it after the emoji edit verifies the trio remains in sync without separate render-rule plumbing. The "spec text picks up visual decoration" concern is real but mitigated by the fact that the spec IS what's rendered (these aren't internal compiler artifacts; they're agent-output formatting rules).

**Why (c) pair #3 ✏️ + 👀:** user picked it directly out of the four options surfaced. Pencil and eyes are action verbs that match the semantic intent (editing vs. looking) without requiring users to learn an arbitrary glyph mapping. Renders reliably across major terminals (some terminals downgrade ⚙️/ℹ️/🛠️ to text symbols which breaks visual consistency).

**Why (d) stay binary:** B-028's binary classification was a deliberate corrective swing back to clear authorization scope after the always-`gogogo!`-on-every-option pattern from v1.24.0 had diluted the gate signal. Expanding to 3+ tiers reintroduces the dilution risk. Blast-radius judgment lives in the proposal prose (per the system-prompt "executing actions with care" guidance — high-stakes irreversible operations get explicit flagging in the proposal text); the marker's job is gate scope, not risk tier. If real adoption surfaces consistent miscalibrations (e.g., the binary keeps lumping force-push with file-edits in ways that hurt), a sub-tier is the natural next refinement — but earned by demonstrated need, not preemptively shipped.

**Failure-mode analysis:**

- **Terminal rendering inconsistency.** Some terminals or fonts may render ✏️ / 👀 differently than expected (text fallback, missing glyph, mis-sized). Mitigation: ✏️ (U+270F) and 👀 (U+1F440) are widely-supported emoji in modern terminals (iTerm, Terminal.app, gnome-terminal, alacritty, kitty all render them as glyphs). If a future adopter reports rendering trouble, swap in a presentation-layer rule that lets the consumer pick an alternate pair via CLAUDE.md override; that's a `presentation-layer` shape we explicitly considered + rejected here but kept on the table as a future option.

- **Emoji-fatigue.** Once the precedent is set ("we have emojis in proposal markers"), pressure to add emojis elsewhere (section headers, status messages, every proposal type) is real. Mitigation: B-037 scope is deliberately narrow — emojis ONLY at the per-option markers in `Choose one:` / `Choose any (in order):` lists; explicitly NOT at section headers, status indicators, single-suggestion proposals, or anywhere else. Future expansion would need its own B-NNN with its own justification.

- **AI-parsing impact.** Emoji characters are multi-byte; could affect text-processing tooling that assumes ASCII. Mitigation: the C4 linter parses files byte-exact and handles UTF-8 correctly; the spec-consistency linter (C5) operates on POSIX ERE patterns over the text content, no emoji-specific regression risk. Smoke test pre-flight (B-031 §0b) counts non-blank chars — emoji characters count, no threshold drift.

- **Binary-vocabulary lock-in.** Shipping the binary-with-emojis sets a UX precedent that may make expanding to `[risky]` harder later (would need new emoji + harmonizing visual system). Mitigation: explicit option to revisit binary in future B-NNN; D-019 records that the expansion question was considered + deferred, so the future-revisit has documented starting points.

**Implemented in:** v1.34.0. Touches: the C4 `proposal-format` region across WORKFLOW.md + templates/CONTRIBUTING.md + templates/CLAUDE.md (byte-exact; B-022 linter verified green after the edit); `docs/spec.md` (B-037 added — frozen; this D-019 entry added). No script changes; no manifest changes; no behavior changes beyond visual marker presentation. C5 spec-consistency linter green — emoji prefix doesn't trigger any forbidden-phrase pattern. Smoke test pre-flight green — C4-region content still well above 100 non-blank-char threshold.

### D-020 (2026-05-19) Forbid null-action options in proposals (B-038)

**Chose:** (a) **forbid entirely** at the spec level (C4 region edit + B-038 freezes the rule); (b) **kit-scope** (matches B-036 / B-037 precedent on `improvements-4`); (c) **non-exhaustive forbidden-phrasings list** (lists the common offenders but the test is intent — "does this option move the conversation forward concretely or just terminate" — not literal phrase match).

**Considered:**
- **(a) Forbid entirely** (chosen) — null-action options are forbidden by the spec; the C4 region carries the rule; the C4 linter (B-022) keeps the rule synced across the trio.
- **(b) Allow but discourage in prose** — keep the option open with a "prefer not to include" note in CLAUDE.md. Pro: less restrictive. Con: the rule wouldn't fire reliably; the entire point of the spec change is to make "no null options" an enforced norm, not a vibe.
- **(c) Add a third option type `[pass]` or `[skip]`** — formalize the "do nothing" semantics with its own marker. Pro: makes the null choice explicit and uniform when it does appear. Con: contradicts D-019's stay-binary decision (which explicitly kept the vocabulary at `[change]` / `[info]` to preserve B-028's corrective swing back to clear authorization scope); makes the dilution problem worse, not better.

**Why (a) wins:** the user observation that motivated this block — "silly and redundant" — was specifically about the null options taking up visual weight without surfacing choice. The fix must be a real prohibition, not a soft preference. Forbid-entirely is the only shape that delivers the no-null-options outcome reliably. Codifying the rule in the C4 region ties it to the byte-exact-enforced trio so it can't drift across the doc tiers.

**Why kit-scope:** matches B-036 (v1.33.0) + B-037 (v1.34.0) precedent on `improvements-4`. Every project that adopts the kit benefits; the cost is one-time C4-region edit + spec block.

**Why non-exhaustive forbidden list:** the failure mode is "options that just terminate without progressing the conversation" — any phrasing variant of "do nothing" is forbidden, not just the literal list. Closed list would invite bypass-by-rewording ("hold off for now" / "park this" / etc. would technically not match a closed list but would clearly violate the spirit). The intent-test ("does this move the conversation forward?") is what the rule actually checks; the listed phrasings are anchors for common cases.

**Failure-mode analysis:**

- **Over-restriction on legitimate "no action" guidance.** Sometimes the right answer IS "nothing here needs to happen now." Mitigation: if the right answer is no-op, the assistant message can simply not include a proposal at all (per B-027's refinement — pure discussion turns where no list-of-paths fits naturally can end without a trailing proposal). The rule forbids the null option, not the null situation. The agent's job is to recognize "there's nothing concrete to propose" and either say so plainly or surface a continued-discussion option, not to pad with a fake "stop here" option.

- **Carve-out wording confusion.** "Continue discussion" vs "stop here" can blur — both sound like "no further state change happens now." Mitigation: the test is "does this option move the conversation forward concretely?" Continue-discussion does (it produces more substantive content next turn); stop-here doesn't (it's just an exit). If an option's action is "the user gets nothing new and the conversation ends," it's forbidden. If its action is "the user gets more information / a refinement / a clarification," it's fine.

- **The rule applies to the agent, not the user.** The user remains free to type "stop" / "wait" / "let's leave it" / etc. at any time — those are user-side directives, not agent-proposed options. The rule constrains what the agent surfaces, not what the user can request.

- **No linter coverage.** Like B-036 (web-search-before-iterate), this is an agent-behavior runtime rule with no static-analysis surface. Mitigation: spec-consistency linter could grow an Invariant that flags forbidden phrasings in active docs that describe the proposal format (e.g., catch a regression that re-adds "stop here for now" as an example to the C4 region). Deferred — D-014 bar ("we've shipped this exact bug already") would need to be met first by a regression that actually shipped.

**Implemented in:** v1.35.0. Touches: C4 `proposal-format` region across WORKFLOW.md + templates/CONTRIBUTING.md + templates/CLAUDE.md (byte-exact; B-022 linter verified green); `docs/spec.md` (B-038 added — frozen; this D-020 entry added). No script changes; no linter changes; no manifest changes. Refines B-027 (proposal-when-path-to-surface) + B-028 (per-option classification).

### D-021 (2026-05-19) Onboarding mechanism — separate website repo + `ONBOARDING_PROMPT.md` in the kit (B-039)

**Chose:** (a) **separate website repo** `denisbalon/phoenixtemplate.com` (cloned to sibling directory `~/github/phoenixtemplate.com/`), not website source in the kit repo; (b) **`ONBOARDING_PROMPT.md` lives in the kit's meta-repo root as `tier: meta-only`**, fetched by Claude via `WebFetch` at bootstrap time, NOT exported by `scripts/export-starter.sh` (doesn't ship to bootstrapped projects); (c) **four-step structure** (greet+Q1 / Q2–Q6 / propose-bootstrap / hand-off) for ONBOARDING_PROMPT.md; (d) **six setup questions** (description, display name, slug, package, GitHub, VPS); (e) **WebFetch fallback at Step 0** — opportunistic, non-blocking, allows paste-on-demand when WebFetch is disabled.

**Considered (mechanism):**
- **(i) Raw repo URL** — user pastes `github.com/denisbalon/phoenixtemplate` and hopes Claude infers what to do. Fragile; relies on Claude having the right context with no explicit guidance.
- **(ii) Repo URL + canned prompt** — landing page with both. Better than (i) but requires Claude to know what to do with the URL.
- **(iii) WebFetch a single onboarding doc** (chosen, combined with ii) — landing page shows one copy-paste prompt that tells Claude to `WebFetch` the canonical `ONBOARDING_PROMPT.md` and follow it verbatim. Document IS the guide; website is discovery + branding.
- **(iv) `curl | bash` install script** — `curl -sSL phoenixtemplate.com/init.sh | bash`. Standard pattern but bypasses Claude entirely; loses the guided-interaction value that's the whole point.
- **(v) MCP server** — structured tool-use server. Heavy infrastructure; users need to configure MCP per-session; not "drop a URL" simple.

**Considered (website repo location):**
- **(a) Separate repo `denisbalon/phoenixtemplate.com`** (chosen) — repo name = domain name = folder name; three-way 1:1 mapping. Sibling directory layout `~/github/phoenixtemplate.com/` next to `~/github/phoenixtemplate/`. Independent governance (no `VERSION`, no `docs/spec.md`, no kit linters, no manifest, no B-NNN discipline).
- **(b) `web/` subdirectory in the kit repo** — single repo for everything. Simpler in some sense but couples site iteration to kit's version discipline; landing-page typo fix would trigger a v1.X.Y bump per B-002 + need to pass all 5 kit linters + spec-block review. Wrong governance for a marketing page.

**Considered (ONBOARDING_PROMPT.md export):**
- **(α) `exported_by_starter: true` / `tier: common`** — file ships in every bootstrapped project's root. Pro: local audit trail of "this is how Claude bootstrapped me"; useful if developer bootstraps another project later from the local archive. Con: noise in every new project's root — file describes bootstrapping a NEW project, not working in this one; developers might re-read it confusedly or attempt to run it again against the already-bootstrapped project.
- **(β) `exported_by_starter: false` / `tier: meta-only`** (chosen) — file lives in the kit meta-repo only; Claude fetches via `WebFetch` from the raw URL at bootstrap time. Clean — new project's root has no "what's this?" confusion. Matches the file's actual use (bootstrap-time, not post-bootstrap). Same pattern as `scripts/check-*.sh` and `scripts/render-example.sh`. "Audit trail" argument addressed by Step 3's CHANGELOG entry ("bootstrapped from phoenixtemplate vX.Y.Z").

**Considered (question count):**
- **3 questions** (display name, slug, package only) — too thin; misses GitHub + VPS deploy context that affects what gets scaffolded.
- **6 questions** (chosen) — description + display name + slug + package + GitHub + VPS deploy. Covers all 10 canonical placeholders + the two main lifecycle decisions (GitHub presence + deploy target). About the right amount of friction for a 5-minute setup.
- **10+ questions** — over-asks for newbies; reduces conversion. The kit's spec.md / BOOTSTRAP.md cover the rest as post-bootstrap reads.

**Considered (WebFetch fallback shape):**
- **Block on WebFetch enablement** — Claude refuses to proceed until user enables WebFetch. High friction; some users will bounce.
- **Opportunistic Step 0** (chosen) — Claude notes WebFetch is disabled and explains how to enable it for future reference, but the bootstrap proceeds via paste-on-demand if needed. Steps 1–4 are self-contained; everything the user needs to bootstrap is in the prompt doc itself. No friction, graceful degradation.

**Why (a) — separate repo:** strict kit governance is overkill for a static landing page. Different audience (developers using bootstrap vs. site visitors), different lifecycle (kit changes per spec block; site changes per copy fix), different deployment (kit ships via export-starter archive; site is just a static page). Repo-name = domain-name is a clean discoverability convention. The mental model "kit lives here, site lives there" is unambiguous when the directories are siblings with matching names.

**Why (b) — meta-only / not exported:** the file is for Claude's use at bootstrap time, not for the developer to read post-bootstrap. Exporting it would litter every adopter's project with a meta-repo artifact — the same pollution problem we just decided to avoid by keeping the website out of the kit repo. The "audit trail" benefit is weak (CHANGELOG entry covers it); the noise cost is real.

**Why (c) — four steps:** clean mental model (greet / ask / propose / hand-off). Aligns with the kit's 5-step `gogogo!` workflow shape (propose-confirm-execute-verify-handoff is the analog). Single-prompt-with-batched-questions would overwhelm a newbie; longer step counts (8–10 micro-steps) would add ceremony without clarity.

**Why (d) — six questions:** covers all 10 canonical B-024 placeholders + the two main lifecycle decisions (GitHub presence + VPS deploy). Calibrated friction — about right for a 5-minute setup. The kit's other docs (BOOTSTRAP.md / WORKFLOW.md) cover the rest as post-bootstrap reads.

**Why (e) — opportunistic WebFetch fallback:** blocking on WebFetch enablement would bounce users who don't want to grant the permission; the doc itself is small enough to paste manually as a fallback. Graceful degradation matches the kit's broader stance ("the manual path is acceptable").

**Failure-mode analysis:**

- **Newbie pastes the prompt with no clue what `WebFetch` is.** Step 0 explains in plain language; the bootstrap proceeds via paste-on-demand. Worst case: one extra paste during Step 3 (the doc itself).

- **User abandons mid-flow.** Bootstrap state is partial; might have rendered some files but no `git init` yet. Mitigation: Step 3's `✏️ [change]` proposal makes the commit atomic — files appear in working tree before the commit, but the commit + push are gated; if user bails before `gogogo!`, working tree has the rendered files but no git history; user can either `rm -rf` to abort or `git init && git add . && git commit` manually to resume.

- **Substitution map gets out of sync with `scripts/render-example.sh`.** B-039 explicitly says "reuse `scripts/render-example.sh` substitution logic" — same canonical mv + sed pattern; same multi-extension scope. If render-example.sh's logic changes, ONBOARDING_PROMPT.md's Step 3 description should change in the same commit (same convention as the substitution-logic invariant between render-example and smoke-test phase 3, per B-035).

- **Website goes down / domain expires.** The fallback bootstrap prompt uses the raw GitHub URL (`raw.githubusercontent.com/denisbalon/phoenixtemplate/main/ONBOARDING_PROMPT.md`); website only adds discovery + branding. Even if the website is unreachable, paste-the-raw-URL still works.

- **WebFetch fetches the wrong version** (e.g., a feature branch instead of main). Raw URL pins to `/main/` explicitly; should always pull the merged-to-main version. If the user discovers the kit via a non-main branch (e.g., reviewing a PR), they need to use that branch's URL instead — documented as advanced case, not in the canonical prompt.

- **Manifest drift.** ONBOARDING_PROMPT.md's Step 3 references `templates/manifest.yaml` as the source-of-truth for what files ship. If the manifest gains/loses entries, the bootstrap covers them automatically — no ONBOARDING_PROMPT.md edit needed. Self-healing.

**Implemented in:** v1.36.0. Touches: new `ONBOARDING_PROMPT.md` at kit meta-repo root; `README.md` Quickstart section refactored to surface the bootstrap path + WebFetch troubleshooting + reference to `phoenixtemplate.com`; `templates/manifest.yaml` gets the ONBOARDING_PROMPT.md entry as `tier: meta-only` / `exported_by_starter: false`; `docs/spec.md` adds B-039 (frozen) + this D-021 entry. NOT touched: `scripts/export-starter.sh` `ROOT_DOCS` (file isn't exported); `scripts/check-doc-references.sh` `VIRTUAL_TEMPLATES_FILES` (no links from `templates/*` reference ONBOARDING_PROMPT.md). Separate work tracked outside this commit: actual website repo creation (`denisbalon/phoenixtemplate.com`) + Pages config + DNS — those are user-side actions guided after this commit lands.

### D-022 (2026-05-20) Rename project phoenixprojecttemplate → phoenixtemplate

**Chose:** Rename the project, GitHub repo, local directory, and (future) domain from `phoenixprojecttemplate` to `phoenixtemplate`.
**Considered:** keep `phoenixprojecttemplate` (longer, more descriptive); `phoenixtemplate` (shorter — chosen); other variants (`phoenix-template`, `phoenixkit`) not seriously pursued.
**Why:** `phoenixprojecttemplate` is a mouthful — 22 characters, awkward to type, awkward as a domain. `phoenixtemplate` keeps the distinctive "phoenix" + the "template" descriptor while dropping the redundant "project" (a template IS for projects). Shorter domain (`phoenixtemplate.com`), shorter repo URL, easier to say and share — material for a kit whose target audience is newcomers typing the name into a browser. The rename rewrites **all** in-repo mentions including historical CHANGELOG + spec entries (consistency over audit-purity — git history + merged-PR titles preserve the old name as provenance). The original source-project name `phoenixtgstat_bot` is unaffected (different string; its 4 audit-trail mentions are intact).
**Implemented in:** v1.37.0. **Phase A** (in-repo text — 50 occurrences across 8 files: CHANGELOG.md, CONTRIBUTING.md, MIGRATION.md, ONBOARDING_PROMPT.md, PROJECT_STARTER.md, README.md, docs/spec.md, presets/PRESET_ARCHITECTURE.md) lands in this commit. **Phase B** (GitHub repo rename `gh repo rename phoenixtemplate` + `git remote set-url`) and **Phase C** (local repo dir `~/github/phoenixprojecttemplate/` → `~/github/phoenixtemplate/` + auto-memory project dir rename, done at session boundary) follow as separately authorized steps. Follows the D-001 precedent (the `code!` → `gogogo!` passphrase rename) — a pure rename decision, decision-only, no B-block.

### D-023 (2026-05-20) Natural-language imperatives do not discharge the gate (B-040)

**Chose:** (a) Promote the "imperatives don't authorize" rule into the canonical C4 `gate-clause` region (synced byte-exact across the doc trio, B-022-enforced) rather than leave it as the un-enforced one-liner it had been; (b) add the explicit "confidence in the interpretation never substitutes for the `gogogo!` token" emphasis as the load-bearing addition; (c) keep the pre-existing templates/CLAUDE.md one-liner as session-facing reinforcement (Option A of the proposal — matches B-021's redundancy pattern for bare-`gogogo!` / mid-execution-deviation, which also live both in a C4 region and as quick-reference lines).
**Considered:** (a) leave the orphaned one-liner as-is (rejected — it was outside C4, un-synced, un-enforced, present in only one of three tiers, which is precisely why it failed to hold); (b) rewrite/remove the templates/CLAUDE.md one-liner to avoid a near-duplicate (Option B — rejected: would single out this one rule to lack the reinforcement its sibling gate rules get, making the CLAUDE.md one-liner cluster inconsistent for a drift risk that doesn't exist, since these one-liners deliberately use varied phrasing and were never byte-exact contracts); (c) a brand-new free-standing rule (rejected once discovery showed the rule already existed in weaker form — the honest framing is promotion/consolidation, not invention).
**Why:** Shipped failure this session — user said "create a PR for this branch and I will do review" (bare imperative, no `gogogo!`); Claude ran `gh pr create` directly, publishing self-authored prose to an external indexed surface without surfacing it for confirmation. The read happened to be correct, which is the trap: a correct guess is indistinguishable from a lucky one until after the irreversible action. The gate is an anti-misread mechanism — its job is to force Claude's interpretation of intent into visible words BEFORE anything outward happens, so a wrong reading dies on screen instead of as a GitHub event / `rm` / force-push. Treating natural language as the token reopens the misread channel the token was built to close. Decision-only on the framing; the behavior change is a frozen B-block (B-040) because it's a binding gate rule, not just a rename. Discovery mid-execution that the rule already existed (in weaker form) triggered a re-proposal before committing — itself an application of the rule being codified.
**Implemented in:** v1.38.0. Touches: the C4 `gate-clause` region across WORKFLOW.md + templates/CONTRIBUTING.md + templates/CLAUDE.md (byte-exact; B-022 verified green after edit); `docs/spec.md` (B-040 added — frozen; this D-023 entry added). NOT touched: the templates/CLAUDE.md line-39 one-liner (kept as-is per Option A); no script changes; no linter changes; no manifest changes. Refines B-026 (propose-and-confirm gate) condition (b) + reinforces B-027 (proposal-ends-every-message).

### D-024 (2026-05-20) Negative handlers belong in the loaded C4 region (B-041)

**Chose:** Consolidate the three known proposal-time negative handlers stranded in spec blocks — B-037's marker-placement negative scope, B-028's conservative-default-`[change]`, and B-028's bare-`N`-against-`[change]` re-prompt — into the byte-exact C4 `proposal-format` region (synced across the trio, B-022-enforced), and freeze the standing invariant (B-041) that any "never here / re-prompt on misuse / default conservatively" clause must live in the loaded region, not only in its originating spec block.
**Considered:** (a) fix only the emoji negative-scope that bit us this session (rejected — the audit showed two more stranded handlers with the identical root cause; patching one instance leaves the pattern live); (b) add a linter to catch malformed proposals (rejected as impossible — proposals live in chat, not tracked files; the C5 spec-consistency linter scans the 5 active docs, not Claude's conversation output, so no CI surface can validate a proposal at the source); (c) leave the handlers in spec blocks and rely on Claude having read the spec (rejected — that is exactly the orphan failure mode B-040 and the emoji slip both demonstrated; spec blocks aren't loaded each session).
**Why:** Two shipped failures in one session shared one root cause — the `proposal-format` region loaded the positive shape of a proposal but stranded the negative handlers in unloaded spec blocks. B-040 fixed one such orphan (imperatives); the audit prompted by the user ("we need to fix your rules so this does not happen") found three total. The honest framing is structural, not cosmetic: Claude reliably applies what's in the loaded region and reliably misses what's only in a spec block, so the durable fix is to relocate proposal-time handlers into the loaded region and name the invariant. No automated enforcement is possible for chat-shaped output; loaded-region presence IS the enforcement mechanism, which is why the relocation is the fix rather than a precursor to one.
**Implemented in:** v1.39.0. Touches: the C4 `proposal-format` region across WORKFLOW.md + templates/CONTRIBUTING.md + templates/CLAUDE.md (three handler sentences appended; B-022 verified green byte-exact); `docs/spec.md` (B-041 added — frozen; this D-024 entry added). NOT touched: B-037 / B-028 spec blocks (they remain the canonical rationale/audit home; the handlers are now *also* in the loaded region — deliberate B-021-style redundancy); no script/manifest/linter changes. Generalizes B-040 (one-off orphan promotion) into a standing rule about where handlers must live; refines B-027 / B-028 / B-037.

## Open project-level decisions

Resolve as they come up. Move resolved entries to the Decision log above.

- [ ] **De-personalize the template.** Partial — original residue was `bootstrap.sh` menu header hardcoded to `phoenixtgstat_bot` + baked-in Telegram/Meta/Keitaro validators. (PROJECT_STARTER.md item A1–A3.) Status:
  - [x] ~~Menu-header hardcode~~ — **Resolved in v1.11.2 (B-017).** `bootstrap.sh` derives via `PROJECT_NAME=$(basename "$ROOT")`.
  - [x] ~~Service-specific validators~~ — **Resolved in v1.12.0 (B-018).** Generic core (`LOG_LEVEL`, `DEV_MODE` only) + sourced sidecar at `templates/scripts/validators.sh` where consumers add their own project-specific validators.
  - [x] ~~Codex Phase 1.3 — broader audit for source-project residue across docs~~ — **Resolved in v1.13.0 (B-019).** Active docs are now vendor-neutral by default; vendor-specific guidance is explicitly labeled. `denisbalon/` hardcodes parametrized to `<GITHUB_USER>`; deploy.sh's `WEBHOOK_BASE_URL` renamed to `SERVICE_URL`; branch/commit examples and stack rationale made generic.

**De-personalize item now fully resolved.**
- [ ] **Stack-agnostic restructure** — *roadmap per D-009.* Today the templates assume Python+uv+FastAPI+VPS. Multi-preset support (`templates/_common/` + `presets/python-uv/`, `presets/node-pnpm/`, `presets/go/`, `presets/none/`) is deferred to a later release. Until shipped, this repo is honestly framed as a Python/uv/FastAPI/VPS starter. (Item C10–C12)
- [ ] **One-shot project bootstrap script.** `scripts/new-project.sh <slug> <package>` doing §1.1–§1.10 of PROJECT_STARTER.md in a single command — including `gh repo create`, branch protection via `gh api`, merge settings via `gh api`. (Item D13)
- [x] ~~**Build the missing `scripts/export-starter.sh`.** Referenced in §1.3 but never shipped. Keep for offline-transfer use case. (Item B4)~~ — **Resolved in v1.10.0 (B-013).**
- [ ] **Implement `bootstrap.sh --export` / `--import` / `e` / `i` / WSL `wslpath` translation.** Documented in PROJECT_STARTER.md §14 but the script doesn't have them. (Item B5)
- [x] ~~**Add language-preset skeletons.** Missing `pyproject.toml`, `src/<package>/`, `tests/`, `LICENSE`. CI assumes they exist. (Item B6–B9)~~ — **Resolved in v1.9.0 (B-012).** Files shipped under `templates/`; bootstrap substitution documented (auto-bootstrap is a follow-up).
- [ ] **Split PROJECT_STARTER.md** into focused docs (`BOOTSTRAP.md`, `WORKFLOW.md`, `CONVENTIONS.md`, `HARNESS_QUIRKS.md`) with PROJECT_STARTER.md as the index. ~1000 lines is hard to navigate. (Item F22)
- [ ] **Decide PROJECT_STARTER.md role in cloned projects.** Snapshot-at-bootstrap (current — drifts) vs. thin pointer + version reference (won't drift). (Item F23)

## Historical blocks (superseded)

Blocks here are retained for audit trail — they capture the rule that WAS in force at some prior version, and the supersession trail makes it possible to trace why the current active rule replaced them. They are NOT currently binding behavior. Cross-references from active blocks (e.g. B-010 "Supersedes B-007, B-009") point here.

### Block B-001: gate passphrase is `gogogo!`

**Rule:** No state-mutating action (Edit / Write / NotebookEdit, git commit/push, gh pr create/merge/comment, deploy) proceeds unless the user's current message contains the literal substring `gogogo!`.
**Rationale:** Universal authorization token, stack-agnostic, distinctive. Replaces the prior `code!` (too narrow — implied code-only). Renamed in v1.2.0.
**Test:** manual — read §2.1 of `PROJECT_STARTER.md`, the gate section at the top of `templates/CLAUDE.md`, and the gate sections of `templates/CONTRIBUTING.md` (cheat-sheet, TL;DR, hard-gate). All three name `gogogo!` as the active passphrase. Historical references to the prior `code!` passphrase in `CHANGELOG.md`, the Decision log, and template-changelog tables are intentional audit trail and do not violate the rule.
**Status:** superseded by B-026 (v1.23.0). Reason: the literal-substring-`gogogo!` requirement survives as condition (b) of B-026's new gate, but the simple "current message contains `gogogo!`" check no longer suffices on its own — B-026 also requires Claude's immediately-preceding message to have contained a concrete proposal (condition a) and that the executed action match the proposal (condition c). The `gogogo!` token itself is unchanged.
**Decision:** — (now under D-010)

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

### Block B-007: PR review is reviewer-agnostic; Codex is the default

**Rule:** The rubric and output contract in `templates/docs/pr_review_instructions.md` apply to whichever reviewer runs (Codex, `/ultrareview`, another LLM, or manual human). **Codex is the default reviewer** via its GitHub App; `@codex review — follow docs/pr_review_instructions.md (Block / Strong / Nit, per-commit comments, "no findings" on clean commits, summary at end)` is the canonical invocation. Reviewers run serially — never in parallel.
**Rationale:** Independence beats deepening. A different model with fresh context catches what the original model missed. Codex is cheap, independent (different model family), and integrated into GitHub PRs natively. `/ultrareview` (still Claude under the hood) shares blind spots with the author and is billed; reserve for high-stakes second opinions. The output contract is reviewer-agnostic because the PR is the audit trail regardless of who wrote the comments.
**Test:** manual — `grep -A5 'Default reviewer' templates/CONTRIBUTING.md` shows Codex; `grep -i 'codex' templates/docs/pr_review_instructions.md` returns a match in the preamble.
**Status:** superseded by B-010 (v1.7.0). Reason: project no longer ships a default reviewer; the reviewer-agnostic principle survives but Codex-as-default and the GitHub-App invocation are removed.
**Decision:** D-005 (superseded by D-008)

### Block B-008: `request-codex-review` skill is the one-command Codex trigger

**Rule:** When the user asks Claude to send the current branch to Codex for review (or invokes `/request-codex-review`), Claude runs the `request-codex-review` skill at `templates/.claude/skills/request-codex-review/SKILL.md`. The skill posts a single PR comment via `gh pr comment` that explicitly names the rubric file (`docs/pr_review_instructions.md`), then stops. It does NOT poll for Codex's response, does NOT take any state-mutating action beyond the comment, and does NOT run mid-branch — only when the branch is finished and has an open PR. A `make request-codex-review` Makefile target wraps the same canonical body for terminal use outside Claude sessions.
**Rationale:** The user's manual ritual is open-Codex-locally → ask-it-to-look-around → ask-it-to-read-the-rubric → ask-it-to-review-the-PR. The skill collapses (b)+(c)+(d) into a single PR comment that Codex's GitHub App picks up. Naming the rubric file in the comment is load-bearing — the user's habit, and the way Codex reliably uses the project's conventions. Async-and-done (no polling) keeps the Claude session free to do other work; the user reads results on the PR page.
**Test:** manual — `ls templates/.claude/skills/request-codex-review/SKILL.md` exists; `grep -E '^request-codex-review:' templates/Makefile` finds the target.
**Status:** superseded by B-009 (v1.6.0). Reason: assumed a Codex GitHub App that doesn't exist on the user's account; pivoted to local CLI.
**Decision:** D-006 (superseded by D-007)

### Block B-009: `request-codex-review` skill runs `codex review --base main` locally

**Rule:** When the user asks Claude to send the current branch to Codex for review (or invokes `/request-codex-review`), Claude runs the `request-codex-review` skill at `templates/.claude/skills/request-codex-review/SKILL.md`. The skill verifies prereqs (`codex` CLI installed, current branch is not `main`, branch has commits ahead of `main`), runs `codex review --base main` synchronously, captures and surfaces the final review block to the user, and stops. Does NOT post to GitHub, does NOT auto-fix, does NOT mutate any state beyond the local CLI invocation. A `make request-codex-review` Makefile target wraps the same checks + invocation for terminal use outside Claude sessions.
**Rationale:** Codex is the project's default reviewer. The local CLI path matches the user's actual setup (codex installed locally; no GitHub App) and matches their established habit of running codex from the project folder. Synchronous output lets findings be triaged in the same session that ran the review. Supersedes B-008 (`gh pr comment @codex` → GitHub App), which targeted a path the user's account doesn't have.
**Test:** manual — `codex review --help` shows the `--base` flag; `make -C templates -n request-codex-review` dry-runs the new invocation cleanly (no `gh pr comment`).
**Status:** superseded by B-010 (v1.7.0). Reason: skill, Makefile target, and verb all removed; review is out-of-band and reviewer-agnostic — user runs any reviewer in a separate session per B-010.
**Decision:** D-007 (superseded by D-008)

### Block B-011: action-verb table (no `review` verb)

**Rule:** The recognized action verbs that pair with `gogogo!` are: `code` · `feat` · `fix` · `chore` · `docs` · `refactor` · `test` · `perf` · `ship` (full 5-step); `commit` (commit + push, no deploy); `PR` · `ready` · `open PR` (open pull request); `merge` (`gh pr merge --rebase --delete-branch`); `deploy` (run project deploy); `revert` (revert last commit + redeploy). There is no `review gogogo!` verb — review is out-of-band per B-010, so the verb would gate nothing Claude does.
**Rationale:** A `gogogo!` verb authorizes a state-mutating action Claude takes. After B-010 made review fully user-side, `review gogogo!` had no Claude action left to authorize. Keeping the verb would either be a no-op or a misleading "Claude is preparing your review" reminder. Removing it keeps the verb table honest. Bare-`gogogo!` clarification prompt no longer offers `review` as a choice. Supersedes B-006.
**Test:** manual — `grep -nE '^\| \`review gogogo' templates/CLAUDE.md templates/CONTRIBUTING.md PROJECT_STARTER.md docs/spec.md` returns nothing on the active rule rows (historical mentions in superseded blocks / changelogs are intentional audit trail).
**Status:** superseded by B-026 (v1.23.0). Reason: the action-verb concept is removed entirely. Under B-026's propose-and-confirm gate, the action description lives in Claude's proposal in plain English; there is no user-typed verb. The workflows the verbs previously mapped to (full 5-step, commit-only, PR-open, merge, deploy, revert) still exist as action shapes — they're just named in the proposal text rather than encoded as verbs.
**Decision:** D-008 (now superseded by D-010 alongside D-004)

### Block B-013: `scripts/export-starter.sh` produces a portable kit archive

**Rule:** Running `./scripts/export-starter.sh` from the repo root writes `~/Downloads/project-starter-v<VERSION>-<YYYY-MM-DD>.tar.gz` (always) and `~/Downloads/project-starter-v<VERSION>-<YYYY-MM-DD>.zip` (only when `zip` is installed — graceful skip with a message otherwise, matching minimal-Linux defaults). The archive contains a top-level `project-starter-v<VERSION>-<YYYY-MM-DD>/` directory holding `PROJECT_STARTER.md` plus the full `templates/` tree, so consumers can `tar -xzf ... --strip-components=1` directly into a new project per PROJECT_STARTER §1.3. Output dir is overridable via the `OUT_DIR` env var; default `~/Downloads` (auto-created if missing). Script reads `VERSION` from the repo root, fails loud (`set -euo pipefail`) if `PROJECT_STARTER.md` or `templates/` are missing, and cleans up its tempdir on exit (`trap`).
**Rationale:** Closes the trust-break Codex flagged at improvement-plan Phase 1.1 (and existing open item #4 / template inventory item B4). `PROJECT_STARTER.md §1.3` has recommended the script as "the quick path" since v1.1.1 (2026-05-04), but the script never shipped — running the recommended command produced "No such file or directory." Until now the doc lied; shipping the script makes the §1.3 contract real and unblocks Package C's smoke test (which can use `export-starter` to instantiate a fake project end-to-end without re-implementing the archive logic).
**Test:** manual — `./scripts/export-starter.sh && ls -la ~/Downloads/project-starter-v$(cat VERSION)-$(date +%F).tar.gz` produces a non-empty archive; `tar -tzf ~/Downloads/project-starter-v$(cat VERSION)-$(date +%F).tar.gz | head` shows entries under `project-starter-v<VERSION>-<DATE>/PROJECT_STARTER.md` and `project-starter-v<VERSION>-<DATE>/templates/...`; `bash -n scripts/export-starter.sh` syntax-checks clean.
**Status:** superseded by B-015 (v1.11.0, same-day). Reason: the "full templates/ tree" wording was ambiguous; the shipped implementation kept `templates/` as a nested subdirectory, which broke PROJECT_STARTER.md §1.3's `chmod +x scripts/*.sh` because `scripts/` ended up at `<root>/templates/scripts/`. The smoke test (B-014) caught this end-to-end. B-015 specifies the correct promoted-contents layout.
**Decision:** —

### Block B-018: `bootstrap.sh` validators — generic core + project-specific sidecar

**Rule:** `templates/scripts/bootstrap.sh` ships a `VALIDATORS` associative array containing ONLY truly generic patterns: `LOG_LEVEL` (log-level enum) and `DEV_MODE` (boolean). Project-specific validators (vendor regexes for tokens/IDs/URLs of services the consuming project happens to use) MUST live in `templates/scripts/validators.sh`, a sourced sidecar file that `bootstrap.sh` sources at load time IF it exists. The sidecar mutates `VALIDATORS` directly (it's sourced from inside `bootstrap.sh`'s scope, so `VALIDATORS[NEW_VAR]='regex'` Just Works). The shipped skeleton `validators.sh` contains an explanatory header plus commented-out example entries (Telegram, Stripe, generic URL/postgres patterns) for guidance, but adds zero validators by default. Consumers uncomment/customize for their own project.
**Rationale:** The prior `bootstrap.sh` hardcoded Telegram/Meta/Keitaro/webhook validators in the generic core — application-specific bake-ins from the project this template was extracted from. Codex improvement-plan Phase 1.2 flagged the contradiction: a generic template that knows about Telegram tokens by default isn't actually generic. The sidecar approach gives consumers a deliberate extension point (Phase 1.2 acceptance criterion: "Project-specific validators live in a deliberate, documented layer") without requiring them to modify shipped template files (which would conflict with future template updates merging into their repo). Generic-only-by-default + explicit sidecar matches the v1.8.0 product-identity decision (D-009): we're a Python/uv/FastAPI/VPS starter; Telegram/Meta/Keitaro are vendor concerns for specific projects, not shipped expectations.
**Test:** manual — `grep -nE '\[TELEGRAM_|\[META_|\[KEITARO_|\[WEBHOOK_BASE_URL' templates/scripts/bootstrap.sh` returns nothing in the live `VALIDATORS` array (audit-trail mentions in `CHANGELOG.md` and the Codex plan are intentional). `ls templates/scripts/validators.sh` exists. `bash -n templates/scripts/{bootstrap,validators}.sh` syntax-checks clean. Smoke test (B-014) still passes — bootstrap not directly exercised but the refactor introduces no regression.
**Status:** superseded by B-020 (v1.15.0). Reason: the `@directive` system (B-020, frozen v1.14.1) provides the same per-var validator extension point inline in `.env.example` via `@validator:` directives. The separate `validators.sh` sidecar was therefore a second mechanism for the same job — exactly the kind of duplication Codex's plan kept warning against. The v1.12.0 work isn't wasted (it was the right step at the time and shipped a working extension point), just superseded by a cleaner unified mechanism. `templates/scripts/validators.sh` deleted; `bootstrap.sh` source block removed.
**Decision:** —
