# Changelog

All notable changes per `VERSION` bump. Per the `gogogo!` 5-step workflow, every change bumps `VERSION` and adds an entry here in the same commit.

Format: `## v<X.Y.Z> — YYYY-MM-DD` followed by bullets, optionally grouped by area.

---

## v1.23.1 — 2026-05-19

Mirrors `PROJECT_STARTER.md` template v1.23.1. **Sweep stale verb references left over from v1.23.0.** Pure doc cleanup — no rule changes, no spec changes. The v1.23.0 CHANGELOG entry explicitly announced this as the v1.23.1 follow-up.

### What was swept (6 files)

- **`templates/CONTRIBUTING.md`**:
  - Cheat-sheet table rows 14-15: `User says \`PR gogogo!\` / \`ready gogogo!\`` → `User \`gogogo!\`s a PR-open proposal`; `User says \`merge gogogo!\`` → `User \`gogogo!\`s a merge proposal`.
  - TL;DR sequence (lines 44-51): each item references verbs (`<verb> gogogo!`, `code gogogo!` + `feat/fix/chore/...`, `PR gogogo!`, `merge gogogo!`, `deploy gogogo!`); rewritten to propose-and-confirm phrasing. Item 2 now reads "No state-mutating action unless Claude's immediately preceding message contained a concrete proposal AND the user's current message contains `gogogo!` (or `N gogogo!` for a numbered choice). The proposal IS the contract — specific files, specific commands, specific commits. Bare `gogogo!` without a preceding proposal is invalid — Claude must ask for clarification."
  - Review section (lines 129, 131, 136): "Claude opens the PR on `PR gogogo!`" → "Claude opens the PR after a `gogogo!`-authorized PR-open proposal"; "Workflow after `PR gogogo!`" → "Workflow after the PR is opened"; "no `review gogogo!` verb" → "no review proposal flow"; "more `<verb> gogogo!`s" → "more `gogogo!`-authorized commits".
  - Canonical-scope marker (line 5): "the *why* behind the gate, the verbs, the 5-step structure" → "the *why* behind the gate, the propose-and-confirm semantics, the 5-step structure"; rule-statement list "(verb table, gate clause, bare-gogogo prompt, allowed-without-gate list, refuse-list)" → "(gate clause, proposal format, bare-gogogo prompt, allowed-without-gate list, refuse-list)"; C4 linter note "Codex plan Phase 3 #3, pending" → "`scripts/check-rule-consistency.sh`" (the linter has shipped since v1.19.0).
- **`templates/docs/pr_review_instructions.md`** line 5: "Claude opens the PR (`PR gogogo!`)" → "Claude opens the PR after a `gogogo!`-authorized PR-open proposal".
- **`PROJECT_STARTER.md`** §2 canonical-scope marker (line 193, the line just BEFORE the rewritten §2.1 — the gate region itself was rewritten in v1.23.0, but the preceding scope marker still carried verb-era prose): "gate semantics, action verbs, 5-step structure" → "gate semantics, propose-and-confirm contract, 5-step structure"; "(verb table, gate clause, ...)" → "(gate clause, proposal format, ...)"; "C4 consistency linter (Codex Phase 3 #3, pending)" → "C4 consistency linter (`scripts/check-rule-consistency.sh`)".
- **`CONTRIBUTING.md`** (meta root): line 7 "(gate, action verbs, 5-step, ...)" → "(the propose-and-confirm `gogogo!` gate, 5-step, ...)"; line 25 "C4 consistency linter (Codex plan Phase 3 #3, pending)" → "C4 consistency linter (`scripts/check-rule-consistency.sh`)".
- **`README.md`** two-layer table (line 13): "`gogogo!` passphrase gate + action-verb workflow, 5-step atomic..." → "`gogogo!` passphrase gate with propose-and-confirm semantics (Claude proposes concretely, user `gogogo!`s the proposal), 5-step atomic...".
- **`docs/spec.md`** B-010 Rule field (line 57): "no skill, no Makefile target, no verb, no reminder" → "no skill, no Makefile target, no review-specific proposal flow, no reminder"; "After `PR gogogo!`, the user opens whichever reviewer..." → "After Claude opens the PR (per a `gogogo!`-authorized PR-open proposal), the user opens whichever reviewer...". B-010's rule itself (PR review is out-of-band and reviewer-agnostic) is unchanged — only the prose mentions of a now-defunct verb concept.

### What stays untouched (intentional audit trail)

- **`CHANGELOG.md`** rows for v1.0 through v1.22.0 — all historical changelog entries describing how the project evolved through the verb era. Past-tense by construction.
- **Template-changelog rows in `PROJECT_STARTER.md`** for past versions — same.
- **`docs/spec.md` historical-superseded section** (B-001, B-006, B-007, B-008, B-009, B-011, B-013, B-018) — each block is preserved as the rule that WAS in force at some prior version, with a supersession status note. Modifying their content would corrupt the audit trail.
- **`docs/spec.md` decision-log Chose/Considered/Why fields** for D-001 through D-009 — past decisions are preserved verbatim (per the decision-log convention at the top of the section: "Decisions live forever in the repo"). D-004's status note at the top points at D-010; the original Chose/Considered/Why stays as the historical record.
- **Active block content in B-021 / B-022 / B-026 / D-010** that legitimately describes the v1.23.0 transition (e.g. "The `verb-table` region was retired in v1.23.0 when B-026 replaced the verb-prefix gate model") — this is current-state context, not stale prose. The references to "verbs" / "verb table" / "action verb" in these blocks are about the model being SUPERSEDED, not the current one.

### What's NOT in this commit (deliberately)

- No spec changes — no new B blocks, no decision-log entries. The rules from v1.23.0 are unchanged; only prose that hadn't caught up gets the update.
- No changes to the linter scripts or CI wiring.
- No structural reorganization (the `PROJECT_STARTER.md` split sequence continues separately at v1.22.1 / v1.22.2 for WORKFLOW.md and BOOTSTRAP.md).

### Verified locally

- All three linters green: C4 rule-consistency (3 regions byte-exact across the doc trio — unchanged from v1.23.0), C2 doc-references (links still resolve), C3 placeholders (no canonical placeholders leaked into prose).

### Next

- **v1.22.1 (`refactor gogogo!`):** Extract `WORKFLOW.md` from `PROJECT_STARTER.md` §2 + §9 + §10 + §11. Coordinates with the C4 linter's `FILES` array (target shifts from `PROJECT_STARTER.md` to `WORKFLOW.md`). Updates B-021's tier table to drop the `(post-split: WORKFLOW.md)` parenthetical. Adds `WORKFLOW.md` to `ROOT_DOCS` + `VIRTUAL_TEMPLATES_FILES`. This is the queued 2 of 3 from the PROJECT_STARTER.md split sequence.

## v1.23.0 — 2026-05-19

Mirrors `PROJECT_STARTER.md` template v1.23.0. **Gate model rewrite — most invasive change in this project's history.** The verb-prefix gate (`feat gogogo!`, `commit gogogo!`, `merge gogogo!`, etc.) is replaced by propose-and-confirm. Triggered by user feedback that the verb system put cognitive burden on the user (remember nine verbs, remember mapping) while only encoding action TYPE, not action SCOPE — a `commit gogogo!` could commit anything Claude had staged. The new model inverts that.

### The new gate (B-026)

> No state-mutating action proceeds unless ALL of: (a) Claude's immediately preceding assistant message contained a concrete proposal — single suggestion or numbered list of choices, with specific files / commands / commits named, not vague phrasing; (b) the user's CURRENT message contains the literal substring `gogogo!`, optionally preceded by a digit selecting one option from a numbered list (e.g. `2 gogogo!`); (c) the action Claude takes is exactly what the proposal described — mid-execution deviation requires a new proposal.

What changes in practice:

- **No more verbs.** The action description lives in Claude's proposal in plain English. `feat gogogo!`, `commit gogogo!`, `PR gogogo!`, etc. all collapse into "Claude proposes the concrete plan, user `gogogo!`s." The workflows themselves (full 5-step, commit-only, PR open, merge, deploy, revert) still exist as action shapes — they're just named in the proposal text.
- **Multi-step ergonomics preserved.** A 5-step feature workflow is still authorized by one `gogogo!`. Claude enumerates the full plan in the proposal upfront (Step 1: spec; Step 2: bump+CHANGELOG; etc.) and one `gogogo!` confirms the whole plan. Same total typing as before; the verb is just gone.
- **Numbered choice for ambiguity.** When there are two-plus plausible paths, Claude presents a numbered list ending with `Type 1 gogogo! or 2 gogogo!`. The user selects with `N gogogo!` (or just `gogogo!` if only one path is offered).
- **Bare `gogogo!` without prior proposal** → reply *"I haven't proposed anything concrete yet. Describe what you'd like and I'll surface options."* This replaces today's "Which action? code / commit / PR / merge / deploy / revert?" prompt.
- **Conversation drift catches.** If Claude's last message was clarification rather than a fresh proposal, the next `gogogo!` does NOT authorize — Claude must re-propose. The "immediately preceding message" constraint in condition (a) is load-bearing for this.

### Canonical proposal format (B-026 + B-022)

The proposal format is byte-exact-matched across the doc trio by C4 linter region `proposal-format`:

- **Single suggestion** — a bold "Proposed: <action>" header, a concrete plan (specific files / commands / commits), and a final line inviting `gogogo!` to proceed.
- **Numbered choice** — a bold "Choose:" header, numbered options (each one concrete), and a final line inviting `N gogogo!` to pick option N.

Concrete means specific files, specific commands, specific commits — not "commit the changes." For multi-step actions, every step is enumerated.

### Failure-mode analysis (why this is safer, not just different)

- **D-004's original failure** ("agent picks wrong workflow on bare authorization") is preserved. Bare `gogogo!` is still invalid — the corrective surface just moves from a user-typed verb to a Claude-surfaced concrete proposal.
- **New failure mode the propose model PREVENTS:** "agent picks wrong file/scope under a correctly-formed verb." Verbs only encoded action TYPE; the proposal encodes everything down to the commit message.
- **New failure mode it could INTRODUCE:** "agent proposes vaguely (`commit the changes`), user `gogogo!`s, agent picks wrong scope." Mitigated by B-026 condition (a)'s explicit "concrete" requirement — vague proposals don't satisfy the gate, and the canonical `proposal-format` region makes "concrete" mechanically inspectable.
- **Another new failure mode it could INTRODUCE:** "user `gogogo!`s after long Q&A drift, expecting old proposal still valid." Mitigated by the IMMEDIATELY-PRECEDING-MESSAGE constraint — drift triggers re-propose, not action on stale plan.

### Files touched

- **`scripts/check-rule-consistency.sh`** REGIONS array: `verb-table` removed, `proposal-format` added. The three regions are now `gate-clause` + `proposal-format` + `bare-gogogo`.
- **`PROJECT_STARTER.md` §2** fully rewritten: new gate clause + new proposal-format section + new bare-gogogo handling + new self-check (4 steps instead of 3) + sweep of verb references in §2.2/§2.6/§2.7/§2.9. Refuse-list table gains two new rows ("Reality deviated mid-action" and "Proposal was several messages ago"). Allowed-without-gogogo list gains "proposing (the propose-then-wait pattern itself never requires `gogogo!`)."
- **`templates/CONTRIBUTING.md`** gate section fully rewritten to match — same three regions byte-exact, same self-check, same refuse-list updates. Surrounding prose framed as per-project operational.
- **`templates/CLAUDE.md`** gate section fully rewritten to match — same three regions byte-exact. The "Canonical scope" header marker updated to name proposal-format instead of verb-table in the duplicated-rule list. Surrounding prose framed as session-facing summary.
- **`docs/spec.md`** surgery: **B-001** and **B-011** moved to the historical-superseded section with `**Status:** superseded by B-026 (v1.23.0)` notes that preserve the original Rule/Rationale/Test for audit. **B-026** added as the new frozen gate rule. **D-004** marked superseded by D-010 with a status note at the top (original Chose/Considered/Why preserved). **D-010** added at the end of the decision log with the full failure-mode analysis. **B-021** content updated in place: the duplicated-rule-statement list now names `gate-clause` / `proposal-format` / `bare-gogogo`; the Test field switched from "manual until C4 linter ships" to "automated via B-022" (this should have happened in v1.19.0 but caught up here). **B-022** content updated in place: the three named regions and the addition/removal rules reflect the new set.

### What stays the same

- `gogogo!` is still the gate token. The literal-substring check (B-001 condition) survives as B-026 condition (b).
- Memory writes (`~/.claude/projects/.../memory/`) and `.claude/settings.local.json` remain carved out — no `gogogo!` needed.
- The refuse-list (rationalizations to refuse) still applies — `yes`, `do it`, "user is rushing", "auto mode says minimize interruptions" — all still NOT authorization.
- The 5-step workflow shape (spec → bump+CHANGELOG → code → commit+push → deploy) is unchanged. So are PR / merge / deploy / revert workflows. Only the triggering changed.
- Auto mode still does NOT override the gate.

### Spec

- **B-001** → moved to Historical blocks; superseded by B-026.
- **B-011** → moved to Historical blocks; superseded by B-026.
- **D-004** → status note added (superseded by D-010); original Chose/Considered/Why preserved for audit.
- **B-026** added (frozen) — the new gate rule + full rationale + failure-mode analysis.
- **D-010** added — the gate-model decision, including the failure-mode analysis at decision level (not just block level).
- **B-021** content updated in place — three-tier model's duplicated-rule list now names the new regions.
- **B-022** content updated in place — REGIONS array contents and the region-add/remove procedure.

### Next

- **v1.23.1 (`refactor gogogo!`):** Sweep remaining repo references to action verbs — CHANGELOG history is naturally preserved as audit trail (historical mentions stay), but any active doc that still describes the verb model gets updated. Likely candidates: README.md (if it mentions verbs), templates/README.md, templates/docs/*, this CHANGELOG entry's "Next" section becomes whatever's next on the roadmap (v1.22.1 WORKFLOW.md extraction, queued from the prior split sequence).

## v1.22.0 — 2026-05-19

Mirrors `PROJECT_STARTER.md` template v1.22.0. **First of three commits splitting `PROJECT_STARTER.md` (Codex Phase 4 #2).** Three companion docs shipped at meta-repo root; the remaining two (`WORKFLOW.md`, `BOOTSTRAP.md`) ship in v1.22.1 and v1.22.2.

### Why staged across three commits

The linter trio (B-022 / B-023 / B-024) shipped in v1.19.0–v1.21.0 was the gating prerequisite for this refactor. Splitting an 1100-line file five ways in a single commit is hard to review and easy to silently drop content from. Staging across three commits lets each commit be independently green:

- **v1.22.0 (this release):** extract three docs that don't touch any C4-linter anchored region (those live in §2). Lower coordination cost.
- **v1.22.1:** extract WORKFLOW.md (§2 + §9 + §10 + §11). Same commit retargets `scripts/check-rule-consistency.sh` `FILES` array from `PROJECT_STARTER.md` to `WORKFLOW.md` so the C4 linter's three rule regions follow the canonical content.
- **v1.22.2:** extract BOOTSTRAP.md (§0 + §1 + §5). Reduces PROJECT_STARTER.md to a thin ~50-line index.

### What shipped

- **`TEMPLATE_INVENTORY.md`** — extracted §3 (file/folder layout tree + folder ownership notes) and §4 (the `templates/` copy-paste reference table with placeholders per file). The table picked up a v1.14.1-era entry for `templates/scripts/_env-schema-parse.sh` (the shared `@directive` parser) that was missing pre-split, and the `.env.example` row gained a reference to B-020. Otherwise content is verbatim.
- **`DEPLOY_BASELINE.md`** — extracted §6 (VPS deploy: DNS / TLS / reverse proxy / service user / systemd / firewall), §7 (CI/CD baseline YAML template + auto-deploy deferred), and §13 (credential handling: never paste in chat / leak-handling protocol / Read+Edit tool-path / masking pattern / no-asking-in-chat). Subsections renumbered to bare headings (no §6.1 → §6.6 ladder) since they're top-level inside the new file. The reverse-proxy section's "§6.2" internal cross-reference rewrote to "TLS section above."
- **`HARNESS_QUIRKS.md`** — extracted §12 (harness quirks: permission gating / SSH gating / TTY-bound commands / `gh` CLI quirks / memory carve-out / branch protection vs. local merge / auto-mode-vs-gate) and §14 (`bootstrap.sh` design: five modes / migration via export+import / comment-block-per-var / optional-vs-required via `@directive` schema / sensitive-value masking / per-var `@validator` regex / input normalization / atomic save / no GUI). §14's "Optional vs required" and "Format validators" subsections were lightly updated in-line to reference B-020's `@directive` schema rather than the legacy prose-grep / hardcoded-regex behavior they superseded — the rest is verbatim.

### What stays in `PROJECT_STARTER.md`

§0 (How to use + scope), §1 (Bootstrap checklist), §2 (the workflow + gate — staying for v1.22.1), §5 (Decisions to answer — staying for v1.22.2), §8 (Audit trail + Decision log), §9 (Conventions — staying for v1.22.1), §10 (Memory seed — staying for v1.22.1), §11 (PR review heuristics — staying for v1.22.1), and the Template changelog tail. §0.2 Reading order rewritten to reference the three new files. Extracted sections retain their heading + a one-line `**Moved to [X.md](X.md) in v1.22.0.**` pointer so readers find the new location and section numbering stays stable across intermediate states.

### Export script + linter coordination

- **`scripts/export-starter.sh`** gained a `ROOT_DOCS` array (`PROJECT_STARTER.md`, `TEMPLATE_INVENTORY.md`, `DEPLOY_BASELINE.md`, `HARNESS_QUIRKS.md`). All four are copied into the archive stage alongside the flattened `templates/` contents, so PROJECT_STARTER.md's cross-links to its companion docs resolve in the consumer's extracted layout. Missing any of them is now a hard failure at export time.
- **`scripts/check-doc-references.sh`** `VIRTUAL_TEMPLATES_FILES` was extended from `[PROJECT_STARTER.md]` to all four root docs, keeping it in sync with `ROOT_DOCS`. The two arrays must always match; both files name each other in their comments. (No template-side links to the new docs exist today, but future ones will resolve correctly.)
- **`scripts/check-rule-consistency.sh`** unchanged in v1.22.0 — its `FILES` array still points at `PROJECT_STARTER.md` because §2 (the source of the three anchored rule regions) hasn't moved yet. v1.22.1 will retarget it to `WORKFLOW.md` in the same commit that moves the anchors.

### Spec

- **B-025** added (frozen) — captures the three-commit split rationale, stub-with-pointer convention, and the `ROOT_DOCS` / `VIRTUAL_TEMPLATES_FILES` coordination requirement.
- **B-015** archive-layout rule updated in place: described archive contents change from "PROJECT_STARTER.md + templates contents" to "`ROOT_DOCS` array + templates contents", with a note that adding a new root doc requires appending to both `ROOT_DOCS` AND `VIRTUAL_TEMPLATES_FILES` in the same commit. Pre-v1.22.0 archive shape (PROJECT_STARTER.md only at root) noted for audit trail.
- **B-023** doc-reference linter description updated to name all four entries currently in `VIRTUAL_TEMPLATES_FILES`.

### README

"Known limitations" section updated: the `PROJECT_STARTER.md` monolith bullet rewrites to describe split progress + remaining work; the drift-detection bullet rewrites to credit the now-shipped linter trio. Docs table gains rows for the three new files.

### Next

- **v1.22.1 (`refactor gogogo!`):** Extract `WORKFLOW.md` (from §2 + §9 + §10 + §11). Retarget B-022 C4 linter's `FILES` array. Update B-021's `(post-split: WORKFLOW.md)` parenthetical to past tense. Spec: update B-021 + B-022 in place.

## v1.21.0 — 2026-05-19

Mirrors `PROJECT_STARTER.md` template v1.21.0. **Codex Phase 8 #3 — placeholder linter.** Closes the third and final linter in the trio that gates the upcoming safe `PROJECT_STARTER.md` split.

### Ship `scripts/check-placeholders.sh` + CI wiring

The template's bootstrap surface defines a canonical set of placeholders that consumers `sed` away on first commit: `<package_name>` (lowercase, package import name); plus `<PACKAGE_NAME>` / `<PROJECT_NAME>` / `<PROJECT_SLUG>` / `<GITHUB_USER>` / `<HOST>` / `<DOMAIN>` / `<PROJECT_DESCRIPTION>` / `<COPYRIGHT_HOLDER>` / `<YEAR>` (the broader set). These belong in `templates/` files (where they're load-bearing) and in meta-repo `*.md` files only inside backticks (where they're documentation of the placeholder concept). What they must never be: out in plain prose of a meta-repo doc — that reads as "the docs shipped with TODO markers."

Until now, that invariant was held only by review attention. The new linter enforces it mechanically:

- **Scope.** Walks meta-repo `*.md` files only — `README.md`, `CONTRIBUTING.md`, `PROJECT_STARTER.md`, `CHANGELOG.md`, and `docs/*.md`. Excludes `templates/` (placeholders expected there) and the external Codex improvement plan (frozen content). Six files in total today.
- **Code-span / fenced-block stripping.** Reuses the same approach as the doc-reference linter (B-023): lines starting with three backticks toggle the fence state and fenced-block lines are emitted as blank lines (line numbers stay in sync with the source file); inline single-backtick spans are stripped before scanning. So a sentence that mentions `<package_name>` inside backticks stays fine — the writer is referencing the placeholder concept, not waiting for substitution.
- **Canonical-set only.** The linter checks the 10-item canonical set explicitly. Generic angle-bracket meta-syntax used elsewhere in prose (`<verb>`, `<file>`, `<region>`, `<X.Y.Z>`, etc.) is not in the set and is not flagged — the repo uses `<X>` as a general placeholder convention for many documentation purposes, only a subset of which are substitution placeholders.
- **Non-.md files NOT scanned.** Meta-repo `*.sh` / `*.py` / `*.toml` files do contain canonical placeholder strings in comments or docstrings (e.g. `scripts/check-doc-references.sh` mentions `<package_name>` in a comment describing what it parses), but those don't render to users and won't surprise a consumer. Markdown is the user-facing surface; that's where the invariant matters.
- **Output.** Clean: `OK: no canonical placeholders found in plain prose across 6 meta-repo files.` (exit 0). Failure: `<file>:<line> -> <placeholder>` per occurrence on stderr, followed by `FAIL: <N> canonical placeholder occurrence(s) leaked into plain prose across 6 meta-repo files.` (exit 1).
- **CI wiring.** `.github/workflows/template-self-test.yml` gains a `check-placeholders` step between `check-doc-references` (B-023) and the smoke test (B-014). Push or PR drift fails the build.

### The C-linter trio is now complete

This closes the trio of mechanical checks for canonical-doc invariants:

- **C4 — rule-consistency** (B-022, v1.19.0): the three deliberately-duplicated rule regions (gate clause, verb table, bare-gogogo prompt) stay byte-exact across `PROJECT_STARTER.md` / `templates/CONTRIBUTING.md` / `templates/CLAUDE.md`.
- **C2 — doc references** (B-023, v1.20.0): every `[label](target)` Markdown link target resolves to a shipped file or directory.
- **C3 — placeholders** (B-024, this release): no canonical substitution placeholder leaks into user-facing prose.

Together they make the upcoming `PROJECT_STARTER.md` split (Codex Phase 4 #2 — break the 1000-line monolith into `BOOTSTRAP.md` / `WORKFLOW.md` / `TEMPLATE_INVENTORY.md` / `DEPLOY_BASELINE.md` / `HARNESS_QUIRKS.md`) safe to do mechanically: file moves and reference rewrites can't silently break rule duplication, link resolution, or placeholder presentation without CI failing.

### Spec

- **B-024** added (frozen) — C3 placeholder linter contract: scope, canonical placeholder set, code-span handling, CI integration, error format.

### Next

- **v1.22.0 (`refactor gogogo!`):** Split `PROJECT_STARTER.md` (Codex Phase 4 #2). Five focused docs; PROJECT_STARTER.md becomes a thin index + canonical authoring source. The linter trio guards the move.

## v1.20.0 — 2026-05-19

Mirrors `PROJECT_STARTER.md` template v1.20.0. **Codex Phase 8 #2 — doc-reference linter.** Resolves B-016's "manual until C2 linter ships" caveat.

### Ship `scripts/check-doc-references.sh` + CI wiring

B-016 (v1.11.1) established the invariant that every live doc reference resolves to a shipped file or is an explicit example. Until now enforcement was a manual audit on each release-prep — fast to forget, easy to regress. Every prior rename or removal of a file (e.g. `request-codex-review` skill, `validators.sh` sidecar, `WEBHOOK_BASE_URL` env var) was one missed `grep` away from leaving a dangling `[..](..)` link somewhere in the docs.

The new linter resolves that:

- **Scope.** Walks every `*.md` file in the repo (excluding `.git/`). Extracts only Markdown link targets of the form `[label](target)` via an awk pattern that handles multiple links per line. Skips fenced code blocks entirely (lines starting with three backticks toggle the fence state) and strips inline single-backtick code spans before scanning, so docs that show the literal Markdown link syntax inside backticks (like this very entry) don't false-trigger. Skips `http://` / `https://` / `mailto:` / `tel:` / `data:` / `ftp://` URLs, anchor-only links (`#section`), autolinks (`<url>`), and empty targets. Strips a trailing `#anchor` or `?query` from the target before the existence check, so `PROJECT_STARTER.md#01-current-scope` is checked as `PROJECT_STARTER.md`. Strips optional Markdown link titles (`[label](path "Title")`). Existence is checked with `[ -e ]` so directory targets like `[templates/](templates/)` pass.
- **Resolution.** Relative targets resolve from the linking file's directory; absolute targets (starting `/`) from the repo root. Paths are normalized via `realpath -m --relative-to="$REPO_ROOT"` (no existence requirement during normalization).
- **Export-layout awareness.** Links inside `templates/` are authored against the consumer's project layout, where the export script flattens templates contents next to `PROJECT_STARTER.md`. To match that, the linter accepts targets that resolve to `templates/<f>` for any `<f>` in `VIRTUAL_TEMPLATES_FILES` (currently just `PROJECT_STARTER.md`) as long as `<f>` exists at meta-repo root. Without this rule, two existing valid links would false-positive: `templates/README.md:19 → PROJECT_STARTER.md` and `templates/docs/spec.md:13 → ../PROJECT_STARTER.md`. Updating the export script to promote additional files requires appending to this list.
- **Backtick paths are NOT linted.** A deliberate scope choice — the false-positive rate on backtick paths is high because much of the prose in `README.md` and `PROJECT_STARTER.md` describes the consumer's layout (`src/<package_name>/...`) or shows illustrative examples rather than this repo's actual files. Markdown link syntax has explicit semantic intent ("this is a navigable reference"), which gives a high signal-to-noise ratio.
- **Output.** On clean run: `OK: 50 Markdown link targets resolved across 19 files.` (exit 0). On any failure: one line per broken link as `<file>:<line> -> <target>  (resolved: <normalized>)` to stderr, followed by `FAIL: <N> broken doc reference(s) across 19 files (<scanned> links scanned).` (exit 1).
- **CI wiring.** `.github/workflows/template-self-test.yml` gains a `check-doc-references` step between the existing `check-rule-consistency` step and the smoke test. Push or PR drift fails the build.

### Spec

- **B-023** added (frozen) — C2 doc-reference linter contract: scope, resolution rules, export-layout awareness, CI integration, error format.
- **B-016** test method updated from manual `find` + grep to automated via B-023. Manual audit remains as backup for the "explicit example" / "placeholder" / "prescriptive recommendation" sub-categories that no machine check covers cleanly.

### Next

- **v1.21.0 (`feat gogogo!`):** Placeholder linter (Codex Phase 8 #3). Enumerates allowed placeholders (`<package_name>`, `<PROJECT_NAME>`, `<GITHUB_USER>`, `<HOST>`, `<DOMAIN>`, `<PROJECT_DESCRIPTION>`, `<COPYRIGHT_HOLDER>`, `<YEAR>`); fails CI on unresolved placeholders in meta-repo files (excluding `templates/`). Closes the linter trio that gates the safe `PROJECT_STARTER.md` split coming after.

## v1.19.0 — 2026-05-19

Mirrors `PROJECT_STARTER.md` template v1.19.0. **Codex Phase 8 #4 — consistency linter for canonical workflow phrases.** Resolves B-021's "manual until C4 linter ships" caveat.

### Ship `scripts/check-rule-consistency.sh` + CI wiring

B-021 (v1.18.0) made the three-tier doc redundancy load-bearing — rule statements (verb table, gate clause, bare-`gogogo!` prompt) are deliberately duplicated across `PROJECT_STARTER.md` §2 / `templates/CONTRIBUTING.md` / `templates/CLAUDE.md` as defensive AI-safety equipment. Without a mechanical check, one careless edit could silently drift the copies and reopen the failure mode B-021 was designed to prevent.

The new linter resolves that:

- **Anchors.** Each of the three canonical rule regions in each of the three files is bracketed by HTML-comment markers `<!-- C4:<region>:start --> ... <!-- C4:<region>:end -->`. HTML comments are invisible in rendered markdown so the source layout stays clean, but bash + awk can locate them trivially. Regions in v1.19.0: `gate-clause`, `verb-table`, `bare-gogogo`.
- **Linter.** `scripts/check-rule-consistency.sh` walks all three files for each region, extracts the content between matching anchors, and diffs every pair (against the first file as reference). Missing region in any file → fail with `ERROR: region '<name>' missing or empty in <file>`. Mismatched region → fail with a unified diff naming the two files and the drifted lines. Clean run prints `OK: canonical rule regions match across 3 files.` and exits 0.
- **CI wiring.** `.github/workflows/template-self-test.yml` gains a `check-rule-consistency` step that runs before the existing smoke test. Push or PR drift fails the build.

### Pre-linter alignment (same commit)

Byte-exact match required normalizing existing-but-divergent wording in the three files first:

- `templates/CLAUDE.md` gate clause: `**Never take any state-mutating action...**` → `**Do NOT take any state-mutating action...**` (matches the canonical wording already present in `PROJECT_STARTER.md` §2.1 and `templates/CONTRIBUTING.md`).
- `PROJECT_STARTER.md` §2.1 verb table: collapsed from 3 columns (Phrase / Action / Workflow) to the 2-column shared form (Phrase / Action) used by the other two tiers. The dropped Workflow column carried §-references (e.g. `5-step (§2.2)`, `§2.5 only`); those moved to a prose sentence immediately below the table so the operational detail isn't lost. Action wording also unified — `Full feature change` → `Full 5-step workflow (spec → bump+CHANGELOG → code → commit+push → deploy)`, etc.
- Bare-`gogogo!` prompt: unified across all three files to a standalone bold paragraph `**Bare `gogogo!` (no verb) is ambiguous** → reply *"Which action? code / commit / PR / merge / deploy / revert?"* and STOP. Review is out-of-band — no verb for it.` In `templates/CONTRIBUTING.md` and `PROJECT_STARTER.md` §2.1, the conflicting bullet in the existing self-check list (which had slightly different phrasing in each file) now reads `Bare `gogogo!` (no verb) → see the canonical prompt above.` — the self-check still walks the four outcomes but no longer duplicates the canonical wording.

### Adding regions in future versions

Append a `C4:<new-region>:start/end` pair (same canonical text in all three files) and add the region name to the linter's `REGIONS` array. No parser changes; the linter is region-name-agnostic.

### Spec

- **B-022** added (frozen) — C4 rule-consistency linter contract: anchor format, three regions, CI integration, drift behavior.

### Next

- **v1.20.0 (`feat gogogo!`):** Doc-reference linter (Codex Phase 8 #2). Parses `*.md` for local file references and verifies existence; closes the P1 #4 audit loop mechanically.

## v1.18.0 — 2026-05-18

Mirrors `PROJECT_STARTER.md` template v1.18.0. **Codex Phase 1 #1 — three-tier doc-canonical model with deliberate AI-safety redundancy.**

### Mark canonical scope across PROJECT_STARTER / CONTRIBUTING / CLAUDE; preserve protective rule duplication

The original Codex Phase 1 #1 framing was "choose one canonical source for workflow policy" (per the design proposal). User pushback caught a critical historical context I'd missed: *"we had 3 places to hold the rules, just because you were constantly missing them."* The triple-source layout wasn't accidental architecture debt — it was defensive redundancy added empirically after each observed AI failure (missed gate, wrong verb mapping, ignored bare-gogogo handling).

The refined framing: **one canonical source per concern, but rule statements stay deliberately duplicated for AI safety.** Three tiers:

- **`PROJECT_STARTER.md` §2** (or post-split `WORKFLOW.md`) — canonical for **core workflow rules + rationale + alternatives + design philosophy**. The "why" lives here exclusively.
- **`templates/CONTRIBUTING.md`** — canonical for **per-project operational concretization** (commands, sequences, per-stack version markers, deploy specifics). References PROJECT_STARTER for *why*. Carries rule statements inline as defensive redundancy.
- **`templates/CLAUDE.md`** — **session-facing summary** the AI loads every session. Carries gate clause, verb table, bare-gogogo prompt, allowed-without-gate list, refuse-list inline — **not as pointers** — because the AI needs them in working context to apply them. Stripping these to pointers was observed historically to cause failures.

Each of the three files now starts with an explicit `**Canonical scope:**` header marker declaring what it owns and naming the other tiers' canonical sources. Sections carrying duplicated rule statements are annotated as deliberate-redundancy with a "keep in sync" note.

**What's deduplicated (safe to remove):** rationale, "why we chose this," alternative-considered narrative, design philosophy. These live canonically in PROJECT_STARTER and are NOT repeated in CONTRIBUTING/CLAUDE.

**What stays duplicated (deliberate AI-safety equipment):** verb table; gate clause; bare-gogogo clarification prompt; allowed-without-`gogogo!` list; refuse-list (rationalizations to refuse); "phrases that look like authorization but aren't." All three files carry these verbatim.

### Sync mechanism

Manual until the C4 consistency linter ships (Codex Phase 3 #3 in current plan). The linter is now higher priority than the original ordering suggested — without it, the deliberate redundancy is one careless edit away from silently drifting. **Next planned commit: build the C4 linter (`feat gogogo!`).** Order reversed from my original "linter first" recommendation per user direction on this commit.

### Plus: thin root CONTRIBUTING.md for the meta repo

Until now we worked on `phoenixprojecttemplate` (the meta repo) by reading `templates/CONTRIBUTING.md` mentally. Added a minimal root `CONTRIBUTING.md` (~30 lines) that points at `PROJECT_STARTER.md §2` for the canonical workflow + names meta-specific overrides (deploy is no-op per B-005; version markers are just `VERSION`; meta repo's CI is `.github/workflows/template-self-test.yml`, not `templates/.github/workflows/ci.yml`). The meta repo now follows its own published workflow honestly.

### Spec

- **B-021** added: three-tier doc-canonical model with deliberate AI-safety redundancy. Names the three tiers, the canonical scope of each, what's deduplicated vs what's deliberately duplicated, and the rationale (including the historical context that drove the original triple-source layout). Frozen. Test is manual until C4 linter ships.

### Next

- **v1.18.1 or v1.19.0 (`feat gogogo!`):** Build the C4 consistency linter (`scripts/check-rule-consistency.sh`). Checks verb table + gate clause + bare-gogogo prompt match across the three files. Wired into `.github/workflows/template-self-test.yml` as a second job.

## v1.17.0 — 2026-05-18

Mirrors `PROJECT_STARTER.md` template v1.17.0. **Codex Phase 1 #3 — first item of the doc-architecture refactor.**

### Split `docs/spec.md` into active + historical-superseded sections

`docs/spec.md` had grown to 295 lines mixing 14 active blocks with 6 superseded blocks in arbitrary file order (mostly chronological reverse). A reader trying to understand "what are the current rules?" had to filter superseded blocks out by eye on every visit. Codex Phase 1 #3 (renumbered from prior plan Phase 2 #3 in the most recent Codex plan refactor): "Keep active blocks in the main section. Move superseded blocks to a historical appendix or dedicated section. Keep the decision log as the durable audit trail."

New structure:

- **`## Frozen behavior`** — 14 active blocks in numerical order: B-001, B-002, B-003, B-004, B-005, B-010, B-011, B-012, B-014, B-015, B-016, B-017, B-019, B-020.
- **`## Decision log`** — 9 decisions in numerical order: D-001 through D-009. Decisions remain in this section regardless of supersession status (each superseded decision retains its full Chose/Considered/Why content plus a `Status:` line explaining what replaced it — same convention as before; no decision content moved).
- **`## Open project-level decisions`** — unchanged.
- **`## Historical blocks (superseded)`** — new appendix at end of file. 6 superseded blocks in numerical order: B-006, B-007, B-008, B-009, B-013, B-018. Block content is preserved verbatim; cross-references from active blocks ("Supersedes B-NNN") still resolve.

Zero content removed. Pure reorganization. Reader who wants current rules reads top of file and stops at "Open project-level decisions"; reader who wants audit trail or context for a supersession trail continues to the appendix.

### Templates skeleton updated

`templates/docs/spec.md` skeleton gains a third editing rule: "Once a Block is marked superseded, move it to a `## Historical blocks (superseded)` appendix at the bottom of this file in the same commit that supersedes it." Consumer projects starting from this skeleton follow the same convention.

### Spec

No new B block (organization change, not behavior). The convention itself is documented in `templates/docs/spec.md`'s editing rules.

### Next on Phase 1

- **Phase 1 #1** — canonical source for workflow policy choice. Architectural decision (PROJECT_STARTER.md vs templates/CONTRIBUTING.md as the canonical source). Needs a **design discussion turn** before code, same flow as Phase 3.
- **Phase 1 #2** — split PROJECT_STARTER.md into BOOTSTRAP / WORKFLOW / TEMPLATE_INVENTORY / DEPLOY_BASELINE / HARNESS_QUIRKS. Depends on Phase 1 #1's decision.
- **Phase 1 #4** — reduce duplication between PROJECT_STARTER / CONTRIBUTING / CLAUDE. Depends on Phase 1 #1's decision.

## v1.16.1 — 2026-05-18

Mirrors `PROJECT_STARTER.md` template v1.16.1. Patch — Codex Phase 5 #2 (Known Limitations), small README addition.

### Add Known Limitations section to README

Pairs with v1.16.0's quickstart README. Without an explicit limitations section, new visitors might assume the template is more polished than it is and hit surprises when first using it. Codex Phase 5 #2: "State explicitly what is still manual. State what is not yet generic or multi-preset. Users are not surprised by remaining edges."

Five concrete limitations, each with a one-paragraph explanation + link to the roadmap item where applicable:

1. **Placeholder substitution is manual** — `bootstrap.sh` only does `.env` credential prompting; placeholder substitution (`<package_name>` mv + sed across `.py`/`.toml`/`Makefile`/`.yml`/`.sh`/`.example`; plus `<PROJECT_NAME>`/`<GITHUB_USER>`/`<HOST>`/`<DOMAIN>` edits) is manual. Open item #3 (`scripts/new-project.sh`) addresses this.
2. **Single language preset** — Python/uv/FastAPI/VPS only. Multi-preset is roadmap per D-009.
3. **`PROJECT_STARTER.md` is a 1000+ line monolith** — split into focused docs is roadmap (open item #7 + Codex plan Phase 1).
4. **No automated drift detection** — doc references, placeholders, workflow-wording consistency manually audited today. Linters are roadmap (Codex plan Phase 3).
5. **Windows requires WSL** — `src/<package_name>/` directory has angle-bracket characters that aren't valid Windows filenames; bash scripts assume POSIX shell. Per D-009 target is Linux/VPS — Windows isn't a first-class target.

Section sits in README between Quickstart and Docs, with a pointer to `docs/spec.md` "Open project-level decisions" for the full roadmap so the README doesn't duplicate.

## v1.16.0 — 2026-05-18

Mirrors `PROJECT_STARTER.md` template v1.16.0. **First commit on new branch `improvements-2` after merging `improvements-1` (PR #1, v1.2.0–v1.15.0).**

### Add a repo-root README — first-contact quickstart (Codex Phase 5 #1)

Until now the repo had no `README.md` at root — GitHub's landing page showed an empty README slot and visitors had to open `PROJECT_STARTER.md` (~1000 lines) to figure out what the project even was. Per the refactored Codex improvement plan's Phase 5 #1: "New users do not need to reverse-engineer the repo from long docs."

Ships a ~250-word README covering:

- **What it is** (reusable bootstrap kit for Claude Code projects) + **who it's for**.
- **Current shipped scope** — explicitly Python/uv/FastAPI/VPS today per D-009; multi-preset is roadmap, not shipped.
- **What you get** — two-layer table separating the stack-agnostic process layer (gate, workflow, spec format, Karpathy rules, review rubric) from the Python preset (FastAPI app, tests, Makefile, CI, deploy script, env-bootstrap with `@directive` schema).
- **Quickstart commands** — `./scripts/export-starter.sh` + `tar -xzf --strip-components=1` + `chmod +x scripts/*.sh`, pointing at `PROJECT_STARTER.md §1` for the rest (placeholder substitution, `uv lock`, GitHub repo creation, etc.).
- **Docs table** linking PROJECT_STARTER, `docs/spec.md`, CHANGELOG, `docs/pr_review_instructions.md`.

Does NOT prominently feature `codex improvement plan.md` — the committed version in git is the v1.8.0 snapshot, which is now stale (Codex has refactored it twice locally; the latest 9.7KB / 300-line version lives in stash@{0} per the user's "no snapshot" decision). The plan file is internal working state, not a consumer-facing artifact.

### Next on Phase 5

- **v1.16.1 (`docs gogogo!`):** Phase 5 #2 — Known Limitations (section in README, or separate `LIMITATIONS.md` — small decision).

## v1.15.0 — 2026-05-18

Mirrors `PROJECT_STARTER.md` template v1.15.0. **Third and final commit implementing Codex Phase 3 (env metadata explicit). Phase 3 complete.**

### Kill `templates/scripts/validators.sh` — superseded by `@directive` system

`validators.sh` shipped in v1.12.0 as the deliberate extension point for project-specific validators (B-018). The `@directive` system shipped in v1.14.0–v1.14.1 (B-020) provides the same per-var validator extension point inline in `.env.example` via `@validator:` directives. Two mechanisms for the same job — exactly the kind of duplication the Codex plan kept warning against.

Removing the sidecar:

- **`templates/scripts/validators.sh`** deleted (`git rm`).
- **`templates/scripts/bootstrap.sh`** — the 9-line "Project-specific validators sidecar (deprecated)" block that sourced it is removed.

The v1.12.0 work isn't wasted — it was the right step at the time and shipped a working extension point. Just superseded by a cleaner unified mechanism three versions later. Spec churn matches the B-008 → B-009 → B-010 lineage from the review-flow saga.

### Breaking change

Consumers using `templates/scripts/validators.sh` to add project-specific validators must migrate those entries to `@validator:` directives in their `.env.example`. For example:

```sh
# in old validators.sh:
VALIDATORS[STRIPE_API_KEY]='^sk_(live|test)_[A-Za-z0-9]{24,}$'

# becomes, in .env.example:
# @description: Stripe API key
# @required
# @sensitive
# @validator: ^sk_(live|test)_[A-Za-z0-9]{24,}$
STRIPE_API_KEY=
```

Per the user's hard-cut decision in the Phase 3 design discussion.

### Spec

- **B-018** (validators.sh sidecar) flipped to **superseded by B-020**. Rationale: same job covered inline by `@validator:` directives; one mechanism is better than two.

### Phase 3 complete

- ✓ v1.14.0 — `.env.example` migrated to `@directive` format; B-020 draft.
- ✓ v1.14.1 — parser swap to directive-only via shared helper; B-020 frozen.
- ✓ v1.15.0 — kill `validators.sh`; B-018 superseded by B-020.

Per the updated codex plan execution order, next is Phase 2 (documentation architecture).

## v1.14.1 — 2026-05-18

Mirrors `PROJECT_STARTER.md` template v1.14.1. **Second of three commits implementing Codex Phase 3 (env metadata explicit).** Parser swap — hard cut from legacy prose-grep to `@directive`-only.

### Parser rewrite + shared helper

- **`templates/scripts/_env-schema-parse.sh`** (new — sourced helper, not invoked directly). Parses `.env.example`; populates global associative arrays `VARS`, `DESCRIPTIONS`, `DEFAULTS`, `VALIDATORS`, `IS_OPTIONAL`, `IS_SENSITIVE`, `COMMENTS`. Recognizes the six `@directive` types from B-020 (case-insensitive directive name to forgive typos like `@Optional`). Unknown `@`-prefixed directives emit a stderr warning and are ignored. Last-wins semantics on duplicate directives in the same var's block. Default-if-neither-`@required`-nor-`@optional`-given is `required`.
- **`templates/scripts/bootstrap.sh`** — sources the helper; the old SENSITIVE_RE constant, the hardcoded `VALIDATORS` array, and the ~30-line inline parser loop are all removed. `mask()` now uses `IS_SENSITIVE[var]` (populated by parser) instead of regex auto-detection. `prompt_var()` now shows the `@description` value prominently plus `(optional)` / `(sensitive)` flag annotations. The validators.sh sidecar source line is retained for this release (v1.15.0 removes it).
- **`templates/scripts/check-env.sh`** — sources the helper; the duplicated ~25-line parser loop is replaced with a 5-line iteration over `VARS` partitioning into `required`/`optional` based on `IS_OPTIONAL`. Rest of the script (compares against actual `.env`, reports missing required vars) is unchanged.

### Hard cut — breaking change for un-migrated consumers

A consumer whose `.env.example` still uses legacy prose ("Optional:" comments instead of `@optional` directives) will now have ALL vars marked required (no @optional → required by default). check-env.sh would refuse to pass. Migration is a one-time edit of `.env.example` to add `@required` / `@optional` / `@default` / `@validator` / `@sensitive` / `@description` directives per B-020. Per the user's hard-cut decision in the design discussion — accepted breaking change at this v1 development stage.

### Spec

- **B-020 promoted from `draft` to `frozen`** (per spec format rule: status promotion rides in the commit that adds the proving test). Test pointer updated to reflect new parser behavior; rule text gains the case-insensitivity + unknown-directive-warning + shared-helper detail.

### What v1.15.0 will do

Kill `templates/scripts/validators.sh` + remove the source-if-present block from bootstrap.sh; supersede B-018. Validator metadata now lives inline in `.env.example` via `@validator:` directives — the sidecar is redundant after v1.14.1.

## v1.14.0 — 2026-05-18

Mirrors `PROJECT_STARTER.md` template v1.14.0. **First of three commits implementing Codex Phase 3 (env metadata explicit).**

### Declare `.env.example` schema via `@directive` comments

Codex Phase 3.1/3.2/3.3: `bootstrap.sh` and `check-env.sh` previously inferred required vs. optional from English prose (case-insensitive grep for "Optional" in any preceding comment line). Fragile by construction — rewording broke the gate silently. Validators lived in a separate sidecar (`templates/scripts/validators.sh` from v1.12.0). The schema was split across two surfaces with two different mechanisms.

This release introduces `@directive` comments as the single explicit-metadata format for env vars. `.env.example` stays the source of truth (Phase 3.3 answered by format choice — no separate schema, no rendering layer):

```bash
# @description: Sentry DSN for error reporting
# @optional
# @sensitive
SENTRY_DSN=
```

Six directives cover everything `bootstrap.sh` + `check-env.sh` need: `@description`, `@required` / `@optional`, `@default`, `@validator`, `@sensitive`. Free-text comments still allowed for human context — bootstrap.sh shows them in prompts but doesn't parse them as metadata. See B-020 in `docs/spec.md` for the full vocabulary.

### Reorder vs. the design proposal

The design proposal sequenced this as commit-1 (parser learns directives) → commit-2 (migrate `.env.example`) → commit-3 (kill validators.sh). With "hard cut" decided, that creates a broken intermediate at commit-1 (parser only understands directives, but template still ships legacy `.env.example`). Reorder: **migrate data first, swap parser second.** Old parser still works on the migrated file because case-insensitive grep for "Optional" matches "@optional" in SENTRY_DSN's block — and no other vars or section headers contain the word "Optional" anywhere. Zero broken intermediate states.

### What this commit ships

- **`templates/.env.example`** rewritten in directive format. File header rewritten to NOT contain the word "optional" anywhere (would otherwise false-match the legacy parser's grep on subsequent vars). Each shipped placeholder var (`VAR_NAME`, `ANOTHER_VAR`, `DB_PATH`, `SENTRY_DSN`, `LOG_LEVEL`, `DEV_MODE`) carries explicit directives.
- **`docs/spec.md` B-020 added in `draft` status** — format defined + data migrated; parser doesn't yet enforce. Will promote to `frozen` in v1.14.1 when parser is rewritten directive-only.

### What the next two commits will do

- **v1.14.1 (`refactor`):** rewrite `bootstrap.sh` + `check-env.sh` to directive-only parsing. Hard cut — consumers with un-migrated legacy `.env.example` will need to migrate. B-020 promoted to `frozen`.
- **v1.15.0 (`refactor`):** kill `templates/scripts/validators.sh`. Supersede B-018. Validator metadata now lives inline in `.env.example` via `@validator:` directives — no second mechanism.

## v1.13.0 — 2026-05-18

Mirrors `PROJECT_STARTER.md` template v1.13.0.

### Audit source-project residue in active docs + scripts (Codex Phase 1.3)

Third and final item of Package B / Codex Phase 1 (de-personalize). The systematic sweep across PROJECT_STARTER.md, templates/README.md, templates/CONTRIBUTING.md, templates/CLAUDE.md, templates/docs/*, and templates/scripts/*.sh surfaced two categories of residue:

**Hardcoded source-project usernames** (`denisbalon/$PROJECT_SLUG` in 3 places in PROJECT_STARTER.md §1.5 + §1.6) — flagged in v1.11.1's A5 audit, deferred to Package B, now fixed. Parametrized to `<GITHUB_USER>/$PROJECT_SLUG` using the existing placeholder convention.

**Vendor-specific examples in supposedly-generic prose** (6 instances in PROJECT_STARTER.md):
- §2.4 branch-naming examples (`feat/click-receiver`, `fix/capi-retry-401`) → generic (`feat/api-handler`, `fix/auth-retry-401`)
- §2.5 commit-message examples (CAPI/Subscribe/phoenixbot) → generic equivalents
- §5.1 stack rationale: "excellent CAPI/Telegram tooling" → "mature async ecosystem and excellent webhook/API tooling"
- §6.1 DNS guidance: "DNS-only for Telegram webhooks" → reframed for "webhook receivers in general where the upstream is sensitive to TLS termination details"
- §8.2 sample CHANGELOG entry: "Add Telegram webhook receiver" → generic "Add webhook receiver"
- §11 cross-cutting concerns: Telegram `chat_join_request` example → explicitly labeled `**Example (Telegram bots):**`
- §13 credential-leak revoke example: "Meta Events Manager" → explicitly labeled `**Example:**`

**Webhook-shaped env var name** (`WEBHOOK_BASE_URL` in `templates/scripts/deploy.sh`) renamed to `SERVICE_URL`. The old name presumed the service was a webhook receiver — a Telegram-bot leftover from the source project. Service URL is generic.

### Breaking change

`WEBHOOK_BASE_URL` → `SERVICE_URL` in `templates/scripts/deploy.sh`. Any consumer with `WEBHOOK_BASE_URL` in their `.env` should rename it (the deploy will silently fall back to the `<DOMAIN>` placeholder otherwise). Acceptable per v1 development phase.

### Spec

- **B-019** added: active docs are vendor-neutral by default; vendor-specific guidance is explicitly labeled. Names the principle for `PROJECT_STARTER.md` + all `templates/**/*.md` + script env var names. Frozen. The future C4 consistency linter (Codex Phase 5.3) tests it automatically.
- **Open project-level decisions** — De-personalize item now **fully resolved** (menu header v1.11.2 + validators v1.12.0 + docs/scripts audit v1.13.0).

### Package B status

- ✓ 1.1 Menu-header (v1.11.2 / B-017)
- ✓ 1.2 Validators (v1.12.0 / B-018)
- ✓ 1.3 Doc + script audit (v1.13.0 / B-019)

Codex Phase 1 (de-personalize) is complete. Per the updated codex plan, next phase in execution order is Phase 3 (env metadata).

## v1.12.0 — 2026-05-18

Mirrors `PROJECT_STARTER.md` template v1.12.0.

### Strip vendor validators from `bootstrap.sh` core; ship `validators.sh` sidecar

Codex improvement-plan Phase 1.2 — second item of Package B / Phase 1 (de-personalize). `templates/scripts/bootstrap.sh` previously hardcoded eight validators in its `VALIDATORS` associative array, six of which were vendor-specific bake-ins from the source project: `TELEGRAM_BOT_TOKEN`, `TELEGRAM_WEBHOOK_SECRET`, `TELEGRAM_CHANNEL_ID`, `META_DEFAULT_PIXEL_ID`, `META_CAPI_TOKEN`, `KEITARO_POSTBACK_BASE`, `KEITARO_POSTBACK_KEY`, plus an application-shaped `WEBHOOK_BASE_URL`. A generic template that knows about Telegram tokens by default isn't actually generic — Codex Phase 1.2's acceptance criterion: "Project-specific validators live in a deliberate, documented layer."

**Approach (Option A from the design menu, plus the required extension point):** strip all vendor-specific entries from the core; ship a sourced sidecar at `templates/scripts/validators.sh` as the deliberate extension point.

- **`templates/scripts/bootstrap.sh` `VALIDATORS` array** now contains only `LOG_LEVEL` (log-level enum) and `DEV_MODE` (boolean) — both truly generic across any project.
- **`templates/scripts/validators.sh`** (new, ships as skeleton): consumers add their own project-specific validators here. The file is sourced from inside `bootstrap.sh`'s scope, so `VALIDATORS[FOO]='regex'` Just Works without modifying core. Ships with an explanatory header + commented-out example entries (`TELEGRAM_BOT_TOKEN`, `STRIPE_API_KEY`, `DATABASE_URL`) for guidance, plus an intentionally-empty active section. Consumers uncomment what applies to their project or add their own.
- **`templates/scripts/bootstrap.sh`** now `source`s `$ROOT/scripts/validators.sh` if it exists, immediately after declaring the generic `VALIDATORS` array. Sidecar mutations take effect for the rest of the script run.

**Breaking change.** Any consumer who relied on the hardcoded TELEGRAM/META/KEITARO validators will see them disappear; their `validators.sh` skeleton has the same patterns commented out — uncomment to restore. Compliant with the v1.8.0 product-identity decision (D-009): we're a Python/uv/FastAPI/VPS starter; vendor-specific validators were the wrong default.

### Spec

- **B-018** added: bootstrap.sh validators — generic core + project-specific sidecar. Frozen. Names the file, the sourcing mechanism, the contents of each layer.
- **Open project-level decisions** — de-personalize item updated: validators sub-item resolved; doc-residue audit (Codex Phase 1.3) still pending.

## v1.11.2 — 2026-05-18

Mirrors `PROJECT_STARTER.md` template v1.11.2. Patch — first item of Package B / Codex Phase 1 (de-personalize). Removes the most visible source-project leftover in the generic template.

### Fix

- **`templates/scripts/bootstrap.sh:200` menu header hardcoded `phoenixtgstat_bot`.** A consumer running the script saw the source-project's name in the credential-setup banner. Replaced with a derived value: `PROJECT_NAME=$(basename "$ROOT")` near the top of the script; menu header now reads `"  $PROJECT_NAME — credential setup"`. The header now correctly shows the consumer's actual project directory name.

### Spec

- **B-017** added: generic `templates/scripts/*` derive project context from `basename "$ROOT"` / env / placeholder; never hardcode source-project names. Frozen. Future C4 consistency linter (Codex Phase 5.3) makes this testable automatically. Audit-trail mentions of the source project's name in `CHANGELOG.md` / `PROJECT_STARTER.md` template-changelog are intentional provenance — excluded from the rule.
- **Open project-level decisions** — de-personalize item split into two sub-items: menu-header (resolved in this commit) + service-specific validators (Telegram/Meta/Keitaro regexes, still hardcoded — needs a design call before Phase 1.2 work begins).

## v1.11.1 — 2026-05-18

Mirrors `PROJECT_STARTER.md` template v1.11.1. Patch — A5 audit (Codex Phase 1.4) of every command / file path / filename mentioned across `PROJECT_STARTER.md`, `templates/README.md`, `templates/CONTRIBUTING.md`, `templates/CLAUDE.md`, `templates/docs/*.md` against the shipped tree.

### Audit findings

Surprisingly thin — most drift had already been caught by v1.7.1 (rubric-path fix), v1.9.0–v1.11.0 (shipping the missing preset + export-starter + smoke test which catches runtime breakage automatically). The systematic sweep surfaced **one real gap**, plus two items that belong to other packages.

### Real gap fixed

- **Missing `uv lock` step in PROJECT_STARTER §1 bootstrap.** CI (`templates/.github/workflows/ci.yml`, three jobs) and deploy (`templates/scripts/deploy.sh`) both use `uv sync --frozen`, which requires `uv.lock` to exist in the consumer's repo. But §1 never told the consumer to generate one. First push to a fresh repo → CI failure with "no lockfile" error. Fix: added a final sub-step to PROJECT_STARTER §1.3 (immediately after the placeholder-substitution paragraph): `uv lock && git add uv.lock` so the first commit includes a real lockfile. Placement matters — must happen AFTER substitution (otherwise the lockfile bakes in `<package_name>`) and BEFORE the first commit (so CI's `--frozen` succeeds on the very first push).

### Not gaps (verified intentional)

- All `request-codex-review` mentions are in the PROJECT_STARTER template-changelog table for v1.5.0/v1.5.1/v1.6.0 — historical audit trail per the supersede pattern, intentional.
- `docs/SPEC` in two rationalization tables (`templates/CONTRIBUTING.md`, `PROJECT_STARTER.md`) is informal English ("It's just a docs/SPEC tweak"), not a path.
- Memory-seed filenames (`architecture_decisions.md`, `gogogo_gate_workflow.md`, etc.) are prescriptive recommendations for the user's local `.claude/memory/` dir, not paths to shipped files.
- `findings.txt`, `review.md`, `Cargo.toml`, `package.json` are explicit illustrative examples (negative-example list / non-Python stack pointers).
- All `templates/scripts/*`, `templates/docs/*`, `templates/.claude/skills/spec-block/SKILL.md` paths resolve to shipped files.

### Deferred to other packages

- **`denisbalon/$PROJECT_SLUG` hardcoded** in PROJECT_STARTER §1.5 + §1.6 (3 places). Real personalization gap; belongs to Package B (Codex Phase 3 / open item #1 de-personalize).
- **`<package_name>` requires manual `mv` + `sed` substitution** until `scripts/bootstrap.sh` automates it. Belongs to Package B (bootstrap-substitution piece that pairs with B1/B2).

### Spec

- **B-016** added: invariant — every live doc reference resolves to a shipped file or is an explicit example. Frozen. Test is manual today; the future C2 doc-reference linter (Codex Phase 8.2) automates it. Smoke test (B-014) already catches the runtime subset of this invariant.

## v1.11.0 — 2026-05-18

Mirrors `PROJECT_STARTER.md` template v1.11.0.

### Template self-tests on CI (Codex Phase 8 — highest leverage after Phase 1)

The repo now proves end-to-end that the template instantiates and runs. Every push and PR against `main` exercises the full consumer flow: export-starter → tar extract → placeholder substitution → `uv sync` → `pytest` + `ruff check` + `mypy src`. Any breakage in template files, scripts, CI assumptions, or doc claims now fails CI and blocks the PR. Codex's improvement plan called this out as the single biggest leverage point: "Everything else gets easier once the template can prove it works."

- **`scripts/smoke-test.sh`** (new, repo root, executable): instantiates the template end-to-end into a tempdir. Substitutes the `<package_name>` placeholder via one `mv` + one `sed`. Runs the four tool checks (`uv sync`, `pytest`, `ruff check .`, `mypy src`) from the synthesized project. Fails loud on any step. Tempdir cleanup via `trap`. `PKG` env var overrides the default package name (`smoketest`).
- **`.github/workflows/template-self-test.yml`** (new — meta-repo's first CI workflow; consumer projects already have their own `templates/.github/workflows/ci.yml`): ubuntu-latest, `astral-sh/setup-uv@v3`, runs `./scripts/smoke-test.sh` on push + PR.

### Fix: `scripts/export-starter.sh` archive layout

The smoke test caught a real bug on its very first run: v1.10.0's `export-starter.sh` kept `templates/` nested as a subdirectory inside the archive. After `tar -xzf --strip-components=1`, the consumer ended up with `<root>/templates/scripts/` instead of `<root>/scripts/`, so PROJECT_STARTER.md §1.3's `chmod +x scripts/*.sh` immediately following the extract would fail. Fixed by changing `cp -R templates` to `cp -R templates/.` (trailing `/.` promotes contents instead of preserving the parent directory name). Same-day fix surfaced by the same-commit smoke test — exactly the drift-catching loop Codex's Phase 8 promises.

### Spec

- **B-014** added: template self-tests on every push + PR via meta-repo CI. Names `scripts/smoke-test.sh` + `.github/workflows/template-self-test.yml` + the four tool checks. Frozen.
- **B-015** added: corrected archive layout — `templates/` contents promoted to the archive root level (not kept nested). Supersedes B-013 with full rationale ("the full templates/ tree" wording was ambiguous; smoke test caught the gap). Frozen.
- **B-013** flipped to superseded by B-015.

## v1.10.0 — 2026-05-18

Mirrors `PROJECT_STARTER.md` template v1.10.0.

### Ship `scripts/export-starter.sh`

Codex's improvement-plan Phase 1.1 (and existing open item #4 / inventory item B4) — `PROJECT_STARTER.md §1.3` has recommended `./scripts/export-starter.sh` as "the quick path" since v1.1.1 (May 4), but the script never shipped. Running the recommended command produced "No such file or directory." The doc lied for two weeks.

This commit ships the script:

- **`scripts/export-starter.sh`** (new, repo root — meta-script, not a consumer template). Reads `VERSION`. Writes `~/Downloads/project-starter-v<VERSION>-<YYYY-MM-DD>.tar.gz` (always) and `~/Downloads/project-starter-v<VERSION>-<YYYY-MM-DD>.zip` (only when `zip` is installed — graceful skip with a message otherwise, matching the v1.1.3 caveat already documented in the template-changelog table). Archive contains a top-level `project-starter-v<VERSION>-<YYYY-MM-DD>/` directory with `PROJECT_STARTER.md` + the full `templates/` tree, so consumers can `tar -xzf ... --strip-components=1` directly into a new project per §1.3. Output dir overridable via `OUT_DIR` env var (default `~/Downloads`, auto-created). Fails loud if source artifacts are missing; cleans up tempdir on exit via `trap`.

Verified by running the script during this commit cycle: produced a 25KB tar.gz containing the expected file tree.

### Spec

- **B-013** added: names the script's contract (output path, archive layout, optional zip, OUT_DIR override, failure semantics). Frozen. No D entry — the script's existence was always planned; this just makes the doc honest.
- **Open project-level decisions** — item #4 (the missing export script) **resolved** by this commit.

## v1.9.1 — 2026-05-18

Mirrors `PROJECT_STARTER.md` template v1.9.1. Patch — fixes the deploy cleanliness check Codex flagged at improvement-plan Phase 1.3.

### Fix

- **`templates/scripts/deploy.sh` cleanliness check was incomplete.** The previous `git diff --quiet --exit-code` only detected unstaged changes against the working tree. It missed: (a) staged-but-uncommitted edits (`git diff --cached`), and (b) untracked files (`git ls-files --others --exclude-standard`). Either could ship a surprise — a half-staged refactor not yet committed, or a brand-new module the dev forgot to `git add`. Replaced the single check with three checks (unstaged, staged, untracked), each reported separately when the tree is dirty. The `--dirty` override still works. Untracked is intentionally part of the gate (catches forgotten-to-add files in `src/`) but respects `.gitignore` via `--exclude-standard` so locally ignored paths like `.env` don't block. Script header comment now documents the policy explicitly.

## v1.9.0 — 2026-05-18

Mirrors `PROJECT_STARTER.md` template v1.9.0.

### Ship the minimal runnable Python/uv/FastAPI preset

Codex's improvement-plan Phase 1.2 (and existing open item #6) flagged that `templates/Makefile` references `<package_name>.app:app`, CI runs `mypy src`, and `scripts/deploy.sh` rsyncs `src/` + curls `/healthz` — but none of those files ship in `templates/`. The template claimed to be runnable; in practice the consumer had to invent the scaffolding themselves. This release closes that gap.

Files added under `templates/`:

- **`pyproject.toml`** — FastAPI + uvicorn runtime; pytest + httpx + ruff + mypy dev via PEP 735 `[dependency-groups]` so default `uv sync --frozen` picks them up (matches the existing CI workflow as-is); hatchling build-backend; tool config for ruff (`E,F,W,I,B,UP,RUF`, line 100, py312), mypy (`strict`, `files = ["src"]`), pytest (`testpaths = ["tests"]`).
- **`src/<package_name>/__init__.py`** — package init with `__version__ = "0.1.0"`.
- **`src/<package_name>/app.py`** — minimal FastAPI app exposing `/healthz` (the endpoint `scripts/deploy.sh` already curls for its post-deploy healthcheck).
- **`tests/__init__.py`** — empty package marker.
- **`tests/test_smoke.py`** — FastAPI `TestClient` smoke test asserting `/healthz` returns 200 / `{"status": "ok"}`.
- **`LICENSE`** — MIT with `<COPYRIGHT_HOLDER>` + `<YEAR>` placeholders.

### Placeholder convention

Single `<package_name>` literal everywhere — including the `src/<package_name>/` directory name itself. Bootstrap substitution is one mv + one sed:

```sh
mv templates/src/<package_name> templates/src/<actual_name>
find templates -type f \( -name '*.py' -o -name '*.toml' -o -name 'Makefile' -o -name '*.yml' -o -name '*.sh' -o -name '*.example' \) -exec sed -i 's/<package_name>/<actual_name>/g' {} +
```

(Today this is manual; automating it in `scripts/bootstrap.sh` is a follow-up open item that pairs with B1/B2 of the Codex plan.)

### Spec

- **B-012** added: `templates/` ships a minimal runnable Python/uv/FastAPI preset. Names the shipped files + the substitution convention + the healthcheck/import-path alignment with Makefile/CI/deploy.sh. Frozen. Decision: D-009.
- **Open project-level decisions** — item 6 ("Add language-preset skeletons. Missing pyproject.toml, src/<package>/, tests/, LICENSE. CI assumes they exist.") is now **resolved** by this commit; removing from the open list and noting in CHANGELOG.

## v1.8.0 — 2026-05-18

Mirrors `PROJECT_STARTER.md` template v1.8.0.

### Declare product identity: Python/uv/FastAPI/VPS starter (now) + multi-preset (roadmap)

Codex's `codex improvement plan.md` flagged the gap at Phase 2/12: top-level docs claim "project-agnostic" but `templates/Makefile` invokes `uv run uvicorn`, CI assumes `pyproject.toml` + `src/<package>/`, `scripts/deploy.sh` is VPS-shaped. Claiming agnostic without shipping presets is dishonest by construction.

This release picks the honest near-term framing (Codex's Phase 12 Option A): **this repo is a Python/uv/FastAPI/VPS starter today.** The stack-agnostic parts (bootstrap process, `gogogo!` gate, 5-step workflow, spec-block format, Karpathy rules, reviewer-agnostic PR rubric) apply to any project. The Python-shaped parts (language preset, Makefile, CI, deploy) are honestly named. Multi-preset support is on the roadmap (D-009) — when it lands, the agnostic claim becomes true and gets re-asserted.

No templates change. No shipped code changes. Only framing.

- **`PROJECT_STARTER.md`** top section reframed: drop the "This document is project-agnostic" line; replace with an honest paragraph naming the current shipped scope (Python/uv/FastAPI/VPS) and what's stack-agnostic vs. Python-specific. New `### 0.1 Current scope` subsection makes the boundary explicit.
- **`docs/spec.md`** — new D-009 captures the decision and the considered alternatives (ship Python-only honest; build multi-preset before next release; keep claiming agnostic).
- **"Open project-level decisions"** — stack-agnostic-restructure item tagged "roadmap per D-009" so it stays on radar but is no longer treated as a near-term gap.

## v1.7.1 — 2026-05-18

Mirrors `PROJECT_STARTER.md` template v1.7.1. Patch — three doc-consistency fixes surfaced by Codex's review of PR #1 (the first real exercise of the v1.7.0 reviewer-agnostic flow, dogfooded on this very branch).

### Fixes

- **`templates/docs/pr_review_instructions.md` hardcoded `gh api` as the only transport.** The output-contract section said "posted via `gh api`" and gave `gh api -X POST` as the only examples, but `PROJECT_STARTER.md §11`, `templates/CONTRIBUTING.md §4`, and the canonical rule in B-010 all describe two paths (gh + native PR integration). Updated the rubric file to match: posted via `gh api` (or the reviewer's native PR-comment integration), with the `gh api` commands re-framed as concrete examples for that path rather than the only valid mechanism. (Codex Block on commit `0e4bcf3` — finding still surviving in the v1.7.0 final state.)
- **`templates/CONTRIBUTING.md §4` allowed a third transport path B-010 doesn't sanction.** v1.7.0 added "or by the user copy-pasting" to the contract phrasing — but B-010 freezes the path as "the reviewer posts comments via `gh` (or its native PR integration) directly." Copy-paste isn't on the sanctioned list; removed. Three doc sources now describe the transport identically. (Codex Block on commit `bbe9013`.)
- **Self-review rubric path was ambiguous on this meta-repo.** `PROJECT_STARTER.md §2.7` tells reviewers to "point it at `docs/pr_review_instructions.md`" — works for consuming projects (where the template gets copied into `docs/`), but this repo ships the rubric only at `templates/docs/pr_review_instructions.md`. Added a one-line pointer file at `docs/pr_review_instructions.md` (repo root) so the self-review path resolves correctly without duplicating content. (Codex Strong on commit `bbe9013`.)

### Process win

Second end-to-end test of the local Codex CLI review path — this time against the v1.7.0 branch with the reviewer-agnostic flow live. Codex posted 7 per-commit comments (clean commits explicitly tagged "No findings on `<sha>`") + 1 overall summary, exactly per the contract `docs/pr_review_instructions.md` mandates. Found three real inconsistencies on the first run — same pattern as the v1.5.0 → v1.5.1 cycle. The flow works.

## v1.7.0 — 2026-05-18

Mirrors `PROJECT_STARTER.md` template v1.7.0.

### Pivot: PR review is out-of-band and reviewer-agnostic

The v1.6.0 local-CLI skill resolved the GitHub-App-doesn't-exist problem but kept Claude in the reviewer-dispatch business — and Codex's own review of that branch flagged the contradiction at [P1]: the skill ran stdout-only, so it couldn't satisfy the per-commit PR-comment contract `templates/docs/pr_review_instructions.md` requires. Plan to switch to an interactive-TUI launcher was rejected by user feedback as more overcomplication of a user-side action ("no make, no nothing. I go to different terminal, start codex …", then "instructions should be agnostic to reviewer").

This release removes all Claude-side reviewer wiring. Claude opens the PR on `PR gogogo!`; everything after that is the user's job in a separate session with any reviewer they prefer.

- **`templates/.claude/skills/request-codex-review/SKILL.md`** deleted (skill removed entirely; parent directory removed).
- **`templates/Makefile`** — `request-codex-review` target, its `.PHONY` entry, and its help comment all removed.
- **`review gogogo!` verb removed everywhere** — `templates/CLAUDE.md` verb table, `templates/CONTRIBUTING.md` verb table + cheat-sheet + TL;DR, `PROJECT_STARTER.md` §2.1 verb table, `docs/spec.md` verb table (inside the now-superseded B-006). Bare-`gogogo!` clarification prompt no longer offers `review` as a choice.
- **`templates/docs/pr_review_instructions.md` preamble rewritten** — no default reviewer named; rubric is presented as the file any reviewer reads (Codex, `/ultrareview`, another LLM, manual). Output contract preserved verbatim — it's reviewer-agnostic, and whichever reviewer the user runs interactively can now satisfy it directly.
- **`templates/CONTRIBUTING.md` §4** rewritten as a short paragraph: review is out-of-band; user runs any reviewer in a separate session against `docs/pr_review_instructions.md` and the open PR. Reviewer matrix, Codex install/invocation steps, GitHub-App fallback all removed.
- **`PROJECT_STARTER.md` §2.7 + §11** rewritten the same way. §11 retains the rubric and output contract (reviewer-agnostic) but drops the `/ultrareview`-vs-Codex framing.

### Spec changes

- **B-007** (Codex-as-default) flipped to `superseded` by B-010. Reviewer-agnostic principle survives in B-010; Codex-as-default and the GitHub-App invocation are removed.
- **B-009** (`codex review --base main` skill) flipped to `superseded` by B-010. Skill + Makefile target + verb all removed.
- **B-006** (verb table with `review gogogo!`) flipped to `superseded` by B-011.
- **B-010** added: PR review is out-of-band and reviewer-agnostic. Project provides no Claude-side reviewer trigger.
- **B-011** added: verb table without `review`. The verb gated nothing Claude does after B-010.
- **D-005** (Codex-as-default) flipped to `superseded` by D-008. Reviewer-agnostic survives in B-010; default-reviewer specification is removed.
- **D-007** (local-CLI skill pivot) flipped to `superseded` by D-008. The whole skill was removed; the "local CLI works" finding still stands but is no longer relevant to what the project ships.
- **D-008** added: captures the rationale for removing all Claude-side reviewer wiring.

## v1.6.0 — 2026-05-18

Mirrors `PROJECT_STARTER.md` template v1.6.0.

### Pivot: `request-codex-review` uses local CLI, not GitHub App

The v1.5.0 skill posted `@codex review` PR comments expecting a Codex GitHub App to pick them up. A read-only probe confirmed the user has **no Apps installed** on their GitHub account — so the skill targeted nothing. The local `codex` CLI is installed (v0.130.0) and has a purpose-built `codex review --base <branch>` subcommand. A dry run against the v1.5.0 branch found three real bugs (fixed in v1.5.1).

This release pivots the skill + Makefile target to use the CLI path that actually works on the user's setup.

- **`templates/.claude/skills/request-codex-review/SKILL.md`** rewritten: verifies prereqs (CLI installed, branch ahead of main), runs `codex review --base main`, surfaces findings, stops. Synchronous. No GitHub interaction.
- **`templates/Makefile` `request-codex-review` target** rewritten: same prereq checks + CLI invocation. Dropped `gh pr comment` / `jq` / PR-state machinery.
- **`PROJECT_STARTER.md` §2.7** and **`templates/CONTRIBUTING.md` §4** updated: Codex invocation procedure now describes the CLI flow. Output-format note: Codex CLI uses `[P1] / [P2] / [P3]`, not `Block / Strong / Nit` — the `--base` flag is mutually exclusive with custom prompts. P1≈Block, P2≈Strong, P3≈Nit when triaging. `codex exec` remains the escape hatch for strict rubric compliance.
- **GitHub App path** is documented as a fallback that only applies if the user ever installs a Codex App. Not the default.

### Spec changes

- **B-008** flipped to `superseded` by B-009 (the rule survives — Codex is the default reviewer — only the mechanism changed).
- **B-009** added: `codex review --base main` is the canonical invocation.
- **D-006** flipped to `superseded` by D-007 with an honest "why it was wrong" note (the original framing called local-CLI "duplicates the GitHub App" without checking whether the App existed or what the CLI could do — both were knowable in 30 seconds).
- **D-007** added: captures the pivot rationale.

## v1.5.1 — 2026-05-18

Mirrors `PROJECT_STARTER.md` template v1.5.1. Patch — three bug fixes surfaced by a Codex CLI review of the v1.5.0 branch (`codex review --base main`).

### Fixes

- **`docs/spec.md:15` version drift.** The prose hardcoded `Current version: 1.2.0` even after VERSION bumps to 1.3/1.4/1.5. Replaced with a pure reference: *"Current version lives in `VERSION` — single source of truth, never duplicated in prose."* Eliminates drift by construction. (Codex P2)
- **`templates/Makefile` `request-codex-review` posted to closed/merged PRs.** The target only queried `.number` from `gh pr view`, so a stale PR resolved cleanly and the command claimed success. Now queries `.number,.state`, requires `state == OPEN`, errors with the actual state otherwise. Matches the guardrail the SKILL.md already documented. (Codex P2)
- **`docs/spec.md` B-001 test pointer wrong.** Said `grep -r 'code!' .` should return 0 — but `CHANGELOG.md` and the Decision log contain historical `code!` references. Updated to grep only the active gate-documentation files (`PROJECT_STARTER.md`, `templates/CLAUDE.md`, `templates/CONTRIBUTING.md`, `templates/docs/spec.md`, `templates/README.md`) and note that audit-trail mentions are intentional. (Codex P3)

### Process win

First end-to-end test of the local Codex CLI review path (the actual one, after v1.5.0's GitHub-App path turned out to target nothing because no App is installed on this account). Found three real bugs on the first run. v1.6.0 will pivot the skill + Makefile target to use `codex review --base main` directly.

## v1.5.0 — 2026-05-18

Mirrors `PROJECT_STARTER.md` template v1.5.0.

### Codex review automation

- Add `templates/.claude/skills/request-codex-review/SKILL.md` — one-command path to trigger Codex review of the current branch's PR. Detects PR number via `gh pr view`, composes a canonical invocation comment that names `docs/pr_review_instructions.md` explicitly (so Codex reads the rubric), posts via `gh pr comment`, confirms, stops. Does NOT poll for results — Codex posts back to the PR async.
- Add `make request-codex-review` Makefile target — wraps the same canonical comment for one-shot terminal invocation outside Claude sessions.
- Documents the re-review pattern (post a second comment naming "addressed prior findings, N new commits") and the no-mid-branch / no-state-mutation-beyond-comment guardrails.

Implements D-006. Adds B-008.

## v1.4.0 — 2026-05-18

Mirrors `PROJECT_STARTER.md` template v1.4.0.

### PR review (reviewer-agnostic + Codex default)

- Reframe `templates/docs/pr_review_instructions.md` with a reviewer-agnostic preamble: rubric + output contract apply to any reviewer (Codex, `/ultrareview`, other LLMs, manual). Independence beats deepening — a different model with fresh context catches what the original missed.
- Rewrite `PROJECT_STARTER.md` §2.7 and `templates/CONTRIBUTING.md` §4: introduce a reviewer matrix (Codex / `/ultrareview` / other LLM / manual) with cost/independence trade-offs. **Default: Codex** via its GitHub App.
- Codex invocation subsection: install GitHub App (one-time); PR comment names the rubric explicitly (`@codex review — follow docs/pr_review_instructions.md ...`); reviewers run serially, not in parallel.
- Output contract preserved verbatim and made universal: per-commit comments via `gh api` (or reviewer's native PR-comment integration), explicit "no findings on `<sha>`" on clean commits, severity-grouped summary at end.
- The `review gogogo!` verb mapping intentionally unchanged — user does PR review separately when the branch is finished; no in-session reviewer dispatch needed.

Implements D-005. Adds B-007.

## v1.3.0 — 2026-05-17

Mirrors `PROJECT_STARTER.md` template v1.3.0.

### Gate convention

- `gogogo!` is now the **execute trigger**; it must be preceded by an **action verb** in the same message specifying *what* to execute. Bare `gogogo!` (no verb) is ambiguous — Claude asks "Which action?" and stops. (`PROJECT_STARTER.md` §2.1, `templates/CLAUDE.md`, `templates/CONTRIBUTING.md`)
- New verb → workflow table covers: `code/feat/fix/... gogogo!` (full 5-step), `commit gogogo!`, `PR gogogo!`, `review gogogo!`, `merge gogogo!`, `deploy gogogo!`, `revert gogogo!`.
- §2.6 (PR) and §2.9 (merge) updated to reference the new explicit phrases (`PR gogogo!`, `merge gogogo!`) instead of bare imperatives.
- Cheat-sheet and TL;DR in `templates/CONTRIBUTING.md` updated to match.
- Two new rationalizations added to the refuse-list: "bare `gogogo!` → default to 5-step" and "verb-A `gogogo!` is close enough to authorize action B".

Implements D-004 (`docs/spec.md`). Adds B-006.

## v1.2.0 — 2026-05-17

Mirrors `PROJECT_STARTER.md` template v1.2.0. First release of this repo as a standalone template kit; previously imported as `project-starter-v1.1.8-2026-05-07.tar.gz`.

### Gate

- Rename the work-authorization passphrase `code!` → `gogogo!` across all template files. Universal across stacks and action types, not just code edits. (PROJECT_STARTER.md §2.1, templates/CLAUDE.md, templates/CONTRIBUTING.md, templates/docs/spec.md, templates/CHANGELOG.md, templates/README.md, ~50 sites)
- Memory-seed file rename: `code_gate_workflow.md` → `gogogo_gate_workflow.md` (PROJECT_STARTER.md §10)

### Karpathy's four pitfalls

- Add `templates/docs/karpathy-claude-rules.md` — full write-up of the four LLM-coding failure modes (unexamined assumptions, overengineering, collateral changes, no verification) with counter-rules, attribution, and how they fit the 5-step workflow.
- Add a condensed `## Coding pitfalls to avoid (Karpathy's four)` section in `templates/CLAUDE.md` so the rules load every session, not just when someone reads `docs/`.
- Link the new doc from `templates/README.md`'s doc table.

### Spec-blocks

- Add `templates/.claude/skills/spec-block/SKILL.md` — interactive skill that walks through writing one Block at a time (Title / Rule / Rationale / Test / Status / Decision), finds the next free `B-NNN`, and inserts in `docs/spec.md` without committing.
- Replace the placeholder bullet-list `## Frozen behavior` in `templates/docs/spec.md` with the fixed Block format + editing rules + a seed `B-001` placeholder.

### This repo

- Adopt the workflow on this repo: add `VERSION`, `CHANGELOG.md`, and `docs/spec.md` (written in the new Block format — eating our own dog food).

## v0.1.0 — 2026-05-17 (implicit)

Initial import of `project-starter-v1.1.8-2026-05-07.tar.gz` to `main` as a single commit (no VERSION file at the time). v1.2.0 is the first release with the workflow fully applied to this repo.
