# Changelog

All notable changes per `VERSION` bump. Per the `gogogo!` 5-step workflow, every change bumps `VERSION` and adds an entry here in the same commit.

Format: `## v<X.Y.Z> — YYYY-MM-DD` followed by bullets, optionally grouped by area.

---

## v1.32.2 — 2026-05-19

Mirrors `PROJECT_STARTER.md` template v1.32.2. **Phase 5.3 of Codex improvement plan — defer `scripts/new-project.sh` (D-017). Closes the Codex improvement plan in full.** Commit 3 of 3 of the Phase-5 trio. Docs-only change; no infrastructure or behavior change. Patch bump per WORKFLOW.md.

### What shipped

D-017 in `docs/spec.md` Decision log records that the candidate `scripts/new-project.sh <slug> <package>` one-shot bootstrap helper named in Phase 5.3 is **deferred**. Manual bootstrap path documented in `BOOTSTRAP.md` is sufficient given adjacent work that shipped this trio.

**Reasoning summary** (full Chose / Considered / Why / Failure-mode analysis in D-017):

- Friction reduced by `scripts/render-example.sh` (B-035, v1.32.1) which shows consumers substituted output in one command.
- Selective-import use cases covered by `MIGRATION.md` (B-034, v1.32.0) without needing a bootstrap helper at all.
- `templates/manifest.yaml` (B-032, v1.31.0) gives consumers a machine-readable per-file placeholder set if they want to script their own substitution.
- Remaining friction (typing `mv` + `sed` once per new project) is small vs. the cost of building / testing / maintaining a helper covering the hard parts — `gh repo create` + branch-protection + merge-settings via `gh api`. Those are largely irreversible side effects sensitive to `gh` auth context, GitHub org permissions, and per-team repo-settings opinions.
- Four options considered: (a) defer chosen; (b) thin substitution-only helper deferred-but-not-rejected as cheapest revisit path; (c) full helper rejected on `gh`-side fragility; (d) gated-by-flag rejected on principle (gating the hard part doesn't reduce maintenance cost).
- Trigger for revisit: adoption friction observable in the wild — option (b) is the cheapest first step at that point.

### Codex improvement plan closes

| Phase | Status | Resolution |
|---|---|---|
| Phase 1 — fix active doc regressions | done | v1.26.x |
| Phase 2 — tighten documentation architecture | done | v1.18.0 / v1.27.1 / v1.29.2 |
| Phase 3 — extend drift-detection automation | done | v1.27.0 / v1.29.x / v1.29.3 |
| Phase 4 — formalize inventory + preset boundaries | done | v1.30.0 / v1.31.x (incl. D-016 for §4.4) |
| Phase 5 — improve adoption UX | done | v1.32.0 / v1.32.1 / v1.32.2 (incl. D-017 for §5.3) |

All five phases resolved. Future roadmap work — actual `_common/` + `presets/python-uv/` file move (gated by B-030); second language preset; new failure modes that emerge in real-world adoption — is outside the Codex plan's scope and tracked separately in `docs/spec.md` "Open project-level decisions."

### Docs

- **`codex improvement plan.md`** — Phase 5 header gains a "Resolved" line; Phase 5 §1/§2/§3 each gain a per-§ resolution paragraph; new "Plan status: closed" appendix below Recommendations summarizing all five phases.

### What didn't change

- No spec block — D-017 is a Decision-log entry, no new B-NNN.
- No script changes; no template changes; no linter changes.
- No changes to existing C4 regions, gate semantics, manifest contents, MIGRATION.md/render-example.sh from this trio's prior commits, or any consumer-facing behavior.

### Verified

- All 5 linters green (C4 + C2 doc-ref + C3 placeholders + C5 spec-consistency + manifest).
- D-017 inserted between D-016 and "Open project-level decisions" section in `docs/spec.md`.
- `codex improvement plan.md` Phase 5 §3 records the deferral; "Plan status: closed" table at the bottom enumerates all five phases.

## v1.32.1 — 2026-05-19

Mirrors `PROJECT_STARTER.md` template v1.32.1. **Phase 5.2 of Codex improvement plan — on-demand example rendering (B-035).** Commit 2 of 3 closing Codex Phase 5. Patch bump per WORKFLOW.md (new convenience script + narrow spec block; no behavioral surface change).

### What shipped

New `scripts/render-example.sh` (~80 lines, meta-only — not exported by `scripts/export-starter.sh`) produces a deterministic, fully-substituted instantiation of the kit for inspection. Output: `OUT_DIR` (default `~/Downloads/phoenixproject-example/`; wiped + recreated on every run).

**Canonical substitution map** covers every B-024 canonical placeholder:

| Placeholder | Value |
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

**Substitution-logic invariant:** matches `scripts/smoke-test.sh` phase 3 byte-for-byte — same canonical pattern (one `mv` for `src/<package_name>` rename; one `sed` across `*.py` / `*.toml` / `Makefile` / `*.yml` / `*.yaml` / `*.sh` / `*.example`). If the smoke-test substitution logic changes, this script changes in the same commit. The smoke test is the executable-and-tested reference; `render-example.sh` is the inspectable-by-humans companion. Extended scope for the canonical-map application: `*.md` + `LICENSE` (smoke-test doesn't apply non-`<package_name>` substitutions because they don't affect tooling correctness; this script applies them all because the purpose is humans-reading-output).

### Shape decision: script-only, no committed example-project/

The Codex Phase 5.2 acceptance is "consumers can compare template form to instantiated form concretely." Two shapes satisfy it: (a) static committed `example-project/` directory + CI drift check; (b) on-demand render script. Picked (b): script + README + MIGRATION pointers. Maintenance cost dramatically lower (no 30-file duplication, no drift surface); same comparison affordance. If (a) becomes wanted later for GitHub-browsable-without-checkout, the renderer becomes the CI re-render source — extension is straightforward.

### Wiring

- **`templates/manifest.yaml`** — new entry: `scripts/render-example.sh`, `tier: meta-only`, `placeholders: []`, `exported_by_starter: false`. Total: 44 entries (was 43).
- **`README.md`** — new paragraph at the end of Quickstart: "Want to see what a rendered project looks like first? Run `./scripts/render-example.sh`..."
- **`MIGRATION.md`** — new paragraph above the When-to-use section: same surface, framed for selective-import audience.

### Spec

- **B-035 added** (frozen) — canonical substitution map (table) + substitution-logic invariant (matches smoke-test phase 3 byte-for-byte) + shape rationale (script-only vs static-committed) + test recipe.

### What didn't change

- No changes to `scripts/smoke-test.sh` — substitution logic already correct; render-example matches it.
- No changes to `templates/` content (all substitutions are runtime; template files retain `<...>` placeholders).
- No changes to existing C4 regions, gate semantics, manifest schema, or any consumer-facing tooling behavior.
- No new linter — render-example correctness is verified by spec.

### Verified

- Clean run: `OUT_DIR=/tmp/rx ./scripts/render-example.sh` exits 0; 29 files rendered.
- Post-render grep: no canonical placeholders remain (`<package_name>` / `<PACKAGE_NAME>` / `<PROJECT_NAME>` / `<PROJECT_SLUG>` / `<GITHUB_USER>` / `<HOST>` / `<DOMAIN>` / `<COPYRIGHT_HOLDER>` / `<YEAR>` / `<PROJECT_DESCRIPTION>` all substituted in their bare form).
- Instructional meta-syntax preserved: `<PROJECT_DESCRIPTION — one or two sentences.>` in `templates/README.md` correctly untouched (not in canonical set).
- `templates/src/<package_name>/` renders as `src/exampleproj/`.
- All 5 linters green; manifest count: 44.

### Next

Commit 3 of 3: D-017 defer `scripts/new-project.sh` + close Codex plan (v1.32.2).

## v1.32.0 — 2026-05-19

Mirrors `PROJECT_STARTER.md` template v1.32.0. **Phase 5.1 of Codex improvement plan — migration guide (B-034).** Commit 1 of 3 closing Codex Phase 5 (the final phase). Minor bump per WORKFLOW.md (new root-exported artifact + new spec block).

### What shipped

New `MIGRATION.md` at meta-repo root (~280 lines) — the canonical guide for adopting the kit selectively or incrementally into an existing project, as opposed to greenfield bootstrap which `BOOTSTRAP.md` already covers.

**Six sections:**

- **When to use the full kit vs. import selected parts** — decision table mapping situation to path.
- **Importing just the process layer** — `gogogo!` gate + 5-step workflow + C4-anchored trio + standing rules. Files: `CONTRIBUTING.md` + `CLAUDE.md` + `.claude/settings.json` + `.claude/skills/spec-block/`. Includes merge-with-existing guidance for projects that already have their own `CONTRIBUTING.md`/`CLAUDE.md`.
- **Importing just docs** — PR review rubric + Karpathy standing rules + spec-block format. Reviewer-agnostic per B-010 — works with any reviewer (Codex CLI, `/ultrareview`, manual, any LLM).
- **Importing just env-bootstrap** — the four-file self-contained unit (`.env.example` + `_env-schema-parse.sh` + `bootstrap.sh` + `check-env.sh`). Includes `.claude/settings.json` `SessionStart` hook wiring snippet.
- **Importing just the linter set** — per-linter standalone-vs-coupled assessment in a table. `check-doc-references.sh` standalone; `check-rule-consistency.sh` / `check-placeholders.sh` / `check-spec-consistency.sh` need local adaptation; `check-manifest.sh` requires the manifest convention (B-032).
- **Adoption order** — recommended week-by-week sequence for projects that want the whole kit eventually but phased across time. Highlights that each layer is independent and reversible (delete the files = back where you started; no schema migration, no persistent state).
- **What this kit doesn't try to be** — explicit non-goals: not a framework; not Python-only except today; not a forced-migration kit.

### Wiring

- **`scripts/export-starter.sh`** — `MIGRATION.md` added to `ROOT_DOCS` array. Archive now ships 7 root docs (was 6).
- **`scripts/check-doc-references.sh`** — `MIGRATION.md` added to `VIRTUAL_TEMPLATES_FILES` so links inside `templates/` resolve correctly in the archive layout (B-023).
- **`templates/manifest.yaml`** — new entry: `tier: common`, `placeholders: []`, `exported_by_starter: true`. Total: 43 entries (was 42).
- **`README.md`** — Quickstart preamble: "Already have a project? Read MIGRATION.md instead..." surfacing the toolkit path before the greenfield path. New docs-table row for MIGRATION.md.

### Spec

- **B-034 added** (frozen) — the kit is consumable as a toolkit (selective import), not only as a fresh-start template; `MIGRATION.md` is canonical for the toolkit path; the four selective-import layers (process / docs / env-bootstrap / linter set) are named explicitly; each has a known file list and a standalone-vs-coupled assessment.

### What didn't change

- No changes to `BOOTSTRAP.md` (greenfield path remains the default; this is additive).
- No changes to existing C4 regions, gate semantics, manifest schema, or any consumer-facing tooling behavior.
- No new scripts; no new linter invariants.

### Verified

- All 5 linters green (C4 + C2 doc-ref + C3 placeholders + C5 spec-consistency + manifest). C2 link target count now 80+ (new MIGRATION.md links land in scope).
- Manifest count: 43 entries.
- `scripts/export-starter.sh` `ROOT_DOCS` includes MIGRATION.md; archive includes it.

### Next

Commit 2 of 3: `scripts/render-example.sh` + B-035 (v1.32.1). Commit 3 of 3: D-017 defer `scripts/new-project.sh` + close Codex plan (v1.32.2).

## v1.31.2 — 2026-05-19

Mirrors `PROJECT_STARTER.md` template v1.31.2. **Phase 4.4 of Codex improvement plan — bootstrap-mode deferral decision (D-016).** Final commit (3 of 3) closing Codex Phase 4. Docs-only change; no infrastructure or behavior change. Patch bump per WORKFLOW.md.

### What shipped

D-016 in `docs/spec.md` Decision log records that bootstrap modes (the candidate set `full-python-vps`, `python-local-only`, `docs-only` named in `presets/PRESET_ARCHITECTURE.md` and Phase 4.4 of the Codex plan) are **deferred** until after the actual `_common/` + `presets/python-uv/` file move ships.

**Reasoning summary** (full Chose / Considered / Why / Failure-mode analysis in the D-016 entry):

- Stacking mode-selection on top of preset-selection before the single-preset multi-tier layout (B-030) even exists doubles the optionality surface for no current consumer.
- The kit ships exactly one preset today (Python/uv/FastAPI/VPS); all candidate modes describe subsets/variants of that one preset, so the mode design can't be validated against multi-preset reality until multi-preset exists.
- The orthogonal-axes shape (`--preset` × `--mode`) is the likely long-term form when the question is revisited.
- Phase 5.1 migration guidance (covered separately in the Codex plan) handles the `docs-only` use case as a manual procedure in the interim — cheaper than mode infrastructure.

### Docs

- `presets/PRESET_ARCHITECTURE.md` "What's deferred" §: replaced the inline "tracked separately" prose for bootstrap-mode decision with a pointer at D-016, plus the orthogonal-axes long-term-form note.
- `codex improvement plan.md` Phase 4 §4: appended a "**Resolved (v1.31.2, D-016): deferred**" paragraph below the existing Acceptance line; original text unchanged.

### Phase 4 of the Codex improvement plan now closes

- §4.1 (machine-readable manifest) — shipped v1.31.0 (B-032).
- §4.2 (core / optional / preset-specific classification) — shipped v1.31.0 as `tier` field in the manifest.
- §4.3 (`_common` vs preset boundary design) — shipped v1.30.0 (B-030 + D-015).
- §4.4 (bootstrap-mode decision) — resolved this commit (D-016, deferred).

All Phase 4 acceptance criteria met. Remaining roadmap work: actual `_common/` + `presets/python-uv/` file move (gated by B-030; separate proposal); Phase 5 adoption-UX work (migration guidance, instantiated-project snapshot, evaluate `scripts/new-project.sh`).

### What didn't change

- No spec block — D-016 is a Decision-log entry, no new B-NNN.
- No linter changes; no script changes; no template changes.
- No changes to existing C4 regions, gate semantics, manifest contents, or any consumer-facing behavior.

### Verified

- All 5 linters green (C4 + C2 doc-ref + C3 placeholders + C5 spec-consistency + manifest).
- D-016 inserted between D-015 and the "Open project-level decisions" section in `docs/spec.md`.
- `presets/PRESET_ARCHITECTURE.md` "What's deferred" § now references D-016.
- `codex improvement plan.md` Phase 4 §4 records the resolution.

## v1.31.1 — 2026-05-19

Mirrors `PROJECT_STARTER.md` template v1.31.1. **Phase 4.1 + 4.2 of Codex improvement plan — manifest linter (B-033).** Commit 2 of 3 closing Codex Phase 4. Patch bump per WORKFLOW.md (typical linter extension; no behavior change).

### What shipped

`scripts/check-manifest.sh` (executable) enforces three invariants on `templates/manifest.yaml`:

- **Invariant 1 — no orphans:** every regular file under `templates/` has a manifest entry. Scope intentionally limited to `templates/`; `scripts/*.sh` meta-only entries listed in the manifest for completeness but not enforced as orphans (avoids forcing manifest edits on every new linter).
- **Invariant 2 — no stale entries:** every `path` in the manifest resolves to an existing file. Covers all three tiers.
- **Invariant 3 — placeholders match:** for each manifest entry under `templates/` (except the self-referential `manifest.yaml`), the declared `placeholders` list equals the B-024 canonical placeholders that actually appear in the file's content. Root-exported docs and meta-only scripts excluded from this invariant — they mention placeholder strings as references TO the substitution targets, not as substitution targets themselves.

### Manifest gap fix (caught by the new linter)

Adding the linter exposed two manifest gaps from v1.31.0 (orphan check):
- `templates/manifest.yaml` itself wasn't listed → added as `common` / `[]` / exported.
- `scripts/check-manifest.sh` (this commit's new linter) added as `meta-only` / `[]` / not exported.

Total entries now 42 (was 40).

### CI / smoke-test wiring

- New step in `.github/workflows/template-self-test.yml` (between `check-spec-consistency` and the smoke test).
- New pre-flight check 0c in `scripts/smoke-test.sh` (after B-031's 0a parse-check and 0b C4-content check). Belt-and-suspenders for local-dev runs that invoke smoke-test directly without running the linters separately.

### Implementation notes

- Manifest parsing uses awk field-by-field extraction; no YAML library dependency.
- Placeholder-set comparison uses `LC_ALL=C sort -u` for locale-stable ordering.
- Pipefail-safe: `grep` calls that may return exit 1 on no-match are wrapped `(grep ... || true)` so empty cases produce empty output instead of killing the script. (Initial run without these wrappers exposed the issue immediately — the linter died silently on the first file with no canonical placeholders.)

### Spec

- **B-033 added** (frozen) — three invariants + scope rules + the `templates/*` placeholder-check restriction + the manifest.yaml self-exclusion + pipefail-safe parsing notes.

### Verified

- Clean run: `OK: manifest valid — 42 entries, no orphans under templates/, no stale paths, placeholders match content.`
- Planted-violation tests: invariant 1 fires on `touch templates/test_orphan.tmp`; invariant 2 fires on appending `templates/this-does-not-exist.txt` to the manifest; invariant 3 fires when adding `HOST` to `templates/Makefile`'s declared list while the file doesn't contain `<HOST>`.
- All 5 linters green (4 existing + new): C4 + C2 doc-ref + C3 placeholders + C5 spec-consistency + manifest.
- Smoke test pre-flight phase 0 now reports 3 checks; phase 1–7 unchanged.

### What didn't change

- No edits to the manifest data itself beyond the two missing-entry fixes.
- No changes to the other 4 linter scripts.
- No changes to gate semantics, C4 regions, version-bump rules, or any consumer-facing behavior.

### Next

Commit 3 of 3: D-016 bootstrap-mode deferral decision (v1.31.2). Phase 4 of the Codex improvement plan closes after that.

## v1.31.0 — 2026-05-19

Mirrors `PROJECT_STARTER.md` template v1.31.0. **Phase 4.1 + 4.2 of the Codex improvement plan — machine-readable template manifest (B-032).** First commit of three closing Codex Phase 4 (4.3 already shipped v1.30.0 as design; this trio handles 4.1 manifest, 4.2 tier classification, 4.4 bootstrap-mode deferral). Minor bump per WORKFLOW.md (new artifact + new spec block).

### What shipped

A new `templates/manifest.yaml` declaring every file the kit ships or maintains, with per-entry `path` / `purpose` / `tier` / `placeholders` / `exported_by_starter`. Covers three categories: (a) the six root docs in `scripts/export-starter.sh`'s `ROOT_DOCS` array; (b) every file under `templates/` (28 entries); (c) every meta-only script under `scripts/` (the four current linters + export-starter + smoke-test). Total: 40 entries.

**Tier vocabulary** matches B-030's layer model exactly so the future `_common/` + `presets/python-uv/` file move is mechanical:

- `common` — stack-agnostic content; lands in future `_common/`. Includes the workflow + gate trio (CONTRIBUTING.md, CLAUDE.md), the spec-block skill, env-bootstrap core, Karpathy rules, review rubric, meta scaffolding.
- `python-preset` — stack-specific to Python/uv/FastAPI/VPS; lands in future `presets/python-uv/`. Includes Makefile, pyproject.toml, .python-version, CI workflow, deploy.sh, src/ + tests/ sample tree, docs/setup.md (Python prereqs), DEPLOY_BASELINE.md (VPS baseline).
- `meta-only` — lives only in the meta-repo; never exported. The four linter scripts plus export-starter + smoke-test.

**Placeholder tracking** lists canonical B-024 names (without angle brackets) per file. Illustrative angle-bracket syntax in prose (`<METHOD>`, `<N>`, `<CMD>`, `<DEPLOY_CMD>`, `<TARGET>`, `<VAR>`, `<IP>`, `<NAME>`, `<DB_PATH>`, `<URL>`, `<ERE>`, `<PRE_MVP_CAVEAT_OR_OMIT>` — anything outside the B-024 set scanned by `scripts/check-placeholders.sh`) is intentionally NOT tracked.

### Spec

- **B-032 added** (frozen) — manifest format + tier vocabulary + scope + the YAML-but-flat parsing constraint. Inserted in the active section right after B-031.

### Docs

- `TEMPLATE_INVENTORY.md` gains a one-paragraph header pointing at the manifest as the machine-readable source of truth. The human-prose table below remains for narrative orientation; the manifest is authoritative for tooling.

### What didn't change

- No linter yet — the manifest is a data file in this commit. `scripts/check-manifest.sh` ships in the next commit (v1.31.1, B-033) and wires into CI.
- No file moves — `templates/` flat structure unchanged; `_common/` and `presets/python-uv/` directories still don't exist (per B-030 v1.30.0 deferral).
- No bootstrap-mode decision yet — that's commit 3 of this trio (v1.31.2, D-016).
- No changes to existing C4 regions, gate semantics, or any shipped script behavior.

### Verified

- `python -c "import yaml; yaml.safe_load(open('templates/manifest.yaml'))"` round-trips clean (40 entries).
- Every `path` in the manifest resolves to an existing file (`for p in $(grep '^  - path:' templates/manifest.yaml | awk '{print $3}'); do [ -e "$p" ] || echo "MISSING: $p"; done` is silent).
- All four existing linters green: C4 (3 regions × 3 trio files) + C2 doc-ref (76 link targets, 6 URL fragments validated across 25 files now adds manifest.yaml as a non-Markdown asset) + C3 placeholders (12 files) + C5 spec-consistency (10 invariant patterns).

### Next

Commit 2 of 3: `scripts/check-manifest.sh` + CI wiring (v1.31.1, B-033). Commit 3 of 3: D-016 bootstrap-mode deferral decision (v1.31.2).

## v1.30.1 — 2026-05-19

Mirrors `PROJECT_STARTER.md` template v1.30.1. **Fix stale `<feature-verb> gogogo!` meta-syntax in `templates/CONTRIBUTING.md` heading** — flagged-not-fixed during Commit 3 (v1.29.2) of the improvements-3 sequence; addressed now as a quick follow-up before PR-open. Patch bump.

### What it was

`templates/CONTRIBUTING.md` line 267 had the heading:

> `## Mandatory 5-step sequence on \`<feature-verb> gogogo!\``

That `<feature-verb>` meta-syntax is the pre-v1.23.0 verb-prefix gate phrasing — the v1.23.0 + v1.23.1 sweeps replaced concrete verbs (`feat`/`commit`/`PR` etc.) and meta-references to the verb model with propose-and-confirm wording. The angle-bracketed meta-syntax `<feature-verb>` escaped the sweep because the v1.23.1 grep pattern targeted literal verb names (`\b(feat|commit|PR|...) gogogo!`) not the meta-syntax form `<...-verb> gogogo!`.

The heading text was internally inconsistent post-v1.23.0: it described the workflow as keyed by `<feature-verb> gogogo!` but the body section is the standard 5-step (spec → bump+CHANGELOG → code → commit → deploy) that runs when the user `gogogo!`s any state-mutating proposal. The verb-prefix gate model has been gone since v1.23.0.

### The fix

Heading rewritten to:

> ``## Mandatory 5-step sequence on a `gogogo!`-authorized feature proposal``

Added a one-line preamble pointing at WORKFLOW.md's canonical "The 5-step atomic sequence" section, with anchor `#the-5-step-atomic-sequence-on-gogogo` validated by the new B-029 URL-fragment linter (6 URL fragments validating now across 25 files, was 5).

### What didn't change

- The 5-step procedure itself (spec → bump+CHANGELOG → code → commit → deploy) is unchanged.
- No other prose in the section was touched.
- No spec edits — the rule itself (B-026 + B-027 + B-028 gate + 5-step from WORKFLOW.md) is unchanged.
- No C4 region edits — this heading is not inside any anchored region.
- No new B blocks, no new D entries.

### Why this didn't get caught by the v1.29.1 Invariant C

Invariant C of the spec-consistency linter catches `verb-prefix gate` / `verb table (per|in|of) (the )?(active|current)` / `action verb (per|in|of) (the )?(active|current)`. The stale heading used `<feature-verb> gogogo!` — meta-syntax with angle brackets — which doesn't match those patterns.

**Follow-up consideration** for a future invariant addition (NOT in this commit): a pattern like `\<[a-z-]+-verb\>` or `<verb> gogogo!` would catch the meta-syntax form. Deferred since this is the only known instance; D-014's bar is "we've shipped this exact bug already" + Invariants B/C were the structural-prevention exception. Adding more speculative patterns now would inflate the false-positive surface. Better to wait until a second instance of meta-syntax verb references actually surfaces, then decide whether to add the pattern.

### Verified

- All 4 linters green: C4 (3 regions) + C2 doc-ref (76 link targets, **6 URL fragments** validated across 25 files) + C3 placeholders (12 files) + C5 spec-consistency (10 invariant patterns).
- Branch state: `improvements-3` now holds **10 commits** ahead of `main`. Ready for PR-open.

### Next

PR-open for `improvements-3` (10 commits). Would surface as a new `[change]` proposal next turn.

## v1.30.0 — 2026-05-19

Mirrors `PROJECT_STARTER.md` template v1.30.0. **Phase 4.3 of the Codex improvement plan — preset architecture design (B-030 + D-015).** Final commit (5 of 5) in the `improvements-3` sequence. Design only; no implementation work in this commit.

### What shipped

A new `presets/PRESET_ARCHITECTURE.md` at meta-repo root (~140 lines) documenting the layer model + composition rule for future multi-preset support:

**Layer model:**

- **`_common/`** — stack-agnostic content shared across all future presets. Owns: workflow docs (WORKFLOW.md + the per-project + AI-session template trio); spec-block format skeleton + the `spec-block` skill; reviewer-agnostic review rubric (B-010); changelog conventions + B-002 version-bump rule; env-bootstrap core (`_env-schema-parse.sh` / `bootstrap.sh` / `check-env.sh`); Karpathy standing rules; meta scaffolding (`.gitignore`, `.claude/settings.json`, `CHANGELOG.md` skeleton).
- **`presets/<preset-name>/`** — stack-specific content. Owns: runtime pin (`.python-version` / `.nvmrc` / etc.); project metadata file (`pyproject.toml` / `package.json` / `go.mod`); Makefile with stack-appropriate commands; CI workflow with stack-appropriate lint / typecheck / test gates; deploy script (varies dramatically per stack); sample source tree (`src/<package_name>/` Python / `src/index.ts` Node / `cmd/<binary>/main.go` Go); sample smoke test; setup-doc prereqs.

**Composition rule:** a bootstrapped project = `_common/` contents flattened with one chosen `presets/<chosen>/` contents at the project root.

**Four constraints frozen by B-030:**

1. Single preset per project — mixed-preset out of scope.
2. No file conflicts between layers — each file has exactly one owner.
3. Uniform placeholders per B-024's canonical set work the same way across all presets.
4. C4-anchored regions (gate-clause / proposal-format / bare-gogogo / env-metadata-contract) live in `_common/`; presets don't override them.

### Spec

- **B-030 added** (frozen) — layer model + composition rule + four constraints. References `presets/PRESET_ARCHITECTURE.md` as the canonical design source.
- **D-015 added** — chosen alternative + rejected alternatives (branched repos, Jinja-style single-tree, inverted naming) with full failure-mode analysis: `_common/` accumulation risk, preset-conflict edge cases (what if a future preset legitimately needs to vary something `_common/` owns?), C4 regions potentially needing preset-specific context, smoke-test coverage multiplication, export-starter.sh update needed when implementation lands.
- Refines D-009 (Python/uv/FastAPI/VPS-only scope + multi-preset roadmap) by specifying HOW multi-preset would work.

### What's NOT in this commit (deliberately deferred)

- **`_common/` and `presets/python-uv/` directories do NOT exist** as of v1.30.0. Only the design doc + spec blocks exist.
- **`templates/` is unchanged** — files stay in their current flat layout.
- **`scripts/export-starter.sh` is unchanged** — still exports flat `templates/`.
- **`scripts/smoke-test.sh` is unchanged** — tests one Python preset (the existing flat layout).
- **No second preset (Node / Go / no-runtime) implementation.**
- **No bootstrap mode decision** (`full-python-vps` vs `python-local-only` vs `docs-only`) — Phase 4.4 of the Codex plan; separate decision.

The design doc includes a suggested implementation order for when the multi-preset work begins: (1) create `_common/` + move stack-agnostic files; (2) create `presets/python-uv/` + move stack-specific files; (3) update `scripts/export-starter.sh` with `--preset` flag; (4) update `scripts/smoke-test.sh` for per-preset matrix; (5) add a second preset to exercise the architecture. Each step is a separate `gogogo!`-authorized proposal when its time comes.

### Verified

- All 4 linters green: C4 (3 regions byte-exact, 4 named) + C2 doc-ref (the new `presets/PRESET_ARCHITECTURE.md` is in scope; its Markdown links resolve including the `docs/spec.md` references) + C3 placeholders (the new doc adds canonical placeholder mentions inside backticks — code spans stripped per linter convention so no false-positives) + C5 spec-consistency (10 invariants, scope unchanged).
- Smoke test green: 4 C4 regions ≥ 100 non-blank chars; `.env.example` parses to 6 vars; full export → instantiate → uv-sync → pytest → ruff → mypy pipeline passes.

### `improvements-3` branch state after this commit

5 commits stacked on `main` (top of branch is this commit). The full sequence:

1. **v1.29.0** (`fd137d4`) — B-029 URL-fragment validation + spec-consistency linter (Phase 3.2).
2. **v1.29.1** (`10a49b2`) — Spec-consistency Invariants B + C structural prevention (Phase 2.1 reframed).
3. **v1.29.2** (`c38f785`) — Trim duplicated refuse-list from templates/CONTRIBUTING.md (Phase 2.2).
4. **v1.29.3** (`37507d1`) — B-031 smoke-test pre-flight integrity checks (Phase 3.3).
5. **v1.30.0** (this commit) — B-030 + D-015 preset architecture design doc (Phase 4.3).

Total: 5 commits, all linter-green, smoke-test-passing. Combined with the v1.27.x + v1.28.0 commits earlier on the branch, `improvements-3` carries 9 commits total ahead of `main`. Ready for a PR-open proposal when directed.

### What's left from the Codex plan after this branch

- **Phase 4.1** — machine-checkable template manifest (gates Phase 4.2's core/optional/preset-specific marking).
- **Phase 4.2** — mark assets explicitly (trivial once 4.1 ships).
- **Phase 4.4** — bootstrap modes decision (`full-python-vps` / `python-local-only` / `docs-only`).
- **Phase 5.1** — migration guidance for existing projects (toolkit-mode adoption).
- **Phase 5.2** — example completed generated project / snapshot.
- **Phase 5.3** — one-shot bootstrap helper (`scripts/new-project.sh` for placeholder substitution).

Plus the deferred-from-Commit-3 follow-up: fix `templates/CONTRIBUTING.md` line ~279 stale heading using `<feature-verb> gogogo!` meta-syntax (v1.23.1 sweep missed it; needs either a one-line edit OR extending Invariant C in spec-consistency to cover meta-syntax patterns).

## v1.29.3 — 2026-05-19

Mirrors `PROJECT_STARTER.md` template v1.29.3. **Phase 3.3 of the Codex improvement plan — two pre-flight smoke checks (B-031)** (commit 4 of 5 in the `improvements-3` sequence). Patch bump.

### What shipped

Two new pre-flight integrity checks added to `scripts/smoke-test.sh` as Phase 0 — runs BEFORE the existing 7-phase template-instantiation flow.

**Check 0a — `.env.example` parses cleanly via `_env-schema-parse.sh`.** Sources the parser with `EXAMPLE=templates/.env.example`, verifies the `VARS` array is populated. Currently parses 6 vars. Catches a near-miss class: a malformed `.env.example` would silently break `bootstrap.sh` + `check-env.sh` in consumer projects, with no automated check between the source file and the B-020 parser contract today. The B-020 spec describes the contract; this smoke check verifies the source actually conforms.

**Check 0b — C4 trio regions carry substantive content (≥ 100 non-blank chars per region per file).** For each of the 4 named regions (gate-clause / proposal-format / bare-gogogo / env-metadata-contract) × 3 trio files (WORKFLOW.md / templates/CONTRIBUTING.md / templates/CLAUDE.md), extracts content between anchors, strips whitespace, counts chars. Fails if any of the 12 (region, file) pairs has < 100 non-blank chars.

Catches the vandalism / accidental-emptying class: B-022's byte-exact-match linter checks regions match each other but matches between three empty regions would PASS — silent loss of rule content. The existing `[[ ! -s "$out" ]]` check in `check-rule-consistency.sh` only fires on zero-byte; whitespace-only or near-empty content passes that check.

### Why these two specifically (the Phase 3.3 bar)

Per Phase 3.3's acceptance from the Codex plan: "Added test coverage is driven by known failure modes, not by checklist completion." Both checks correspond to concrete near-miss / failure classes:

- **0a** — the v1.14.x parser-swap commits could have shipped a parsing regression in `_env-schema-parse.sh` interpreting `.env.example`; no test caught the parser-output↔source relationship until now. Live regression risk is low (the parser is stable) but the gap was real.
- **0b** — the v1.23.0 + v1.24.0 + v1.27.0 commits all edited C4 regions byte-exact across the trio. An accidental near-empty edit (just delete the prose, leave the anchors) would be caught by the byte-exact linter only if SOME files have content and others don't — but if all 3 are vandalized to whitespace simultaneously, the linter passes. Defense-in-depth: 0b adds a per-region minimum-content threshold the byte-exact check can't enforce.

The check-list won't grow speculatively. New checks added per shipped regression.

### Spec

- **B-031 added** (frozen) — both checks + per-check rationale + per-check failure modes + 100-char threshold reasoning.
- No new D entry — B-031 is execution under the B-014 / B-029 framework, not a new architectural decision.

### Verified

- All 4 linters green: C4 (3 regions) + C2 doc-ref (74 link targets, 5 fragments) + C3 placeholders (11 files) + C5 spec-consistency (10 invariant patterns).
- Smoke test passes end-to-end with the new pre-flight checks: `✓ parsed 6 vars from templates/.env.example` + `✓ all 4 C4 regions ≥ 100 non-blank chars across 3 trio files`.
- Planted-violation tests: Check 0a fails when `EXAMPLE=/tmp/nonexistent` (parser aborts with `not found`); Check 0b fails when a region is emptied (`✗ region 'gate-clause' in templates/CLAUDE.md has only 1 non-blank chars (< 100)`).

### Next in 5-commit sequence

Commit 5 of 5 (v1.30.0) — Phase 4.3: preset-architecture design doc (`presets/PRESET_ARCHITECTURE.md` + B-030 + D-015). Design only, no implementation.

## v1.29.2 — 2026-05-19

Mirrors `PROJECT_STARTER.md` template v1.29.2. **Phase 2.2 of the Codex improvement plan — conservative trim of duplication outside C4 regions** (commit 3 of 5 in the `improvements-3` sequence). Patch bump.

### Audit findings

| Section | `WORKFLOW.md` | `templates/CONTRIBUTING.md` | `templates/CLAUDE.md` |
|---|---|---|---|
| Refuse-list (rationalizations) | 15 content rows | 11 rows (**drifted by 4**) | 0 (none) |
| Self-check list | full | full (drifted) | none |
| "Phrases that LOOK like authorization" | present | present | none |
| "Allowed without `gogogo!`" | present | present | none |

The trio's non-C4 duplication is asymmetric — `WORKFLOW.md` and `templates/CONTRIBUTING.md` both carry the lists; `templates/CLAUDE.md` (the AI-session-loaded surface) stays minimal with just the C4 regions. The four-row refuse-list drift represented real maintenance debt: rows added to WORKFLOW.md in v1.24.0 + v1.28.0 (after introducing always-propose + per-option [change]/[info] markers + multi-select rejection rationalizations) never propagated to CONTRIBUTING.md.

### The trim

Per the mid-execution sub-proposal (user picked Option 1: conservative-trim refuse-list only):

- **`templates/CONTRIBUTING.md` "Rationalizations to refuse"** table replaced with a one-line pointer to `WORKFLOW.md` → "Rationalizations to refuse". Pointer text includes the rationale (list evolves per observed failure mode → too high-churn for byte-exact cross-file duplication → C4 regions cover the load-bearing rules → templates/CLAUDE.md was already pointer-style).
- The new B-029 URL-fragment validation verified `#rationalizations-to-refuse` resolves to a real heading in `WORKFLOW.md` (fragment count: 4 → 5).
- **Kept intact:** self-check list, "Phrases that LOOK like authorization", "Allowed without `gogogo!`" — those serve human contributors reading CONTRIBUTING.md without WORKFLOW.md and have less drift risk.

Net code change: ~13 lines removed from `templates/CONTRIBUTING.md`. No other files touched.

### Stale-heading finding (NOT fixed in this commit)

While auditing the area around the refuse-list, found that `templates/CONTRIBUTING.md` line 279 has a section heading:

> `## Mandatory 5-step sequence on \`<feature-verb> gogogo!\``

This uses pre-v1.23 verb-prefix language — the heading says `<feature-verb> gogogo!` which is the OLD verb-prefix gate model (B-001 + B-011, superseded v1.23.0 by B-026). The v1.23.1 sweep that swept verb references through active docs missed this heading because:

1. Its grep pattern was `\b(feat|commit|PR|ready|...) gogogo!` — looking for specific verb-names with `gogogo!`. Not the meta-syntax `<feature-verb> gogogo!`.
2. The new Invariant C in spec-consistency-checker (v1.29.1) catches `verb-prefix gate` / `verb table (per|in|of)` / `action verb (per|in|of)` but not section headings using the meta-syntax `<verb> gogogo!`.

**Surfaced but deliberately NOT fixed in this commit** — out of scope for the authorized refuse-list trim. Flagged here for a follow-up; could be addressed in:

- A "Phase 2.1 cleanup-residual" commit next (small targeted edit).
- An extension to Invariant C in `check-spec-consistency.sh` adding the `<feature-verb>` meta-syntax pattern (would catch the heading on next CI run; structural prevention).

### Spec

- No new B blocks. No new D entries. B-021's three-tier model already accommodates pointer-style non-anchored duplication (it specifies what's deliberately duplicated for AI safety — the C4 regions — but doesn't mandate that ALL safety-related content be duplicated; non-C4 lists are pointer-OK).

### Verified

- All 4 linters green: C4 (3 regions) + C2 doc-ref (75 link targets, 5 URL fragments validated, up from 4) + C3 placeholders (11 files) + C5 spec-consistency (10 invariant patterns).
- Anchor `#rationalizations-to-refuse` in `WORKFLOW.md` resolves correctly per B-029 URL-fragment check.

### Next in 5-commit sequence

Commit 4 of 5 (v1.29.3) — Phase 3.3: focused smoke-coverage additions. Two narrow checks (`.env.example` parses cleanly via `_env-schema-parse.sh`; C4 regions non-empty in each trio file).

## v1.29.1 — 2026-05-19

Mirrors `PROJECT_STARTER.md` template v1.29.1. **Phase 2.1 reframed as structural prevention** (commit 2 of 5 in the `improvements-3` sequence). Patch bump.

### Why "reframed"

Original Phase 2.1 was scoped as a doc-cleanup audit for stale canonical-source claims. The audit (greps for `PROJECT_STARTER.md is canonical for workflow`, pre-v1.23 verb-gogogo patterns, pre-v1.28 strict B-027 wording, stale reviewer-wiring) came up **clean** — prior sweeps (v1.23.1, v1.26.2) plus natural cleanup during v1.25.0/v1.26.0/v1.27.0/v1.28.0 commits had already covered the original scope. Per the proposal's mid-execution-deviation rule, stopped + re-proposed; user picked Option 2 (convert cleanup commit into structural-prevention).

### What shipped

Two new invariants in `scripts/check-spec-consistency.sh`:

**Invariant B — canonical-source for workflow lives in `WORKFLOW.md`, not `PROJECT_STARTER.md`.** Four forbidden POSIX-ERE patterns, case-sensitive:

- `PROJECT_STARTER\.md is the canonical`
- `PROJECT_STARTER\.md is canonical for`
- `PROJECT_STARTER\.md §2.{0,30}canonical`
- `canonical source.{0,30}PROJECT_STARTER\.md`

Catches any drift back toward the pre-v1.25.0 framing where PROJECT_STARTER.md §2 was the canonical workflow source. The audit-trail form (`was \`PROJECT_STARTER.md §2\` before v1.25.0`) doesn't match because "canonical" doesn't appear within 30 chars of `PROJECT_STARTER.md`.

**Invariant C — verb-prefix gate model is superseded.** Three patterns:

- `verb-prefix gate`
- `verb table (per|in|of) (the )?(active|current)`
- `action verb (per|in|of) (the )?(active|current)`

Locks in the v1.23.0 propose-and-confirm transition. Historical mentions in `docs/spec.md` decision-log + historical-superseded section remain valid (those files are intentionally out of the active-doc scope).

### How this differs from Invariant A's bar

D-014's original rationale for spec-consistency invariants: "bar for new invariants is we've shipped this exact bug already." Invariant A (env-metadata) followed that bar — it was added BECAUSE v1.26.1 shipped a regression in that class. Invariants B and C are **structural prevention** — no actual regression has been shipped in either class. The user explicitly authorized this exception during the mid-execution re-propose; the rationale is that a regression-class boundary settled by a B block / D entry (B-025 + D-012 for PROJECT_STARTER.md role; B-026 + D-010 for propose-and-confirm gate) is itself sufficient evidence to add structural prevention without waiting for a literal regression to ship. B-029 Rule field updated to reflect this nuance.

### Verified

- All 4 linters green: C4 (3 regions) + C2 doc-ref (74 link targets, 4 fragments) + C3 placeholders (11 files) + C5 spec consistency (10 invariant patterns, 5 docs).
- Planted-violation tests for both new invariants caught their patterns and restored clean.
- Zero false positives against current active doc set (pre-checked via raw greps before adding to linter).

### Spec

- **B-029 Rule field** extended to describe Invariants B + C with rationale ("structural prevention vs shipped-bug bar — minor exception when a regression-class boundary is settled by a B block/D entry").
- No new B blocks. No new D entries.

### What didn't change

- C4 regions (gate-clause / proposal-format / bare-gogogo / env-metadata-contract) — unchanged.
- Other linter scripts — unchanged.
- Active doc prose — unchanged. This is pure linter-extension; no doc edits.

### Next in 5-commit sequence

Commit 3 of 5 (v1.29.2) — Phase 2.2: trim low-value duplication outside C4 regions. Conservative audit; collapse explanatory repetition where safety doesn't require duplication.

## v1.29.0 — 2026-05-19

Mirrors `PROJECT_STARTER.md` template v1.29.0. **Phase 3.2 of the Codex improvement plan (B-029 + D-014): close v1.26.1 + v1.26.2 regression classes via two new automation surfaces — URL-fragment validation + narrow forbidden-phrase spec-consistency checker.** Minor bump (notable new automation).

### What shipped

**(a) `scripts/check-doc-references.sh` extended with URL-fragment validation.** Three new functions:

- `extract_headings()` — emits each heading line from a Markdown file (line starts with `#+` whitespace), skipping fenced code blocks (lines starting with `#` inside ``` fences aren't headings — e.g. shell comments).
- `github_slug()` — computes GitHub's auto-anchor slug: lowercase → drop characters outside `[a-z0-9 _-]` → whitespace runs to single hyphen → trim leading/trailing hyphens. Mirrors GitHub's behavior for typical headings. Doesn't handle duplicate-anchor disambiguation (`-1`/`-2` suffixes) — accepted limitation; no duplicates in this repo.
- `validate_fragment()` — given a file + fragment, returns 0 if the fragment matches a heading slug in the file. Used by the per-link processing loop.

Integration: after the existence check passes (real or virtual-fallback), if the original target had a `#anchor` portion, the linter validates the anchor against the resolved file's headings. Failure prints `<file>:<line> -> <target>  (broken URL fragment: #<frag> in <resolved>)`. 4 URL fragments currently validate across 24 Markdown files.

**(b) New `scripts/check-spec-consistency.sh` linter.** Narrow forbidden-phrase checker scoped to 5 active root docs (README, BOOTSTRAP, WORKFLOW, templates/CONTRIBUTING, templates/CLAUDE). Strips fenced code blocks + inline single-backtick code spans before scanning (matches the convention used by B-023 / B-024).

Invariant A (env-metadata `@directive` contract, per B-020) — forbidden POSIX-ERE patterns, case-sensitive:

- `Optional prose`
- `comment block.*Optional`
- `"Optional" if`

Hits print `<file>:<line> [Invariant A] forbidden phrase matched "<pattern>": <line content>`. Exit 0 on clean, 1 on hit. Invariant set is extensible — new entries added per shipped regression class, not speculatively.

**Wired into CI:** `.github/workflows/template-self-test.yml` gains a `check spec consistency (B-029)` step between the placeholder linter and the smoke test. The extended `check doc references` step runs the new fragment-validation in-place (no separate step needed).

### Closing the regression classes

- **v1.26.1** ("WORKFLOW.md's `.env.example` section described requiredness via `Optional` prose while B-020 said `@directive`"): the new spec-consistency linter's Invariant A catches this directly. Same forbidden phrasing → CI fails.
- **v1.26.2** ("WORKFLOW.md linked to `PROJECT_STARTER.md#16-branch-protection-on-main` after §1.6 moved to BOOTSTRAP.md"): the new fragment-validation in B-023 catches this. File-level link still resolved; anchor goes nowhere → linter fails with `(broken URL fragment: #16-... in PROJECT_STARTER.md)`.

Both regressions are now structurally prevented.

### One in-scope fix during Commit 1

The new fragment-validation immediately caught one live broken anchor on its first run:

- **PROJECT_STARTER.md line 40** (v1.25.0 row of Template changelog) contained the literal Markdown link `[PROJECT_STARTER.md §1.6](PROJECT_STARTER.md#16-branch-protection-on-main)` as part of describing what v1.25.0 changed in WORKFLOW.md's §2.9 prose. The link was VALID at v1.25.0 time (when §1.6 still lived in PROJECT_STARTER.md) but became DEAD in v1.26.0 (BOOTSTRAP.md absorbed §1.6).

Fixed by wrapping the historical link syntax in backticks so it reads as a literal code example (the linter strips inline code before parsing link targets, so the anchor is no longer checked). Added a parenthetical noting "the link was valid at v1.25.0 time; §1.6 later moved to BOOTSTRAP.md in v1.26.0, so the anchor is dead today — historical-syntax example only." Preserves audit-trail accuracy without leaving a live broken anchor.

### Spec

- **B-029 added** (frozen) — defines both surfaces (URL-fragment validation + spec-consistency linter), scope, acceptance, exit codes, CI integration.
- **D-014 added** — rationale, rejected alternatives (extend-only-B-023, broader semantic analysis, more C4 regions, defer-to-manual-audit), failure-mode analysis. Codifies "bar for new invariants is we've shipped this exact bug already."
- No changes to other linters / C4 regions.

### Linter trio → quartet

The active linter set as of v1.29.0:

- **C4 rule consistency** (B-022) — byte-exact match across the doc trio for 4 anchored regions (gate-clause / proposal-format / bare-gogogo / env-metadata-contract).
- **C2 doc references** (B-023, extended in v1.29.0) — Markdown link targets resolve as files/dirs AND `#anchor` fragments match real headings.
- **C3 placeholders** (B-024) — no canonical substitution placeholders leak into plain prose.
- **C5 spec consistency** (B-029, new) — narrow forbidden-phrase invariants in active docs.

### Verified

- All 4 linters green: `OK: canonical rule regions match across 3 files.` / `OK: 74 Markdown link targets resolved across 24 files (4 URL fragments validated).` / `OK: no canonical placeholders found in plain prose across 11 meta-repo files.` / `OK: no forbidden phrases found in 5 active docs (3 invariant patterns checked).`
- Planted-violation tests: both new check types fail loudly on synthetic bad inputs (broken anchor, forbidden phrase) and pass after restoration.

### Next in this 5-commit sequence

Commit 2 of 5 (v1.29.1) — Phase 2.1: canonical-vs-duplicated cleanup across active docs.

## v1.28.0 — 2026-05-19

Mirrors `PROJECT_STARTER.md` template v1.28.0. **Gate refinement (D-013): per-option `[change]`/`[info]` classification + scoped `gogogo!`.** User pushback that B-027's always-propose-with-`gogogo!` pattern was diluting the gate's deliberate-state-change signal — applied universally even to navigation and discussion options where nothing mutates state. Minor bump per WORKFLOW.md (notable behavior change in the gate).

### The user critique

> "lets discuss that point of our rules where you always come up with suggestions. Like `gogogo!` was needed to gate suggestions that at the end involves chnages to code documentation or database. you add it everywhere now."

And the proposed shape:

> "i suggest we add `gogogo!` to only items that do code docs database and other changes. if the list has items that are for discussion or like research etc its og to just enter option number."

The diagnosis was sharp: `gogogo!` was designed as a deliberate state-change authorization signal (per B-001/B-026), but v1.24.0's B-027 "every message ends with a proposal" + the trio of invitation forms ended up appending `gogogo!`-shaped invitations to messages where nothing was about to mutate state. Ceremony, not safety.

### The fix (B-028 + refined B-027)

Each numbered option in a "Choose one:" or "Choose any (in order):" proposal is now prefixed with one of two markers:

- **`[change]`** — state-mutating: tracked-file `Edit`/`Write`/`NotebookEdit`, `git commit`/`push`, `gh pr create|merge|comment`, deploy, external POST/PUT/DELETE. **Requires `gogogo!`.**
- **`[info]`** — read-only, research, discussion, navigation, planning text, memory writes, `.claude/settings.local.json` writes. **Bare `N` only; no `gogogo!` needed.**

Single-suggestion proposals get the same classification (whole-suggestion-level): state-mutating ones still end with `Type \`gogogo!\` to proceed.`; pure-info single suggestions end naturally with no invitation line.

Pure discussion / clarification turns where no list-of-paths fits naturally MAY end without a trailing proposal. B-027's original "every message must propose" is refined to "propose when there's a path to surface; pure discussion can end naturally" — the no-round-trip property is preserved by B-028, because `[info]` picks are single-keystroke regardless.

Example (preview of the new shape):

> **Choose one:**
> 1. **[change]** Open PR for `improvements-3` (3 commits) → runs `gh pr create ...`. Bumps state.
> 2. **[info]** Show me what option 1 would post as the PR body, without running it.
> 3. **[info]** Discuss whether to split the 3 commits across two PRs instead.
> 4. **[change]** Continue stacking Phase 2.1 work on `improvements-3` → new edits + commit.
>
> Type `1 gogogo!` or `4 gogogo!` for [change] options; just `2` or `3` for [info] options.

### Files touched

- **C4 `gate-clause` region** updated byte-exact across `WORKFLOW.md` / `templates/CONTRIBUTING.md` / `templates/CLAUDE.md` — condition (b) now explicitly handles `[change]` vs `[info]` selection. `gogogo!` is required when picking `[change]` options; bare `N` is fine for `[info]`. Mid-execution `[info]` → `[change]` re-classification triggers STOP and re-propose.
- **C4 `proposal-format` region** updated byte-exact across the trio — describes the `[change]`/`[info]` markers, the three invitation forms in their per-option variants, the no-trailing-proposal-on-pure-discussion-turn relaxation, and the mid-execution re-classification rule.
- **C4 `bare-gogogo` region** unchanged. The rule "bare `gogogo!` without prior proposal → re-prompt" still holds; the marker convention doesn't change that case.
- **C4 `env-metadata-contract` region** unchanged (shipped v1.27.0).
- **`scripts/check-rule-consistency.sh`** REGIONS array unchanged — same 4 named regions, just different content in 2 of them.
- **WORKFLOW.md supporting prose** — self-check list extended to 6 steps (was 5); decision-tree gains `[change]` and `[info]` branches; refuse-list table gains 3 new rows (force-proposal-in-discussion, bare-N-against-[change], info→change-re-classification).
- **templates/CONTRIBUTING.md supporting prose** — self-check list extended similarly.
- **templates/CLAUDE.md** — no supporting-prose changes beyond the C4 region content (the file is the AI session-facing summary; the new rule lives entirely inside the byte-exact regions).
- **docs/spec.md** — B-027 Rule field rewritten in place ("refined v1.28.0" status note; original D-011 framing preserved as history); B-028 added (frozen); D-013 added with full failure-mode analysis.

### What stays

- **B-026** (the propose-and-confirm gate proper) — unchanged. Conditions a/b/c still apply. The refinement is to WHAT triggers `gogogo!` requirement (per-option, not per-proposal).
- **B-001's carve-outs** — memory writes + `.claude/settings.local.json` still need no `gogogo!`. B-028 just extends the carve-out logic to `[info]` options of any kind.
- **C4 linter machinery** — same script, same 4 regions, just updated content in 2.
- **Multi-select semantics** — multi-digit `N1 N2 ... gogogo!` against "Choose any (in order):" still works. The new wrinkle: one `gogogo!` covers all `[change]` items in the typed sequence; `[info]` items proceed in the same message without separate authorization.

### Failure modes

- **User types bare `N` against a `[change]` option** → re-prompt: "Option N is `[change]` — type `N gogogo!` to authorize."
- **Claude mis-classifies an option** — `[info]` when reality reveals state mutation → STOP and re-propose with the option re-classified as `[change]`. Conservative-default-`[change]` rule for borderline cases.
- **Mixed multi-select** — `1 2 3 gogogo!` where 1, 3 are `[change]`, 2 is `[info]` → one `gogogo!` authorizes the `[change]` items; `[info]` item proceeds in the same message.
- **Discussion turn ends without proposal** → user can pick the moment to switch back to execution mode by saying so; bare `N` against the next proposal proceeds without authorization needed for `[info]`.

### Verified

- All three linters green: C4 (4 regions byte-exact across the trio), C2 (75 link targets, 24 files), C3 (11 files clean).
- Smoke test irrelevant (no shipped-file changes — `templates/.env.example` is already `@directive`).

### Branch state after this commit

`improvements-3` holds 4 commits stacked on `main` (v1.26.2 Phase 1.2 sweep + v1.27.0 Phase 3.1 env-metadata C4 + v1.27.1 Phase 2.3 D-012 + v1.28.0 this commit — gate refinement). Ready for a PR-open proposal whenever you direct.

### Next

- Open PR for `improvements-3` (4 commits) — would surface a new proposal next turn.
- Continue stacking remaining Codex plan items (Phase 2.1, 2.2, 3.2, 3.3, 4.x, 5.x).
- Pause.

User direction will guide. Per the new B-028 rule, those next-step options would surface as a Choose-one with `[change]`/`[info]` markers.

## v1.27.1 — 2026-05-19

Mirrors `PROJECT_STARTER.md` template v1.27.1. **Phase 2.3 of the Codex improvement plan — D-012 settling PROJECT_STARTER.md's long-term role.** Decision-doc only; no file restructure required. Patch bump (spec-only addition).

### The open question (per the Codex plan, Phase 2.3)

> Should PROJECT_STARTER.md remain a snapshot index that ships with every export? Or should it become even thinner, with more of the durable content living in the companion docs only?

After v1.26.0 the file is already a 75-line thin index — but spec didn't formally pin that as the end state. D-012 resolves the open question.

### The decision (D-012)

**Chose:** PROJECT_STARTER.md remains a **permanent** thin-index entry-point. The post-v1.26.0 structure (title + Template version + intro + docs table + Template changelog tail) is the target end state, not a transitional one. No further reductions or restructures planned.

**Considered + rejected:**

- **(b)** Merge into BOOTSTRAP.md, drop the file entirely — would require rewriting B-002 (which binds Template version + Template changelog to PROJECT_STARTER.md). The Template changelog is per-doc state; it belongs in the file it describes, not in BOOTSTRAP.md. Concern-mixing not worth the "one fewer root file" win.
- **(c)** Drop in favor of README.md — different purposes. README.md is GitHub-rendered for visitors at github.com/owner/repo; PROJECT_STARTER.md is the in-repo navigation hub for consumers who've cloned/exported the kit. Collapsing them loses the distinction.

### Why (a) wins

- PROJECT_STARTER.md has been the entry point throughout the project's history; name is established.
- The current content (title + Template version + intro + docs table + changelog tail) is genuinely the minimum viable index — no further reduction would add value.
- Template changelog has nowhere natural to live other than the file it describes.
- The thin-index serves a real navigation purpose without bloat.

### Spec updates

- **D-012 added** to the decision log (before "Open project-level decisions" section).
- **B-025 Rule field** updated in place: "As of v1.26.0 (long-term role settled per D-012), the meta-repo root ships `PROJECT_STARTER.md` (a permanent thin ~40-line index) plus five companion docs..." (was "As of v1.26.0 ... a thin ~40-line index").
- No new B blocks. No file restructure — v1.26.0's structure already matches the chosen permanent state.

### Verified

- All three linters green: C4 (4 regions byte-exact across the trio), C2 (75 link targets, 24 files), C3 (11 files clean).
- Smoke test irrelevant (no shipped-file changes).

### Branch state after this commit

`improvements-3` holds 3 commits stacked on top of `main` (v1.26.2 + v1.27.0 + v1.27.1). Ready for a PR-open proposal whenever you'd like to surface them. The three commits cover:

- Phase 1.2 (v1.26.2) — post-split active-doc consistency sweep; fixed broken §-anchor in WORKFLOW.md.
- Phase 3.1 (v1.27.0) — new C4 region `env-metadata-contract`; structural prevention of v1.26.1's regression class.
- Phase 2.3 (v1.27.1) — D-012 settling PROJECT_STARTER.md's long-term role.

### Next

- Remaining Codex plan items (Phase 2.1 canonical-vs-duplicated cleanup, Phase 2.2 duplication trim, Phase 3.2 active-doc-vs-spec checks + URL fragment validation, Phase 4 manifest + preset boundaries, Phase 5 adoption UX) — wait for user direction.

## v1.27.0 — 2026-05-19

Mirrors `PROJECT_STARTER.md` template v1.27.0. **Phase 3.1 of the Codex improvement plan — extend C4 rule-consistency coverage to env-metadata.** Closes the regression class v1.26.1 surfaced (WORKFLOW.md's `.env.example` description drifted from B-020). Minor bump per WORKFLOW.md version-bump rule (new C4 region is a notable feature).

### The mid-execution design decision

My original Phase 3.1 proposal flagged that env-metadata might not fit C4 cleanly: C4 was designed for AI-safety-critical rule statements deliberately duplicated across the doc trio (gate-clause / proposal-format / bare-gogogo — the trio that `templates/CLAUDE.md` auto-loads every session), while env-metadata is more like single-source documentation. I surfaced four sub-options:

1. Force-fit C4 — add env-metadata to all 3 trio files (over-duplication).
2. Refactor linter for per-region file scopes (over-engineering).
3. Re-scope Phase 3.1 to genuinely-duplicated content like the refuse-list.
4. Skip Phase 3.1 entirely.

User picked **Option 1** — accept the over-duplication trade-off. Env-metadata wording joins the trio.

### What shipped

- **New C4 region `env-metadata-contract`** added byte-exact across the trio. Region content:

  > **`.env.example` env-metadata contract (per B-020):** Each var's metadata is declared via `@directive` comments — `@description` · `@required` · `@optional` · `@default` · `@validator` · `@sensitive`. Both `bootstrap.sh` and `check-env.sh` read the same shared parser (`templates/scripts/_env-schema-parse.sh`); the directives are the contract, not the prose. Free-text comments without `@` are shown in bootstrap prompts but not parsed as metadata. Default-if-neither-given is `@required`. Full vocabulary + parsing rules in B-020.

- **`WORKFLOW.md`** — existing "Environment variables (`.env.example` format)" section restructured. The descriptive paragraph (one sentence) and the recognized-directives sentence (one sentence) consolidate into the canonical C4 region at the top of the section. The code-block example stays below the region under a new "Example:" intro line. Net effect: the rule statement is anchored; the example is illustrative supporting documentation that stays only in WORKFLOW.md.

- **`templates/CONTRIBUTING.md`** — new section `## Env-metadata contract` appended after `## After a violation`. Contains only the C4 region (no code-block example).

- **`templates/CLAUDE.md`** — new section `## Env-metadata contract` inserted before `## When the user asks a question that's already documented`. Contains only the C4 region.

- **`scripts/check-rule-consistency.sh`** — `REGIONS` array grows from 3 to 4 entries (adds `"env-metadata-contract"`). The script's logic is region-name-agnostic; no other changes needed.

### Spec updates

- **B-022 Rule field** — extended to name the new region (region (iv)) with rationale: "added v1.27.0 to close the regression class v1.26.1 surfaced: a doc-trio-canonical rule statement that drifted from frozen B-020 because no mechanical check existed; now duplicated byte-exact across the trio and enforced."
- **B-021 tier table** — the Session-facing row (templates/CLAUDE.md) gains "env-metadata contract (per B-020)" in its "What it carries" column, since templates/CLAUDE.md now carries that rule statement inline as part of the deliberate trio duplication.
- No new B blocks. No new D entries.

### The trade-off accepted

The new region adds env-metadata wording to two files where it's not strictly AI-session-relevant (templates/CONTRIBUTING.md = per-project operational doc; templates/CLAUDE.md = session-facing AI summary — env-metadata isn't a gate concern). The trade is: byte-exact mechanical prevention of the v1.26.1 regression class, at the cost of carrying ~80 words of duplicated rule text into those two files. User accepted explicitly. If this duplication proves burdensome in practice, Option 2 (linter refactor for per-region file scopes) remains a future path that would let env-metadata-contract be narrowed back to WORKFLOW.md-only.

### Verified

- All three linters green: C4 (now 4 regions byte-exact across 3 files), C2 (75 link targets across 24 files), C3 (11 files clean).
- Smoke test irrelevant (no shipped-file changes — `templates/.env.example` already uses `@directive` per v1.14.0).

### What this prevents structurally

A future regression where any single trio file's env-metadata description drifts (e.g., someone edits WORKFLOW.md's region to add a new directive without updating templates/CONTRIBUTING.md or templates/CLAUDE.md) → C4 linter fails the build immediately with a unified diff. The class of bug v1.26.1 caught (pre-`@directive` "Optional prose" wording surviving into an active surface) cannot recur without a CI failure now.

### Next

- Commit 3 of 3 in this `improvements-3` sequence: **Phase 2.3 — D-012 settling PROJECT_STARTER.md's long-term role** (v1.27.1).

## v1.26.2 — 2026-05-19

Mirrors `PROJECT_STARTER.md` template v1.26.2. **Phase 1.2 of the Codex improvement plan — post-split active-doc consistency sweep.** Patch bump; one Block finding identified and fixed in the same commit.

### Audit scope + method

Per the (working-tree) `codex improvement plan.md` Phase 1.2 acceptance criterion: "No active doc contradicts current frozen behavior in `docs/spec.md`."

The five active root docs (README.md, BOOTSTRAP.md, WORKFLOW.md, PROJECT_STARTER.md, CONTRIBUTING.md) were greped for known stale patterns and inspected for prose that might have been copied forward from older phases:

- §-anchored refs to PROJECT_STARTER.md sections that moved during the split (§0 + §1 + §5 → BOOTSTRAP.md, §2 + §9 + §10 + §11 → WORKFLOW.md, §3 + §4 / §6 + §7 + §13 / §12 + §14 → TEMPLATE_INVENTORY / DEPLOY_BASELINE / HARNESS_QUIRKS in v1.22.0).
- Stale `<verb> gogogo!` patterns from the pre-v1.23.0 gate model (already swept v1.23.1, re-confirmed clean).
- "Action verb" / "verb table" / "verb-table" prose.
- "`PROJECT_STARTER.md §2` canonical" claims (post-v1.25.0 canonical is WORKFLOW.md).
- "Optional" prose for env-metadata (post-v1.14.1 the contract is `@directive` per B-020; v1.26.1 fixed WORKFLOW.md; re-confirmed no occurrences elsewhere).
- Markdown URL fragments pointing at PROJECT_STARTER.md anchors that no longer exist.
- Review-flow stale claims (post-v1.7.0 review is out-of-band per B-010).
- 5-step references (all current).

### The Block finding

**WORKFLOW.md line 236**, in the `## Merge` section, linked to a now-dead anchor:

> With branch protection on (`[PROJECT_STARTER.md §1.6](PROJECT_STARTER.md#16-branch-protection-on-main)`), the canonical merge path is `gh pr merge --rebase --delete-branch`...

After v1.26.0's BOOTSTRAP.md extract, §1 (including §1.6 "Branch protection on `main`") moved into BOOTSTRAP.md. PROJECT_STARTER.md became a thin index without §1.6 content; the `#16-branch-protection-on-main` anchor goes nowhere. The file-level link still resolved (PROJECT_STARTER.md exists), which is why the v1.20.0 doc-reference linter (B-023) didn't catch it — that linter strips URL fragments before the existence check (it only validates file/dir existence, not anchor presence).

### The fix

WORKFLOW.md `## Merge` section's parenthetical updated to:

> With branch protection on (set up per [`BOOTSTRAP.md` → "Branch protection on `main`"](BOOTSTRAP.md#branch-protection-on-main)), ...

The new URL anchor matches BOOTSTRAP.md's actual heading (`### Branch protection on \`main\``, which GitHub slugs to `#branch-protection-on-main`).

### Gap surfaced for Phase 3.2

The B-023 doc-reference linter validates file existence but strips `#anchor` and `?query` before checking. URL fragment validity is currently a manual concern. This is exactly the kind of semantic-consistency gap Phase 3.2 of the Codex plan targets — extending automation to catch active-doc-vs-spec drift the current linters miss. Specifically: extend `scripts/check-doc-references.sh` to verify that `<file>.md#<anchor>` targets resolve to a real heading anchor in `<file>.md`. Will be addressed in a future commit (out of scope for this Phase 1.2 fix).

### What stayed (intentional historical context, not stale claims)

- **BOOTSTRAP.md preamble** ("Extracted from `PROJECT_STARTER.md` §0 + §1 + §5 in v1.26.0...") — historical attribution of where this file's content came from. Reads like a stale §-ref but isn't; it documents the extraction. OK to keep.
- **WORKFLOW.md preamble** ("Extracted from `PROJECT_STARTER.md` §2 + §9 + §10 + §11 in v1.25.0...") — same pattern. OK.
- **CONTRIBUTING.md line 21** ("`WORKFLOW.md` is canonical for the rule + rationale (was `PROJECT_STARTER.md §2` before v1.25.0)") — audit-trail in parens. OK.
- **Template changelog rows in PROJECT_STARTER.md** — historical version diary; references §-numbers and pre-v1.23.0 verb model intentionally. OK.
- **WORKFLOW.md example commit message** at line 458 (`drop legacy admin user from runbook §4`) — example commit subject inside a code block, not a real §-ref. OK.
- **WORKFLOW.md "Recommended auto-memory seed" table** row `gogogo_gate_workflow.md` (description: "The `gogogo!` passphrase gate + 5-step workflow rules") — suggested memory filename; description says "gate + 5-step workflow" which is current; the filename itself is just a slug. OK.

### Verified

- All three linters green: C4 (3 regions byte-exact), C2 (74 link targets, 24 files), C3 (11 files placeholder-clean).
- Smoke test irrelevant (no shipped-file changes).

### Next

- Commit 2 of 3 in this `improvements-3` branch sequence: **Phase 3.1 — extend C4 to env-metadata wording** (v1.27.0). Addresses the structural prevention of regressions like v1.26.1's WORKFLOW.md `.env.example` Block.
- Commit 3 of 3: **Phase 2.3 — D-012 settling PROJECT_STARTER.md's long-term role** (v1.27.1).

## v1.26.1 — 2026-05-19

Mirrors `PROJECT_STARTER.md` template v1.26.1. **Fix the Block finding from PR #2 review on commit `97dbe67`** (v1.25.0 WORKFLOW.md extraction). Pure doc fix — no spec changes; brings WORKFLOW.md into compliance with already-frozen B-020.

### The Block finding (verbatim from the PR review)

> Commit `97dbe67`: **Block.** `WORKFLOW.md` becomes an active canonical doc in this commit, but its `Environment variables (.env.example format)` section still says the comment block includes the word `"Optional"` and that `bootstrap.sh` uses that prose to decide requiredness. That directly contradicts frozen B-020 in `docs/spec.md`, where `.env.example` semantics are declared via `@directive` comments and both `bootstrap.sh` and `check-env.sh` read the shared parser. The split extracted stale pre-v1.14 wording back into an active surface.

### What happened (the staleness history)

The `Environment variables (.env.example format)` section was originally written in early-v1.x PROJECT_STARTER.md §9.1, describing the pre-@directive prose-grep behavior that was in force at the time. **B-020 froze in v1.14.1** (parser swap to `@directive` with shared `_env-schema-parse.sh`; both `bootstrap.sh` and `check-env.sh` use the new contract). That commit should have updated §9.1's wording in PROJECT_STARTER.md but didn't — the staleness lived hidden in the 1100-line monolith.

When **v1.25.0** (`97dbe67`) extracted §9.1 verbatim into WORKFLOW.md as part of the split, the staleness was elevated to an active canonical surface where it now actively contradicts frozen B-020. The PR #2 reviewer caught this cleanly.

This is one of the failure modes the PROJECT_STARTER.md split was supposed to expose, ironically by making each concern's doc small enough that drift becomes visible. Worked as intended — just took an external reviewer to surface it.

### Three edits to `WORKFLOW.md` → "Environment variables (`.env.example` format)"

- **Descriptive paragraph** rewritten:
  - Was: "Each var has a comment block above it explaining where to find or generate the value. The block includes 'Optional' if the var is not required (the bootstrap script uses this to decide whether to demand a non-empty answer)."
  - Now: "Each var has a comment block declaring its metadata via `@directive` comments (B-020 in `docs/spec.md`) and explaining where to find or generate the value. Both `bootstrap.sh` and `check-env.sh` read the same shared parser (`templates/scripts/_env-schema-parse.sh`) — the directives are the contract, not the prose."
- **Code-block example** replaced. Was a pre-@directive layout with prose `Optional:` line + `OPTIONAL_VAR=`. Now uses `@directive`-annotated vars: `VAR_NAME` shows `@description` + `@required`; `OPTIONAL_VAR` shows `@description` + `@optional` + `@validator`. Examples are vendor-neutral per B-019 — "BotFather → /newbot" Telegram example dropped, replaced with "service admin console → API keys" generic placeholder.
- **Closing sentence added** listing recognized directives (`@description` / `@required` / `@optional` / `@default` / `@validator` / `@sensitive`), noting that free-text comments without `@` are shown in prompts but not parsed, the default-if-neither-given convention (`@required`), and a pointer to B-020 for full vocabulary + parsing rules.

### What didn't change

- **No spec changes.** B-020 already names the `@directive` contract; this commit brings WORKFLOW.md into compliance with the already-frozen behavior.
- **No script changes.** `bootstrap.sh` + `check-env.sh` + `_env-schema-parse.sh` already work correctly (per v1.14.0–v1.14.1).
- **No `templates/.env.example` changes.** The ship file already uses `@directive` per v1.14.0 (B-020). The doc inconsistency was only in the WORKFLOW.md description — not in the actual artifact consumers `sed` and `bootstrap.sh` reads.

### Verified

- All three linters green: C4 rule-consistency, C2 doc-references (74 links across 24 files), C3 placeholders (11 files clean).
- Smoke test passes end-to-end.

### Reviewer credit

Caught by the external reviewer on PR #2 — the propose-and-confirm gate's review-out-of-band model worked as designed (independence beats deepening per B-010). All 12 other commits in `main..HEAD` reviewed cleanly with no Strong or Nit findings.

### Next

- PR #2 auto-updates with this commit. Reviewer can re-walk `97dbe67..HEAD` (or just the new fix commit) to confirm the Block clears. After the PR is clean, user `gogogo!`s a merge proposal.

## v1.26.0 — 2026-05-19

Mirrors `PROJECT_STARTER.md` template v1.26.0. **Final commit of the PROJECT_STARTER.md split sequence (3 of 3).** Extracts `BOOTSTRAP.md` and reduces PROJECT_STARTER.md to a thin index. The split sequence that started at v1.22.0 is complete: from a single 1121-line monolith to a thin 75-line index pointing at 5 focused companion files.

### What shipped

A new `BOOTSTRAP.md` (~250 lines) at meta-repo root containing:

- The "About this kit" scope statement (was `§0.1 Current scope`).
- A "Reading order" guide (was `§0.2`, now adapted to point at BOOTSTRAP.md itself as the starting point).
- The complete Bootstrap checklist (was `§1.1`–`§1.10`): pick names, init git, copy templates, initial VERSION, GitHub repo, branch protection, repo merge settings, auto-memory seed, first commit, verify.
- The "Decisions to answer before writing feature code" Q&A list (was `§5.1`–`§5.10`): stack, process model, database, hosting, backups, module layout, CI strategy, secrets store, observability, deploy frequency.

Section numbers inside BOOTSTRAP.md are dropped — top-level concepts get `##` headings, subsections get `###`. Section-anchored internal cross-references updated: `§2 Process` references retargeted to `WORKFLOW.md`; `§10 auto-memory seed` reference retargeted to "WORKFLOW.md → Recommended auto-memory seed"; `§1.6 branch protection` cross-reference within BOOTSTRAP.md changed to "Branch protection on `main`" by-name reference (same file).

### PROJECT_STARTER.md changes

Drops from 436 lines to 75 lines. All stub-pointer sections from earlier split commits (`## 2.` through `## 14.`) are gone — they were intermediate state. The new structure is purely:

- Title + Template version + Last updated metadata
- One-paragraph intro explaining what the kit is + thin-index purpose
- A 5-row Docs table linking the companion files (BOOTSTRAP / WORKFLOW / TEMPLATE_INVENTORY / DEPLOY_BASELINE / HARNESS_QUIRKS) with one-line "read when" guidance per row
- A short pointer paragraph naming `docs/spec.md`, `CHANGELOG.md`, and `templates/`
- A reference to the export script's `ROOT_DOCS` array (the coordination mechanism)
- The Template changelog table at the tail (the per-version diary of THIS doc per B-002; gains the v1.26.0 row)

§8 Audit trail is removed entirely. Its content was either redundant (Decision log already lives in `docs/spec.md`, CHANGELOG already documents version diary, auto-memory conventions already in WORKFLOW.md's "Recommended auto-memory seed" section) or recoverable from git history (specifically the `gh pr list --search <sha>` commit-to-PR mapping tip from pre-v1.26.0 §8.1, retained in this CHANGELOG entry for findability).

### Linter + tooling coordination

- **`scripts/export-starter.sh`** — `ROOT_DOCS` array grows from 5 entries to 6 (adds `"BOOTSTRAP.md"`). Archive now ships 6 root docs alongside flattened templates contents.
- **`scripts/check-doc-references.sh`** — `VIRTUAL_TEMPLATES_FILES` mirrors the addition (6 entries). Keeps the two arrays in sync per B-025's coordination requirement.
- **`scripts/check-rule-consistency.sh`** — unchanged (`FILES` array still targets `WORKFLOW.md` first; C4 regions don't move in this commit).

### Cross-reference updates

- **`README.md`** — three sites retargeted from `PROJECT_STARTER.md` section anchors to `BOOTSTRAP.md`:
  - Top of file: "Current shipped scope" link → `BOOTSTRAP.md` (was `PROJECT_STARTER.md §0.1`).
  - Quickstart paragraph: "Then follow [...]" → `BOOTSTRAP.md` (was `PROJECT_STARTER.md §1` "Bootstrap checklist").
  - Docs table: gains a `BOOTSTRAP.md` row between PROJECT_STARTER.md and WORKFLOW.md.
  - Known Limitations: the "PROJECT_STARTER.md split is in progress" bullet is removed entirely — split sequence complete, no longer a limitation.
- **All `PROJECT_STARTER.md §X` URL anchors in the docs are now non-functional** (the §-numbered sections don't exist anymore). The doc-reference linter doesn't flag this because it only checks file existence, not anchor presence — file targets all still resolve. Section-anchored deep links from outside the repo (if any) would 404 to that anchor but render the thin index page; the page's docs table provides the redirect.

### Spec updates

- **B-025 Rule** rewritten to "v1.26.0, the meta-repo root ships PROJECT_STARTER.md (now a thin ~40-line index) plus five companion docs" and adds BOOTSTRAP.md as the final entry. The "PROJECT_STARTER.md retains §0 / §1 / §5 / §8 / Template changelog" sentence updates to "PROJECT_STARTER.md retains only the entry-point index + Template changelog tail" with an audit-trail note explaining §8's removal.
- **B-025 rationale** stub-pointer convention prose updated to "earlier intermediate-state stubs ... served their purpose during the split but are gone as of v1.26.0 — PROJECT_STARTER.md is now a clean thin index with a docs table replacing the §-numbered navigation." Version-number renumber note retained.
- **B-025 Rationale's "Stage in three commits"** bullet updates v1.26.0 description to past tense and notes the split sequence is complete.
- **B-025 Test field** tar-grep extended from 5-file to 6-file match (adds `BOOTSTRAP`); `wc -l PROJECT_STARTER.md` expected value updates from ~435 to ~75.
- **B-025 Status** updates to "frozen (v1.26.0 — all five planned companion files shipped: TEMPLATE_INVENTORY, DEPLOY_BASELINE, HARNESS_QUIRKS, WORKFLOW, BOOTSTRAP). The PROJECT_STARTER.md split sequence is complete."
- No new B blocks. No new D entries.

### What stays unchanged

- C4 linter REGIONS array (`gate-clause`, `proposal-format`, `bare-gogogo`) and its first FILES entry (`WORKFLOW.md`). The gate-rule machinery is untouched.
- B-001 / B-002 / B-027 / etc. — all unchanged. PROJECT_STARTER.md still has the template version line per B-002.
- The 5-step workflow, gate carve-outs, refuse-list, every other invariant.

### Verified

- All three linters green: C4 rule-consistency (3 regions byte-exact), C2 doc-references (74 links across 24 files), C3 placeholders (11 files clean — BOOTSTRAP.md adds a new file to the scope).
- Archive `tar -tzf` confirms BOOTSTRAP.md at the staged top level alongside the 5 existing root docs.
- Smoke test (template instantiates end-to-end) passes.

### Result of the split sequence (v1.22.0 → v1.26.0)

| Pre-split (PROJECT_STARTER.md monolith) | Post-split (5 companions + thin index) |
|---|---|
| 1 file, 1121 lines | 6 files, ~75 + 250 + 530 + ~115 + ~155 + ~70 = ~1195 lines total |
| All concerns in one place — navigation by `Ctrl-F` on section number | One file per concern — navigation by docs table at PROJECT_STARTER.md |
| Section numbers binding (§2 / §10 / etc.) | Concept names binding (`WORKFLOW.md` / "Recommended auto-memory seed") |
| Single-file source of truth for AI rule regions (C4 linter) | First C4 tier = `WORKFLOW.md` (retargeted v1.25.0) |

Total lines went up slightly (≈74 net) due to per-file preambles + duplicated metadata; that's the cost of focused docs. The payoff is each file fits the concern; updates touch only the relevant doc; reviewers can hold the whole thing in their head.

### Next

- No imminent roadmap commit. Possible follow-ups: bootstrap.sh placeholder substitution (the "Placeholder substitution is manual" item from README's earlier Known Limitations — removed in this release but the underlying gap remains); multi-preset architecture (D-009 roadmap item: Node/Go/no-runtime); product boundary statement (`docs/spec.md` open items). Wait for user direction.

## v1.25.0 — 2026-05-19

Mirrors `PROJECT_STARTER.md` template v1.25.0. **Extract `WORKFLOW.md` from PROJECT_STARTER.md** — the 2-of-3 commit of the original split sequence (third one is the BOOTSTRAP.md extraction queued as v1.26.0). The risky one: this is the commit that moves the C4-anchored rule regions, so the linter retarget had to land in the same commit.

### What shipped

A new top-level `WORKFLOW.md` (~530 lines) containing:

- The gate clause + proposal format + bare-gogogo handling (the three C4 byte-exact regions — moved with `§2.1`).
- The full self-check / refuse-list / allowed-without-gogogo content from `§2.1`.
- The 5-step atomic sequence, version-bump rule, branching, commit mechanics + message quality + template, PR open / review / address feedback / merge / cleanup / deploy timing / after-violation / phase frequency (was `§2.2`–`§2.13`).
- Conventions (was `§9.1`–`§9.5`): `.env.example` format, sensitive value handling, naming, comments in code, document boundary.
- Recommended auto-memory seed table (was `§10`).
- PR review heuristics (was `§11`) — output contract, Block/Strong/Nit rubric, don't-flag list, cross-cutting concerns.

Section numbers inside `WORKFLOW.md` are dropped (everything was renumbered to bare top-level `##` or `###` headings since the file is its own top-level concern now). Internal `§N.X` cross-references updated to either inline names ("see 'PR review heuristics' below") or explicit `PROJECT_STARTER.md` URL links where the target stayed in the index file.

### PROJECT_STARTER.md changes

Drops from 821 to 435 lines. The four extracted sections (§2, §9, §10, §11) become stub pointers preserving their `## N. <title>` headings + a one-line `**Moved to [WORKFLOW.md](WORKFLOW.md) in v1.25.0.**` line. Same pattern as v1.22.0's three stubs.

`§0.2 Reading order` rewritten: step 2 now says "Read [`WORKFLOW.md`](WORKFLOW.md) once" instead of "Read §2 once"; step 6 simplified to "§8 (audit trail + decision log) lives in this file"; the closing paragraph names both v1.22.0 + v1.25.0 split rounds and notes v1.26.0 as the final reduction to a thin index.

### Linter + tooling coordination (all in this commit)

- **`scripts/check-rule-consistency.sh`** — `FILES[0]` changes from `"PROJECT_STARTER.md"` to `"WORKFLOW.md"`. The C4 regions move with the content; the linter's first target follows. Verified byte-exact match across WORKFLOW.md / templates/CONTRIBUTING.md / templates/CLAUDE.md after the move. Header comment updated to name `WORKFLOW.md` with an audit-trail note about the pre-v1.25.0 state.
- **`scripts/export-starter.sh`** — `ROOT_DOCS` array grows from 4 entries to 5 (adds `"WORKFLOW.md"`). Archive now ships 5 root docs alongside flattened templates contents.
- **`scripts/check-doc-references.sh`** — `VIRTUAL_TEMPLATES_FILES` mirrors `ROOT_DOCS` (same addition). Future templates/-side links to `WORKFLOW.md` resolve correctly under the export-layout fallback.

### Cross-reference updates (outside the doc trio)

- **`CONTRIBUTING.md` (meta root)** — workflow pointer "Read `PROJECT_STARTER.md §2`" → "Read `WORKFLOW.md`"; doc tier description updated to name WORKFLOW.md as canonical with audit-trail note.
- **`templates/CONTRIBUTING.md`** canonical-scope marker — "live canonically in `PROJECT_STARTER.md §2`" → "live canonically in `WORKFLOW.md`" (twice, for rules-live-here and rule-statements-also-in-here).
- **`templates/CLAUDE.md`** canonical-scope marker — same retarget; "Editing any rule here means editing it in `CONTRIBUTING.md` + `PROJECT_STARTER.md §2` too" → "...in `CONTRIBUTING.md` + `WORKFLOW.md` too".
- **`README.md`** Known Limitations — updated to "four of five companion files ship at repo root"; lists WORKFLOW.md as the v1.25.0 addition. Docs table gains a WORKFLOW.md row between the PROJECT_STARTER.md row and the TEMPLATE_INVENTORY.md row.

### Spec updates

- **B-021 tier table** drops the `(post-split: WORKFLOW.md)` parenthetical from the first row's File column — the post-split state is now reality. First-row file becomes `WORKFLOW.md (was \`PROJECT_STARTER.md\` §2 before v1.25.0)`.
- **B-022 Rule** updated to name `WORKFLOW.md` as the first canonical-doc tier with an audit-trail note: "the first tier was `PROJECT_STARTER.md` §2 before v1.25.0's extraction into `WORKFLOW.md`."
- **B-025 status note** updated to "four of five planned files shipped"; rule body extended to name WORKFLOW.md with `extracted v1.25.0`; rationale section's "v1.22.1 handles WORKFLOW.md and the coordinated B-022 linter retarget" updated to past tense ("v1.25.0 handled..."); test field's tar-grep regex extended from 4-file to 5-file match (adds `WORKFLOW`); status updated to "frozen (v1.25.0 — four of five planned files shipped)"; will reach final state in v1.26.0.
- **B-025 audit-trail note** explains the v1.22.1 → v1.25.0 renumber: VERSION is monotonically increasing, so the originally-planned label of "v1.22.1" wasn't usable once v1.23/v1.24 intervened.

No new B blocks (this is execution of D-009's roadmap continuation under B-025's split framework).

### What's NOT in this commit (deliberately)

- §1 (Bootstrap checklist) and §5 (Decisions to answer) — both stay in PROJECT_STARTER.md until v1.26.0's BOOTSTRAP.md extraction.
- §8 (Audit trail) + Decision log + Template changelog — stay in PROJECT_STARTER.md (these are about THIS template's audit trail; not consumer-project content).
- New linter machinery — same three C4 regions, new file target, otherwise unchanged.

### Verified

- All three linters green: C4 rule-consistency (3 regions byte-exact across `WORKFLOW.md` / templates/CONTRIBUTING.md / templates/CLAUDE.md), C2 doc-references (74 links across 23 files, up from 66/22), C3 placeholders (10 files clean, up from 9).
- Smoke test passes (template instantiates end-to-end; archive now ships WORKFLOW.md alongside the other 4 root docs).
- Archive `tar -tzf` confirms WORKFLOW.md at the staged top level.

### Next

- **v1.26.0 (a future `gogogo!`-authorized proposal):** Extract `BOOTSTRAP.md` (§0 + §1 + §5). Reduce PROJECT_STARTER.md to a thin ~50-line index pointing at all 5 companion files. Final commit of the split sequence.

## v1.24.0 — 2026-05-19

Mirrors `PROJECT_STARTER.md` template v1.24.0. **Gate refinements (D-011): keep `gogogo!`, always-propose, multi-select.** Three changes to the v1.23.0 propose-and-confirm model, driven by user feedback after living with it for a day.

### What changed

**1. `gogogo!` stays.** Renaming to `go!` (3 chars) was considered and rejected — D-001's original analysis (false-positive risk on natural English: "let's go!", "ready, set, go!", "don't go!") still applies, and is in some ways more important under propose-and-confirm because the false-positive window is exactly "after a proposal, when the user types a negation containing the substring". The 4-char `gogo!` compromise was rejected too; the ergonomics gain (3 chars) wasn't worth the safety margin.

**2. Every assistant message ends with a concrete proposal.** Formalized as new **B-027**. The asymmetry that v1.23.0 introduced — user `gogogo!`s a single token, Claude does the work of articulating what — was being undermined whenever Claude ended a turn with a question ("what would you like next?"). User had to re-elicit a proposal, then `gogogo!`. Extra round-trip every time. Now: clarification turns end with "continue with [next queued item], or describe a different direction"; design-discussion turns end with "discuss further, or summarize this into a spec change"; the trailing proposal is always there, even if the proposal is "decide what to do next." The user can always `gogogo!` forward motion in one keystroke-worth.

**3. Multi-select syntax: `N1 N2 ... gogogo!`.** Numbered proposals now come in two flavors, distinguished by header:

- **`**Choose one:**`** — mutually exclusive alternatives. Only `N gogogo!` works. Multi-digit `N M gogogo!` is invalid → re-prompt.
- **`**Choose any (in order):**`** — independent options that can batch. `N gogogo!` picks one; `N1 N2 ... gogogo!` authorizes multiple in the typed order. Skipping is fine (`1 2 4 5 gogogo!` runs 1/2/4/5, skips 3).

User's insight that drove this design: **each authorized item was a concrete proposal Claude already surfaced and the user inspected.** That's the key difference from `gogogo!N` / autopilot pre-auth shapes (which were considered and rejected) — pre-auth weakens the v1.23.0 safety property by authorizing UNKNOWN future proposals; multi-select-of-already-surfaced-items doesn't. Multi-select is a strict extension of single-pick.

### Doc trio changes (byte-exact across PROJECT_STARTER.md §2.1 + templates/CONTRIBUTING.md + templates/CLAUDE.md)

- **`gate-clause` region** updated: condition (b) now allows whitespace-separated multi-digit selection; condition (a) requires the proposal to end with one of the canonical invitation lines.
- **`proposal-format` region** rewritten: grew from two invitation forms to three (Single suggestion / Choose one / Choose any (in order)); added the explicit "every assistant message ends with a concrete proposal" requirement.
- **`bare-gogogo` region** unchanged.

C4 linter `REGIONS` array unchanged (same three names; content differs). The linter passed byte-exact across all three files immediately after the edits.

### Supporting prose changes (each file's own)

- Self-check list extended from 4 steps to 5 — new step 4 catches multi-select-against-Choose-one. Decision-tree gains two new branches (multi-select against valid vs invalid form).
- Refuse-list table gains 2 new rows: "user multi-selected against my Choose-one list — close enough" and "I should answer this clarifying question without proposing anything" (both are wrong).
- Supporting paragraph after gate-clause mentions the safety property: multi-select is a STRICT extension because each item was already surfaced; doesn't pre-auth unknown proposals.

### Spec

- **B-026** content updated in place — rule condition (b) updated for multi-digit; proposal-format described as three forms; rationale gains v1.24.0 refinement note; test field adds three new manual checks (multi-select against "Choose any" works, multi-select against "Choose one" re-prompts, every assistant message ends with one of three canonical invitation lines).
- **B-027** added (frozen) — the always-end-with-proposal requirement. References D-011.
- **D-011** added — three-refinement decision with full Considered / Why / Failure-mode analysis. Includes the explicit rejection rationale for `go!`, `gogo!`, `gogogo!N`, and autopilot-mode shapes that were considered.

### What didn't change

- C4 linter REGIONS array (`gate-clause`, `proposal-format`, `bare-gogogo`) — same three regions, just different content.
- B-001 + B-011 + D-004 stay in historical-superseded (still superseded by B-026, not by B-027/D-011).
- The 5-step workflow shape, all carve-outs (memory + local-only settings), the refuse-list framing, the Karpathy standing rules, and every other invariant that's not directly about how proposals are surfaced.

### Failure modes

- **User multi-selects against a "Choose one:" proposal.** Mitigation: my proposal explicitly labels the form; multi-select against "Choose one:" is invalid → re-prompt.
- **I forget to label the form** and the list is ambiguous. Caught at user-inspection time; user can reject. Future improvement noted in B-022 for the linter: extend C4 to verify "Choose..." headers use one of the two canonical forms.
- **I end a turn without a proposal.** Caught at session review. The C4 linter only enforces the canonical region text, not at-message-end usage. Automating the at-message-end check via transcript scanning is possible but not currently shipped.

### Verified

- All three linters green: C4 rule-consistency (3 regions byte-exact), C2 doc-references, C3 placeholders.
- No shipped-file changes; smoke test irrelevant for this commit.

### Next

- **v1.22.1 (a future `gogogo!`-authorized proposal):** Extract `WORKFLOW.md` from `PROJECT_STARTER.md` §2 + §9 + §10 + §11. Coordinates with the C4 linter's `FILES` array (target shifts from `PROJECT_STARTER.md` to `WORKFLOW.md`). Updates B-021's tier table to drop the `(post-split: WORKFLOW.md)` parenthetical. Adds `WORKFLOW.md` to `ROOT_DOCS` + `VIRTUAL_TEMPLATES_FILES`. This is the queued 2 of 3 from the PROJECT_STARTER.md split sequence.

## v1.23.1 — 2026-05-19

Mirrors `PROJECT_STARTER.md` template v1.23.1. **Sweep stale verb references left over from v1.23.0.** Pure doc cleanup — no rule changes, no spec changes. The v1.23.0 CHANGELOG entry explicitly announced this as the v1.23.1 follow-up.

### What was swept (6 files)

- **`templates/CONTRIBUTING.md`**:
  - Cheat-sheet table rows 14-15: `User says \`PR gogogo!\` / \`ready gogogo!\`` → `User \`gogogo!\`s a PR-open proposal`; `User says \`merge gogogo!\`` → `User \`gogogo!\`s a merge proposal`.
  - TL;DR sequence (lines 44-51): each item references verbs (`<verb> gogogo!`, `code gogogo!` + `feat/fix/chore/...`, `PR gogogo!`, `merge gogogo!`, `deploy gogogo!`); rewritten to propose-and-confirm phrasing. Item 2 now reads "No state-mutating action unless Claude's immediately preceding message contained a concrete proposal AND the user's current message contains `gogogo!` (or `N gogogo!` for a numbered choice). The proposal IS the contract — specific files, specific commands, specific commits. Bare `gogogo!` without a preceding proposal is invalid — Claude must ask for clarification."
  - Review section (lines 129, 131, 136): "Claude opens the PR on `PR gogogo!`" → "Claude opens the PR after a `gogogo!`-authorized PR-open proposal"; "Workflow after `PR gogogo!`" → "Workflow after the PR is opened"; "no `review gogogo!` verb" → "no review proposal flow"; "more `<verb> gogogo!`s" → "more `gogogo!`-authorized commits".
  - Canonical-scope marker (line 5): "the *why* behind the gate, the verbs, the 5-step structure" → "the *why* behind the gate, the propose-and-confirm semantics, the 5-step structure"; rule-statement list "(verb table, gate clause, bare-gogogo prompt, allowed-without-gate list, refuse-list)" → "(gate clause, proposal format, bare-gogogo prompt, allowed-without-gate list, refuse-list)"; C4 linter note "Codex plan Phase 3 #3, pending" → "`scripts/check-rule-consistency.sh`" (the linter has shipped since v1.19.0).
- **`templates/docs/pr_review_instructions.md`** line 5: "Claude opens the PR (`PR gogogo!`)" → "Claude opens the PR after a `gogogo!`-authorized PR-open proposal".
- **`PROJECT_STARTER.md`** §2 canonical-scope marker (line 193, the line just BEFORE the rewritten §2.1 — the gate region itself was rewritten in v1.23.0, but the preceding scope marker still carried verb-era prose): "gate semantics, action verbs, 5-step structure" → "gate semantics, propose-and-confirm contract, 5-step structure"; "(verb table, gate clause, ...)" → "(gate clause, proposal format, ...)"; "C4 consistency linter (Codex Phase 3 #3, pending)" → "C4 consistency linter (`scripts/check-rule-consistency.sh`)".
- **`CONTRIBUTING.md`** (meta root): line 7 "(gate, action verbs, 5-step, ...)" → "(the propose-and-confirm `gogogo!` gate, 5-step, ...)"; line 25 "C4 consistency linter (Codex plan Phase 3 #3, pending)" → "C4 consistency linter (`scripts/check-rule-consistency.sh`)".
- **`README.md`** two-layer table (line 13): "`gogogo!` passphrase gate + action-verb workflow, 5-step atomic..." → "`gogogo!` passphrase gate with propose-and-confirm semantics (Claude proposes concretely, user `gogogo!`s the proposal), 5-step atomic...".
- **`docs/spec.md`** B-010 Rule field (line 57): "no skill, no Makefile target, no verb, no reminder" → "no skill, no Makefile target, no review-specific proposal flow, no reminder"; "After `PR gogogo!`, the user opens whichever reviewer..." → "After Claude opens the PR (per a `gogogo!`-authorized PR-open proposal), the user opens whichever reviewer...". B-010's rule itself (PR review is out-of-band and reviewer-agnostic) is unchanged — only the prose mentions of a now-defunct verb concept.

### What stays untouched (intentional audit trail)

- **`CHANGELOG.md`** rows for v1.0 through v1.22.0 — all historical changelog entries describing how the project evolved through the verb era. Past-tense by construction.
- **Template-changelog rows in `PROJECT_STARTER.md`** for past versions — same.
- **`docs/spec.md` historical-superseded section** (B-001, B-006, B-007, B-008, B-009, B-011, B-013, B-018) — each block is preserved as the rule that WAS in force at some prior version, with a supersession status note. Modifying their content would corrupt the audit trail.
- **`docs/spec.md` decision-log Chose/Considered/Why fields** for D-001 through D-009 — past decisions are preserved verbatim (per the decision-log convention at the top of the section: "Decisions live forever in the repo"). D-004's status note at the top points at D-010; the original Chose/Considered/Why stays as the historical record.
- **Active block content in B-021 / B-022 / B-026 / D-010** that legitimately describes the v1.23.0 transition (e.g. "The `verb-table` region was retired in v1.23.0 when B-026 replaced the verb-prefix gate model") — this is current-state context, not stale prose. The references to "verbs" / "verb table" / "action verb" in these blocks are about the model being SUPERSEDED, not the current one.

### What's NOT in this commit (deliberately)

- No spec changes — no new B blocks, no decision-log entries. The rules from v1.23.0 are unchanged; only prose that hadn't caught up gets the update.
- No changes to the linter scripts or CI wiring.
- No structural reorganization (the `PROJECT_STARTER.md` split sequence continues separately at v1.22.1 / v1.22.2 for WORKFLOW.md and BOOTSTRAP.md).

### Verified locally

- All three linters green: C4 rule-consistency (3 regions byte-exact across the doc trio — unchanged from v1.23.0), C2 doc-references (links still resolve), C3 placeholders (no canonical placeholders leaked into prose).

### Next

- **v1.22.1 (`refactor gogogo!`):** Extract `WORKFLOW.md` from `PROJECT_STARTER.md` §2 + §9 + §10 + §11. Coordinates with the C4 linter's `FILES` array (target shifts from `PROJECT_STARTER.md` to `WORKFLOW.md`). Updates B-021's tier table to drop the `(post-split: WORKFLOW.md)` parenthetical. Adds `WORKFLOW.md` to `ROOT_DOCS` + `VIRTUAL_TEMPLATES_FILES`. This is the queued 2 of 3 from the PROJECT_STARTER.md split sequence.

## v1.23.0 — 2026-05-19

Mirrors `PROJECT_STARTER.md` template v1.23.0. **Gate model rewrite — most invasive change in this project's history.** The verb-prefix gate (`feat gogogo!`, `commit gogogo!`, `merge gogogo!`, etc.) is replaced by propose-and-confirm. Triggered by user feedback that the verb system put cognitive burden on the user (remember nine verbs, remember mapping) while only encoding action TYPE, not action SCOPE — a `commit gogogo!` could commit anything Claude had staged. The new model inverts that.

### The new gate (B-026)

> No state-mutating action proceeds unless ALL of: (a) Claude's immediately preceding assistant message contained a concrete proposal — single suggestion or numbered list of choices, with specific files / commands / commits named, not vague phrasing; (b) the user's CURRENT message contains the literal substring `gogogo!`, optionally preceded by a digit selecting one option from a numbered list (e.g. `2 gogogo!`); (c) the action Claude takes is exactly what the proposal described — mid-execution deviation requires a new proposal.

What changes in practice:

- **No more verbs.** The action description lives in Claude's proposal in plain English. `feat gogogo!`, `commit gogogo!`, `PR gogogo!`, etc. all collapse into "Claude proposes the concrete plan, user `gogogo!`s." The workflows themselves (full 5-step, commit-only, PR open, merge, deploy, revert) still exist as action shapes — they're just named in the proposal text.
- **Multi-step ergonomics preserved.** A 5-step feature workflow is still authorized by one `gogogo!`. Claude enumerates the full plan in the proposal upfront (Step 1: spec; Step 2: bump+CHANGELOG; etc.) and one `gogogo!` confirms the whole plan. Same total typing as before; the verb is just gone.
- **Numbered choice for ambiguity.** When there are two-plus plausible paths, Claude presents a numbered list ending with `Type 1 gogogo! or 2 gogogo!`. The user selects with `N gogogo!` (or just `gogogo!` if only one path is offered).
- **Bare `gogogo!` without prior proposal** → reply *"I haven't proposed anything concrete yet. Describe what you'd like and I'll surface options."* This replaces today's "Which action? code / commit / PR / merge / deploy / revert?" prompt.
- **Conversation drift catches.** If Claude's last message was clarification rather than a fresh proposal, the next `gogogo!` does NOT authorize — Claude must re-propose. The "immediately preceding message" constraint in condition (a) is load-bearing for this.

### Canonical proposal format (B-026 + B-022)

The proposal format is byte-exact-matched across the doc trio by C4 linter region `proposal-format`:

- **Single suggestion** — a bold "Proposed: <action>" header, a concrete plan (specific files / commands / commits), and a final line inviting `gogogo!` to proceed.
- **Numbered choice** — a bold "Choose:" header, numbered options (each one concrete), and a final line inviting `N gogogo!` to pick option N.

Concrete means specific files, specific commands, specific commits — not "commit the changes." For multi-step actions, every step is enumerated.

### Failure-mode analysis (why this is safer, not just different)

- **D-004's original failure** ("agent picks wrong workflow on bare authorization") is preserved. Bare `gogogo!` is still invalid — the corrective surface just moves from a user-typed verb to a Claude-surfaced concrete proposal.
- **New failure mode the propose model PREVENTS:** "agent picks wrong file/scope under a correctly-formed verb." Verbs only encoded action TYPE; the proposal encodes everything down to the commit message.
- **New failure mode it could INTRODUCE:** "agent proposes vaguely (`commit the changes`), user `gogogo!`s, agent picks wrong scope." Mitigated by B-026 condition (a)'s explicit "concrete" requirement — vague proposals don't satisfy the gate, and the canonical `proposal-format` region makes "concrete" mechanically inspectable.
- **Another new failure mode it could INTRODUCE:** "user `gogogo!`s after long Q&A drift, expecting old proposal still valid." Mitigated by the IMMEDIATELY-PRECEDING-MESSAGE constraint — drift triggers re-propose, not action on stale plan.

### Files touched

- **`scripts/check-rule-consistency.sh`** REGIONS array: `verb-table` removed, `proposal-format` added. The three regions are now `gate-clause` + `proposal-format` + `bare-gogogo`.
- **`PROJECT_STARTER.md` §2** fully rewritten: new gate clause + new proposal-format section + new bare-gogogo handling + new self-check (4 steps instead of 3) + sweep of verb references in §2.2/§2.6/§2.7/§2.9. Refuse-list table gains two new rows ("Reality deviated mid-action" and "Proposal was several messages ago"). Allowed-without-gogogo list gains "proposing (the propose-then-wait pattern itself never requires `gogogo!`)."
- **`templates/CONTRIBUTING.md`** gate section fully rewritten to match — same three regions byte-exact, same self-check, same refuse-list updates. Surrounding prose framed as per-project operational.
- **`templates/CLAUDE.md`** gate section fully rewritten to match — same three regions byte-exact. The "Canonical scope" header marker updated to name proposal-format instead of verb-table in the duplicated-rule list. Surrounding prose framed as session-facing summary.
- **`docs/spec.md`** surgery: **B-001** and **B-011** moved to the historical-superseded section with `**Status:** superseded by B-026 (v1.23.0)` notes that preserve the original Rule/Rationale/Test for audit. **B-026** added as the new frozen gate rule. **D-004** marked superseded by D-010 with a status note at the top (original Chose/Considered/Why preserved). **D-010** added at the end of the decision log with the full failure-mode analysis. **B-021** content updated in place: the duplicated-rule-statement list now names `gate-clause` / `proposal-format` / `bare-gogogo`; the Test field switched from "manual until C4 linter ships" to "automated via B-022" (this should have happened in v1.19.0 but caught up here). **B-022** content updated in place: the three named regions and the addition/removal rules reflect the new set.

### What stays the same

- `gogogo!` is still the gate token. The literal-substring check (B-001 condition) survives as B-026 condition (b).
- Memory writes (`~/.claude/projects/.../memory/`) and `.claude/settings.local.json` remain carved out — no `gogogo!` needed.
- The refuse-list (rationalizations to refuse) still applies — `yes`, `do it`, "user is rushing", "auto mode says minimize interruptions" — all still NOT authorization.
- The 5-step workflow shape (spec → bump+CHANGELOG → code → commit+push → deploy) is unchanged. So are PR / merge / deploy / revert workflows. Only the triggering changed.
- Auto mode still does NOT override the gate.

### Spec

- **B-001** → moved to Historical blocks; superseded by B-026.
- **B-011** → moved to Historical blocks; superseded by B-026.
- **D-004** → status note added (superseded by D-010); original Chose/Considered/Why preserved for audit.
- **B-026** added (frozen) — the new gate rule + full rationale + failure-mode analysis.
- **D-010** added — the gate-model decision, including the failure-mode analysis at decision level (not just block level).
- **B-021** content updated in place — three-tier model's duplicated-rule list now names the new regions.
- **B-022** content updated in place — REGIONS array contents and the region-add/remove procedure.

### Next

- **v1.23.1 (`refactor gogogo!`):** Sweep remaining repo references to action verbs — CHANGELOG history is naturally preserved as audit trail (historical mentions stay), but any active doc that still describes the verb model gets updated. Likely candidates: README.md (if it mentions verbs), templates/README.md, templates/docs/*, this CHANGELOG entry's "Next" section becomes whatever's next on the roadmap (v1.22.1 WORKFLOW.md extraction, queued from the prior split sequence).

## v1.22.0 — 2026-05-19

Mirrors `PROJECT_STARTER.md` template v1.22.0. **First of three commits splitting `PROJECT_STARTER.md` (Codex Phase 4 #2).** Three companion docs shipped at meta-repo root; the remaining two (`WORKFLOW.md`, `BOOTSTRAP.md`) ship in v1.22.1 and v1.22.2.

### Why staged across three commits

The linter trio (B-022 / B-023 / B-024) shipped in v1.19.0–v1.21.0 was the gating prerequisite for this refactor. Splitting an 1100-line file five ways in a single commit is hard to review and easy to silently drop content from. Staging across three commits lets each commit be independently green:

- **v1.22.0 (this release):** extract three docs that don't touch any C4-linter anchored region (those live in §2). Lower coordination cost.
- **v1.22.1:** extract WORKFLOW.md (§2 + §9 + §10 + §11). Same commit retargets `scripts/check-rule-consistency.sh` `FILES` array from `PROJECT_STARTER.md` to `WORKFLOW.md` so the C4 linter's three rule regions follow the canonical content.
- **v1.22.2:** extract BOOTSTRAP.md (§0 + §1 + §5). Reduces PROJECT_STARTER.md to a thin ~50-line index.

### What shipped

- **`TEMPLATE_INVENTORY.md`** — extracted §3 (file/folder layout tree + folder ownership notes) and §4 (the `templates/` copy-paste reference table with placeholders per file). The table picked up a v1.14.1-era entry for `templates/scripts/_env-schema-parse.sh` (the shared `@directive` parser) that was missing pre-split, and the `.env.example` row gained a reference to B-020. Otherwise content is verbatim.
- **`DEPLOY_BASELINE.md`** — extracted §6 (VPS deploy: DNS / TLS / reverse proxy / service user / systemd / firewall), §7 (CI/CD baseline YAML template + auto-deploy deferred), and §13 (credential handling: never paste in chat / leak-handling protocol / Read+Edit tool-path / masking pattern / no-asking-in-chat). Subsections renumbered to bare headings (no §6.1 → §6.6 ladder) since they're top-level inside the new file. The reverse-proxy section's "§6.2" internal cross-reference rewrote to "TLS section above."
- **`HARNESS_QUIRKS.md`** — extracted §12 (harness quirks: permission gating / SSH gating / TTY-bound commands / `gh` CLI quirks / memory carve-out / branch protection vs. local merge / auto-mode-vs-gate) and §14 (`bootstrap.sh` design: five modes / migration via export+import / comment-block-per-var / optional-vs-required via `@directive` schema / sensitive-value masking / per-var `@validator` regex / input normalization / atomic save / no GUI). §14's "Optional vs required" and "Format validators" subsections were lightly updated in-line to reference B-020's `@directive` schema rather than the legacy prose-grep / hardcoded-regex behavior they superseded — the rest is verbatim.

### What stays in `PROJECT_STARTER.md`

§0 (How to use + scope), §1 (Bootstrap checklist), §2 (the workflow + gate — staying for v1.22.1), §5 (Decisions to answer — staying for v1.22.2), §8 (Audit trail + Decision log), §9 (Conventions — staying for v1.22.1), §10 (Memory seed — staying for v1.22.1), §11 (PR review heuristics — staying for v1.22.1), and the Template changelog tail. §0.2 Reading order rewritten to reference the three new files. Extracted sections retain their heading + a one-line `**Moved to [X.md](X.md) in v1.22.0.**` pointer so readers find the new location and section numbering stays stable across intermediate states.

### Export script + linter coordination

- **`scripts/export-starter.sh`** gained a `ROOT_DOCS` array (`PROJECT_STARTER.md`, `TEMPLATE_INVENTORY.md`, `DEPLOY_BASELINE.md`, `HARNESS_QUIRKS.md`). All four are copied into the archive stage alongside the flattened `templates/` contents, so PROJECT_STARTER.md's cross-links to its companion docs resolve in the consumer's extracted layout. Missing any of them is now a hard failure at export time.
- **`scripts/check-doc-references.sh`** `VIRTUAL_TEMPLATES_FILES` was extended from `[PROJECT_STARTER.md]` to all four root docs, keeping it in sync with `ROOT_DOCS`. The two arrays must always match; both files name each other in their comments. (No template-side links to the new docs exist today, but future ones will resolve correctly.)
- **`scripts/check-rule-consistency.sh`** unchanged in v1.22.0 — its `FILES` array still points at `PROJECT_STARTER.md` because §2 (the source of the three anchored rule regions) hasn't moved yet. v1.22.1 will retarget it to `WORKFLOW.md` in the same commit that moves the anchors.

### Spec

- **B-025** added (frozen) — captures the three-commit split rationale, stub-with-pointer convention, and the `ROOT_DOCS` / `VIRTUAL_TEMPLATES_FILES` coordination requirement.
- **B-015** archive-layout rule updated in place: described archive contents change from "PROJECT_STARTER.md + templates contents" to "`ROOT_DOCS` array + templates contents", with a note that adding a new root doc requires appending to both `ROOT_DOCS` AND `VIRTUAL_TEMPLATES_FILES` in the same commit. Pre-v1.22.0 archive shape (PROJECT_STARTER.md only at root) noted for audit trail.
- **B-023** doc-reference linter description updated to name all four entries currently in `VIRTUAL_TEMPLATES_FILES`.

### README

"Known limitations" section updated: the `PROJECT_STARTER.md` monolith bullet rewrites to describe split progress + remaining work; the drift-detection bullet rewrites to credit the now-shipped linter trio. Docs table gains rows for the three new files.

### Next

- **v1.22.1 (`refactor gogogo!`):** Extract `WORKFLOW.md` (from §2 + §9 + §10 + §11). Retarget B-022 C4 linter's `FILES` array. Update B-021's `(post-split: WORKFLOW.md)` parenthetical to past tense. Spec: update B-021 + B-022 in place.

## v1.21.0 — 2026-05-19

Mirrors `PROJECT_STARTER.md` template v1.21.0. **Codex Phase 8 #3 — placeholder linter.** Closes the third and final linter in the trio that gates the upcoming safe `PROJECT_STARTER.md` split.

### Ship `scripts/check-placeholders.sh` + CI wiring

The template's bootstrap surface defines a canonical set of placeholders that consumers `sed` away on first commit: `<package_name>` (lowercase, package import name); plus `<PACKAGE_NAME>` / `<PROJECT_NAME>` / `<PROJECT_SLUG>` / `<GITHUB_USER>` / `<HOST>` / `<DOMAIN>` / `<PROJECT_DESCRIPTION>` / `<COPYRIGHT_HOLDER>` / `<YEAR>` (the broader set). These belong in `templates/` files (where they're load-bearing) and in meta-repo `*.md` files only inside backticks (where they're documentation of the placeholder concept). What they must never be: out in plain prose of a meta-repo doc — that reads as "the docs shipped with TODO markers."

Until now, that invariant was held only by review attention. The new linter enforces it mechanically:

- **Scope.** Walks meta-repo `*.md` files only — `README.md`, `CONTRIBUTING.md`, `PROJECT_STARTER.md`, `CHANGELOG.md`, and `docs/*.md`. Excludes `templates/` (placeholders expected there) and the external Codex improvement plan (frozen content). Six files in total today.
- **Code-span / fenced-block stripping.** Reuses the same approach as the doc-reference linter (B-023): lines starting with three backticks toggle the fence state and fenced-block lines are emitted as blank lines (line numbers stay in sync with the source file); inline single-backtick spans are stripped before scanning. So a sentence that mentions `<package_name>` inside backticks stays fine — the writer is referencing the placeholder concept, not waiting for substitution.
- **Canonical-set only.** The linter checks the 10-item canonical set explicitly. Generic angle-bracket meta-syntax used elsewhere in prose (`<verb>`, `<file>`, `<region>`, `<X.Y.Z>`, etc.) is not in the set and is not flagged — the repo uses `<X>` as a general placeholder convention for many documentation purposes, only a subset of which are substitution placeholders.
- **Non-.md files NOT scanned.** Meta-repo `*.sh` / `*.py` / `*.toml` files do contain canonical placeholder strings in comments or docstrings (e.g. `scripts/check-doc-references.sh` mentions `<package_name>` in a comment describing what it parses), but those don't render to users and won't surprise a consumer. Markdown is the user-facing surface; that's where the invariant matters.
- **Output.** Clean: `OK: no canonical placeholders found in plain prose across 6 meta-repo files.` (exit 0). Failure: `<file>:<line> -> <placeholder>` per occurrence on stderr, followed by `FAIL: <N> canonical placeholder occurrence(s) leaked into plain prose across 6 meta-repo files.` (exit 1).
- **CI wiring.** `.github/workflows/template-self-test.yml` gains a `check-placeholders` step between `check-doc-references` (B-023) and the smoke test (B-014). Push or PR drift fails the build.

### The C-linter trio is now complete

This closes the trio of mechanical checks for canonical-doc invariants:

- **C4 — rule-consistency** (B-022, v1.19.0): the three deliberately-duplicated rule regions (gate clause, verb table, bare-gogogo prompt) stay byte-exact across `PROJECT_STARTER.md` / `templates/CONTRIBUTING.md` / `templates/CLAUDE.md`.
- **C2 — doc references** (B-023, v1.20.0): every `[label](target)` Markdown link target resolves to a shipped file or directory.
- **C3 — placeholders** (B-024, this release): no canonical substitution placeholder leaks into user-facing prose.

Together they make the upcoming `PROJECT_STARTER.md` split (Codex Phase 4 #2 — break the 1000-line monolith into `BOOTSTRAP.md` / `WORKFLOW.md` / `TEMPLATE_INVENTORY.md` / `DEPLOY_BASELINE.md` / `HARNESS_QUIRKS.md`) safe to do mechanically: file moves and reference rewrites can't silently break rule duplication, link resolution, or placeholder presentation without CI failing.

### Spec

- **B-024** added (frozen) — C3 placeholder linter contract: scope, canonical placeholder set, code-span handling, CI integration, error format.

### Next

- **v1.22.0 (`refactor gogogo!`):** Split `PROJECT_STARTER.md` (Codex Phase 4 #2). Five focused docs; PROJECT_STARTER.md becomes a thin index + canonical authoring source. The linter trio guards the move.

## v1.20.0 — 2026-05-19

Mirrors `PROJECT_STARTER.md` template v1.20.0. **Codex Phase 8 #2 — doc-reference linter.** Resolves B-016's "manual until C2 linter ships" caveat.

### Ship `scripts/check-doc-references.sh` + CI wiring

B-016 (v1.11.1) established the invariant that every live doc reference resolves to a shipped file or is an explicit example. Until now enforcement was a manual audit on each release-prep — fast to forget, easy to regress. Every prior rename or removal of a file (e.g. `request-codex-review` skill, `validators.sh` sidecar, `WEBHOOK_BASE_URL` env var) was one missed `grep` away from leaving a dangling `[..](..)` link somewhere in the docs.

The new linter resolves that:

- **Scope.** Walks every `*.md` file in the repo (excluding `.git/`). Extracts only Markdown link targets of the form `[label](target)` via an awk pattern that handles multiple links per line. Skips fenced code blocks entirely (lines starting with three backticks toggle the fence state) and strips inline single-backtick code spans before scanning, so docs that show the literal Markdown link syntax inside backticks (like this very entry) don't false-trigger. Skips `http://` / `https://` / `mailto:` / `tel:` / `data:` / `ftp://` URLs, anchor-only links (`#section`), autolinks (`<url>`), and empty targets. Strips a trailing `#anchor` or `?query` from the target before the existence check, so `PROJECT_STARTER.md#01-current-scope` is checked as `PROJECT_STARTER.md`. Strips optional Markdown link titles (`[label](path "Title")`). Existence is checked with `[ -e ]` so directory targets like `[templates/](templates/)` pass.
- **Resolution.** Relative targets resolve from the linking file's directory; absolute targets (starting `/`) from the repo root. Paths are normalized via `realpath -m --relative-to="$REPO_ROOT"` (no existence requirement during normalization).
- **Export-layout awareness.** Links inside `templates/` are authored against the consumer's project layout, where the export script flattens templates contents next to `PROJECT_STARTER.md`. To match that, the linter accepts targets that resolve to `templates/<f>` for any `<f>` in `VIRTUAL_TEMPLATES_FILES` (currently just `PROJECT_STARTER.md`) as long as `<f>` exists at meta-repo root. Without this rule, two existing valid links would false-positive: `templates/README.md:19 → PROJECT_STARTER.md` and `templates/docs/spec.md:13 → ../PROJECT_STARTER.md`. Updating the export script to promote additional files requires appending to this list.
- **Backtick paths are NOT linted.** A deliberate scope choice — the false-positive rate on backtick paths is high because much of the prose in `README.md` and `PROJECT_STARTER.md` describes the consumer's layout (`src/<package_name>/...`) or shows illustrative examples rather than this repo's actual files. Markdown link syntax has explicit semantic intent ("this is a navigable reference"), which gives a high signal-to-noise ratio.
- **Output.** On clean run: `OK: 50 Markdown link targets resolved across 19 files.` (exit 0). On any failure: one line per broken link as `<file>:<line> -> <target>  (resolved: <normalized>)` to stderr, followed by `FAIL: <N> broken doc reference(s) across 19 files (<scanned> links scanned).` (exit 1).
- **CI wiring.** `.github/workflows/template-self-test.yml` gains a `check-doc-references` step between the existing `check-rule-consistency` step and the smoke test. Push or PR drift fails the build.

### Spec

- **B-023** added (frozen) — C2 doc-reference linter contract: scope, resolution rules, export-layout awareness, CI integration, error format.
- **B-016** test method updated from manual `find` + grep to automated via B-023. Manual audit remains as backup for the "explicit example" / "placeholder" / "prescriptive recommendation" sub-categories that no machine check covers cleanly.

### Next

- **v1.21.0 (`feat gogogo!`):** Placeholder linter (Codex Phase 8 #3). Enumerates allowed placeholders (`<package_name>`, `<PROJECT_NAME>`, `<GITHUB_USER>`, `<HOST>`, `<DOMAIN>`, `<PROJECT_DESCRIPTION>`, `<COPYRIGHT_HOLDER>`, `<YEAR>`); fails CI on unresolved placeholders in meta-repo files (excluding `templates/`). Closes the linter trio that gates the safe `PROJECT_STARTER.md` split coming after.

## v1.19.0 — 2026-05-19

Mirrors `PROJECT_STARTER.md` template v1.19.0. **Codex Phase 8 #4 — consistency linter for canonical workflow phrases.** Resolves B-021's "manual until C4 linter ships" caveat.

### Ship `scripts/check-rule-consistency.sh` + CI wiring

B-021 (v1.18.0) made the three-tier doc redundancy load-bearing — rule statements (verb table, gate clause, bare-`gogogo!` prompt) are deliberately duplicated across `PROJECT_STARTER.md` §2 / `templates/CONTRIBUTING.md` / `templates/CLAUDE.md` as defensive AI-safety equipment. Without a mechanical check, one careless edit could silently drift the copies and reopen the failure mode B-021 was designed to prevent.

The new linter resolves that:

- **Anchors.** Each of the three canonical rule regions in each of the three files is bracketed by HTML-comment markers `<!-- C4:<region>:start --> ... <!-- C4:<region>:end -->`. HTML comments are invisible in rendered markdown so the source layout stays clean, but bash + awk can locate them trivially. Regions in v1.19.0: `gate-clause`, `verb-table`, `bare-gogogo`.
- **Linter.** `scripts/check-rule-consistency.sh` walks all three files for each region, extracts the content between matching anchors, and diffs every pair (against the first file as reference). Missing region in any file → fail with `ERROR: region '<name>' missing or empty in <file>`. Mismatched region → fail with a unified diff naming the two files and the drifted lines. Clean run prints `OK: canonical rule regions match across 3 files.` and exits 0.
- **CI wiring.** `.github/workflows/template-self-test.yml` gains a `check-rule-consistency` step that runs before the existing smoke test. Push or PR drift fails the build.

### Pre-linter alignment (same commit)

Byte-exact match required normalizing existing-but-divergent wording in the three files first:

- `templates/CLAUDE.md` gate clause: `**Never take any state-mutating action...**` → `**Do NOT take any state-mutating action...**` (matches the canonical wording already present in `PROJECT_STARTER.md` §2.1 and `templates/CONTRIBUTING.md`).
- `PROJECT_STARTER.md` §2.1 verb table: collapsed from 3 columns (Phrase / Action / Workflow) to the 2-column shared form (Phrase / Action) used by the other two tiers. The dropped Workflow column carried §-references (e.g. `5-step (§2.2)`, `§2.5 only`); those moved to a prose sentence immediately below the table so the operational detail isn't lost. Action wording also unified — `Full feature change` → `Full 5-step workflow (spec → bump+CHANGELOG → code → commit+push → deploy)`, etc.
- Bare-`gogogo!` prompt: unified across all three files to a standalone bold paragraph `**Bare `gogogo!` (no verb) is ambiguous** → reply *"Which action? code / commit / PR / merge / deploy / revert?"* and STOP. Review is out-of-band — no verb for it.` In `templates/CONTRIBUTING.md` and `PROJECT_STARTER.md` §2.1, the conflicting bullet in the existing self-check list (which had slightly different phrasing in each file) now reads `Bare `gogogo!` (no verb) → see the canonical prompt above.` — the self-check still walks the four outcomes but no longer duplicates the canonical wording.

### Adding regions in future versions

Append a `C4:<new-region>:start/end` pair (same canonical text in all three files) and add the region name to the linter's `REGIONS` array. No parser changes; the linter is region-name-agnostic.

### Spec

- **B-022** added (frozen) — C4 rule-consistency linter contract: anchor format, three regions, CI integration, drift behavior.

### Next

- **v1.20.0 (`feat gogogo!`):** Doc-reference linter (Codex Phase 8 #2). Parses `*.md` for local file references and verifies existence; closes the P1 #4 audit loop mechanically.

## v1.18.0 — 2026-05-18

Mirrors `PROJECT_STARTER.md` template v1.18.0. **Codex Phase 1 #1 — three-tier doc-canonical model with deliberate AI-safety redundancy.**

### Mark canonical scope across PROJECT_STARTER / CONTRIBUTING / CLAUDE; preserve protective rule duplication

The original Codex Phase 1 #1 framing was "choose one canonical source for workflow policy" (per the design proposal). User pushback caught a critical historical context I'd missed: *"we had 3 places to hold the rules, just because you were constantly missing them."* The triple-source layout wasn't accidental architecture debt — it was defensive redundancy added empirically after each observed AI failure (missed gate, wrong verb mapping, ignored bare-gogogo handling).

The refined framing: **one canonical source per concern, but rule statements stay deliberately duplicated for AI safety.** Three tiers:

- **`PROJECT_STARTER.md` §2** (or post-split `WORKFLOW.md`) — canonical for **core workflow rules + rationale + alternatives + design philosophy**. The "why" lives here exclusively.
- **`templates/CONTRIBUTING.md`** — canonical for **per-project operational concretization** (commands, sequences, per-stack version markers, deploy specifics). References PROJECT_STARTER for *why*. Carries rule statements inline as defensive redundancy.
- **`templates/CLAUDE.md`** — **session-facing summary** the AI loads every session. Carries gate clause, verb table, bare-gogogo prompt, allowed-without-gate list, refuse-list inline — **not as pointers** — because the AI needs them in working context to apply them. Stripping these to pointers was observed historically to cause failures.

Each of the three files now starts with an explicit `**Canonical scope:**` header marker declaring what it owns and naming the other tiers' canonical sources. Sections carrying duplicated rule statements are annotated as deliberate-redundancy with a "keep in sync" note.

**What's deduplicated (safe to remove):** rationale, "why we chose this," alternative-considered narrative, design philosophy. These live canonically in PROJECT_STARTER and are NOT repeated in CONTRIBUTING/CLAUDE.

**What stays duplicated (deliberate AI-safety equipment):** verb table; gate clause; bare-gogogo clarification prompt; allowed-without-`gogogo!` list; refuse-list (rationalizations to refuse); "phrases that look like authorization but aren't." All three files carry these verbatim.

### Sync mechanism

Manual until the C4 consistency linter ships (Codex Phase 3 #3 in current plan). The linter is now higher priority than the original ordering suggested — without it, the deliberate redundancy is one careless edit away from silently drifting. **Next planned commit: build the C4 linter (`feat gogogo!`).** Order reversed from my original "linter first" recommendation per user direction on this commit.

### Plus: thin root CONTRIBUTING.md for the meta repo

Until now we worked on `phoenixprojecttemplate` (the meta repo) by reading `templates/CONTRIBUTING.md` mentally. Added a minimal root `CONTRIBUTING.md` (~30 lines) that points at `PROJECT_STARTER.md §2` for the canonical workflow + names meta-specific overrides (deploy is no-op per B-005; version markers are just `VERSION`; meta repo's CI is `.github/workflows/template-self-test.yml`, not `templates/.github/workflows/ci.yml`). The meta repo now follows its own published workflow honestly.

### Spec

- **B-021** added: three-tier doc-canonical model with deliberate AI-safety redundancy. Names the three tiers, the canonical scope of each, what's deduplicated vs what's deliberately duplicated, and the rationale (including the historical context that drove the original triple-source layout). Frozen. Test is manual until C4 linter ships.

### Next

- **v1.18.1 or v1.19.0 (`feat gogogo!`):** Build the C4 consistency linter (`scripts/check-rule-consistency.sh`). Checks verb table + gate clause + bare-gogogo prompt match across the three files. Wired into `.github/workflows/template-self-test.yml` as a second job.

## v1.17.0 — 2026-05-18

Mirrors `PROJECT_STARTER.md` template v1.17.0. **Codex Phase 1 #3 — first item of the doc-architecture refactor.**

### Split `docs/spec.md` into active + historical-superseded sections

`docs/spec.md` had grown to 295 lines mixing 14 active blocks with 6 superseded blocks in arbitrary file order (mostly chronological reverse). A reader trying to understand "what are the current rules?" had to filter superseded blocks out by eye on every visit. Codex Phase 1 #3 (renumbered from prior plan Phase 2 #3 in the most recent Codex plan refactor): "Keep active blocks in the main section. Move superseded blocks to a historical appendix or dedicated section. Keep the decision log as the durable audit trail."

New structure:

- **`## Frozen behavior`** — 14 active blocks in numerical order: B-001, B-002, B-003, B-004, B-005, B-010, B-011, B-012, B-014, B-015, B-016, B-017, B-019, B-020.
- **`## Decision log`** — 9 decisions in numerical order: D-001 through D-009. Decisions remain in this section regardless of supersession status (each superseded decision retains its full Chose/Considered/Why content plus a `Status:` line explaining what replaced it — same convention as before; no decision content moved).
- **`## Open project-level decisions`** — unchanged.
- **`## Historical blocks (superseded)`** — new appendix at end of file. 6 superseded blocks in numerical order: B-006, B-007, B-008, B-009, B-013, B-018. Block content is preserved verbatim; cross-references from active blocks ("Supersedes B-NNN") still resolve.

Zero content removed. Pure reorganization. Reader who wants current rules reads top of file and stops at "Open project-level decisions"; reader who wants audit trail or context for a supersession trail continues to the appendix.

### Templates skeleton updated

`templates/docs/spec.md` skeleton gains a third editing rule: "Once a Block is marked superseded, move it to a `## Historical blocks (superseded)` appendix at the bottom of this file in the same commit that supersedes it." Consumer projects starting from this skeleton follow the same convention.

### Spec

No new B block (organization change, not behavior). The convention itself is documented in `templates/docs/spec.md`'s editing rules.

### Next on Phase 1

- **Phase 1 #1** — canonical source for workflow policy choice. Architectural decision (PROJECT_STARTER.md vs templates/CONTRIBUTING.md as the canonical source). Needs a **design discussion turn** before code, same flow as Phase 3.
- **Phase 1 #2** — split PROJECT_STARTER.md into BOOTSTRAP / WORKFLOW / TEMPLATE_INVENTORY / DEPLOY_BASELINE / HARNESS_QUIRKS. Depends on Phase 1 #1's decision.
- **Phase 1 #4** — reduce duplication between PROJECT_STARTER / CONTRIBUTING / CLAUDE. Depends on Phase 1 #1's decision.

## v1.16.1 — 2026-05-18

Mirrors `PROJECT_STARTER.md` template v1.16.1. Patch — Codex Phase 5 #2 (Known Limitations), small README addition.

### Add Known Limitations section to README

Pairs with v1.16.0's quickstart README. Without an explicit limitations section, new visitors might assume the template is more polished than it is and hit surprises when first using it. Codex Phase 5 #2: "State explicitly what is still manual. State what is not yet generic or multi-preset. Users are not surprised by remaining edges."

Five concrete limitations, each with a one-paragraph explanation + link to the roadmap item where applicable:

1. **Placeholder substitution is manual** — `bootstrap.sh` only does `.env` credential prompting; placeholder substitution (`<package_name>` mv + sed across `.py`/`.toml`/`Makefile`/`.yml`/`.sh`/`.example`; plus `<PROJECT_NAME>`/`<GITHUB_USER>`/`<HOST>`/`<DOMAIN>` edits) is manual. Open item #3 (`scripts/new-project.sh`) addresses this.
2. **Single language preset** — Python/uv/FastAPI/VPS only. Multi-preset is roadmap per D-009.
3. **`PROJECT_STARTER.md` is a 1000+ line monolith** — split into focused docs is roadmap (open item #7 + Codex plan Phase 1).
4. **No automated drift detection** — doc references, placeholders, workflow-wording consistency manually audited today. Linters are roadmap (Codex plan Phase 3).
5. **Windows requires WSL** — `src/<package_name>/` directory has angle-bracket characters that aren't valid Windows filenames; bash scripts assume POSIX shell. Per D-009 target is Linux/VPS — Windows isn't a first-class target.

Section sits in README between Quickstart and Docs, with a pointer to `docs/spec.md` "Open project-level decisions" for the full roadmap so the README doesn't duplicate.

## v1.16.0 — 2026-05-18

Mirrors `PROJECT_STARTER.md` template v1.16.0. **First commit on new branch `improvements-2` after merging `improvements-1` (PR #1, v1.2.0–v1.15.0).**

### Add a repo-root README — first-contact quickstart (Codex Phase 5 #1)

Until now the repo had no `README.md` at root — GitHub's landing page showed an empty README slot and visitors had to open `PROJECT_STARTER.md` (~1000 lines) to figure out what the project even was. Per the refactored Codex improvement plan's Phase 5 #1: "New users do not need to reverse-engineer the repo from long docs."

Ships a ~250-word README covering:

- **What it is** (reusable bootstrap kit for Claude Code projects) + **who it's for**.
- **Current shipped scope** — explicitly Python/uv/FastAPI/VPS today per D-009; multi-preset is roadmap, not shipped.
- **What you get** — two-layer table separating the stack-agnostic process layer (gate, workflow, spec format, Karpathy rules, review rubric) from the Python preset (FastAPI app, tests, Makefile, CI, deploy script, env-bootstrap with `@directive` schema).
- **Quickstart commands** — `./scripts/export-starter.sh` + `tar -xzf --strip-components=1` + `chmod +x scripts/*.sh`, pointing at `PROJECT_STARTER.md §1` for the rest (placeholder substitution, `uv lock`, GitHub repo creation, etc.).
- **Docs table** linking PROJECT_STARTER, `docs/spec.md`, CHANGELOG, `docs/pr_review_instructions.md`.

Does NOT prominently feature `codex improvement plan.md` — the committed version in git is the v1.8.0 snapshot, which is now stale (Codex has refactored it twice locally; the latest 9.7KB / 300-line version lives in stash@{0} per the user's "no snapshot" decision). The plan file is internal working state, not a consumer-facing artifact.

### Next on Phase 5

- **v1.16.1 (`docs gogogo!`):** Phase 5 #2 — Known Limitations (section in README, or separate `LIMITATIONS.md` — small decision).

## v1.15.0 — 2026-05-18

Mirrors `PROJECT_STARTER.md` template v1.15.0. **Third and final commit implementing Codex Phase 3 (env metadata explicit). Phase 3 complete.**

### Kill `templates/scripts/validators.sh` — superseded by `@directive` system

`validators.sh` shipped in v1.12.0 as the deliberate extension point for project-specific validators (B-018). The `@directive` system shipped in v1.14.0–v1.14.1 (B-020) provides the same per-var validator extension point inline in `.env.example` via `@validator:` directives. Two mechanisms for the same job — exactly the kind of duplication the Codex plan kept warning against.

Removing the sidecar:

- **`templates/scripts/validators.sh`** deleted (`git rm`).
- **`templates/scripts/bootstrap.sh`** — the 9-line "Project-specific validators sidecar (deprecated)" block that sourced it is removed.

The v1.12.0 work isn't wasted — it was the right step at the time and shipped a working extension point. Just superseded by a cleaner unified mechanism three versions later. Spec churn matches the B-008 → B-009 → B-010 lineage from the review-flow saga.

### Breaking change

Consumers using `templates/scripts/validators.sh` to add project-specific validators must migrate those entries to `@validator:` directives in their `.env.example`. For example:

```sh
# in old validators.sh:
VALIDATORS[STRIPE_API_KEY]='^sk_(live|test)_[A-Za-z0-9]{24,}$'

# becomes, in .env.example:
# @description: Stripe API key
# @required
# @sensitive
# @validator: ^sk_(live|test)_[A-Za-z0-9]{24,}$
STRIPE_API_KEY=
```

Per the user's hard-cut decision in the Phase 3 design discussion.

### Spec

- **B-018** (validators.sh sidecar) flipped to **superseded by B-020**. Rationale: same job covered inline by `@validator:` directives; one mechanism is better than two.

### Phase 3 complete

- ✓ v1.14.0 — `.env.example` migrated to `@directive` format; B-020 draft.
- ✓ v1.14.1 — parser swap to directive-only via shared helper; B-020 frozen.
- ✓ v1.15.0 — kill `validators.sh`; B-018 superseded by B-020.

Per the updated codex plan execution order, next is Phase 2 (documentation architecture).

## v1.14.1 — 2026-05-18

Mirrors `PROJECT_STARTER.md` template v1.14.1. **Second of three commits implementing Codex Phase 3 (env metadata explicit).** Parser swap — hard cut from legacy prose-grep to `@directive`-only.

### Parser rewrite + shared helper

- **`templates/scripts/_env-schema-parse.sh`** (new — sourced helper, not invoked directly). Parses `.env.example`; populates global associative arrays `VARS`, `DESCRIPTIONS`, `DEFAULTS`, `VALIDATORS`, `IS_OPTIONAL`, `IS_SENSITIVE`, `COMMENTS`. Recognizes the six `@directive` types from B-020 (case-insensitive directive name to forgive typos like `@Optional`). Unknown `@`-prefixed directives emit a stderr warning and are ignored. Last-wins semantics on duplicate directives in the same var's block. Default-if-neither-`@required`-nor-`@optional`-given is `required`.
- **`templates/scripts/bootstrap.sh`** — sources the helper; the old SENSITIVE_RE constant, the hardcoded `VALIDATORS` array, and the ~30-line inline parser loop are all removed. `mask()` now uses `IS_SENSITIVE[var]` (populated by parser) instead of regex auto-detection. `prompt_var()` now shows the `@description` value prominently plus `(optional)` / `(sensitive)` flag annotations. The validators.sh sidecar source line is retained for this release (v1.15.0 removes it).
- **`templates/scripts/check-env.sh`** — sources the helper; the duplicated ~25-line parser loop is replaced with a 5-line iteration over `VARS` partitioning into `required`/`optional` based on `IS_OPTIONAL`. Rest of the script (compares against actual `.env`, reports missing required vars) is unchanged.

### Hard cut — breaking change for un-migrated consumers

A consumer whose `.env.example` still uses legacy prose ("Optional:" comments instead of `@optional` directives) will now have ALL vars marked required (no @optional → required by default). check-env.sh would refuse to pass. Migration is a one-time edit of `.env.example` to add `@required` / `@optional` / `@default` / `@validator` / `@sensitive` / `@description` directives per B-020. Per the user's hard-cut decision in the design discussion — accepted breaking change at this v1 development stage.

### Spec

- **B-020 promoted from `draft` to `frozen`** (per spec format rule: status promotion rides in the commit that adds the proving test). Test pointer updated to reflect new parser behavior; rule text gains the case-insensitivity + unknown-directive-warning + shared-helper detail.

### What v1.15.0 will do

Kill `templates/scripts/validators.sh` + remove the source-if-present block from bootstrap.sh; supersede B-018. Validator metadata now lives inline in `.env.example` via `@validator:` directives — the sidecar is redundant after v1.14.1.

## v1.14.0 — 2026-05-18

Mirrors `PROJECT_STARTER.md` template v1.14.0. **First of three commits implementing Codex Phase 3 (env metadata explicit).**

### Declare `.env.example` schema via `@directive` comments

Codex Phase 3.1/3.2/3.3: `bootstrap.sh` and `check-env.sh` previously inferred required vs. optional from English prose (case-insensitive grep for "Optional" in any preceding comment line). Fragile by construction — rewording broke the gate silently. Validators lived in a separate sidecar (`templates/scripts/validators.sh` from v1.12.0). The schema was split across two surfaces with two different mechanisms.

This release introduces `@directive` comments as the single explicit-metadata format for env vars. `.env.example` stays the source of truth (Phase 3.3 answered by format choice — no separate schema, no rendering layer):

```bash
# @description: Sentry DSN for error reporting
# @optional
# @sensitive
SENTRY_DSN=
```

Six directives cover everything `bootstrap.sh` + `check-env.sh` need: `@description`, `@required` / `@optional`, `@default`, `@validator`, `@sensitive`. Free-text comments still allowed for human context — bootstrap.sh shows them in prompts but doesn't parse them as metadata. See B-020 in `docs/spec.md` for the full vocabulary.

### Reorder vs. the design proposal

The design proposal sequenced this as commit-1 (parser learns directives) → commit-2 (migrate `.env.example`) → commit-3 (kill validators.sh). With "hard cut" decided, that creates a broken intermediate at commit-1 (parser only understands directives, but template still ships legacy `.env.example`). Reorder: **migrate data first, swap parser second.** Old parser still works on the migrated file because case-insensitive grep for "Optional" matches "@optional" in SENTRY_DSN's block — and no other vars or section headers contain the word "Optional" anywhere. Zero broken intermediate states.

### What this commit ships

- **`templates/.env.example`** rewritten in directive format. File header rewritten to NOT contain the word "optional" anywhere (would otherwise false-match the legacy parser's grep on subsequent vars). Each shipped placeholder var (`VAR_NAME`, `ANOTHER_VAR`, `DB_PATH`, `SENTRY_DSN`, `LOG_LEVEL`, `DEV_MODE`) carries explicit directives.
- **`docs/spec.md` B-020 added in `draft` status** — format defined + data migrated; parser doesn't yet enforce. Will promote to `frozen` in v1.14.1 when parser is rewritten directive-only.

### What the next two commits will do

- **v1.14.1 (`refactor`):** rewrite `bootstrap.sh` + `check-env.sh` to directive-only parsing. Hard cut — consumers with un-migrated legacy `.env.example` will need to migrate. B-020 promoted to `frozen`.
- **v1.15.0 (`refactor`):** kill `templates/scripts/validators.sh`. Supersede B-018. Validator metadata now lives inline in `.env.example` via `@validator:` directives — no second mechanism.

## v1.13.0 — 2026-05-18

Mirrors `PROJECT_STARTER.md` template v1.13.0.

### Audit source-project residue in active docs + scripts (Codex Phase 1.3)

Third and final item of Package B / Codex Phase 1 (de-personalize). The systematic sweep across PROJECT_STARTER.md, templates/README.md, templates/CONTRIBUTING.md, templates/CLAUDE.md, templates/docs/*, and templates/scripts/*.sh surfaced two categories of residue:

**Hardcoded source-project usernames** (`denisbalon/$PROJECT_SLUG` in 3 places in PROJECT_STARTER.md §1.5 + §1.6) — flagged in v1.11.1's A5 audit, deferred to Package B, now fixed. Parametrized to `<GITHUB_USER>/$PROJECT_SLUG` using the existing placeholder convention.

**Vendor-specific examples in supposedly-generic prose** (6 instances in PROJECT_STARTER.md):
- §2.4 branch-naming examples (`feat/click-receiver`, `fix/capi-retry-401`) → generic (`feat/api-handler`, `fix/auth-retry-401`)
- §2.5 commit-message examples (CAPI/Subscribe/phoenixbot) → generic equivalents
- §5.1 stack rationale: "excellent CAPI/Telegram tooling" → "mature async ecosystem and excellent webhook/API tooling"
- §6.1 DNS guidance: "DNS-only for Telegram webhooks" → reframed for "webhook receivers in general where the upstream is sensitive to TLS termination details"
- §8.2 sample CHANGELOG entry: "Add Telegram webhook receiver" → generic "Add webhook receiver"
- §11 cross-cutting concerns: Telegram `chat_join_request` example → explicitly labeled `**Example (Telegram bots):**`
- §13 credential-leak revoke example: "Meta Events Manager" → explicitly labeled `**Example:**`

**Webhook-shaped env var name** (`WEBHOOK_BASE_URL` in `templates/scripts/deploy.sh`) renamed to `SERVICE_URL`. The old name presumed the service was a webhook receiver — a Telegram-bot leftover from the source project. Service URL is generic.

### Breaking change

`WEBHOOK_BASE_URL` → `SERVICE_URL` in `templates/scripts/deploy.sh`. Any consumer with `WEBHOOK_BASE_URL` in their `.env` should rename it (the deploy will silently fall back to the `<DOMAIN>` placeholder otherwise). Acceptable per v1 development phase.

### Spec

- **B-019** added: active docs are vendor-neutral by default; vendor-specific guidance is explicitly labeled. Names the principle for `PROJECT_STARTER.md` + all `templates/**/*.md` + script env var names. Frozen. The future C4 consistency linter (Codex Phase 5.3) tests it automatically.
- **Open project-level decisions** — De-personalize item now **fully resolved** (menu header v1.11.2 + validators v1.12.0 + docs/scripts audit v1.13.0).

### Package B status

- ✓ 1.1 Menu-header (v1.11.2 / B-017)
- ✓ 1.2 Validators (v1.12.0 / B-018)
- ✓ 1.3 Doc + script audit (v1.13.0 / B-019)

Codex Phase 1 (de-personalize) is complete. Per the updated codex plan, next phase in execution order is Phase 3 (env metadata).

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
