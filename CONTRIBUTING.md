# Contributing to phoenixtemplate

This file is for working on **this meta repo** — the template kit itself. For working on a consumer project bootstrapped from this template, see `templates/CONTRIBUTING.md` (the per-project operational doc that ships with each bootstrap).

## Workflow

Read [`WORKFLOW.md`](WORKFLOW.md) — it's the canonical source for the workflow rules (the propose-and-confirm `gogogo!` gate, on-branch per-node cadence with N≥1 commits per branch, version-bump, branching, PR/merge flow, review flow, conventions). This meta repo follows the same rules as any consumer project, with the meta-specific overrides below.

## Meta-repo specifics (overrides vs. consumer projects)

- **Deploy is a no-op** (per B-005 in `docs/spec.md`). The merge `gogogo!` is still atomic over three sub-steps (`gh pr merge --rebase --delete-branch` → `git checkout main && git pull --ff-only origin main` → deploy) but the deploy sub-step is documented-as-no-op rather than skipped, because this repo ships docs + templates, not a running service. The "release" is `main` being up to date.
- **Pre-push hook activation** — run `git config core.hooksPath .githooks` once per fresh clone of this meta-repo to enable the `.githooks/pre-push` block on direct pushes to `main`. (The kit has no top-level `Makefile`; consumer projects get a `make install-hooks` target via `templates/Makefile`.)
- **Version markers:** just `VERSION` at the repo root. There's no `pyproject.toml` or `src/<package>/__init__.py` at meta level — those are template content shipped under `templates/`.
- **CI:** the meta repo's CI is [`.github/workflows/template-self-test.yml`](.github/workflows/template-self-test.yml), which runs `scripts/smoke-test.sh` on every push/PR. Don't confuse with `templates/.github/workflows/ci.yml` — that's the CI workflow shipped to consumer projects.
- **Review:** out-of-band per B-010 — same as consumer projects. User runs Codex (or any reviewer) in a separate terminal against the open PR + `docs/pr_review_instructions.md` (resolves to `templates/docs/pr_review_instructions.md` for this repo per the `docs/pr_review_instructions.md` pointer file).
- **Tracked artifacts unique to the meta repo:** `PROJECT_STARTER.md` (the template kit's master doc), `docs/spec.md` (this repo's own spec, written in the same Block format consumer projects use), `codex improvement plan.md` (Codex's working roadmap; intentionally not consumer-facing), `scripts/export-starter.sh` + `scripts/smoke-test.sh` (meta tooling, not shipped to consumers).

## Doc tiers (per B-021)

When you touch a workflow rule, remember the three-tier model:

- `WORKFLOW.md` is **canonical** for the rule + rationale (was `PROJECT_STARTER.md §2` before v1.25.0).
- `templates/CONTRIBUTING.md` carries the per-project operational version (and the rule statement again, for defensive redundancy).
- `templates/CLAUDE.md` carries the session-facing summary (and the rule statement again, because the AI needs it in working context).

Changes to a rule statement land in **all three places** in the same commit. The C4 consistency linter (`scripts/check-rule-consistency.sh`) catches drift automatically.
