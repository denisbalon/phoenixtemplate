# Product specification — <PROJECT_NAME>

Living spec. <PROJECT_SPECIFIC: reference to any external/legacy spec if applicable.>

## Summary

<One paragraph describing what the system does end-to-end.>

## Process & versioning

Process for making changes — branching, commits, the **`code!` passphrase gate**, the **5-step atomic workflow** (spec → bump+CHANGELOG → code → commit → deploy; ENDS at deploy, does not auto-open a PR), the **push-after-every-commit** policy, the **multi-commit-per-branch** rule, the **rebase-merge** strategy, the **version-bump-on-every-change** rule — is binding and lives in [`CONTRIBUTING.md`](../CONTRIBUTING.md). Current version: `<X.Y.Z>` (see `VERSION` at repo root). Per-version diary lives in [`CHANGELOG.md`](../CHANGELOG.md). Architectural decisions live in the Decision log below.

The reusable template behind this project's process and structure lives at [`PROJECT_STARTER.md`](../PROJECT_STARTER.md).

## Frozen behavior

Decisions that are binding on implementation. Update via PR; never silently change.

- <Frozen rule 1>
- <Frozen rule 2>

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
