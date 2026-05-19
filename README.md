# phoenixprojecttemplate

A reusable bootstrap kit for new software projects worked on with **Claude Code**. Each new project starts from a known-good baseline instead of re-deriving workflow, structure, and conventions every time.

**Current shipped scope:** Python/uv/FastAPI/VPS starter. Multi-preset (Node, Go, no-runtime) is roadmap, not shipped today. See [`PROJECT_STARTER.md §0.1`](PROJECT_STARTER.md#01-current-scope) for the exact boundary.

## What you get

Two layers with different scopes:

| Layer | Scope | Contents |
|---|---|---|
| **Process** (stack-agnostic) | Any project | `gogogo!` passphrase gate with propose-and-confirm semantics (Claude proposes concretely, user `gogogo!`s the proposal), 5-step atomic release sequence, spec-block format (`B-NNN` blocks + Decision log), Karpathy's four LLM-coding pitfalls as standing rules, reviewer-agnostic PR review rubric. |
| **Python preset** (Python-only today) | Python/uv/FastAPI/VPS | Minimal FastAPI app + smoke test, `pyproject.toml` (PEP 735 dependency groups, hatchling, ruff/mypy/pytest config), `Makefile`, GitHub Actions CI, VPS rsync `scripts/deploy.sh` with `/healthz` curl, interactive env-bootstrap with `@directive` schema. |

Plus meta tooling: `scripts/export-starter.sh` (portable kit archive), `scripts/smoke-test.sh` + `.github/workflows/template-self-test.yml` (proves the template instantiates end-to-end on every push/PR).

## Quickstart

From this repo (the source of truth):

```sh
./scripts/export-starter.sh
# writes ~/Downloads/project-starter-v<VERSION>-<DATE>.tar.gz (always)
# and matching .zip (if `zip` is installed)
```

In your new project's empty directory:

```sh
tar -xzf ~/Downloads/project-starter-v*.tar.gz --strip-components=1
chmod +x scripts/*.sh
```

Then follow [`PROJECT_STARTER.md §1` "Bootstrap checklist"](PROJECT_STARTER.md#1-bootstrap-checklist-zero--first-commit) for the rest: placeholder substitution (`<package_name>`, `<PROJECT_NAME>`, `<GITHUB_USER>`, `<HOST>`, `<DOMAIN>`), `uv lock && git add uv.lock`, `gh repo create`, branch protection, first commit.

## Known limitations

What's missing or manual today vs. the polished end state. For the active roadmap see [`docs/spec.md` "Open project-level decisions"](docs/spec.md).

- **Placeholder substitution is manual.** After unpacking the kit, you need to run one `mv` (rename `src/<package_name>/` to your actual package name) plus one `sed` across `.py` / `.toml` / `Makefile` / `.yml` / `.sh` / `.example` files for `<package_name>`, plus similar manual edits for `<PROJECT_NAME>`, `<GITHUB_USER>`, `<HOST>`, `<DOMAIN>`, `<PROJECT_DESCRIPTION>`, `<COPYRIGHT_HOLDER>`, `<YEAR>`. `bootstrap.sh` only handles `.env` credential prompting today — it does **not** do placeholder substitution. Open item #3 (`scripts/new-project.sh`) automates this.
- **Single language preset.** Only Python/uv/FastAPI/VPS ships today. Multi-preset (Node/pnpm, Go, no-runtime) is roadmap per D-009 — not shipped.
- **`PROJECT_STARTER.md` split is in progress.** Four of five companion files ship at repo root: [`TEMPLATE_INVENTORY.md`](TEMPLATE_INVENTORY.md) (was §3+§4, v1.22.0), [`DEPLOY_BASELINE.md`](DEPLOY_BASELINE.md) (was §6+§7+§13, v1.22.0), [`HARNESS_QUIRKS.md`](HARNESS_QUIRKS.md) (was §12+§14, v1.22.0), and [`WORKFLOW.md`](WORKFLOW.md) (was §2+§9+§10+§11, v1.25.0 — now canonical for the gate + workflow rules per B-021). Still to come: `BOOTSTRAP.md` (zero-to-first-commit, v1.26.0). PROJECT_STARTER.md is now ~435 lines and shrinks to a thin index in v1.26.0.
- **Drift detection is mostly mechanical now.** Three linters guard the canonical docs: rule-consistency (B-022), doc-reference (B-023), and placeholder (B-024). All three run on every push/PR via `template-self-test.yml`. The smoke test (B-014) covers runtime drift. Remaining manual-audit territory: the "explicit example" / "prescriptive recommendation" sub-categories of B-016 that no machine check covers cleanly.
- **Windows requires WSL.** The shipped `src/<package_name>/` directory has angle-bracket characters that aren't valid Windows filenames; bash scripts everywhere assume POSIX shell. Per D-009 the target deployment is Linux/VPS — Windows isn't a first-class target.

## Docs

| Topic | Doc |
|---|---|
| **Start here** — bootstrap checklist, decisions, audit trail | [`PROJECT_STARTER.md`](PROJECT_STARTER.md) |
| Workflow + gate + propose-and-confirm contract + conventions + PR review rubric | [`WORKFLOW.md`](WORKFLOW.md) |
| File layout + `templates/` reference | [`TEMPLATE_INVENTORY.md`](TEMPLATE_INVENTORY.md) |
| VPS deploy baseline + CI/CD + credential handling | [`DEPLOY_BASELINE.md`](DEPLOY_BASELINE.md) |
| Claude Code harness gotchas + `bootstrap.sh` design | [`HARNESS_QUIRKS.md`](HARNESS_QUIRKS.md) |
| Frozen behavior (Block format) + Decision log + open items | [`docs/spec.md`](docs/spec.md) |
| Per-version changelog | [`CHANGELOG.md`](CHANGELOG.md) |
| PR review rubric (used by Codex, `/ultrareview`, manual, or any reviewer) | [`docs/pr_review_instructions.md`](docs/pr_review_instructions.md) |

---

**Status:** v1 in active development. Current version is whatever [`VERSION`](VERSION) says. Open items + roadmap live in [`docs/spec.md` "Open project-level decisions"](docs/spec.md).
