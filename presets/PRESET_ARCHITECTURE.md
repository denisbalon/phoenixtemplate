# Preset Architecture

The design for how `phoenixprojecttemplate` will support multiple language presets — Python/uv/FastAPI/VPS today (per D-009); Node/pnpm, Go, no-runtime as roadmap. **Design only as of v1.30.0; no `_common/` or `presets/python-uv/` directory implementation yet.** Adding actual presets is separate work gated by this architecture (B-030 + D-015 in `docs/spec.md`).

## Goal

Make multi-preset expansion mechanical: a consumer picks one preset at bootstrap time, the (current or future) bootstrap automation assembles the right files. Today the kit ships only Python/uv/FastAPI/VPS — files in `templates/` are written assuming that stack. Future presets need to share stack-agnostic content (workflow, gate, conventions, spec format) without duplicating it per preset; per-preset content (Makefile, CI, deploy script, runtime pin, sample source tree) lives separately.

## Layer model

Two layers, composed at bootstrap time:

### `_common/` — shared across all presets

Stack-agnostic content; applies to every project regardless of language / runtime / deployment target.

Owned by `_common/`:

- **Workflow + gate.** `WORKFLOW.md` (canonical workflow rules + rationale), template versions of `CONTRIBUTING.md` and `CLAUDE.md` (the per-project + AI-session-facing tiers of the B-021 trio). The four C4-anchored regions (`gate-clause`, `proposal-format`, `bare-gogogo`, `env-metadata-contract`) are stack-agnostic — every project uses propose-and-confirm regardless of language.
- **Spec-block format.** `templates/docs/spec.md` skeleton + `templates/.claude/skills/spec-block/SKILL.md` for the B-NNN authoring convention.
- **Review rubric.** `templates/docs/pr_review_instructions.md` — reviewer-agnostic per B-010; applies to any project.
- **Changelog conventions.** Per-version diary structure + the version-bump rule (B-002).
- **Env-bootstrap core.** `templates/scripts/_env-schema-parse.sh` (shared parser), `templates/scripts/bootstrap.sh` (interactive populator), `templates/scripts/check-env.sh` (CI env-gate). The `@directive` schema (B-020) is stack-agnostic.
- **Karpathy standing rules.** `templates/docs/karpathy-claude-rules.md` + the `## Coding pitfalls` block inside `templates/CLAUDE.md`.
- **Meta scaffolding.** `templates/.gitignore` (common ignores like `.env`, OS junk), `templates/.claude/settings.json` (gate permissions + `SessionStart` hook), `templates/CHANGELOG.md` skeleton.

### `presets/<preset-name>/` — preset-specific

Content that varies by language / runtime / deployment target. Each preset directory holds its own:

- **Runtime pin** — `.python-version` (Python preset), `.nvmrc` (Node), `.tool-versions` (Go via `asdf`), etc.
- **Project metadata file** — `pyproject.toml` (Python), `package.json` (Node), `go.mod` (Go), nothing (no-runtime preset).
- **Build / test / lint Makefile** — commands per stack (`uv run pytest` vs `pnpm test` vs `go test ./...`).
- **CI workflow** — `.github/workflows/ci.yml`. Three gates (lint / typecheck / test) using stack-appropriate tools.
- **Deploy script** — `scripts/deploy.sh`. Shape varies dramatically (`rsync src/` to VPS vs `docker build && docker push` vs `fly deploy`).
- **Sample source tree** — `src/<package_name>/` Python layout vs `src/index.ts` Node entry vs `cmd/<binary>/main.go` Go.
- **Sample smoke test** — `tests/test_smoke.py` Python vs `tests/smoke.test.ts` Node vs `*_test.go` Go.
- **Setup expectations doc** — `docs/setup.md`'s prereqs section varies per stack.

## Composition rule

A bootstrapped project's file tree = `_common/` contents + `presets/<chosen>/` contents flattened together at the project root. The (future) bootstrap tooling reads from both, places files into the new project.

Constraints (frozen by B-030):

1. **Single preset per project.** A project picks exactly one preset at bootstrap time. Mixed-preset projects are out of scope.
2. **No file conflicts between layers.** `_common/` and any individual preset MUST NOT both declare the same file path. Each file has exactly one owner. If a future preset needs a path `_common/` claims, the layer model breaks — needs redesign or move the file to preset-specific.
3. **Uniform placeholders.** `<package_name>`, `<PROJECT_NAME>`, `<HOST>`, `<DOMAIN>`, `<COPYRIGHT_HOLDER>`, `<YEAR>`, `<GITHUB_USER>`, `<PROJECT_DESCRIPTION>`, `<PACKAGE_NAME>`, `<PROJECT_SLUG>` (the B-024 canonical set) work the same way across all presets. Substitution rules + the placeholder linter remain uniform.
4. **C4 regions live in `_common/`.** The byte-exact rule statements (per B-021's three-tier model + B-022's linter) are stack-agnostic. Presets don't override them. The C4 linter's `FILES` array points at `_common/` files; presets' workflow + gate text matches by inheriting `_common/`, not by re-declaring.

## What's deferred (not in this commit's scope)

- **Actual `_common/` + `presets/python-uv/` directory creation.** Moving files from `templates/` into the new layout is separate work gated by this design. Estimated as 2-3 commits when it lands.
- **`scripts/export-starter.sh` update** to compose `_common/` + chosen preset for the archive. Currently exports `templates/` flat — needs reshaping when the new structure ships.
- **Bootstrap mode decision** (Phase 4.4 of the Codex plan) — whether bootstrap modes (`full-python-vps`, `python-local-only`, `docs-only`) sit alongside preset selection, OR replace it, OR layer over it. **Deferred per D-016 (v1.31.2)** until after the actual file move ships; the orthogonal-axes shape (`--preset` × `--mode`) is the likely long-term form when the question is revisited. See D-016's failure-mode analysis for what triggers a revisit and how Phase 5.1 migration guidance covers the `docs-only` use case in the interim.
- **Specific Node / Go / no-runtime preset content.** Each preset is its own follow-on commit set once the architecture is in place.
- **Migration of existing v1.x consumers** when `_common/` + `presets/python-uv/` actually ship. No forced migration; existing consumers keep their flat `templates/`-shaped files; new bootstraps from the release that introduces the layered structure use it. Consumers can opt to re-export later.

## Alternatives considered

- **A: Two-layer composed model** (`_common/` + `presets/<preset>/`) — chosen. See "Why" below.
- **B: Branched template repos** — each preset is a separate repo (e.g., `phoenixprojecttemplate-python`, `phoenixprojecttemplate-node`). Maximum isolation but maximum drift — each repo re-derives workflow / gate / spec-format content. Loses the AI-safety benefit of B-021's three-tier model (each branch would need its own C4 regions with no cross-branch sync).
- **C: Single tree with stack-conditional rendering** — keep one `templates/` tree, use Jinja-style placeholders like `{% if stack == 'python' %}pyproject.toml{% endif %}` for stack-specific blocks. Lower file count but harder to reason about; "view the Python preset" becomes a filtering operation; templates mixing 3+ conditional stacks notoriously hard to maintain.
- **D: Inverted naming — `_python-uv/` + `<core>/`.** Same architecture as A, naming swapped. Rejected on user-facing semantics: `presets/<name>/` matches `cookiecutter` / `copier` conventions and reads more naturally for the variable part.

## Why the layered model (A) wins

- **Clear ownership.** Each file has exactly one home. No "which copy is canonical" question.
- **Mechanically composable.** No template engine needed; the bootstrap tooling just flattens two directories. Easy to lint (each layer can be scanned independently); easy to test (smoke-test each preset = `_common/` + that preset).
- **Future-friendly.** Adding Node preset = `mkdir presets/node-pnpm/` + populate; no `_common/` edits unless the new preset surfaces a previously-Python-specific assumption to extract. Each preset author writes content for one stack without thinking about the others.
- **Migrate-friendly.** Existing v1.x consumers continue using their flat `templates/`-derived files; the new layout only affects future bootstraps. No forced upgrade.
- **AI-safety preserved.** The C4-anchored rule trio (B-022) stays in `_common/`. Every preset inherits the same gate / proposal-format / bare-gogogo / env-metadata-contract. No per-preset re-derivation; no drift surface.

## Implementation order (for future reference, not in scope here)

Suggested sequence when the actual implementation work begins:

1. Create `_common/` and move stack-agnostic files from `templates/` into it. Update doc-ref linter / export script paths.
2. Create `presets/python-uv/` and move stack-specific files. Verify smoke-test still passes.
3. Update `scripts/export-starter.sh` to compose `_common/` + chosen preset. Add a `--preset` flag (default `python-uv` for backward compatibility).
4. Update `scripts/smoke-test.sh` to test each preset separately (matrix in CI).
5. Add second preset (Node or Go) as a separate commit set — exercises the architecture.

Each step is a separate `gogogo!`-authorized proposal when its time comes.

## Spec references

- **D-009** (v1.8.0) — declared the Python-only scope; named multi-preset as roadmap.
- **B-030** (v1.30.0, frozen) — the layer model + composition rule itself.
- **D-015** (v1.30.0) — the chosen-vs-rejected-alternatives decision.
- **B-022 / B-029 / B-031** — linter framework that the layered model must remain compatible with.
- **B-024** — canonical placeholder set, which stays uniform across presets per constraint 3 above.
