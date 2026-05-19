# Codex Improvement Plan

## Status

Closed on 2026-05-19.

The original Codex improvement plan is complete. Phases 1 through 5 were resolved across v1.9.0 through v1.32.2, and the repo now has explicit closure recorded in `docs/spec.md` via D-017.

## What Was Delivered

The plan’s major outcomes are now shipped:

1. The template’s bootstrap path is real: export works, the Python preset ships, deploy dirtiness checks are correct, and doc references were reconciled.
2. The template is de-personalized: source-project branding and baked-in vendor assumptions were removed or explicitly labeled.
3. Environment metadata is explicit: `.env.example` uses `@directive` comments with a shared parser, and the old prose-driven / sidecar validator model is gone.
4. Documentation architecture is split and clarified: `PROJECT_STARTER.md` is a thin index, companion docs own their areas, and the active spec is separated from historical-superseded content.
5. Drift-detection automation exists: rule-consistency, doc-reference, placeholder, spec-consistency, and manifest linters all ship and run in CI.
6. Inventory and preset-boundary groundwork exists: `templates/manifest.yaml` is authoritative, `presets/PRESET_ARCHITECTURE.md` defines the future layered model, and bootstrap modes were explicitly deferred.
7. Adoption UX exists beyond greenfield bootstrap: `README.md`, Known Limitations, `MIGRATION.md`, and `scripts/render-example.sh` cover first contact, selective import, and “show me a rendered project” use cases.
8. The one-shot `new-project.sh` helper was explicitly revisited and deferred by D-017 rather than left as silent roadmap debt.

## Remaining Work

The old Codex plan is done, but there is still future roadmap work outside its scope.

### 1. Implement the layered preset structure

Current state:
- The design exists in [`presets/PRESET_ARCHITECTURE.md`](presets/PRESET_ARCHITECTURE.md).
- The actual `_common/` and `presets/python-uv/` file move has not happened yet.

Still to build:
- create `_common/`
- move stack-agnostic assets into `_common/`
- create `presets/python-uv/`
- move Python-specific assets there
- update export, manifest, smoke-test, and lint wiring to compose the layered structure instead of the current flat `templates/` tree

Why this matters:
- This is the real foundation for multi-preset growth.

### 2. Add a second preset

Current state:
- Python/uv/FastAPI/VPS is still the only shipped preset.

Still to build:
- choose the next preset (`node-pnpm`, `go`, or `no-runtime`)
- implement it against the B-030 architecture
- make CI and smoke coverage exercise more than one preset

Why this matters:
- The architecture is only truly proven once a second preset exists.

### 3. Revisit bootstrap modes only after layered presets are real

Current state:
- Deferred explicitly by D-016.

Still to decide later:
- whether `--mode` exists at all
- whether modes are orthogonal to `--preset`
- whether shapes like `docs-only` or `python-local-only` are worth supporting in tooling instead of only through migration guidance

Why this matters:
- Mode design should be validated against actual multi-preset reality, not guessed in advance.

### 4. Revisit `scripts/new-project.sh` only if adoption friction shows up in real use

Current state:
- Deferred explicitly by D-017.
- `BOOTSTRAP.md`, `MIGRATION.md`, `templates/manifest.yaml`, and `scripts/render-example.sh` together make the current manual path acceptable.

Possible future path:
- if real adopters report bootstrap friction, the first revisit should be the thin substitution-only helper, not the full GitHub-side orchestration script

Why this matters:
- The expensive part is not placeholder replacement; it is reliably automating `gh`-side repo creation and settings without becoming wrong for most users.

### 5. Continue fixing new drift or failure modes as they appear

Current state:
- The repo now has strong prevention against known drift classes.

Still true:
- future regressions can create new classes the current linters do not cover
- those should be handled case-by-case in `docs/spec.md`, not by reopening the old Codex plan wholesale

## Recommended Next Focus

If development continues, the highest-value next step is:

1. implement `_common/` plus `presets/python-uv/`,
2. then ship one second preset,
3. then re-evaluate bootstrap modes and helper tooling against that real structure.

## Source Of Truth

For future work, treat these as authoritative instead of this closed plan:

- [`docs/spec.md`](docs/spec.md)
  - active frozen behavior
  - Decision log
  - Open project-level decisions
- [`presets/PRESET_ARCHITECTURE.md`](presets/PRESET_ARCHITECTURE.md)
  - future layered preset design
- [`CHANGELOG.md`](CHANGELOG.md)
  - what already shipped, in order
