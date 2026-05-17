# Changelog

All notable changes per `VERSION` bump. Per the `gogogo!` 5-step workflow, every change bumps `VERSION` and adds an entry here in the same commit.

Format: `## v<X.Y.Z> — YYYY-MM-DD` followed by bullets, optionally grouped by area.

---

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

- Adopt the workflow on this repo: add `VERSION`, `CHANGELOG.md` (this file), and `docs/spec.md` written in the new Block format. Eats our own dog food.

## v0.1.0 — 2026-05-17 (implicit)

Initial import of `project-starter-v1.1.8-2026-05-07.tar.gz` to `main` as a single commit (no VERSION file at the time). v1.2.0 is the first release with the workflow fully applied to this repo.
