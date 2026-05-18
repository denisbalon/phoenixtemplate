# Codex Improvement Plan

## Goal

Turn `phoenixprojecttemplate` from a strong personal workflow kit into a reliable reusable template. The priorities are:

1. Remove trust breaks.
2. Make the happy path real.
3. Reduce hidden coupling and duplicated policy text.
4. Make the product boundary explicit.
5. Add automation that catches future drift.

## Phase 0: Success Criteria

Define done before changing anything.

1. A brand-new user can bootstrap a fresh repo from this template and get to `make dev`, `make test`, and passing CI without inventing missing files.
2. Every command recommended in `PROJECT_STARTER.md` exists and works as documented.
3. Every path referenced in docs exists, or is clearly marked as an example only.
4. The template’s actual scope is explicit: either “Python/uv/FastAPI/VPS starter” or “multi-preset starter”.
5. Workflow rules have one canonical source, not several hand-synchronized copies.
6. The repo has automated checks that catch doc/path/template drift.

## Phase 1: Fix Trust-Breaking Gaps

These are highest priority because they make the template misleading today.

### 1. Implement or remove `scripts/export-starter.sh`

Reason:
- `PROJECT_STARTER.md` recommends it as the quick path.
- `docs/spec.md` explicitly admits it is missing.

Work:
- Either ship `scripts/export-starter.sh` now.
- Or delete all recommendation text that presents it as available.
- If deferred, mark it clearly as planned, not shipped.

Acceptance:
- Running the documented export command works exactly as described.
- Or no shipped doc recommends it.

### 2. Ship a minimal runnable Python preset

Reason:
- Current setup assumes a project skeleton that is not included.
- `templates/docs/setup.md`, `templates/.github/workflows/ci.yml`, and `templates/scripts/deploy.sh` all assume Python files that do not ship.
- `docs/spec.md` already lists this as missing.

Work:
- Add `templates/pyproject.toml`.
- Add `templates/src/<package>/app.py` or equivalent minimal app.
- Add `templates/tests/test_smoke.py`.
- Add any package init files needed.
- Ensure `make dev`, `make test`, CI, and deploy skeleton all target the same file layout.

Acceptance:
- A fresh project created from the template can run `uv sync`, `make test`, and CI without extra manual scaffolding.

### 3. Fix the deploy cleanliness check

Reason:
- `templates/scripts/deploy.sh` only checks `git diff --quiet`.
- That misses staged-but-uncommitted changes and untracked files.

Work:
- Replace the cleanliness check with a full repository cleanliness test.
- Decide whether untracked files should block deploy by default.
- Document the exact policy in the script header and runbook.

Acceptance:
- Dirty deploy detection matches documented policy.
- Staged-only changes are caught.
- Untracked behavior is explicit.

### 4. Reconcile all recommended paths with actual shipped files

Reason:
- This repo already had path drift in review flow docs.
- Similar breakage can exist elsewhere.

Work:
- Audit every command, file path, and filename mentioned in:
  - `PROJECT_STARTER.md`
  - `templates/README.md`
  - `templates/CONTRIBUTING.md`
  - `templates/CLAUDE.md`
  - `templates/docs/*`
- For each reference, do one of:
  - ship the referenced file,
  - change wording to example-only,
  - or remove the reference.

Acceptance:
- No doc points at a missing file or command unless explicitly labeled illustrative.

## Phase 2: Narrow or Reframe the Template Scope

The template currently claims broader reuse than it earns.

### 1. Decide the product identity

Choices:
- Option A: Python/uv/FastAPI/VPS starter.
- Option B: multi-preset project starter.

Recommendation:
- Choose Option A immediately for honesty.
- Build toward Option B later.

Work:
- Update README and top-level framing.
- Remove or soften project-agnostic claims until presets exist.

Acceptance:
- Top-level positioning matches what the repo actually ships.

### 2. If staying Python-first, make that explicit everywhere

Reason:
- The repo says stack-agnostic work is still open.
- Many surfaces still imply broad generality.

Work:
- Add a short Current Scope section in README and `PROJECT_STARTER.md`.
- State that the current shipped preset is Python/uv/FastAPI/VPS-shaped.
- Keep future presets as roadmap, not current fact.

Acceptance:
- A new reader cannot mistake the current artifact for a neutral multi-language starter.

### 3. Define preset architecture before adding more languages

Work:
- Specify `_common` vs preset boundaries.
- Decide which files are common:
  - workflow docs
  - review rubric
  - changelog format
  - env bootstrap core
- Decide which files are preset-specific:
  - Makefile
  - CI
  - deploy script
  - setup doc
  - runtime pin
  - sample source tree

Acceptance:
- There is a design doc for preset boundaries before more scaffolding is added.

## Phase 3: De-Personalize the Template

Remove inherited assumptions from the original app.

### 1. Remove hardcoded product identity from `bootstrap.sh`

Reason:
- The script still prints `phoenixtgstat_bot`.

Work:
- Derive display name from repo directory, env, or a placeholder.
- Avoid origin-project branding in generic flows.

Acceptance:
- No shipped generic script names a source project.

### 2. Remove baked-in service-specific validators from the generic env bootstrapper

Reason:
- The bootstrap script hardcodes Telegram, Meta, and Keitaro validators.

Work:
- Move validators into a project-specific config file or metadata file.
- Keep only truly generic validators in core.
- Let consuming projects extend validator maps explicitly.

Acceptance:
- The generic bootstrapper has no ad hoc service names hardcoded.
- Project-specific validators live in a deliberate extension point.

### 3. Audit docs for source-project residue

Work:
- Search for app-specific nouns, vendor assumptions, and domain-specific phrasing.
- Keep only examples clearly marked as examples.

Acceptance:
- Remaining vendor-specific text is either example-only or belongs to a named preset.

## Phase 4: Simplify the Documentation Architecture

The docs are useful but too duplicated.

### 1. Choose one canonical source for workflow policy

Current problem:
- `gogogo!` gate, action verbs, version-bump rule, PR flow, and review flow are mirrored across multiple files.

Recommendation:
- Make `PROJECT_STARTER.md` the canonical source for template authoring.
- Generate or extract project-facing `CONTRIBUTING.md` and `CLAUDE.md` sections from it.

Alternative:
- Make `templates/CONTRIBUTING.md` canonical for workflow rules and keep `PROJECT_STARTER.md` as explanation and rationale only.

Acceptance:
- One file owns normative wording.
- Other files quote or derive from it, not hand-copy it.

### 2. Split `PROJECT_STARTER.md` into focused docs

Reason:
- It is over 1000 lines.

Recommended split:
- `BOOTSTRAP.md`
- `WORKFLOW.md`
- `TEMPLATE_INVENTORY.md`
- `DEPLOY_BASELINE.md`
- `HARNESS_QUIRKS.md`
- `PROJECT_STARTER.md` as index and overview

Acceptance:
- A new reader can find bootstrap, workflow, and deploy information without scrolling through everything else.

### 3. Separate current rules from historical rationale

Reason:
- `docs/spec.md` mixes active and superseded behavior inline.

Work:
- Keep active blocks in the main section.
- Move superseded blocks to a Historical Blocks appendix.
- Keep decision log as permanent archive.

Acceptance:
- A reader can understand current policy without filtering history first.

### 4. Reduce prose duplication between `PROJECT_STARTER.md`, `templates/CONTRIBUTING.md`, and `templates/CLAUDE.md`

Work:
- `CONTRIBUTING.md` should be short, normative, operational.
- `CLAUDE.md` should be short, session-facing, agent-oriented.
- `PROJECT_STARTER.md` should explain why and how.

Acceptance:
- Each document has a distinct role and little overlap.

## Phase 5: Make Environment and Bootstrap Metadata Explicit

Right now behavior is hidden inside comments.

### 1. Replace Optional comment parsing with explicit metadata

Current issue:
- `bootstrap.sh` and `check-env.sh` infer required/optional from comment text.

Work:
- Design an explicit metadata format.

Options:
- inline annotations in `.env.example`
- separate `env.schema`
- structured YAML/JSON metadata

Recommendation:
- Use a separate simple schema file if validators, optionality, descriptions, and masking rules need to scale.

Acceptance:
- Required/optional status does not depend on English wording.

### 2. Move validation rules into metadata too

Work:
- Define per-var fields:
  - required
  - default
  - validator regex or validator type
  - sensitive
  - description
  - source instructions

Acceptance:
- `bootstrap.sh` and `check-env.sh` read the same explicit schema.

### 3. Decide whether `.env.example` remains source of truth or becomes rendered artifact

Recommendation:
- Source of truth should be structured metadata.
- `.env.example` can be generated from it.

Acceptance:
- One authoritative env definition model exists.

## Phase 6: Rework the Workflow Policy to Be Reusable

Current rules are coherent but too rigid as a default.

### 1. Revisit spec before code as a universal mandate

Current rule:
- Spec update before any code is written.

Risk:
- Too heavy for small fixes, spikes, internal refactors, and bootstrap work.

Recommendation:
- Keep it as default for feature work.
- Allow lighter flows for trivial changes.

Acceptance:
- Workflow supports both high-discipline and low-friction changes without contradiction.

### 2. Revisit ANY change means version bump

Current rule:
- Any change bumps version.

Risk:
- Excessive noise for docs-only edits, typo fixes, and internal clarifications.
- Encourages changelog churn.

Recommendation:
- Define what counts as a releasable change.
- Optionally keep strict mode for production repos and lighter mode for templates/internal tooling.

Acceptance:
- Versioning policy aligns with actual release semantics.

### 3. Revisit push after every commit

Current rule:
- No local-only commits.

Risk:
- Useful for machine-swap safety, but rigid for experimental or disconnected work.

Recommendation:
- Make it a strong default, not an absolute invariant.
- Clarify exceptions if any.

Acceptance:
- The template distinguishes hard safety requirements from personal preference.

### 4. Decide whether `gogogo!` is a universal template default or a personal operating mode

Current rule:
- `gogogo!` is mandatory gate syntax.

Risk:
- Very opinionated and unusual for broader adoption.

Recommendation:
- Keep it if the product is explicitly a Denis-style workflow starter.
- Otherwise make it a selectable policy mode.

Acceptance:
- The gate is either clearly part of the brand or clearly optional.

### 5. Define workflow profiles

Recommended profiles:
- `strict`: current behavior
- `standard`: spec for features, version bump for releases, push regularly
- `lite`: minimal policy scaffolding

Acceptance:
- Different teams and projects can adopt the template without inheriting all-or-nothing process.

## Phase 7: Improve the Review System Design

This area is much better now, but can still be cleaned up.

### 1. Collapse review rules into a single canonical rubric artifact plus one short workflow pointer

Work:
- Keep the detailed rubric in one place.
- Keep workflow docs brief: open PR, run reviewer, reviewer posts per-commit comments.

Acceptance:
- Review behavior is documented once.

### 2. Add repo-level tests for review-doc consistency

Work:
- Check that review doc paths exist.
- Check that no active workflow doc mentions removed review verbs or tools.
- Check that transport wording matches canonical rule.

Acceptance:
- Review-flow drift gets caught automatically.

### 3. Decide how much reviewer-specific wording belongs in historical docs

Work:
- Keep old decisions for audit trail.
- Reduce how often current readers see obsolete mechanism details.

Acceptance:
- Historical context remains available without crowding active policy.

## Phase 8: Make the Template Self-Testing

This is the biggest leverage improvement after Phase 1.

### 1. Add a template smoke test

Work:
- Create a script that instantiates a temp project from the template.
- Replace placeholders with dummy values.
- Run:
  - bootstrap validation
  - `uv sync`
  - `make test`
  - `make lint`
  - optionally `make dev` smoke

Acceptance:
- CI proves the template can produce a runnable minimal project.

### 2. Add a doc reference linter

Work:
- Parse docs for local file references and verify existence.
- Verify executable commands mentioned as recommended actually exist.

Acceptance:
- Missing-path drift is caught in CI.

### 3. Add a placeholder linter

Work:
- Enumerate allowed placeholders.
- Fail CI if unresolved placeholders appear in files that are supposed to be concrete in this repo.
- Allow placeholders in templates intentionally.

Acceptance:
- Placeholder discipline is explicit.

### 4. Add a consistency linter for canonical workflow phrases

Examples:
- `gogogo!` clarification choices
- review transport wording
- PR and merge triggers
- version-bump wording

Acceptance:
- Known drift-prone phrases are checked automatically.

## Phase 9: Improve the File and Template Inventory

The template inventory is useful but should become executable.

### 1. Convert template inventory into a machine-checkable manifest

Work:
- Create a manifest of shipped template files, purpose, placeholders, and preset ownership.

Acceptance:
- Docs can derive from the manifest.
- CI can verify that documented files actually exist.

### 2. Add required vs optional template parts

Work:
- Mark which files every project should copy.
- Mark which files are Python-only or deploy-only.

Acceptance:
- Consumers know what is core versus optional.

### 3. Add bootstrap modes

Examples:
- `full-python-vps`
- `python-local-only`
- `docs-only`

Acceptance:
- Users can start from a right-sized subset.

## Phase 10: Improve the Developer Experience

These are not blockers, but they make the template easier to trust and adopt.

### 1. Add a real quickstart at repo root

Work:
- 60-second summary of what this is, who it is for, current scope, and what works today.

Acceptance:
- New users do not need to reverse-engineer the repo from long docs.

### 2. Add a known limitations section

Work:
- Say explicitly what is not yet generic.
- Say what remains manual.

Acceptance:
- Users are not surprised by missing pieces.

### 3. Add migration guidance for existing projects

Work:
- Explain how to adopt parts of the template incrementally.

Acceptance:
- Template is usable as a toolkit, not only full bootstrap.

### 4. Add examples of a completed generated project

Work:
- Keep one tiny example app or snapshot.

Acceptance:
- Consumers can compare template form to filled-in form.

## Phase 11: Clean Up the Spec Structure

The spec is good, but it can be easier to operate.

### 1. Move superseded blocks into an appendix

Targets:
- Superseded review-flow blocks in `docs/spec.md`.

Acceptance:
- Main frozen section contains only active blocks.

### 2. Shorten rationale where it duplicates decision log

Acceptance:
- Blocks stay atomic and current.
- Decisions hold long narrative.

### 3. Add a current active invariants index

Acceptance:
- Readers can skim active rules quickly.

## Phase 12: Decide What This Product Is

This is the strategic step.

### 1. Pick one product identity

Choose one:
- A personal high-discipline starter with strong workflow opinions.
- A Python/VPS starter for solo production projects.
- A general-purpose multi-preset project template framework.

### 2. Remove features and claims that do not support the chosen product

Reason:
- The repo is partially all three right now.

### 3. Write a product boundary statement

It should answer:
- Who is this for?
- What does it ship today?
- What does it not try to do?
- What workflow assumptions are opinionated rather than universal?

## Suggested Execution Order

1. Phase 1
2. Phase 8 items 1 to 3
3. Phase 2
4. Phase 3
5. Phase 4
6. Phase 5
7. Phase 6
8. Phase 9
9. Phase 10
10. Phase 11
11. Phase 12

## Suggested Claude Work Packages

### Package 1: Make the template honest and runnable

Includes:
- export script issue
- minimal Python preset
- deploy dirtiness fix
- doc/path reconciliation

### Package 2: De-personalize and modularize bootstrap/env handling

Includes:
- generic bootstrap core
- explicit env metadata
- validator extraction

### Package 3: Refactor docs into canonical sources

Includes:
- split `PROJECT_STARTER.md`
- reduce duplication
- move historical blocks out of active spec
- inventory manifest

### Package 4: Add template self-tests

Includes:
- generated-project smoke test
- doc/path linter
- placeholder linter
- workflow consistency linter

### Package 5: Reframe product scope and workflow modes

Includes:
- current-scope rewrite
- strict, standard, and lite modes
- product boundary statement
- preset roadmap

## Recommendation

Do not start with doc cleanup.

Start with honesty and runnable bootstrap:

1. ship the missing runnable preset,
2. stop recommending missing scripts,
3. fix deploy correctness,
4. and add smoke tests.

Everything else gets easier once the template can prove it works.
