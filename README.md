# phoenixtemplate

A reusable bootstrap kit for new software projects worked on with **Claude Code**. Each new project starts from a known-good baseline instead of re-deriving workflow, structure, and conventions every time.

**Current shipped scope:** Python/uv/FastAPI/VPS starter. Multi-preset (Node, Go, no-runtime) is roadmap, not shipped today. See [`BOOTSTRAP.md`](BOOTSTRAP.md) — "Current scope" section — for the exact boundary.

## What you get

Two layers with different scopes:

| Layer | Scope | Contents |
|---|---|---|
| **Process** (stack-agnostic) | Any project | `gogogo!` passphrase gate with propose-and-confirm semantics (Claude proposes concretely, user `gogogo!`s the proposal), on-branch 6-step atomic feature sequence (branch → spec → bump+CHANGELOG → code → commit+push → open PR) + atomic merge `gogogo!` (rebase-merge → pull → deploy), spec-block format (`B-NNN` blocks + Decision log), Karpathy's four LLM-coding pitfalls as standing rules, reviewer-agnostic PR review rubric, local `.githooks/pre-push` block on direct pushes to `main`. |
| **Python preset** (Python-only today) | Python/uv/FastAPI/VPS | Minimal FastAPI app + smoke test, `pyproject.toml` (PEP 735 dependency groups, hatchling, ruff/mypy/pytest config), `Makefile`, GitHub Actions CI, VPS rsync `scripts/deploy.sh` with `/healthz` curl, interactive env-bootstrap with `@directive` schema. |

Plus meta tooling: `scripts/export-starter.sh` (portable kit archive), `scripts/smoke-test.sh` + `.github/workflows/template-self-test.yml` (proves the template instantiates end-to-end on every push/PR).

## Quickstart

**Brand new to the kit?** The fastest path is via [phoenixtemplate.com](https://phoenixtemplate.com) — paste one prompt into Claude Code, answer six questions, get a working project. Or paste this directly into Claude Code in an empty directory:

> Read https://raw.githubusercontent.com/denisbalon/phoenixtemplate/main/ONBOARDING_PROMPT.md and follow it exactly to bootstrap a new project for me here. If you can't fetch URLs, ask me to enable WebFetch via `/permissions` first.

Claude reads [`ONBOARDING_PROMPT.md`](ONBOARDING_PROMPT.md), asks six setup questions, scaffolds the project, and optionally creates the GitHub repo. ~5 minutes end-to-end. **WebFetch not enabled?** Type `/permissions` in Claude Code, add `WebFetch` to the allow list, then try the paste again.

**Already have a project?** Read [`MIGRATION.md`](MIGRATION.md) instead — the kit is consumable as a toolkit (selective-import paths for the process layer, docs, env-bootstrap, or linter set), not only as a fresh-start template.

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

Then follow [`BOOTSTRAP.md`](BOOTSTRAP.md) — the "Bootstrap checklist" section — for the rest: placeholder substitution (`<package_name>`, `<PROJECT_NAME>`, `<GITHUB_USER>`, `<HOST>`, `<DOMAIN>`), `uv lock && git add uv.lock`, `gh repo create`, branch protection, first commit.

**Want to see what a rendered project looks like first?** Run `./scripts/render-example.sh` — produces a deterministic example with every placeholder substituted (output at `~/Downloads/phoenixproject-example/`; override via `OUT_DIR=`).

## Known limitations

What's missing or manual today vs. the polished end state. For the active roadmap see [`docs/spec.md` "Open project-level decisions"](docs/spec.md).

- **Placeholder substitution is manual.** After unpacking the kit, you need to run one `mv` (rename `src/<package_name>/` to your actual package name) plus one `sed` across `.py` / `.toml` / `Makefile` / `.yml` / `.sh` / `.example` files for `<package_name>`, plus similar manual edits for `<PROJECT_NAME>`, `<GITHUB_USER>`, `<HOST>`, `<DOMAIN>`, `<PROJECT_DESCRIPTION>`, `<COPYRIGHT_HOLDER>`, `<YEAR>`. `bootstrap.sh` only handles `.env` credential prompting today — it does **not** do placeholder substitution. Open item #3 (`scripts/new-project.sh`) automates this.
- **Single language preset.** Only Python/uv/FastAPI/VPS ships today. Multi-preset (Node/pnpm, Go, no-runtime) is roadmap per D-009 — not shipped.
- **Drift detection is mostly mechanical now.** Three linters guard the canonical docs: rule-consistency (B-022), doc-reference (B-023), and placeholder (B-024). All three run on every push/PR via `template-self-test.yml`. The smoke test (B-014) covers runtime drift. Remaining manual-audit territory: the "explicit example" / "prescriptive recommendation" sub-categories of B-016 that no machine check covers cleanly.
- **Windows requires WSL.** The shipped `src/<package_name>/` directory has angle-bracket characters that aren't valid Windows filenames; bash scripts everywhere assume POSIX shell. Per D-009 the target deployment is Linux/VPS — Windows isn't a first-class target.

## Docs

| Topic | Doc |
|---|---|
| **Start here** — entry-point index pointing at all five companion docs | [`PROJECT_STARTER.md`](PROJECT_STARTER.md) |
| Bootstrap checklist (zero → first commit) + decisions to answer before feature code | [`BOOTSTRAP.md`](BOOTSTRAP.md) |
| Migration — adopting the kit selectively or incrementally into an existing project | [`MIGRATION.md`](MIGRATION.md) |
| Workflow + gate + propose-and-confirm contract + conventions + PR review rubric | [`WORKFLOW.md`](WORKFLOW.md) |
| File layout + `templates/` reference | [`TEMPLATE_INVENTORY.md`](TEMPLATE_INVENTORY.md) |
| VPS deploy baseline + CI/CD + credential handling | [`DEPLOY_BASELINE.md`](DEPLOY_BASELINE.md) |
| Claude Code harness gotchas + `bootstrap.sh` design | [`HARNESS_QUIRKS.md`](HARNESS_QUIRKS.md) |
| Frozen behavior (Block format) + Decision log + open items | [`docs/spec.md`](docs/spec.md) |
| Per-version changelog | [`CHANGELOG.md`](CHANGELOG.md) |
| PR review rubric (used by Codex, `/ultrareview`, manual, or any reviewer) | [`docs/pr_review_instructions.md`](docs/pr_review_instructions.md) |

---

**Status:** v1 in active development. Current version is whatever [`VERSION`](VERSION) says. Open items + roadmap live in [`docs/spec.md` "Open project-level decisions"](docs/spec.md).
