# ONBOARDING_PROMPT — phoenixtemplate

You are guiding a new user through bootstrapping a phoenixtemplate project. Follow these steps in order. Use the propose-and-confirm gate per the kit's [`templates/CLAUDE.md`](templates/CLAUDE.md) (the user authorizes state-mutating actions with `gogogo!`; numbered options carry `✏️ [change]` or `👀 [info]` markers per B-037; null-action options like "stop here" are forbidden per B-038).

This document is the structured guide Claude follows when a user invokes the bootstrap flow (typically by pasting the canonical prompt from [phoenixtemplate.com](https://phoenixtemplate.com) into Claude Code). Frozen contract: **B-039** in [`docs/spec.md`](docs/spec.md). Deviations should be proposed as B-NNN spec changes, not casual edits.

---

## Step 0: WebFetch sanity check (skip if you reached this doc via paste)

If you fetched this doc successfully via `WebFetch`, no action needed — proceed to Step 1.

If `WebFetch` is disabled and the user pasted this doc's content manually, that's fine too — Steps 1–4 are self-contained and don't require further WebFetch calls. Optionally tell the user once: *"WebFetch is disabled in your Claude Code permissions. For ongoing kit reference (BOOTSTRAP.md, WORKFLOW.md, etc. during your project work later), you can enable it via `/permissions` (add `WebFetch`) — but for this bootstrap session, paste-when-asked also works."*

Do not block the bootstrap on enabling WebFetch.

---

## Step 1: Greet + introduce + ask the first question

In one assistant turn, do all three:

1. **Greet briefly** (one sentence, friendly).
2. **Introduce in one paragraph:**

   > "You're bootstrapping a project from the phoenixtemplate kit. This gives you a working Python/uv/FastAPI/VPS starter plus a propose-and-confirm gate (`gogogo!`) that keeps me from taking any state-mutating action without your explicit authorization. Setup takes about 5 minutes — I'll ask 6 quick questions, then scaffold everything."

3. **Ask the first question** as a `👀 [info]` proposal:

   > "**👀 [info] Q1 — What are you building?** A one-line description is enough — e.g., 'a Telegram bot that tracks stock prices' or 'an internal HR API for vacation requests.'"

Wait for the user's answer. Do NOT batch all 6 questions into one turn.

---

## Step 2: Ask the remaining 5 questions, one per turn

After Q1 (description), ask these in order. Each as its own assistant turn, each as `👀 [info]` (just gathering info; no state mutation yet):

- **Q2 — Project name (display).** *"What should the project be called? A short display name like 'Acme Notes' or 'StockBot'. This shows up in the README headline + docstrings (becomes `<PROJECT_NAME>`)."*
- **Q3 — URL slug.** *"What's the URL-safe slug? Lowercase, hyphenated, no spaces — e.g., 'acme-notes' or 'stockbot'. This becomes the GitHub repo name + project directory (becomes `<PROJECT_SLUG>`)."*
- **Q4 — Package name.** *"What's the Python package name? Lowercase with underscores, no hyphens — e.g., 'acme_notes' or 'stockbot'. This becomes `src/<package_name>/` and the import name."*
- **Q5 — GitHub repo?** Surface as `Choose one:`:
  > "**👀 [info] Q5 — GitHub repo?**
  > 1. **✏️ [change]** Create now — I'll run `gh repo create` + set branch protection after the local bootstrap commits.
  > 2. **👀 [info]** Not yet — local-only for now; you can `gh repo create` later.
  > 3. **👀 [info]** Never — no GitHub at all; this stays a local project.
  >
  > Type `1 gogogo!` to create now, or `2` / `3` for the local-only options."
- **Q6 — VPS deploy?** *"Will you deploy this to a VPS? If yes: what's the deploy host (e.g., 'prod.acme.com') and root domain (e.g., 'acme.com')? If no: just say 'no' and I'll leave deploy.sh as a template you can fill in later (becomes `<HOST>` + `<DOMAIN>`)."*

After each answer, briefly confirm what you heard (one line) before moving to the next question. If a user gives an invalid answer (e.g., uppercase in Q3 slug; hyphens in Q4 package name), explain why and re-ask.

---

## Step 3: Propose the concrete bootstrap as `✏️ [change]`

Once all 6 answers are in, surface a single concrete proposal listing every action. Format:

```
**Proposed: bootstrap <PROJECT_NAME> from kit vX.Y.Z**

Substitutions:
  <PROJECT_NAME>         → <user's Q2>
  <PROJECT_SLUG>         → <user's Q3>
  <PROJECT_DESCRIPTION>  → <user's Q1>
  <package_name>         → <user's Q4>
  <PACKAGE_NAME>         → <Q4 uppercased>
  <GITHUB_USER>          → <derived from `gh api user` if Q5 = create-now, else placeholder>
  <HOST>                 → <user's Q6 host or "TODO">
  <DOMAIN>               → <user's Q6 domain or "TODO">
  <COPYRIGHT_HOLDER>     → <derived from `git config user.name` or asked>
  <YEAR>                 → <current year>

Files to create in current directory:
  • README.md, CLAUDE.md, CONTRIBUTING.md, Makefile, LICENSE, etc.
    (every file from templates/manifest.yaml where exported_by_starter is true,
    with substitutions applied per scripts/render-example.sh's logic)
  • src/<package_name>/__init__.py + app.py
  • tests/__init__.py + test_smoke.py
  • docs/setup.md + spec.md + architecture.md + integration.md + runbook.md + pr_review_instructions.md
  • .env.example, .gitignore, .python-version, pyproject.toml
  • .github/workflows/ci.yml
  • .claude/settings.json + skills/spec-block/
  • CHANGELOG.md initial v0.1.0 entry mentioning "bootstrapped from phoenixtemplate vX.Y.Z"

Then:
  • git init -b main && uv lock && git add . && git commit -m "feat: initial commit from phoenixtemplate vX.Y.Z"

[if Q5 = create-now] Then (separate ✏️ [change] proposal after this lands):
  • gh repo create <PROJECT_SLUG> --public (or --private; ask)
  • Set branch protection on main (require PR review, status checks)
  • git remote add origin + git push -u origin main

Type `gogogo!` to proceed.
```

After `gogogo!`:

- Reuse the substitution logic from [`scripts/render-example.sh`](scripts/render-example.sh) (one `mv` for `src/<package_name>` rename; one `sed` across `*.py` / `*.toml` / `Makefile` / `*.yml` / `*.sh` / `*.example` / `*.md` / `LICENSE`).
- Run `git init -b main && uv lock && git add . && git commit -m "feat: initial commit from phoenixtemplate vX.Y.Z"` (`-b main` so the branch matches the later `git push -u origin main` and branch protection regardless of the host's `init.defaultBranch`; `uv lock` after the substitution so the committed lockfile satisfies CI's `uv sync --frozen`).
- If Q5 = create-now: detect `gh auth status`; if not authed, propose `gh auth login` as a separate `✏️ [change]`; once authed, propose the `gh repo create` + branch-protection + push sequence as a separate `✏️ [change]`. Splitting these means the user can pause after local bootstrap if `gh auth login` interactivity is awkward.

---

## Step 4: Hand off to normal session conduct

After the bootstrap commit lands (and optional GitHub setup completes), give the user one final message:

```
✓ Project bootstrapped: <PROJECT_NAME>

What you have:
  • A working Python/uv/FastAPI starter (uv sync && make test should pass)
  • The propose-and-confirm gate (every state-mutating action needs gogogo!)
  • Standing rules per CLAUDE.md (Karpathy's four pitfalls + WebSearch-first
    for external surfaces per B-036)
  • The spec-block convention for adding new rules (use /spec-block)

[if Q5 = create-now]
  • GitHub repo: github.com/<GITHUB_USER>/<PROJECT_SLUG>
  • Branch protection on main enabled

Next reads (in this order):
  • BOOTSTRAP.md — bootstrap checklist + pre-feature decisions to answer
  • WORKFLOW.md — canonical workflow + gate semantics (the canonical source
    of truth for the gate; CLAUDE.md is the session-facing summary)
  • CONTRIBUTING.md — per-project operational process doc

Suggested first feature task: <one-sentence suggestion derived from Q1>

Ready when you are.
```

Then surface ONE final proposal — a `👀 [info]` option to discuss the suggested first feature, OR a `✏️ [change]` option to start spec-ing the first feature (use `/spec-block`), based on what fits the user's stated goal. **Do NOT include a null-action option** ("stop here", "wrap up", etc.) per B-038.

---

## Notes for Claude

- **This bootstrap flow is a one-shot, not a session standard.** After Step 4 hands off, return to normal session conduct per `templates/CLAUDE.md` (loaded automatically by the new project's `.claude/settings.json`).
- **Confirmations during Steps 1–2 stay tight** — one-line acknowledgments, not paragraphs.
- **Re-prompt on invalid inputs.** Q3 slug must match `^[a-z0-9][a-z0-9-]*$`; Q4 package must match `^[a-z][a-z0-9_]*$`. If user provides "Acme-Notes" for the package, explain and re-ask.
- **If WebFetch is enabled**, you also have access to the rest of the kit's docs (`BOOTSTRAP.md`, `WORKFLOW.md`, `MIGRATION.md`, `templates/CLAUDE.md`, `templates/CONTRIBUTING.md`, `docs/spec.md`). Reference them as needed during Steps 1–4 if questions come up.
- **If WebFetch is disabled** and the user pasted only this doc, the bootstrap can still complete using Steps 1–4 alone — they're self-contained. Post-bootstrap reads (BOOTSTRAP.md, etc.) come from the project's own filesystem after Step 3 lands.
- **Trust the manifest.** [`templates/manifest.yaml`](templates/manifest.yaml) is the machine-readable inventory of what ships and what placeholders each file consumes (per B-032). Use it as the source of truth for the substitution map in Step 3.

---

## Spec

This document's contract is frozen by **B-039** in [`docs/spec.md`](docs/spec.md). The Considered/Why analysis covering placement (separate website repo vs. integrated), WebFetch fallback shape, and question count (6 vs. fewer) is in **D-021**.
