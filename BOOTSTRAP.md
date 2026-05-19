# Bootstrap

The "zero to first commit" procedure for a new project bootstrapped from this template, plus the decisions to answer before writing any feature code. Extracted from `PROJECT_STARTER.md` §0 + §1 + §5 in v1.26.0 as the final commit of the doc-split sequence (Codex Phase 4 #2). Read this when starting a new project from the kit; after the first commit lands, primary reference shifts to [`WORKFLOW.md`](WORKFLOW.md).

## Current scope

The repo ships two layers with different scopes:

| Layer | Scope | What it contains |
|---|---|---|
| **Process** (stack-agnostic) | Any project | `gogogo!` gate convention, 5-step atomic workflow, spec-block format, Karpathy standing rules, reviewer-agnostic PR rubric, bootstrap checklist (minus the language-specific bits), version-bump + CHANGELOG rules |
| **Language preset** (Python-only today) | Python/uv/FastAPI/VPS | `templates/Makefile`, `templates/.github/workflows/ci.yml`, `templates/scripts/deploy.sh`, `templates/.env.example` validators, expected `pyproject.toml` + `src/<package>/` + `tests/` layout |

If you're starting a project in a **different stack** today, you can still adopt the process layer manually (read [`WORKFLOW.md`](WORKFLOW.md), copy `templates/CLAUDE.md` + `templates/CONTRIBUTING.md` + `templates/docs/`, customize) but the language-preset files will need stack-appropriate substitutes you write yourself. Multi-preset support (Node, Go, no-runtime) is on the roadmap (D-009 in `docs/spec.md`) but not shipped — when it lands, this section flips.

## Reading order

1. **Read "Bootstrap checklist" below** — the one-time zero-to-first-commit procedure.
2. **Read [`WORKFLOW.md`](WORKFLOW.md) once** — the binding workflow you'll follow on every change (gate, propose-and-confirm contract, 5-step sequence, branching/commits/PR/merge/deploy mechanics, conventions, PR review rubric).
3. **Skim [`TEMPLATE_INVENTORY.md`](TEMPLATE_INVENTORY.md)** — file/folder layout you'll be reproducing + the copy-paste references in `templates/`.
4. **Answer "Decisions to answer before writing feature code" below** in chat with Claude before touching `src/` — these are the decisions that shape everything.
5. **Customize [`DEPLOY_BASELINE.md`](DEPLOY_BASELINE.md) if deploying to a VPS**, otherwise replace it with your platform's deploy procedure. It also covers the CI/CD baseline and credential handling.
6. **Audit-trail conventions** live in `docs/spec.md` (Decision log) and `CHANGELOG.md` (per-version diary) — see those when tracing past decisions.
7. **[`HARNESS_QUIRKS.md`](HARNESS_QUIRKS.md)** — Claude Code operational gotchas + `bootstrap.sh` internals. Read when something behaves unexpectedly or before modifying the bootstrap script.

---

## Bootstrap checklist (zero → first commit)

This is a one-time procedure, run when creating a new project. Follow in order; each step is small.

### Pick names + directory

Pick:
- **Project slug** (kebab-case, lowercase, ASCII): e.g. `widget-tracker`. This is the local directory name and the GitHub repo name.
- **Package/module name** (snake_case for Python, camelCase for JS, etc.): e.g. `widget_tracker`. This is the import name in code.

```sh
PROJECT_SLUG=widget-tracker
PACKAGE_NAME=widget_tracker
mkdir -p ~/github/$PROJECT_SLUG
cd ~/github/$PROJECT_SLUG
```

### Initialize git

```sh
git init -b main
```

The default branch must be `main` (not `master`). Branch protection rules in "Branch protection on `main`" below reference `main`.

### Copy templates

**Quick path (recommended).** From the source-of-truth repo, run the export script to produce a portable archive, then unpack it into the new project:

```sh
# In the source-of-truth repo (one-time per export)
cd ~/github/<source-project>
./scripts/export-starter.sh    # writes ~/Downloads/project-starter-v<version>-<date>.tar.gz (and .zip if `zip` is installed; on minimal Linux installs you may only get the .tar.gz)

# In the new project's empty directory
cd ~/github/<PROJECT_SLUG>
tar -xzf ~/Downloads/project-starter-v*.tar.gz --strip-components=1
chmod +x scripts/*.sh
```

The `--strip-components=1` flag drops the leading `project-starter-v.../` directory so contents land directly at the project root.

**Alternative — direct file copy.** If both repos are on the same machine:

```sh
SOURCE=~/github/<source-project>
cp -r $SOURCE/templates/* ./
cp $SOURCE/templates/.gitignore ./
cp $SOURCE/templates/.python-version ./   # adjust if non-Python
cp -r $SOURCE/templates/.claude ./
cp -r $SOURCE/templates/.github ./
cp $SOURCE/templates/CHANGELOG.md ./
chmod +x scripts/*.sh
```

Then customize: search for `<PROJECT_NAME>`, `<PACKAGE_NAME>`, `<PROJECT_DESCRIPTION>`, `<HOST>`, `<DOMAIN>` and similar placeholders. The README, CLAUDE.md, CONTRIBUTING.md, and docs/* skeletons are the main customization targets. The Python preset additionally requires renaming the `src/<package_name>/` directory to your real package name (`mv src/<package_name> src/<PACKAGE_NAME>`) plus running the same sed across `pyproject.toml`, `tests/`, and `Makefile`.

**After substitution, generate the lockfile so CI's `uv sync --frozen` succeeds on the first push:**

```sh
uv lock          # produces uv.lock based on the now-substituted pyproject.toml
git add uv.lock  # bundled into the first commit
```

Without this, the first push to a fresh repo will fail the CI workflow (`templates/.github/workflows/ci.yml` uses `--frozen` for reproducibility) with a missing-lockfile error. Bootstrap-automation that does this for you is on the roadmap (Package B in the Codex improvement plan).

### Initial VERSION

```sh
echo "0.1.0" > VERSION
```

The version-bump rule (see [`WORKFLOW.md`](WORKFLOW.md)) applies on every subsequent change.

### GitHub repo

Create the repo (use `--private` unless you know it should be public):

```sh
gh repo create <GITHUB_USER>/$PROJECT_SLUG --private --source=. --remote=origin --description "<short description>"
```

If the repo already exists (created via the GitHub UI), skip the `gh repo create` and instead:

```sh
git remote add origin git@github.com:<GITHUB_USER>/$PROJECT_SLUG.git
```

### Branch protection on `main`

In **GitHub → Settings → Branches → Add classic branch protection rule** for `main`:

- ✅ Require a pull request before merging
- ✅ Require linear history
- ❌ Allow force pushes
- ❌ Allow deletions
- ✅ Do not allow bypassing the above settings

Don't tick "Require approvals" (you're solo). Don't tick status checks until CI lands.

### Repo merge settings

In **GitHub → Settings → General → Pull Requests**:

- ❌ Allow merge commits — **untick**
- ❌ Allow squash merging — **untick**
- ✅ Allow rebase merging — **leave ticked** (this is the canonical merge path with branch protection)
- ✅ Always suggest updating pull request branches
- ✅ Automatically delete head branches

This forces all PRs to merge as rebase, producing linear history.

### Auto-memory seed

Create the project's auto-memory directory (path is computed by Claude Code; usually `~/.claude/projects/<sanitized-cwd>/memory/`). On the first Claude Code session in the new project's directory, ask Claude to write seed memory entries — see [`WORKFLOW.md`](WORKFLOW.md)'s "Recommended auto-memory seed" section for the recommended set.

### First commit

```sh
git add -A
git status   # review what you're staging
git commit -m "$(cat <<'EOF'
chore: scaffold project skeleton v0.1.0

Initial project bootstrap from PROJECT_STARTER template v1.0.0. Adopts the
gogogo! gate, 5-step workflow, rebase-merge strategy, version-bump rule.
No source code yet.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
git push -u origin main
```

This is the **only direct push to `main`** the project will ever do. Branch protection blocks all subsequent direct pushes; everything else goes through PRs.

### Verify

```sh
git log --oneline -1                 # should show your initial commit
gh repo view --json visibility,url   # should show your repo
gh api /repos/<GITHUB_USER>/$PROJECT_SLUG/branches/main/protection 2>&1 | head  # should NOT be 404
```

Bootstrap complete. From here on, all work follows [`WORKFLOW.md`](WORKFLOW.md).

---

## Decisions to answer before writing feature code

Open these as a Q&A with Claude before touching `src/`. Each has options + recommended pick. Tailor to your project — some don't apply (e.g., DB choice on a CLI tool).

### Stack

What runtime + framework? Picking sets language for `pyproject.toml`/`package.json`/`go.mod`, naming conventions, CI tools.

Common picks:
- **Python 3.12 + FastAPI + uvicorn** — async web service, mature async ecosystem, strong webhook/API/HTTP-client tooling
- **Node 20 + Hono / Express** — when most of the team is JS-native
- **Go 1.22+** — when raw performance matters more than ecosystem

### Process model

How does the service run on the host?

- **(a) systemd unit running as root or service-user.** Simplest. Direct file access. Great for small VPS deployments.
- **(b) Container (Podman / Docker).** Reproducible builds. Required if multi-host / orchestrated.
- **(c) Managed (Fly.io / Render / Vercel).** No server to manage. Costs more per request but zero ops.

### Database

- **(a) SQLite** — single-instance, zero ops, fits up to millions of rows.
- **(b) Postgres** — multi-instance, real concurrency. Costs ops complexity.
- **(c) Managed Postgres** (Neon / Supabase / RDS) — best of both at $$.
- **(d) None** — ephemeral or stateless service.

### Hosting

- **(a) VPS** (Hetzner / OVH / DigitalOcean / your-existing-box) — cheapest, full control.
- **(b) PaaS** (Fly.io / Render / Railway) — push-to-deploy, less ops.
- **(c) Serverless** (Lambda / Cloud Run / Workers) — pay-per-request, ephemeral.

### Backups

- **(a) Local snapshots only** — nightly `.backup` to disk, manual scp-down.
- **(b) Off-site object storage** — daily push to R2 / S3 / B2.
- **(c) Managed DB backup** — included with managed Postgres.
- **(d) None** — accept loss; only valid if data is reproducible.

### Module layout (within `src/`)

- **(a) Flat** — ~10 files at package root. Best for v1. Refactor when files exceed ~300 lines.
- **(b) Grouped** — `api/`, `services/`, `clients/`, `db/` subpackages. Best when v1 already has 15+ files or layered architecture is the norm.

### CI strategy

- **(a) Three gates** — lint, typecheck, test. Standard.
- **(b) Add coverage gate** — `--cov-fail-under=80`. Useful in established codebases, premature in v1.
- **(c) Add security scan** — `bandit`, `safety`, `trivy`. Useful for client-facing services with secrets.

### Secrets store

- **(a) `.env` file on host** — gitignored, chmod 600. Simple, works for solo VPS.
- **(b) Cloud secret manager** (AWS / GCP / Doppler / 1Password Secrets) — better for teams or compliance.
- **(c) Hashicorp Vault** — overkill for solo dev.

### Observability

- **(a) journald + Sentry** — minimum viable. Logs in journald, errors in Sentry.
- **(b) + Grafana / Loki** — when you need dashboards.
- **(c) + OpenTelemetry** — when you need distributed tracing across services.

### Deploy frequency

- **(a) Deploy on every commit to main** — fastest iteration, no separate envs.
- **(b) Deploy on tag** — `git tag v0.2.0 && git push --tags` triggers deploy. Slower but auditable.
- **(c) Manual deploy** — `make deploy` from a clean main. Defaults to (a) but you skip when you want.
