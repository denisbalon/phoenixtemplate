# Codex Improvement Plan

## Goal

Turn `phoenixprojecttemplate` from a strong personal workflow kit into a reliable reusable template without weakening the core operating model. The `gogogo!` gate stays strict. Versioning stays strict. The remaining work is about finishing the documentation architecture, tightening drift detection, formalizing preset boundaries, and smoothing adoption.

## Already Covered

These major items are done and should not stay on the active roadmap:

1. `scripts/export-starter.sh` exists and matches the documented quick path.
2. A minimal runnable Python/uv/FastAPI preset ships in `templates/`.
3. `templates/scripts/deploy.sh` catches staged and untracked dirtiness too.
4. Product identity is framed honestly as Python/uv/FastAPI/VPS today, with multi-preset as roadmap.
5. The main doc set was audited against shipped files and commands.
6. The template has a smoke test plus CI self-test workflow.
7. Generic scripts no longer hardcode source-project identity.
8. Active docs and script naming were de-personalized; vendor-specific examples are labeled explicitly.
9. `.env.example` now carries explicit `@directive` metadata parsed by a shared helper used by `bootstrap.sh` and `check-env.sh`.
10. Validator extension is unified under inline `@validator` directives; the sidecar mechanism is gone.
11. The spec is split into active versus historical-superseded sections.
12. Root onboarding docs now exist: `README.md`, Known Limitations, and the split companion docs.
13. The planned `PROJECT_STARTER.md` split is complete: `BOOTSTRAP.md`, `WORKFLOW.md`, `TEMPLATE_INVENTORY.md`, `DEPLOY_BASELINE.md`, and `HARNESS_QUIRKS.md` now exist, with `PROJECT_STARTER.md` reduced to a thin index.
14. Drift-detection automation now exists for:
   - rule consistency (`scripts/check-rule-consistency.sh`)
   - doc references (`scripts/check-doc-references.sh`)
   - placeholder leaks (`scripts/check-placeholders.sh`)

## Remaining Priorities

The active plan is done when:

1. The newly split docs are internally consistent with the frozen spec and no stale pre-split semantics remain in active surfaces.
2. Review-flow and workflow wording drift are caught automatically in the places the current linters do not yet cover.
3. The template inventory is machine-checkable and explicit about common vs preset-specific assets.
4. Adoption docs cover both fresh-start usage and incremental adoption of the kit into an existing project.
5. Multi-preset expansion has a clear boundary design before any new language preset lands.

## Phase 1: Fix Active Doc Regressions

These are highest priority because they are current correctness issues in active docs.

### 1. Fix the stale `.env.example` contract in `WORKFLOW.md`

Current issue:
- The latest review found that `WORKFLOW.md` still says requiredness is driven by the prose word `Optional`.
- That contradicts frozen B-020, where the live contract is explicit `@directive` metadata parsed by the shared helper.

Work:
- Rewrite the `Environment variables (.env.example format)` section in `WORKFLOW.md` to match B-020 exactly.
- Remove the stale prose-based `Optional` wording and examples.
- Re-check nearby docs for copied versions of the same outdated explanation.

Acceptance:
- No active doc claims `bootstrap.sh` infers requiredness from prose comments.
- Active workflow docs match B-020’s `@directive` contract.

### 2. Do a post-split active-doc consistency sweep

Reason:
- The doc split landed a lot of moved text quickly.
- The latest `WORKFLOW.md` regression proves there is still stale content risk inside active root docs.

Work:
- Audit `README.md`, `BOOTSTRAP.md`, `WORKFLOW.md`, `PROJECT_STARTER.md`, and `CONTRIBUTING.md` for behavior claims that may have been copied forward from older phases.
- Prioritize gate semantics, env metadata, review flow, and bootstrap substitution instructions.

Acceptance:
- No active doc contradicts current frozen behavior in `docs/spec.md`.

## Phase 2: Tighten Documentation Architecture

The big split is done. The remaining work is to make the new architecture cleaner and harder to drift.

### 1. Clarify canonical versus duplicated surfaces after the split

Current state:
- `WORKFLOW.md` is canonical for core workflow + rationale.
- `templates/CONTRIBUTING.md` and `templates/CLAUDE.md` intentionally duplicate safety-critical rule statements.

Remaining work:
- Make sure every root/meta doc and every template doc uses that model consistently.
- Remove any leftover wording that still implies `PROJECT_STARTER.md` is the canonical owner of the core workflow.

Acceptance:
- Canonical ownership is unambiguous across all active docs.

### 2. Trim any leftover low-value duplication outside the deliberate C4 regions

Reason:
- Some duplication is intentional safety redundancy.
- Other duplication is still maintenance debt.

Work:
- Audit repeated prose outside the C4 rule regions.
- Keep deliberate duplication only where it materially reduces AI or operator failure risk.
- Collapse explanatory repetition where a pointer is enough.

Acceptance:
- Active duplication is either explicitly intentional or removed.

### 3. Decide the long-term role of `PROJECT_STARTER.md` in cloned projects

Open question:
- Should it remain a snapshot index that ships with every export?
- Or should it become even thinner, with more of the durable content living in the companion docs only?

Work:
- Decide whether the current thin-index shape is final or transitional.
- If final, document that explicitly.

Acceptance:
- The role of `PROJECT_STARTER.md` is settled instead of implicitly evolving.

## Phase 3: Extend Drift-Detection Automation

The first linter wave is in place. The remaining work is to cover the gaps they do not catch yet.

### 1. Extend rule-consistency coverage beyond the current C4 regions where justified

Reason:
- The current linter covers the highest-risk duplicated gate regions.
- The latest `WORKFLOW.md` regression happened outside those exact anchored regions.

Work:
- Decide which additional anchored regions are worth enforcing mechanically.
- Candidates include env-metadata contract wording and review-flow wording if those remain duplicated intentionally.

Acceptance:
- Known duplicated high-risk rule text is mechanically checked, not only manually reviewed.

### 2. Add checks for active-doc versus spec consistency where feasible

Reason:
- Current linters catch link drift, placeholder leaks, and exact duplicated regions.
- They do not catch semantic drift like “doc says Optional prose controls requiredness” versus “spec says `@directive` metadata does.”

Work:
- Identify a small set of high-value invariant phrases or claims that can be checked safely.
- Keep the check narrow to avoid brittle false positives.

Acceptance:
- The repo catches at least the highest-value semantic drift patterns automatically.

### 3. Expand smoke coverage only where it closes a real past failure mode

Work:
- Evaluate whether to add checks for bootstrap/env doc examples, export variants, or placeholder substitution edges.
- Avoid broad, fragile smoke inflation.

Acceptance:
- Added test coverage is driven by known failure modes, not by checklist completion.

## Phase 4: Formalize Inventory and Preset Boundaries

The split made the docs clearer. The next step is to make the shipped asset model more explicit and machine-checkable.

### 1. Create a machine-checkable template manifest

Work:
- Define a manifest for shipped template files, purpose, placeholders, and ownership.
- Include root docs exported by `scripts/export-starter.sh`, template assets, and meta-only tooling distinctions where useful.

Acceptance:
- Docs can derive from the manifest.
- CI can verify documented files against the manifest.

### 2. Mark core vs optional vs preset-specific assets explicitly

Work:
- Distinguish:
  - common process-layer files
  - Python-preset files
  - deploy-only files
  - meta-repo-only tooling

Acceptance:
- Consumers can tell what is mandatory versus optional without reverse-engineering the repo.

### 3. Define `_common` vs preset boundaries before adding more presets

Work:
- Specify which assets belong to the future common layer:
  - workflow docs
  - review rubric
  - changelog conventions
  - env bootstrap core
- Specify which assets are preset-specific:
  - Makefile
  - CI
  - deploy script
  - setup expectations
  - runtime pin
  - sample source tree

Acceptance:
- Multi-preset expansion has a real boundary design before implementation starts.

### 4. Decide whether bootstrap modes belong in v1 of the preset architecture

Examples:
- `full-python-vps`
- `python-local-only`
- `docs-only`

Acceptance:
- Bootstrap modes are either explicitly planned with boundaries, or explicitly deferred.

**Resolved (v1.31.2, D-016): deferred** until after the actual `_common/` + `presets/python-uv/` file move ships. Stacking mode-selection on top of preset-selection before the layered structure even exists doubles the optionality surface for no current consumer; the candidate modes all describe subsets of the single Python preset that ships today, so the mode design can't be validated against multi-preset reality until multi-preset exists. The orthogonal-axes shape (`--preset` × `--mode`) is the likely long-term form when the question is revisited. Phase 5.1 migration guidance covers the `docs-only` use case in the interim. Full Considered / Why / Failure-mode analysis in `docs/spec.md` D-016.

## Phase 5: Improve Adoption UX Further

The first-contact docs are much better now. The remaining UX work is about making adoption easier for more than just greenfield bootstrap.

**Resolved (v1.32.0 + v1.32.1 + v1.32.2). Phase 5 closed.** See per-§ resolution notes below; D-017 in `docs/spec.md` records the Phase 5.3 decision and the closure of the Codex improvement plan in full.

### 1. Add migration guidance for existing projects

Work:
- Explain how to adopt the process layer, docs, or specific tooling incrementally.
- Distinguish “full bootstrap from scratch” from “import selected parts into an existing repo.”

Acceptance:
- The kit is usable as a toolkit, not only as a fresh-start template.

**Resolved (v1.32.0, B-034):** `MIGRATION.md` at meta-repo root documents four selective-import paths (process layer / docs / env-bootstrap / linter set) with file lists + merge-with-existing guidance + standalone-vs-coupled assessment per linter, plus a week-by-week adoption order for phased import. Added to `scripts/export-starter.sh` ROOT_DOCS so it ships in the archive. B-034 in `docs/spec.md` makes the toolkit affordance contractual.

### 2. Add an example completed generated project or equivalent snapshot

Work:
- Keep one tiny instantiated example or a maintained snapshot of filled placeholders.

Acceptance:
- Consumers can compare template form to instantiated form concretely.

**Resolved (v1.32.1, B-035):** `scripts/render-example.sh` produces a deterministic, fully-substituted instantiation on demand (default `~/Downloads/phoenixproject-example/`; override via `OUT_DIR`). Canonical substitution map covers all 10 B-024 placeholders with obviously-example values. Substitution-logic invariant matches `scripts/smoke-test.sh` phase 3 byte-for-byte. Picked the script-only shape over a static-committed `example-project/` directory + CI drift-check — same comparison affordance at materially lower maintenance cost. If static-committed becomes wanted later, renderer becomes the CI re-render source.

### 3. Consider a one-shot bootstrap helper only if it genuinely reduces current manual risk

Candidate:
- `scripts/new-project.sh <slug> <package>`

Reason:
- Placeholder substitution is still manual and error-prone.
- But any automation here should be justified by real bootstrap friction, not by a desire to script everything.

Acceptance:
- Either a clear helper is shipped, or the repo explicitly decides the manual path is acceptable for now.

**Resolved (v1.32.2, D-017): deferred.** Manual bootstrap path documented in `BOOTSTRAP.md` is sufficient given adjacent work that shipped this trio: `scripts/render-example.sh` (B-035) shows consumers the substituted output in one command; `MIGRATION.md` (B-034) gives a non-bootstrap path for selective import; `templates/manifest.yaml` (B-032) makes the per-file placeholder set machine-readable for consumers who want to script their own substitution. Remaining friction (typing `mv` + `sed` once per new project) is small vs. the cost of building, testing, and maintaining a helper covering the `gh repo create` / branch-protection / merge-settings flows reliably. Full Chose / Considered / Why / Failure-mode analysis covers four options (a defer chosen; b thin substitution-only helper deferred-but-not-rejected as cheapest revisit path; c full helper rejected on `gh`-side fragility; d gated-by-flag rejected on principle). Trigger for revisit: adoption friction observable in the wild — option (b) is the cheapest first step at that point.

## Suggested Execution Order

1. Phase 1
2. Phase 2
3. Phase 3
4. Phase 4
5. Phase 5

## Suggested Claude Work Packages

### 1. Fix active doc regressions and do a post-split sweep

Includes:
- fix the stale `WORKFLOW.md` env-metadata wording
- audit root active docs against current frozen behavior

### 2. Tighten the new documentation architecture

Includes:
- canonical ownership cleanup
- duplication audit outside C4 regions
- settle the long-term role of `PROJECT_STARTER.md`

### 3. Extend drift-detection coverage

Includes:
- expand C4 only where justified
- add narrow active-doc versus spec consistency checks
- evaluate focused smoke-test additions

### 4. Formalize inventory and preset boundaries

Includes:
- machine-checkable manifest
- core versus optional versus preset-specific classification
- `_common` versus preset design
- bootstrap-mode decision

### 5. Improve incremental adoption UX

Includes:
- migration guidance
- example instantiated project
- evaluate `scripts/new-project.sh`

## Recommendation

Do not spend the next cycle on new language presets yet. First:

1. fix the active-doc regression from the latest review,
2. finish stabilizing the post-split doc architecture,
3. extend automation around the remaining drift gaps,
4. and only then formalize preset boundaries for multi-preset growth.

---

## Plan status: closed (2026-05-19)

All five phases of the Codex improvement plan are resolved:

| Phase | Status | Resolution |
|---|---|---|
| Phase 1 — fix active doc regressions | done | v1.26.x |
| Phase 2 — tighten documentation architecture | done | v1.18.0 / v1.27.1 / v1.29.2 |
| Phase 3 — extend drift-detection automation | done | v1.27.0 / v1.29.x / v1.29.3 |
| Phase 4 — formalize inventory + preset boundaries | done | v1.30.0 / v1.31.x (incl. D-016 for §4.4) |
| Phase 5 — improve adoption UX | done | v1.32.0 / v1.32.1 / v1.32.2 (incl. D-017 for §5.3) |

Future roadmap work — actual `_common/` + `presets/python-uv/` file move (gated by B-030); second language preset; new failure modes that emerge in real-world adoption — is outside the Codex plan's scope and tracked separately in `docs/spec.md` "Open project-level decisions."
