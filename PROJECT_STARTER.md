# Project Starter

**Template version:** v1.25.0
**Last updated:** 2026-05-19

A reusable bootstrap kit for new software projects worked on with Claude Code. Captures the workflow, file structure, conventions, and decision framework so each new project starts from a known-good baseline instead of re-deriving them.

**Current shipped scope: a Python/uv/FastAPI/VPS starter.** The process layer (bootstrap checklist, `gogogo!` gate, 5-step workflow, spec-block format, Karpathy standing rules, reviewer-agnostic PR rubric) is **stack-agnostic** and works for any project. The language-preset layer (Makefile, CI workflow, deploy script, `.env.example` validators, `pyproject.toml` once shipped, `src/<package>/`) is **Python-only today**. Multi-preset support (Node/pnpm, Go, no-runtime) is roadmap per D-009 — see §0.1.

The companion [`templates/`](templates/) directory holds copy-paste-ready file scaffolds (scripts, doc skeletons, config). Each new project copies the relevant template files in §4, customizes the placeholders, and answers §5's decision bank before writing code.

---

## 0. How to use this document

### 0.1 Current scope

The repo ships two layers with different scopes:

| Layer | Scope | What it contains |
|---|---|---|
| **Process** (stack-agnostic) | Any project | `gogogo!` gate convention, 5-step atomic workflow, spec-block format, Karpathy standing rules, reviewer-agnostic PR rubric, bootstrap checklist (§1 minus the language-specific bits), version-bump + CHANGELOG rules |
| **Language preset** (Python-only today) | Python/uv/FastAPI/VPS | `templates/Makefile`, `templates/.github/workflows/ci.yml`, `templates/scripts/deploy.sh`, `templates/.env.example` validators, expected `pyproject.toml` + `src/<package>/` + `tests/` layout |

If you're starting a project in a **different stack** today, you can still adopt the process layer manually (read §2, copy `templates/CLAUDE.md` + `templates/CONTRIBUTING.md` + `templates/docs/`, customize) but the language-preset files will need stack-appropriate substitutes you write yourself. Multi-preset support (Node, Go, no-runtime) is on the roadmap (D-009) but not shipped — when it lands, this section flips.

### 0.2 Reading order

1. **Read §1 once** — the bootstrap checklist, zero to first commit.
2. **Read [`WORKFLOW.md`](WORKFLOW.md) once** — the binding workflow you'll follow on every change (gate, propose-and-confirm contract, 5-step sequence, branching/commits/PR/merge/deploy mechanics, conventions, PR review rubric).
3. **Skim [`TEMPLATE_INVENTORY.md`](TEMPLATE_INVENTORY.md)** — file/folder layout you'll be reproducing + the copy-paste references in `templates/`.
4. **Answer §5 in chat with Claude** before writing any feature code — these are the decisions that shape everything.
5. **Customize [`DEPLOY_BASELINE.md`](DEPLOY_BASELINE.md) if deploying to a VPS**, otherwise replace it with your platform's deploy procedure. It also covers the CI/CD baseline and credential handling.
6. **§8 (audit trail + decision log)** lives in this file — read when tracing past decisions.
7. **[`HARNESS_QUIRKS.md`](HARNESS_QUIRKS.md)** — Claude Code operational gotchas + `bootstrap.sh` internals. Read when something behaves unexpectedly or before modifying the bootstrap script.

This document was split incrementally — v1.22.0 extracted file-layout, deploy-baseline, and harness-quirks content (`TEMPLATE_INVENTORY.md` / `DEPLOY_BASELINE.md` / `HARNESS_QUIRKS.md`); v1.25.0 extracted the workflow + conventions + memory seed + PR review heuristics (`WORKFLOW.md` — now canonical for the gate + workflow rules per B-021). §0/§1/§5/§8 still live in this file; the rest are stubs pointing at the new files. Final thin-index reduction will land in v1.26.0 (BOOTSTRAP.md extraction).

When this document changes (template version bump), update the template version at the top and add a row to its own changelog at the bottom.

---

## 1. Bootstrap checklist (zero → first commit)

This is a one-time procedure, run when creating a new project. Follow in order; each step is small.

### 1.1 Pick names + directory

Pick:
- **Project slug** (kebab-case, lowercase, ASCII): e.g. `widget-tracker`. This is the local directory name and the GitHub repo name.
- **Package/module name** (snake_case for Python, camelCase for JS, etc.): e.g. `widget_tracker`. This is the import name in code.

```sh
PROJECT_SLUG=widget-tracker
PACKAGE_NAME=widget_tracker
mkdir -p ~/github/$PROJECT_SLUG
cd ~/github/$PROJECT_SLUG
```

### 1.2 Initialize git

```sh
git init -b main
```

The default branch must be `main` (not `master`). Branch protection rules in §1.6 reference `main`.

### 1.3 Copy templates

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

### 1.4 Initial VERSION

```sh
echo "0.1.0" > VERSION
```

The version-bump rule (§2) applies on every subsequent change.

### 1.5 GitHub repo

Create the repo (use `--private` unless you know it should be public):

```sh
gh repo create <GITHUB_USER>/$PROJECT_SLUG --private --source=. --remote=origin --description "<short description>"
```

If the repo already exists (created via the GitHub UI), skip the `gh repo create` and instead:

```sh
git remote add origin git@github.com:<GITHUB_USER>/$PROJECT_SLUG.git
```

### 1.6 Branch protection on `main`

In **GitHub → Settings → Branches → Add classic branch protection rule** for `main`:

- ✅ Require a pull request before merging
- ✅ Require linear history
- ❌ Allow force pushes
- ❌ Allow deletions
- ✅ Do not allow bypassing the above settings

Don't tick "Require approvals" (you're solo). Don't tick status checks until CI lands.

### 1.7 Repo merge settings

In **GitHub → Settings → General → Pull Requests**:

- ❌ Allow merge commits — **untick**
- ❌ Allow squash merging — **untick**
- ✅ Allow rebase merging — **leave ticked** (this is the canonical merge path with branch protection)
- ✅ Always suggest updating pull request branches
- ✅ Automatically delete head branches

This forces all PRs to merge as rebase, producing linear history.

### 1.8 Auto-memory seed

Create the project's auto-memory directory (path is computed by Claude Code; usually `~/.claude/projects/<sanitized-cwd>/memory/`). On the first Claude Code session in the new project's directory, ask Claude to write seed memory entries — see §10 for the recommended set.

### 1.9 First commit

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

### 1.10 Verify

```sh
git log --oneline -1                 # should show your initial commit
gh repo view --json visibility,url   # should show your repo
gh api /repos/<GITHUB_USER>/$PROJECT_SLUG/branches/main/protection 2>&1 | head  # should NOT be 404
```

Bootstrap complete. From here on, all work follows §2.

---

## 2. The process (workflow + gate)

**Moved to [`WORKFLOW.md`](WORKFLOW.md) in v1.25.0** as part of the doc split (Codex Phase 4 #2). That file also covers `## 9. Conventions`, `## 10. Recommended auto-memory seed`, and `## 11. PR review heuristics`.

---

## 3. Structure (file/folder layout)

**Moved to [`TEMPLATE_INVENTORY.md`](TEMPLATE_INVENTORY.md) in v1.22.0** as part of the doc split (Codex Phase 4 #2).

---

## 4. Templates (copy-paste references)

**Moved to [`TEMPLATE_INVENTORY.md`](TEMPLATE_INVENTORY.md) in v1.22.0.**

---

## 5. Decisions to answer before writing feature code

Open these as a Q&A with Claude before touching `src/`. Each has options + recommended pick. Tailor to your project — some don't apply (e.g., DB choice on a CLI tool).

### 5.1 Stack

What runtime + framework? Picking sets language for `pyproject.toml`/`package.json`/`go.mod`, naming conventions, CI tools.

Common picks:
- **Python 3.12 + FastAPI + uvicorn** — async web service, mature async ecosystem, strong webhook/API/HTTP-client tooling
- **Node 20 + Hono / Express** — when most of the team is JS-native
- **Go 1.22+** — when raw performance matters more than ecosystem

### 5.2 Process model

How does the service run on the host?

- **(a) systemd unit running as root or service-user.** Simplest. Direct file access. Great for small VPS deployments.
- **(b) Container (Podman / Docker).** Reproducible builds. Required if multi-host / orchestrated.
- **(c) Managed (Fly.io / Render / Vercel).** No server to manage. Costs more per request but zero ops.

### 5.3 Database

- **(a) SQLite** — single-instance, zero ops, fits up to millions of rows.
- **(b) Postgres** — multi-instance, real concurrency. Costs ops complexity.
- **(c) Managed Postgres** (Neon / Supabase / RDS) — best of both at $$.
- **(d) None** — ephemeral or stateless service.

### 5.4 Hosting

- **(a) VPS** (Hetzner / OVH / DigitalOcean / your-existing-box) — cheapest, full control.
- **(b) PaaS** (Fly.io / Render / Railway) — push-to-deploy, less ops.
- **(c) Serverless** (Lambda / Cloud Run / Workers) — pay-per-request, ephemeral.

### 5.5 Backups

- **(a) Local snapshots only** — nightly `.backup` to disk, manual scp-down.
- **(b) Off-site object storage** — daily push to R2 / S3 / B2.
- **(c) Managed DB backup** — included with managed Postgres.
- **(d) None** — accept loss; only valid if data is reproducible.

### 5.6 Module layout (within `src/`)

- **(a) Flat** — ~10 files at package root. Best for v1. Refactor when files exceed ~300 lines.
- **(b) Grouped** — `api/`, `services/`, `clients/`, `db/` subpackages. Best when v1 already has 15+ files or layered architecture is the norm.

### 5.7 CI strategy

- **(a) Three gates** — lint, typecheck, test. Standard.
- **(b) Add coverage gate** — `--cov-fail-under=80`. Useful in established codebases, premature in v1.
- **(c) Add security scan** — `bandit`, `safety`, `trivy`. Useful for client-facing services with secrets.

### 5.8 Secrets store

- **(a) `.env` file on host** — gitignored, chmod 600. Simple, works for solo VPS.
- **(b) Cloud secret manager** (AWS / GCP / Doppler / 1Password Secrets) — better for teams or compliance.
- **(c) Hashicorp Vault** — overkill for solo dev.

### 5.9 Observability

- **(a) journald + Sentry** — minimum viable. Logs in journald, errors in Sentry.
- **(b) + Grafana / Loki** — when you need dashboards.
- **(c) + OpenTelemetry** — when you need distributed tracing across services.

### 5.10 Deploy frequency

- **(a) Deploy on every commit to main** — fastest iteration, no separate envs.
- **(b) Deploy on tag** — `git tag v0.2.0 && git push --tags` triggers deploy. Slower but auditable.
- **(c) Manual deploy** — `make deploy` from a clean main. Defaults to (a) but you skip when you want.

---

## 6. VPS deploy baseline

**Moved to [`DEPLOY_BASELINE.md`](DEPLOY_BASELINE.md) in v1.22.0** as part of the doc split (Codex Phase 4 #2).

---

## 7. CI/CD baseline

**Moved to [`DEPLOY_BASELINE.md`](DEPLOY_BASELINE.md) in v1.22.0.**

---

## 8. Audit trail

How to keep history of decisions + commits + PRs traceable.

### 8.1 Commit-to-PR mapping

With rebase-merge (the canonical merge path under branch protection), commit subjects do **not** automatically include the PR number — `gh pr merge --rebase` preserves original commits verbatim. To trace a commit back to its PR, two options:

- **Manual:** include `Refs #<PR-number>` in the commit body once the PR is open. Requires `git commit --amend` + `git push --force-with-lease` on the feature branch (allowed; never on main).
- **GitHub API:** `gh pr list --state merged --search "<commit-sha>"` finds the PR for any merged commit.

Document the chosen approach in `CONTRIBUTING.md`.

### 8.2 CHANGELOG.md

Per-version human-readable diary. One section per `VERSION` bump:

```md
# Changelog

## v0.2.0 — 2026-05-15

- Add webhook receiver for `<upstream-service>` — PR #12
- Update spec §5.4 for delayed-confirmation mode — PR #11

## v0.1.0 — 2026-05-04

Initial scaffold.
```

Update as part of the same `gogogo!` that bumps `VERSION` (ride-along; not a separate commit).

### 8.3 Decision log

The spec (`docs/spec.md`) holds the *what* and *why* of every design decision. When a decision is made, add an entry to a "Decision log" subsection in `docs/spec.md`:

```md
## Decision log

### D-001 (2026-05-04) Multi-pixel routing — option B
**Chose:** `pixels` table from day 1, single seed row.
**Considered:** (a) hardcode single pixel, (c) full admin UX for managing pixels.
**Why:** Future TikTok-Spain campaign + backup-pixel failover scenario; ~10 LoC overhead now vs. refactor later.
**Implemented in:** PR #4
```

Decisions live forever in the repo; the chat history that produced them does not.

### 8.4 Memory (Claude-specific, user-local by default)

Auto-memory at `~/.claude/projects/<sanitized-cwd>/memory/` captures:
- Project-level facts (overview, infra pointers, spec location)
- User preferences (working style, tolerance for ceremony, repeated-warning preferences)
- Harness quirks observed
- Process rules (the `gogogo!` gate workflow itself)

Memory is **user-local by default** — not in the repo. If a project requires shared memory across collaborators, set `autoMemoryDirectory` in `~/.claude/settings.json` to point at `<repo>/.claude/memory/` and commit that directory.

---

## 9. Conventions

**Moved to [`WORKFLOW.md`](WORKFLOW.md) in v1.25.0.**

---

## 10. Recommended auto-memory seed

**Moved to [`WORKFLOW.md`](WORKFLOW.md) in v1.25.0.**

---

## 11. PR review heuristics

**Moved to [`WORKFLOW.md`](WORKFLOW.md) in v1.25.0.**

---

## 12. Claude Code harness quirks

**Moved to [`HARNESS_QUIRKS.md`](HARNESS_QUIRKS.md) in v1.22.0** as part of the doc split (Codex Phase 4 #2).

---

## 13. Credential handling

**Moved to [`DEPLOY_BASELINE.md`](DEPLOY_BASELINE.md) in v1.22.0** (credential handling belongs with deploy concerns).

---

## 14. Bootstrap.sh design principles

**Moved to [`HARNESS_QUIRKS.md`](HARNESS_QUIRKS.md) in v1.22.0.**

---

## Template changelog

Update the **Template version** at the top of this document and add a row here whenever this file changes.

| Version | Date | Notes |
|---|---|---|
| 1.25.0 | 2026-05-19 | **Extract `WORKFLOW.md` (2 of 3 of the PROJECT_STARTER.md split sequence).** Moves §2 (workflow + gate) + §9 (conventions) + §10 (recommended auto-memory seed) + §11 (PR review heuristics) into a new root-level `WORKFLOW.md`. PROJECT_STARTER.md drops from 821 to ~435 lines; the four extracted sections become stub pointers preserving §-numbers. Section subheadings inside §2 (§2.1-§2.13) and §9 (§9.1-§9.5) are renumbered to bare headings inside WORKFLOW.md. Internal cross-references updated: §2.2's "see §10 for what each project tracks" → "see 'Recommended auto-memory seed' below"; §2.7's "Full rules: §11" → "Full rules: 'PR review heuristics' below"; §2.9's "(§1.6)" → "([PROJECT_STARTER.md §1.6](PROJECT_STARTER.md#16-branch-protection-on-main))"; §11's "see §2.7 for the workflow" → "see 'Review' above". Coordinated linter retargets: `scripts/check-rule-consistency.sh` `FILES[0]` shifts from `PROJECT_STARTER.md` to `WORKFLOW.md` (the three C4 anchored regions — `gate-clause`, `proposal-format`, `bare-gogogo` — move with §2.1 byte-exact into WORKFLOW.md); `scripts/export-starter.sh` `ROOT_DOCS` grows to 5 entries (adds WORKFLOW.md); `scripts/check-doc-references.sh` `VIRTUAL_TEMPLATES_FILES` mirrors the ROOT_DOCS addition. Cross-references in `CONTRIBUTING.md` (meta root) / `templates/CONTRIBUTING.md` canonical-scope marker / `templates/CLAUDE.md` canonical-scope marker all retargeted from `PROJECT_STARTER.md §2` to `WORKFLOW.md`. README.md two-layer table gains a WORKFLOW.md row; Known Limitations updated to "four of five companion files ship." `§0.2 Reading order` in PROJECT_STARTER.md rewritten to point readers at WORKFLOW.md as step 2 (was "Read §2"). Spec: B-021 tier table drops the `(post-split: WORKFLOW.md)` parenthetical (post-split is now reality); B-022 rule field updated to name `WORKFLOW.md` as first tier with audit-trail note; B-025 grows to "four of five planned files shipped" status; no new B blocks (this is execution of D-009's roadmap continuation under B-025's split framework). Minor bump per §2.3 (notable refactor, ~900 lines moved). |
| 1.24.0 | 2026-05-19 | **Gate refinements (D-011): keep `gogogo!`, always-propose, multi-select.** Three changes to the v1.23.0 propose-and-confirm model: (1) rename `gogogo!`→`go!` was considered and rejected — D-001's false-positive protection on common English ("let's go!", "don't go!") still matters, so the 7-char token stays; (2) every assistant message now ends with a concrete proposal, even clarification turns (formalized as new B-027) — no more user round-trips to re-elicit a proposal; (3) numbered proposals now distinguish "Choose one:" (mutually exclusive alternatives, only `N gogogo!` valid) from "Choose any (in order):" (independent options that can batch, supports `N1 N2 ... gogogo!` syntax for multi-select, e.g. `1 2 4 5 gogogo!` runs options 1/2/4/5 in typed order, skipping 3). Multi-select is a STRICT extension of single-pick — each authorized item was a concrete proposal already surfaced and inspected; multi-select doesn't pre-auth unknown future proposals (which `gogogo!N` / autopilot proposals were rejected for doing), it batches known ones. The three C4 doc-trio regions (`gate-clause`, `proposal-format`, `bare-gogogo`) get content updates byte-exact across PROJECT_STARTER.md §2.1 + templates/CONTRIBUTING.md + templates/CLAUDE.md — REGIONS array unchanged in scripts/check-rule-consistency.sh. `proposal-format` region grows from two invitation forms to three. Supporting prose in §2.1 extends the self-check list (4→5 steps) and adds two refuse-list rows ("user multi-selected against my Choose-one list" + "I should answer this clarifying question without proposing"). Spec: B-026 content updated in place (rule condition b allows multi-digit; rationale gains the v1.24.0 refinement note); B-027 added (frozen — always-end-with-proposal); D-011 added (the three-refinement decision with full failure-mode analysis). No new linter machinery. Minor bump per §2.3 (multi-select is a notable feature). |
| 1.23.1 | 2026-05-19 | Sweep stale verb references in active docs left over from v1.23.0 (announced as the v1.23.1 follow-up in that release's CHANGELOG entry). Five files touched: `templates/CONTRIBUTING.md` (cheat-sheet table rows mentioning `PR gogogo!` / `merge gogogo!` → "User `gogogo!`s a PR-open proposal" / "merge proposal"; TL;DR sequence rewritten to propose-and-confirm phrasing for items 1/2/3/5/6/7/8; review section "Claude opens the PR on `PR gogogo!`" → "after a `gogogo!`-authorized PR-open proposal" + "Workflow after `PR gogogo!`" → "after the PR is opened" + "more `<verb> gogogo!`s" → "more `gogogo!`-authorized commits"; canonical-scope marker's "the verbs" → "propose-and-confirm semantics" and "verb table" → "proposal format"); `templates/docs/pr_review_instructions.md` (one site); `PROJECT_STARTER.md` §2 canonical-scope marker (the line BEFORE the rewritten §2.1; "action verbs, 5-step structure" → "propose-and-confirm contract, 5-step structure"; "verb table" → "proposal format" in the duplicated-rule list; C4 linter note refreshed from "Phase 3 #3, pending" → script name); root `CONTRIBUTING.md` line 7 ("gate, action verbs, 5-step..." → "the propose-and-confirm `gogogo!` gate, 5-step...") + line 25 C4-linter "pending" note refreshed; `README.md` two-layer table ("`gogogo!` passphrase gate + action-verb workflow" → "`gogogo!` passphrase gate with propose-and-confirm semantics (Claude proposes concretely, user `gogogo!`s the proposal)"); `docs/spec.md` B-010 rule field ("no verb, no reminder" → "no review-specific proposal flow, no reminder"; "After `PR gogogo!`" → "After Claude opens the PR (per a `gogogo!`-authorized PR-open proposal)"). What stays untouched as audit trail: `CHANGELOG.md` (all historical), template-changelog rows in `PROJECT_STARTER.md` (historical), `docs/spec.md` historical-superseded section (B-001, B-006, B-011, etc.), `docs/spec.md` decision-log Chose/Considered/Why fields (D-004, D-005, D-006, D-007, D-008 reference past decisions), and the legitimate historical context in active blocks B-021 / B-022 / B-026 / D-010 (describing the v1.23.0 transition). No spec changes (no new B blocks — the rules haven't changed, the prose has just caught up). Patch bump (1.23.0 → 1.23.1) per the §2.3 increment policy: typical changes default to patch; this is doc cleanup only. |
| 1.23.0 | 2026-05-19 | **Gate model rewrite: propose-and-confirm replaces verb-prefix.** Most invasive change since the project started — touches B-001 + B-011 + D-004 (all superseded), B-021 + B-022 content (regions list updated), the doc trio (PROJECT_STARTER.md §2 / templates/CONTRIBUTING.md / templates/CLAUDE.md fully rewritten), and `scripts/check-rule-consistency.sh` (REGIONS array). New gate rule: no state-mutating action proceeds unless (a) Claude's immediately-preceding assistant message contained a concrete proposal (specific files/commands/commits, not vague phrasing), (b) the user's CURRENT message contains the literal substring `gogogo!` (optionally preceded by a digit selecting from a numbered list), and (c) the action matches the proposal exactly — mid-execution deviation requires a new proposal. There are no action verbs anymore; the action description lives in the proposal in plain English. Multi-step workflows (5-step feature work) still authorize on one `gogogo!` — Claude enumerates the plan upfront. Bare `gogogo!` without a preceding proposal triggers a clarification prompt. The three C4 linter regions are now `gate-clause` (new text) + `proposal-format` (new region) + `bare-gogogo` (new text); `verb-table` region is retired. Failure-mode analysis: D-004's original "agent picks wrong workflow on bare authorization" is preserved (corrective surface moves from user-typed verb to Claude-surfaced concrete proposal). New protection: "agent picks wrong file/scope under a correctly-formed verb" — verbs only encoded action type, proposals encode files / commands / commits too. New mitigation: vague proposals don't satisfy the gate's "concrete" requirement; the IMMEDIATELY-PRECEDING-MESSAGE constraint catches conversation drift. Spec: B-001 + B-011 moved to historical-superseded section; D-004 marked superseded; B-026 added (frozen, the new gate); D-010 added; B-021 + B-022 content updated in place. User feedback drove the design: *"always re-ask users, so he confirms your understanding"* — the proposal IS the re-ask. Sweep of remaining repo references to verbs will land in v1.23.1. |
| 1.22.0 | 2026-05-19 | First of three commits splitting `PROJECT_STARTER.md` (Codex Phase 4 #2). Three companion docs shipped at meta-repo root: `TEMPLATE_INVENTORY.md` (extracted §3 + §4 — file/folder layout + `templates/` reference table), `DEPLOY_BASELINE.md` (extracted §6 + §7 + §13 — VPS deploy + CI/CD baseline + credential handling), `HARNESS_QUIRKS.md` (extracted §12 + §14 — Claude Code harness gotchas + `bootstrap.sh` design principles). PROJECT_STARTER.md drops from 1121 to ~810 lines; the extracted sections retain their heading + a one-line pointer for stable mental anchors. §0.2 Reading order rewritten to reference the new files. `scripts/export-starter.sh` gains a `ROOT_DOCS` array and copies all four root docs into the archive stage so cross-links resolve in the consumer's extracted layout; `scripts/check-doc-references.sh` `VIRTUAL_TEMPLATES_FILES` extended to match. README.md "Known limitations" updated to reflect split progress + linter trio. Spec: B-025 added (frozen — captures the three-commit split rationale and stub-with-pointer convention); B-015 archive-layout rule updated in place to name `ROOT_DOCS` instead of just PROJECT_STARTER.md; B-023's `VIRTUAL_TEMPLATES_FILES` mention updated. Next: v1.22.1 ships WORKFLOW.md (extracts §2 + §9 + §10 + §11, coordinates B-022 C4-linter target relocation); v1.22.2 ships BOOTSTRAP.md (extracts §0 + §1 + §5) and reduces PROJECT_STARTER.md to a thin index. |
| 1.21.0 | 2026-05-19 | C3 placeholder linter (Codex Phase 8 #3). `scripts/check-placeholders.sh` walks meta-repo `*.md` files (excluding `templates/` and the external Codex plan), strips fenced code blocks and inline code spans, and fails non-zero if any canonical substitution placeholder (`<package_name>` / `<PACKAGE_NAME>` / `<PROJECT_NAME>` / `<PROJECT_SLUG>` / `<GITHUB_USER>` / `<HOST>` / `<DOMAIN>` / `<PROJECT_DESCRIPTION>` / `<COPYRIGHT_HOLDER>` / `<YEAR>`) appears in plain prose. Catches the failure mode where an unresolved placeholder leaks from the template-bootstrap surface into a user-facing meta-doc, making the docs read as if they ship with TODO markers. Mentions inside backticks like `<package_name>` stay fine — code spans are a clear signal the writer is referencing the placeholder concept rather than waiting for substitution. Scope is meta-repo `*.md` only (not `*.sh` / `*.py` / `*.toml`, where placeholder strings appear as docstrings or comments that don't render to users); generic angle-bracket meta-syntax (`<verb>`, `<file>`, `<X.Y.Z>`) is not flagged because it isn't in the canonical set. Wired into `.github/workflows/template-self-test.yml` after the doc-reference linter (B-023) and before the smoke test (B-014). Six meta-repo files currently pass clean. Completes the linter trio (B-022 / B-023 / B-024) that gates the upcoming safe `PROJECT_STARTER.md` split. Spec: B-024 added. |
| 1.20.0 | 2026-05-19 | C2 doc-reference linter (Codex Phase 8 #2). `scripts/check-doc-references.sh` walks every Markdown file in the repo, extracts `[label](target)` link targets (skipping URLs, anchors, autolinks), strips `#anchor` and `?query`, resolves relative to the linking file's directory, and fails non-zero if any target file or directory is missing on disk. 50 Markdown link targets across 19 files currently pass. Knows about the export layout: links inside `templates/` that target `PROJECT_STARTER.md` resolve via `VIRTUAL_TEMPLATES_FILES` because `scripts/export-starter.sh` flattens templates contents alongside `PROJECT_STARTER.md` in the archive. Wired into `.github/workflows/template-self-test.yml` as a step between rule-consistency and the smoke test. Closes the "manual until C2 linter ships" caveat in B-016. Spec: B-023 added. |
| 1.19.0 | 2026-05-19 | C4 rule-consistency linter (Codex Phase 8 #4). `scripts/check-rule-consistency.sh` extracts three named rule regions — `gate-clause` / `verb-table` / `bare-gogogo` — bracketed by `<!-- C4:<region>:start/end -->` HTML-comment anchors from `PROJECT_STARTER.md` §2, `templates/CONTRIBUTING.md`, `templates/CLAUDE.md`; diffs them pairwise; exits non-zero with a unified diff on drift. Wired into `.github/workflows/template-self-test.yml` as a step before the existing smoke test, so drift fails CI. Pre-linter alignment commit: `templates/CLAUDE.md` gate clause `Never` → `Do NOT`; PROJECT_STARTER §2 verb table simplified from 3-column (Phrase/Action/Workflow) to 2-column shared form, with the dropped Workflow column's section refs moved to a prose sentence below the table; bare-`gogogo!` prompt unified across all three files to a standalone bold paragraph with trailing "Review is out-of-band — no verb for it." Resolves B-021's "manual until C4 linter ships" caveat. Spec: B-022 added. |
| 1.18.0 | 2026-05-18 | Codex Phase 1 #1 — three-tier doc-canonical model with deliberate AI-safety redundancy. Refined from "one canonical source" framing per user pushback: the historical triple-source layout was defensive redundancy added after observed AI failures (missed gate, wrong verb, ignored bare-gogogo) — not architecture debt. New framing: canonical per concern, rule statements deliberately duplicated. **PROJECT_STARTER §2** canonical for core workflow rules + rationale; **templates/CONTRIBUTING.md** canonical for per-project ops; **templates/CLAUDE.md** session-facing summary with mandatory inline rule duplication. Each file has a `**Canonical scope:**` header marker; duplicated rule sections annotated as deliberate redundancy. Plus thin root `CONTRIBUTING.md` for the meta repo (~30 lines, pointer + meta-specific overrides). Spec: B-021 added (three-tier model + redundancy rationale). Next: C4 consistency linter (mechanical sync for the deliberate duplication). |
| 1.17.0 | 2026-05-18 | Codex Phase 1 #3 — split `docs/spec.md` into active + historical-superseded sections. 14 active blocks (B-001/002/003/004/005/010/011/012/014/015/016/017/019/020) live in `## Frozen behavior` in numerical order; 6 superseded blocks (B-006/007/008/009/013/018) moved to new `## Historical blocks (superseded)` appendix at end of file. Decision log + Open project-level decisions unchanged. Zero content removed — pure reorganization. `templates/docs/spec.md` skeleton gains a third editing rule documenting the convention so consumer projects follow it. No new B block. Next on Phase 1: #1 canonical-source design discussion, then #2 PROJECT_STARTER split + #4 duplication reduction. |
| 1.16.1 | 2026-05-18 | Add Known Limitations section to README (Codex Phase 5 #2). Five concrete limitations with one-paragraph explanations each: (1) placeholder substitution still manual — `bootstrap.sh` only handles `.env` creds; (2) single language preset (Python/uv/FastAPI/VPS only); (3) `PROJECT_STARTER.md` still a 1000-line monolith; (4) no automated drift detection (no linters yet); (5) Windows requires WSL. Each links to the relevant open item / roadmap phase. Section sits between Quickstart and Docs; points at `docs/spec.md` "Open project-level decisions" for full roadmap. No spec block (doc-only). |
| 1.16.0 | 2026-05-18 | Add repo-root `README.md` — first-contact quickstart (Codex Phase 5 #1, first commit on `improvements-2`). ~250-word README covering what-it-is + current shipped scope (Python/uv/FastAPI/VPS per D-009; multi-preset roadmap, not shipped) + two-layer table (process / preset) + quickstart commands pointing at PROJECT_STARTER §1 for the deep bootstrap + docs table. Until now the GitHub landing page had no README; visitors had to open PROJECT_STARTER.md to learn what the project is. `codex improvement plan.md` intentionally not linked in docs table — the committed v1.8.0 version is stale; Codex's latest refactor lives in stash@{0} per the user's no-snapshot decision. No spec block (doc deliverable, not behavior). |
| 1.15.0 | 2026-05-18 | **Phase 3 complete.** Third commit: kill `templates/scripts/validators.sh` sidecar (shipped v1.12.0, B-018). The `@directive` system from v1.14.0–v1.14.1 (B-020) covers the same per-var validator extension point inline in `.env.example` via `@validator:` directives — one mechanism for the same job. Bootstrap.sh's `source` block removed. Breaking change for consumers using the sidecar — migrate validators to inline `@validator:` directives. Spec: B-018 flipped to superseded by B-020. Phase 3 done: 1.14.0 (data migrate) + 1.14.1 (parser swap, B-020 frozen) + 1.15.0 (this — kill the redundant sidecar). |
| 1.14.1 | 2026-05-18 | Second of three Phase 3 commits — parser swap. New `templates/scripts/_env-schema-parse.sh` shared helper parses the `@directive` schema and populates `VARS`/`DESCRIPTIONS`/`DEFAULTS`/`VALIDATORS`/`IS_OPTIONAL`/`IS_SENSITIVE`/`COMMENTS` arrays. `bootstrap.sh` and `check-env.sh` both source it; ~30+25 lines of duplicated legacy parsing replaced. `mask()` uses `IS_SENSITIVE[var]` instead of regex auto-detection. Case-insensitive directive name matching forgives typos; unknown `@directive` emits stderr warning. **Breaking change:** consumers with un-migrated `.env.example` (legacy "Optional:" prose) need to add `@optional` directives — per user's hard-cut decision. Spec: B-020 promoted from draft to frozen. validators.sh sidecar source line retained for this release; v1.15.0 removes it. |
| 1.14.0 | 2026-05-18 | First of three commits implementing Codex Phase 3 (env metadata explicit). `templates/.env.example` migrated to `@directive` format — each var carries `@description / @required / @optional / @default / @validator / @sensitive` metadata in preceding comments instead of relying on English prose ("Optional:") parsed by case-insensitive grep. Single source of truth; no separate schema, no rendering layer. This commit migrates data only — parser still reads legacy prose-grep (which case-insensitively matches "@optional" on SENTRY_DSN, so zero behavior change in this intermediate state). Spec: B-020 added in `draft` status (format defined; parser enforcement pending v1.14.1). Next two commits rewrite the parser (v1.14.1, hard cut) and kill `validators.sh` (v1.15.0, supersedes B-018). |
| 1.13.0 | 2026-05-18 | Audit source-project residue in active docs + scripts (Codex Phase 1.3 — last item of Package B). Three categories: (a) `denisbalon/$PROJECT_SLUG` hardcodes in §1.5/§1.6 parametrized to `<GITHUB_USER>/$PROJECT_SLUG` (closes the v1.11.1 A5 deferral); (b) six vendor-specific examples in supposedly-generic prose made generic (branch names, commit-message examples, stack rationale, DNS guidance, sample CHANGELOG entry) or explicitly labeled (`**Example (Telegram bots):**` for §11's chat_join_request example, `**Example:**` for §13's Meta credential-revoke pointer); (c) `WEBHOOK_BASE_URL` env var in `templates/scripts/deploy.sh` renamed to `SERVICE_URL` (webhook-shaped name was Telegram-bot leftover). Breaking change: consumers with `WEBHOOK_BASE_URL` in `.env` should rename. Spec: B-019 added (active docs vendor-neutral by default; labeled exceptions). Package B / Codex Phase 1 (de-personalize) now complete: 1.1 ✓ (v1.11.2), 1.2 ✓ (v1.12.0), 1.3 ✓ (this release). |
| 1.12.0 | 2026-05-18 | Strip vendor validators from `bootstrap.sh` core; ship `templates/scripts/validators.sh` sidecar (Codex Phase 1.2). Eight validators in the `VALIDATORS` associative array — six vendor-specific (TELEGRAM_BOT_TOKEN / TELEGRAM_WEBHOOK_SECRET / TELEGRAM_CHANNEL_ID / META_DEFAULT_PIXEL_ID / META_CAPI_TOKEN / KEITARO_POSTBACK_BASE / KEITARO_POSTBACK_KEY) plus app-shaped WEBHOOK_BASE_URL — were bake-ins from the source project. Core now contains only truly generic validators (`LOG_LEVEL`, `DEV_MODE`); vendor patterns moved to a sourced sidecar `templates/scripts/validators.sh` (skeleton with commented examples). Breaking change for consumers relying on the hardcoded patterns — uncomment in the new sidecar to restore. Spec: B-018 added (generic core + sidecar architecture). |
| 1.11.2 | 2026-05-18 | Patch — first item of Package B / Codex Phase 1 (de-personalize). `templates/scripts/bootstrap.sh:200` menu header hardcoded `phoenixtgstat_bot` (source-project leftover); replaced with `$(basename "$ROOT")` derivation so the consumer's actual project directory name shows in the banner. Spec: B-017 added (generic scripts derive project context, don't hardcode source names; future C4 linter testable). Open item split — menu-header fixed; service-specific validators (Telegram/Meta/Keitaro regex bake-ins in the same script) still pending Codex Phase 1.2 (needs a small design call on extraction approach). |
| 1.11.1 | 2026-05-18 | Patch — A5 audit (Codex Phase 1.4) of every command/file/path reference across `PROJECT_STARTER.md`, `templates/README.md`, `templates/CONTRIBUTING.md`, `templates/CLAUDE.md`, `templates/docs/*`. Surprisingly thin — most drift was already caught by v1.7.1 / v1.9.0-v1.11.0. One real gap fixed: §1.3 didn't tell consumers to run `uv lock && git add uv.lock` after placeholder substitution, so first push to a fresh repo failed CI's `uv sync --frozen` for missing lockfile. Personalization residue (`denisbalon/` hardcodes) and the `<package_name>` manual-substitution requirement are real gaps but deferred to Package B (de-personalize + bootstrap automation) — out of A5's path-audit scope. Spec: B-016 added (invariant — live doc references resolve to shipped files or are explicit examples; future C2 linter will test this automatically). |
| 1.11.0 | 2026-05-18 | Template self-tests on CI (Codex Phase 8). New `scripts/smoke-test.sh` end-to-end-instantiates the template: export-starter → tar extract → sed substitute `<package_name>` → `uv sync` → pytest + ruff + mypy. New `.github/workflows/template-self-test.yml` runs the smoke test on every push and PR against `main` (meta-repo's first CI workflow). Same-commit fix to `scripts/export-starter.sh` archive layout: smoke test caught that v1.10.0 kept `templates/` nested, breaking §1.3's `chmod +x scripts/*.sh` line; fixed by promoting templates contents to the archive root via `cp -R templates/.` trailing-slash trick. Spec: B-014 added (self-test rule); B-015 added (correct layout); B-013 superseded by B-015 with audit-trail rationale. |
| 1.10.0 | 2026-05-18 | Ship `scripts/export-starter.sh` at repo root (Codex Phase 1.1 + open item #4 — both resolved). Reads VERSION; writes `~/Downloads/project-starter-v<VERSION>-<DATE>.tar.gz` (always) and `.zip` (only if `zip` is installed). Archive top-level dir matches the archive name so `tar -xzf ... --strip-components=1` per §1.3 works. Closes the "quick path doc lies" gap that's existed since v1.1.1. Spec: B-013 added. |
| 1.9.1 | 2026-05-18 | Patch — fix `templates/scripts/deploy.sh` cleanliness check (Codex Phase 1.3). Previous `git diff --quiet` only caught unstaged changes; now also blocks on staged-but-uncommitted edits (`git diff --cached --quiet`) and untracked files (`git ls-files --others --exclude-standard`, respecting `.gitignore`). Each scenario is reported separately on failure. `--dirty` override unchanged. Script header documents the policy. |
| 1.9.0 | 2026-05-18 | Ship the minimal runnable Python/uv/FastAPI preset (Codex Phase 1.2 + existing open item #6 — both resolved). New files in `templates/`: `pyproject.toml` (FastAPI + uvicorn runtime; pytest/httpx/ruff/mypy dev via PEP 735 `[dependency-groups]` so the existing `uv sync --frozen` CI step picks them up without flags; hatchling build-backend; tool config for ruff/mypy/pytest), `src/<package_name>/{__init__.py,app.py}` (FastAPI app exposing `/healthz` — matches `scripts/deploy.sh`'s post-deploy curl), `tests/{__init__.py,test_smoke.py}` (`TestClient` smoke test for `/healthz`), `LICENSE` (MIT with `<COPYRIGHT_HOLDER>` + `<YEAR>` placeholders). Single `<package_name>` placeholder convention across everything (including the `src/<package_name>/` directory name); bootstrap substitution is one mv + one sed (documented in the v1.9.0 CHANGELOG entry; auto-substitution in `scripts/bootstrap.sh` is a follow-up open item). Spec: B-012 added; open item #6 closed. |
| 1.8.0 | 2026-05-18 | Declare product identity (D-009): this template is a **Python/uv/FastAPI/VPS starter today**; multi-preset is roadmap, not current fact. Drops the "this document is project-agnostic" claim from §0 and replaces it with an honest paragraph naming current shipped scope; adds `§0.1 Current scope` making the stack-agnostic vs. Python-only boundary explicit. No templates change; no code change; only framing. Spec: D-009 added; "Open project-level decisions" tags stack-agnostic-restructure as "roadmap per D-009". Triggered by Codex's `codex improvement plan.md` (Phase 2 + Phase 12). |
| 1.7.1 | 2026-05-18 | Patch — three doc-consistency fixes surfaced by Codex's review of PR #1 (first dogfood of the v1.7.0 flow). (a) `templates/docs/pr_review_instructions.md` hardcoded `gh api` as the only transport; updated to match B-010's two-path rule (gh + native PR integration). (b) `templates/CONTRIBUTING.md §4` had snuck in "or by the user copy-pasting" as a third path; removed — B-010 doesn't sanction it. (c) `PROJECT_STARTER.md §2.7` told reviewers on this meta-repo to open `docs/pr_review_instructions.md`, but the repo only ships `templates/docs/pr_review_instructions.md`; added a one-line pointer file at `docs/pr_review_instructions.md` so the self-review path resolves. No behavior change; no spec change — three Codex findings (Block/Block/Strong) addressed by aligning surfaces to the already-canonical B-010. |
| 1.7.0 | 2026-05-18 | Remove all Claude-side reviewer wiring. The v1.6.0 local-CLI skill + Makefile target + `review gogogo!` verb are all deleted; `templates/docs/pr_review_instructions.md` preamble rewritten as reviewer-agnostic with no default reviewer named; §2.7 in this doc and §4 in `templates/CONTRIBUTING.md` rewritten as a short paragraph saying review is out-of-band. After `PR gogogo!`, the user opens any reviewer they prefer in a separate session, points it at the open PR and the rubric, and the reviewer posts comments via `gh` directly. Resolves the [P1] Codex flagged on the v1.6.0 branch (stdout-only skill couldn't satisfy the per-commit comment contract) by removing the contradiction at its source — Claude no longer claims a contract it can't satisfy. Spec: B-006/B-007/B-009 superseded by B-010 + B-011; D-005/D-007 superseded by D-008. |
| 1.6.0 | 2026-05-18 | Pivot `request-codex-review` skill + Makefile target from GitHub-App PR-comment (`gh pr comment @codex`) to **local CLI** (`codex review --base main`). Original design assumed a Codex GitHub App that doesn't exist on the user's account; the CLI has a purpose-built `review` subcommand that works synchronously and found three real bugs on its first dry run. §2.7 in this doc and §4 in `templates/CONTRIBUTING.md` updated with the new invocation flow and an output-format note (`[P1]/[P2]/[P3]`, not `Block/Strong/Nit` — `--base` is mutually exclusive with custom prompts in the CLI). GitHub App path documented as a fallback for accounts that have one. Spec: B-008 superseded by B-009; D-006 superseded by D-007 (with an honest "why it was wrong" note). |
| 1.5.1 | 2026-05-18 | Patch fixing three bugs surfaced by the first Codex CLI review (`codex review --base main`): (a) `docs/spec.md` prose hardcoded a version number that drifted past VERSION bumps — replaced with a pure VERSION reference; (b) `make request-codex-review` posted to closed/merged PRs without checking `.state` — now requires `state == OPEN`; (c) B-001's test pointer used a too-broad `grep -r 'code!' .` that would false-fail because CHANGELOG and Decision log retain historical mentions — narrowed to active gate-doc files only. |
| 1.5.0 | 2026-05-18 | §2.7 Codex invocation gains a **one-command shortcut**: the `request-codex-review` skill (`templates/.claude/skills/request-codex-review/SKILL.md`) and the matching `make request-codex-review` Makefile target. Both post the canonical PR-comment body that names `docs/pr_review_instructions.md` explicitly (load-bearing for Codex to use the project's rubric). Skill is async-and-done: posts one comment, confirms, stops; does not poll for results. Implements D-006 (this repo's `docs/spec.md`). |
| 1.4.0 | 2026-05-18 | §2.7 PR review reframed as **reviewer-agnostic**: same rubric + output contract for Codex / `/ultrareview` / other LLMs / manual. **Default reviewer: Codex** (cheap, independent, different model family). Adds reviewer matrix (cost / independence / when-to-use), Codex invocation steps (GitHub App install + PR-comment naming the rubric explicitly), and the "reviewers run serially, not in parallel" rule. `templates/docs/pr_review_instructions.md` gains a reviewer-agnostic preamble. `templates/CONTRIBUTING.md` §4 rewritten to match. The `review gogogo!` verb mapping intentionally unchanged — branch-owner triggers review out-of-session when the branch is finished. Implements D-005 (this repo's `docs/spec.md`). |
| 1.3.0 | 2026-05-17 | §2.1 gate rewrite: `gogogo!` is now the execute trigger only; it must be preceded by an action verb in the same message specifying *what* to execute. Adds verb→workflow table covering `code/feat/fix/... gogogo!` (full 5-step), `commit gogogo!`, `PR gogogo!`, `review gogogo!`, `merge gogogo!`, `deploy gogogo!`, `revert gogogo!`. Bare `gogogo!` is ambiguous and triggers a clarification question. §2.6 and §2.9 updated to reference the new explicit phrases. Same convention propagated to `templates/CLAUDE.md` and `templates/CONTRIBUTING.md` (cheat-sheet + TL;DR + gate section). Two new rationalizations added to the refuse-list. Implements D-004 (this repo's `docs/spec.md`). |
| 1.2.0 | 2026-05-17 | Rename gate passphrase `code!` → `gogogo!` (universal, stack-agnostic — not just for code edits). Add Karpathy's four LLM-coding pitfalls as standing rules in `templates/CLAUDE.md` and a full reference at `templates/docs/karpathy-claude-rules.md`. Add `spec-block` skill (`templates/.claude/skills/spec-block/SKILL.md`) plus a fixed Block format (`B-NNN` with Rule / Rationale / Test / Status / Decision) in `templates/docs/spec.md` to make the spec atomic and navigable. |
| 1.1.8 | 2026-05-07 | §11 + §2.7: explicit "Output contract" — every PR review must post per-commit GitHub comments via `gh api`, including a "no findings on `<sha>`" comment for clean commits. Local files, chat-only summaries, and PR-description edits are explicitly forbidden as substitutes. Closes the "was this commit reviewed and clean, or skipped by accident?" ambiguity in the prior wording. Template review skeleton (`templates/docs/pr_review_instructions.md`) and `templates/CONTRIBUTING.md` §4 carry the same contract. |
| 1.1.7 | 2026-05-07 | §14: `bootstrap.sh --export` on WSL also prints the Windows-translated path (via `wslpath`) so Windows-side tooling can pick the file up directly. macOS / native Linux unchanged — POSIX path is already the local path. |
| 1.1.6 | 2026-05-07 | §14: `bootstrap.sh` interactive menu gains `e` / `i` shortcuts for export/import (TUI parity with the `--export` / `--import` flags). |
| 1.1.5 | 2026-05-07 | §14 expanded: `bootstrap.sh` gains `--export [path]` and `--import <path>` for portable cred snapshots. Documents the migration flow (export → scp → import) as the primary cross-host credential transfer mechanism. |
| 1.1.4 | 2026-05-04 | §2.5 expanded with explicit "Commit message quality" subsection: bad/good subject examples, "explain the why in the body" rule, file/section-naming rule, `Refs #N` / `Implements D-NNN` references, no-fillers rule, the read-aloud-without-diff self-check, version-suffix requirement. |
| 1.1.3 | 2026-05-04 | §1.3 export-starter caveat: tar.gz always; .zip only if `zip` is installed (matches script's actual behavior on minimal Linux installs). |
| 1.1.2 | 2026-05-04 | Align workflow wording across all docs (Codex-audit fix): standardize merge path on `gh pr merge --rebase --delete-branch` (live `CONTRIBUTING.md` had stale `git merge --ff-only` in cheat-sheet, principles, TL;DR, §6); standardize 5-step step 2 wording on "bump versions + CHANGELOG entry" (TL;DR step 3 in `CONTRIBUTING.md` and §1.9 example commit message in this doc both said just "bump versions"). |
| 1.1.1 | 2026-05-04 | Add §1.3 "Quick path" pointing at `scripts/export-starter.sh` (one-command portable export of PROJECT_STARTER.md + templates/ as tar.gz + zip). |
| 1.1.0 | 2026-05-04 | Add §11 PR review heuristics, §12 Harness quirks, §13 Credential handling, §14 Bootstrap.sh design principles. Update §2.2 5-step to fold CHANGELOG entry into step 2 and Decision log entries into step 1. |
| 1.0.0 | 2026-05-04 | Initial extraction from phoenixtgstat_bot. Captures the `gogogo!` gate, 5-step workflow, push-every-commit, ff-only/rebase-merge strategy, multi-commit-per-branch, version-bump rule, branch protection setup, decision bank, audit-trail conventions, memory seed. |
