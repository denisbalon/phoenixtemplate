# Setup

First-time setup for <PROJECT_NAME>. Walks from zero to a running dev environment.

## 1. Prerequisites

- <runtime + version, e.g. "Python 3.12+ (installed by uv if absent)">
- `uv` package manager (or your stack's equivalent): `curl -LsSf https://astral.sh/uv/install.sh | sh`
- `git`, `make`, `openssl`
- SSH key on the deploy target (only required for deploy)
- <PROJECT_SPECIFIC: any external service accounts or credentials>

## 2. Clone and bootstrap

```bash
git clone <repo-url> <project-slug>
cd <project-slug>
./scripts/bootstrap.sh    # interactive: prompts for each credential
uv sync                   # creates .venv and installs deps
```

`bootstrap.sh` prompts for every variable in `.env.example` and writes your answers to `.env`.

## 3. Credential reference

| Variable | Where to get it |
|---|---|
| `<VAR>` | <description of where to find / how to generate> |

## 4. Local dev

```bash
make dev
```

<PROJECT_SPECIFIC: any tunneling or webhook config needed for local development.>

## 5. Deploy

See [runbook.md](runbook.md).

## 6. Going further

- Architecture and data flow: [architecture.md](architecture.md)
- Frozen product behavior + open decisions: [spec.md](spec.md)
- External system contracts: [integration.md](integration.md)
- Day-2 ops: [runbook.md](runbook.md)
- PR review checklist: [pr_review_instructions.md](pr_review_instructions.md)
