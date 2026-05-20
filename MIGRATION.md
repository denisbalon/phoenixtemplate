# Migration

Adopting `phoenixtemplate` into an **existing** project — selectively or incrementally — rather than bootstrapping a greenfield project from scratch. Read this when you already have a repo and want to pull in specific pieces of the kit without rewriting everything you have.

**Spec:** B-034 in [`docs/spec.md`](docs/spec.md) — the kit is consumable as a toolkit, not only as a fresh-start template; this doc is the canonical guide for that path.

If you're starting fresh, [`BOOTSTRAP.md`](BOOTSTRAP.md) is the right doc instead — it walks you from zero to first commit. This doc assumes the project already exists.

---

**Want to see what a fully-rendered project looks like before deciding what to import?** Run `./scripts/render-example.sh` from this repo — produces a deterministic example with every canonical placeholder substituted (`PROJECT_NAME=ExampleProject`, `package_name=exampleproj`, etc.). Output lives at `~/Downloads/phoenixproject-example/` by default; override via `OUT_DIR=/path/to/wherever`. The script doesn't require uv or Python — just bash — so it's safe to run on any machine without setting up the dev environment first.

---

## When to use the full kit vs. import selected parts

| Situation | Path |
|---|---|
| Brand-new project, no constraints | Full kit — follow `BOOTSTRAP.md`. |
| Existing project, want to standardize on the `gogogo!` gate + spec-block format + Karpathy rules across an existing AI-coding workflow | "Process layer" import below. |
| Existing project, just want the PR review rubric or the spec-block authoring convention | "Docs" import below. |
| Existing project, struggling with `.env` setup + drift | "Env-bootstrap" import below. |
| Existing project, want the doc-consistency linters but not the rest | "Linter set" import below. |
| Existing project, want the whole kit eventually | Adoption order below — phase the import over weeks, not all at once. |

The four selective-import paths are designed to land cleanly in an existing project without breaking what's already there. Each ships as a small set of files with a known dependency surface.

---

## Importing just the process layer

The `gogogo!` propose-and-confirm gate + 5-step atomic workflow + per-project rules. This is the most-asked-for piece because it changes how AI sessions feel without touching the codebase.

**Files to copy** (from this kit's `templates/` into your project root):

```
templates/CONTRIBUTING.md            → CONTRIBUTING.md
templates/CLAUDE.md                  → CLAUDE.md
templates/.claude/settings.json      → .claude/settings.json
templates/.claude/skills/spec-block/ → .claude/skills/spec-block/
```

Plus the four C4-anchored rule regions need a canonical owner — copy `WORKFLOW.md` from this repo's root to your project root, OR fold the same rules into your existing process doc (your choice; B-021's three-tier model permits either as long as the trio of `WORKFLOW.md` + `CONTRIBUTING.md` + `CLAUDE.md` stays byte-exact across the four anchored regions: `gate-clause`, `proposal-format`, `bare-gogogo`, `env-metadata-contract`).

**Merging with existing `CONTRIBUTING.md` / `CLAUDE.md`:**

- Most existing `CONTRIBUTING.md` files don't define a `gogogo!`-style gate; insert the C4-anchored regions from `templates/CONTRIBUTING.md` at the top of your existing file, keep your project-specific sections (branching strategy, commit conventions, code review process) below.
- For `CLAUDE.md`: same pattern — the four C4 regions plus the standing Karpathy rules go at the top; project-specific stack / sensitive-context / coding-conventions sections from your existing `CLAUDE.md` (if any) stay below.
- Run `scripts/check-rule-consistency.sh` (see linter-set import below) to verify the C4 regions match across all three files; this catches accidental drift during the merge.

**What you gain:**

- Every assistant message ends with a concrete proposal classified `[change]` / `[info]`.
- State-mutating actions require `gogogo!` authorization against a specific surfaced proposal — no ambiguous "go ahead" / "do it" verbs.
- Multi-select against "Choose any (in order):" lists (`1 2 3 gogogo!`) covers multiple authorizations in one turn.

**What you don't get** (unless you also import the linter set): mechanical enforcement that the C4 regions stay byte-exact. The gate works without the linter, but rule drift across the trio becomes invisible without `scripts/check-rule-consistency.sh`.

---

## Importing just docs

The reviewer-agnostic PR review rubric, the Karpathy standing rules, the spec-block authoring convention. These are pure-docs artifacts with no behavioral surface to integrate — drop them into your `docs/` tree and link from your existing entry-point docs.

**Files to copy:**

```
templates/docs/pr_review_instructions.md   → docs/pr_review_instructions.md
templates/docs/karpathy-claude-rules.md    → docs/karpathy-claude-rules.md
templates/docs/spec.md                     → docs/spec.md   (only if you don't already have one)
templates/.claude/skills/spec-block/       → .claude/skills/spec-block/
```

**`docs/pr_review_instructions.md`** is reviewer-agnostic (B-010) — works with Codex CLI, `/ultrareview`, manual review, any LLM-based reviewer. Point your existing PR review automation (or your team's manual reviewers) at it. No coupling to `gogogo!` or any other kit-specific machinery.

**`docs/karpathy-claude-rules.md`** is the full reference text for the four standing rules (think before coding / simplicity first / surgical changes / goal-driven execution). If your existing `CLAUDE.md` already has its own standing-rules section, either replace it with the Karpathy four or merge by category — neither breaks anything.

**`docs/spec.md`** with the B-NNN block format (per B-004) is for projects that don't already have a spec doc. If you have one in a different format (RFC numbers, ADRs, free-form prose), keep yours — the format is a convention, not a binding. The `spec-block` skill (`/spec-block` slash command, invokable interactively to author one B-NNN block) is only useful if you adopt the format.

---

## Importing just env-bootstrap

The `.env.example` `@directive` schema (B-020) + the shared parser + the interactive `bootstrap.sh` populator + the CI-side `check-env.sh` gate. A self-contained four-file unit; no other parts of the kit need to be imported for this to work.

**Files to copy:**

```
templates/.env.example                  → .env.example
templates/scripts/_env-schema-parse.sh  → scripts/_env-schema-parse.sh
templates/scripts/bootstrap.sh          → scripts/bootstrap.sh
templates/scripts/check-env.sh          → scripts/check-env.sh
```

**Adapting `.env.example` to your variables:**

- Replace the example vars (`LOG_LEVEL`, `DEV_MODE`, `SENTRY_DSN`, etc.) with your project's actual environment variables.
- For each var, declare its metadata via `@directive` comments preceding the var declaration. Recognized directives (full vocabulary in B-020): `@description` (string) · `@required` (flag — default if neither given) · `@optional` (flag) · `@default` (string) · `@validator` (ERE regex) · `@sensitive` (flag; auto-detected for var-name substrings `TOKEN`/`SECRET`/`KEY`/`DSN`/`PASSWORD`).
- Free-text comments preceding a var are displayed in `bootstrap.sh` prompts but not parsed as metadata.

**Wiring into your project's `SessionStart` hook** (if you use Claude Code) — add to `.claude/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [
      { "type": "command", "command": "./scripts/check-env.sh" }
    ]
  }
}
```

When `check-env.sh` reports missing or empty vars, Claude walks the user through `scripts/bootstrap.sh` interactively.

**What you don't need:** the `Makefile`, the `templates/CLAUDE.md` env-metadata C4 region, or the rest of the kit. The four files above are self-contained. (Reading `templates/CLAUDE.md`'s `env-metadata-contract` C4 region is still useful as a one-paragraph summary of the directive vocabulary, but copying it isn't required for the env-bootstrap unit to work.)

---

## Importing just the linter set

The five drift-detection scripts. Useful for projects that have their own conventions and want mechanical enforcement, or that adopted the process layer (above) and want the gate-region drift check.

**Files to copy:**

```
scripts/check-rule-consistency.sh   → scripts/check-rule-consistency.sh   (B-022)
scripts/check-doc-references.sh     → scripts/check-doc-references.sh     (B-023, B-029)
scripts/check-placeholders.sh       → scripts/check-placeholders.sh       (B-024)
scripts/check-spec-consistency.sh   → scripts/check-spec-consistency.sh   (B-029)
scripts/check-manifest.sh           → scripts/check-manifest.sh           (B-033)
```

**Standalone-vs-coupled status:**

| Linter | Standalone? | Notes |
|---|---|---|
| `check-rule-consistency.sh` | Coupled to C4 regions | Edit the `FILES` and `REGIONS` arrays at the top of the script to match your project's anchored regions; otherwise it'll fail because it expects `WORKFLOW.md` etc. |
| `check-doc-references.sh` | Standalone | Walks every Markdown file in the repo; works on any repo. URL-fragment validation (B-029) is on by default. |
| `check-placeholders.sh` | Coupled to B-024 placeholder set | The `PLACEHOLDERS` array lists the canonical set; edit if your project uses different placeholders. |
| `check-spec-consistency.sh` | Coupled to active-doc list + forbidden-phrase patterns | Edit the `ACTIVE_DOCS` and `INV_*_PATTERNS` arrays to match your project's invariants. |
| `check-manifest.sh` | Requires `templates/manifest.yaml` | Useless without the manifest; only import this if you also adopt the manifest convention (B-032). |

**CI wiring** — add the relevant linters to your CI workflow. Pattern matches `.github/workflows/template-self-test.yml` in this repo:

```yaml
- name: check doc references
  run: ./scripts/check-doc-references.sh
- name: check rule consistency
  run: ./scripts/check-rule-consistency.sh
# ... etc
```

The two standalone-ish linters (`check-doc-references.sh` and a B-024-style placeholder check with your own placeholder set) give immediate value on any repo. The other three require local adaptation to your project's conventions.

---

## Adoption order

If you want the whole kit eventually but spread the import across weeks rather than landing it all at once, here's a sequence that minimizes per-step risk:

1. **Week 1 — process layer.** Copy `CONTRIBUTING.md` + `CLAUDE.md` + `.claude/settings.json` + `.claude/skills/spec-block/`. Adopt the `gogogo!` gate. Live with it for a week; you'll discover what doesn't fit your team's workflow.
2. **Week 2 — docs.** Add `docs/pr_review_instructions.md`, `docs/karpathy-claude-rules.md`. Point your reviewer (whatever it is) at the new rubric. Adopt the `spec-block` skill for new architectural decisions.
3. **Week 3 — env-bootstrap.** Migrate your existing `.env.example` to the `@directive` schema (B-020). Add `bootstrap.sh` + `check-env.sh` + `_env-schema-parse.sh`. Wire the `SessionStart` hook.
4. **Week 4 — standalone linters.** Add `check-doc-references.sh` and a customized `check-placeholders.sh` to CI. These give immediate broken-link / leaked-placeholder catches with low integration cost.
5. **Week 5+ — the coupled linters and the manifest.** Adopt `check-rule-consistency.sh` once your C4 regions are stable. Adopt `templates/manifest.yaml` + `check-manifest.sh` if you want machine-readable per-file inventory.

**Skipping a step is fine.** Each layer is independent. The process layer is the highest-leverage import; everything else compounds it.

**Reverting a step is fine.** Each layer is reversible — the gate is a doc convention, the linters are shell scripts, the env-bootstrap is four files. No persistent state, no schema migration, no database. If something doesn't work for your team, delete the files and you're back where you started.

---

## What this kit doesn't try to be

To set expectations correctly:

- **Not a framework.** The kit is conventions + linters + templates. No runtime, no library you import, no service to run. Once you adopt pieces of it, they're your files — diverge them however you need.
- **Not a Python-only kit, except today.** The shipped preset is Python/uv/FastAPI/VPS (D-009). The process layer (gate / spec-block / Karpathy / review rubric / env-bootstrap) is stack-agnostic and works for any language. Multi-preset support (Node, Go, no-runtime) is roadmap per B-030 / D-015 — not shipped today.
- **Not a forced-migration kit.** Once you adopt a version, you're not obligated to track upstream. Re-import later if you want; otherwise keep what you have. The kit ships no auto-updater.

---

## Questions or feedback

This doc is part of an active iteration. If a selective-import path is unclear, or your project's existing convention doesn't fit any of the patterns above, open an issue in this repo and we'll either document the integration or extract a new pattern from your case.
