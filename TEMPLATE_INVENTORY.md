# Template Inventory

What ships in `templates/` and the standard project file layout. Extracted from `PROJECT_STARTER.md` in v1.22.0 as part of the doc split (Codex Phase 4 #2). Read this when you're orienting on the template repo or copying skeleton files into a new project.

---

## Structure (file/folder layout)

Standard tree for a new project. Stack-specific files (`pyproject.toml`, `package.json`, `Cargo.toml`, etc.) replace one another based on language.

```
<project-slug>/
├── README.md                       # 30-second pitch + table of doc links
├── CLAUDE.md                       # Claude Code session conventions
├── CONTRIBUTING.md                 # process rules (gate, branching, etc.)
├── PROJECT_STARTER.md              # this template (kept for reference); update its version when modified
├── VERSION                         # plain text, e.g. "0.1.0\n"
├── CHANGELOG.md                    # per-version diary (v0.1.0 entry → v...)
├── .env.example                    # var declarations with comment-block-per-var
├── .gitignore                      # ignore .env, build artifacts, etc.
├── Makefile                        # dev / test / lint / fix / deploy targets
│
├── docs/
│   ├── setup.md                    # first-time machine setup procedure
│   ├── spec.md                     # product behavior — the contract
│   ├── architecture.md             # data flow + components + DB schema
│   ├── integration.md              # external system contracts (APIs, webhooks)
│   ├── runbook.md                  # day-2 ops: deploy, logs, incidents
│   └── pr_review_instructions.md   # for review automation / external reviewers
│
├── scripts/
│   ├── check-env.sh                # diff .env against .env.example
│   ├── bootstrap.sh                # interactive .env populator
│   └── deploy.sh                   # deploy to target host
│
├── src/<package_name>/             # source code (flat layout for v1)
│   ├── __init__.py | index.ts | mod.rs
│   ├── ...
│
├── tests/                          # one file per source module is a fine starting point
│   └── conftest.py | setup.ts
│
├── .claude/
│   ├── settings.json               # gate permissions, SessionStart hook (committed)
│   └── settings.local.json         # per-machine overrides (gitignored)
│
└── .github/
    └── workflows/
        └── ci.yml                  # lint + typecheck + test gates per PR
```

**Folder ownership:**
- `docs/` is for written-down decisions and procedures. Keep it small; one file per concern.
- `scripts/` is for shell scripts. Don't grow this; complexity belongs in source.
- `src/` is the only place runtime code lives.
- `tests/` mirrors `src/` structure.
- `.claude/` is for Claude Code harness configuration only.

---

## Templates (copy-paste references)

The companion `templates/` directory holds skeleton files. When bootstrapping a new project, copy the relevant ones, then search-and-replace the `<placeholders>`.

| Template file | Purpose | Placeholders to fill |
|---|---|---|
| `templates/README.md` | Project entry point — pitch + doc-table | `<PROJECT_NAME>`, `<PROJECT_DESCRIPTION>` |
| `templates/CLAUDE.md` | Session conventions for Claude Code; auto-loaded every session | `<PROJECT_NAME>`, `<STACK>`, `<HOST>`, sensitive context |
| `templates/CONTRIBUTING.md` | Process rules — verbatim copy of `PROJECT_STARTER.md` §2 with project specifics filled in | `<PROJECT_NAME>`, version-marker list |
| `templates/CHANGELOG.md` | Per-version diary skeleton | initial v0.1.0 entry |
| `templates/.env.example` | Env-var declarations skeleton with `@directive` metadata (see B-020 in `docs/spec.md`) | category headers; vars per project |
| `templates/.gitignore` | Sensible default ignores | language-specific lines if needed |
| `templates/.python-version` | Python version pin (if Python) | `3.12` typical |
| `templates/Makefile` | Dev/test/lint/deploy targets | command bodies per stack |
| `templates/.claude/settings.json` | Permission allowlist + SessionStart hook running `check-env.sh` | absolute paths |
| `templates/.github/workflows/ci.yml` | CI pipeline: lint + typecheck + test | tool versions per stack |
| `templates/scripts/check-env.sh` | Verifies `.env` against `.env.example` via shared `@directive` parser | none — generic |
| `templates/scripts/bootstrap.sh` | Interactive `.env` populator with masking + per-var validators | none — generic |
| `templates/scripts/_env-schema-parse.sh` | Shared parser for `.env.example` `@directive` schema (sourced by `bootstrap.sh` + `check-env.sh`) | none — generic |
| `templates/scripts/deploy.sh` | Skeleton deploy script | `<HOST>`, `<REMOTE_DIR>` |
| `templates/docs/setup.md` | First-time setup procedure skeleton | per project |
| `templates/docs/spec.md` | Product spec skeleton with Process & versioning section | per project |
| `templates/docs/architecture.md` | Data flow + components skeleton | per project |
| `templates/docs/integration.md` | External integrations skeleton | per project |
| `templates/docs/runbook.md` | Day-2 ops skeleton | per project |
| `templates/docs/pr_review_instructions.md` | PR review checklist skeleton | per project |
