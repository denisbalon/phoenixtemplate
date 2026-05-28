# Product specification — <PROJECT_NAME>

Living spec. <PROJECT_SPECIFIC: reference to any external/legacy spec if applicable.>

## Summary

<One paragraph describing what the system does end-to-end.>

## Process & versioning

Process for making changes — branching, commits, the **`gogogo!` passphrase gate**, the **on-branch per-node `gogogo!` cadence** (N≥1 atomic commits per branch; each of stake-branch, each commit, open-PR, each address-review iteration, and merge is its own `gogogo!`; per-commit shape spec? → bump → CHANGELOG → code → commit + push), the **push-after-every-commit** policy, the **branch-name-no-version-suffix** rule (versions live in commit subjects; PR title carries the range `v<X.Y.A>..v<X.Y.B>` covered by the branch's commits), the **one-PR-per-branch** rule (opened as its own `gogogo!` after N≥1 commits), the **no-WIP-commits** rule, the **rebase-merge** strategy, the **merge-`gogogo!`-is-atomic-over-three-substeps** rule (gh pr merge → git pull → deploy), the **version-bump-on-every-commit** rule, the **local `.githooks/pre-push` block on direct pushes to `main`** — is binding and lives in [`CONTRIBUTING.md`](../CONTRIBUTING.md). The current version is stored in `VERSION` at the repo root; for projects with a language preset (Python/uv), the three version markers (`VERSION` + `pyproject.toml` `[project].version` + `__version__` in `src/<package>/__init__.py`) move together within each commit. Per-version diary lives in [`CHANGELOG.md`](../CHANGELOG.md). Architectural decisions live in the Decision log below.

The reusable template behind this project's process and structure lives at [`PROJECT_STARTER.md`](../PROJECT_STARTER.md).

## Frozen behavior

Binding product behavior, written as **Blocks**. Each Block is atomic, numbered (`B-NNN`), and addressable from PRs, decisions, and tests. Format is fixed — don't invent fields. Use the `spec-block` skill (`/spec-block`) to add new ones so the format stays consistent.

### Block format

```
### Block B-NNN: <Title>
**Rule:** <one-line invariant the system must uphold>
**Rationale:** <why — constraint, decision, prior incident>
**Test:** <path/to/test_file.py::test_name or "manual">
**Status:** proposed | draft | frozen | superseded
**Decision:** D-NNN (if implementing a decision-log entry; else "—")
```

**Editing rules:**
- Frozen Blocks don't get edited in place — supersede via a new Block + Decision-log entry, and flip the old one to `superseded`.
- Status promotion (`proposed → draft → frozen`) IS allowed in place and rides in the commit that adds the proving test.
- Once a Block is marked `superseded`, move it to a `## Historical blocks (superseded)` appendix at the bottom of this file in the same commit that supersedes it. The `## Frozen behavior` section then contains only `proposed`/`draft`/`frozen` blocks. Cross-references from active blocks (e.g. "Supersedes B-NNN") still resolve — the superseded block lives in the appendix, not the main section. Keeps the active spec readable as it grows without losing audit trail.

### Block B-001: <Title>

**Rule:** <one-line rule>
**Rationale:** <why>
**Test:** <test pointer or "manual">
**Status:** proposed
**Decision:** —

## Database schema

See `migrations/` for the canonical schema.

- **`<table>`** — <purpose>. Indexed on `<col>`.

## Decision log

One entry per architectural decision. Decisions live forever; chat history that produced them does not.

### D-001 (<YYYY-MM-DD>) <Title>

**Chose:** <option>.
**Considered:** <alternatives>.
**Why:** <rationale>.
**Implemented in:** PR #<N>.

## Open project-level decisions

Resolve as you go. Move resolved entries to the Decision log above.

- [ ] <Open question 1>
- [ ] <Open question 2>
