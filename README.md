# phoenixprojecttemplate

A reusable bootstrap kit for new software projects worked on with **Claude Code**. Each new project starts from a known-good baseline instead of re-deriving workflow, structure, and conventions every time.

**Current shipped scope:** Python/uv/FastAPI/VPS starter. Multi-preset (Node, Go, no-runtime) is roadmap, not shipped today. See [`PROJECT_STARTER.md §0.1`](PROJECT_STARTER.md#01-current-scope) for the exact boundary.

## What you get

Two layers with different scopes:

| Layer | Scope | Contents |
|---|---|---|
| **Process** (stack-agnostic) | Any project | `gogogo!` passphrase gate + action-verb workflow, 5-step atomic release sequence, spec-block format (`B-NNN` blocks + Decision log), Karpathy's four LLM-coding pitfalls as standing rules, reviewer-agnostic PR review rubric. |
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

## Docs

| Topic | Doc |
|---|---|
| **Start here** — bootstrap, workflow, conventions, decisions, deploy baseline | [`PROJECT_STARTER.md`](PROJECT_STARTER.md) |
| Frozen behavior (Block format) + Decision log + open items | [`docs/spec.md`](docs/spec.md) |
| Per-version changelog | [`CHANGELOG.md`](CHANGELOG.md) |
| PR review rubric (used by Codex, `/ultrareview`, manual, or any reviewer) | [`docs/pr_review_instructions.md`](docs/pr_review_instructions.md) |

---

**Status:** v1 in active development. Current version is whatever [`VERSION`](VERSION) says. Open items + roadmap live in [`docs/spec.md` "Open project-level decisions"](docs/spec.md).
