---
name: spec-block
description: Author one frozen-behavior Block in docs/spec.md interactively. Use when adding, freezing, or proposing a single product-behavior rule so the spec stays a navigable, atomic record (B-NNN entries) rather than a wall of bullet points. Walks the user through Title / Rule / Rationale / Test / Status / Decision one field at a time and inserts the block in the right place.
---

# spec-block — write product spec one Block at a time

When invoked, walk the user through creating exactly **one** new Block in `docs/spec.md`. Do not write multiple blocks in a single invocation — atomic by design.

## What a Block is

A **Block** is the smallest unit of frozen product behavior: one rule, one rationale, one test pointer, one status. Numbered `B-NNN` and addressable from PRs, decisions (`D-NNN`), and tests.

```
### Block B-NNN: <Title>
**Rule:** <one-line invariant the system must uphold>
**Rationale:** <why — constraint, decision, prior incident>
**Test:** <path/to/test_file.py::test_name or "manual">
**Status:** proposed | draft | frozen | superseded
**Decision:** D-NNN (if this implements a decision-log entry; else "—")
```

The format is fixed. Don't invent new fields per block — drift kills the navigability.

## Procedure

1. **Find the next free `B-NNN`** by scanning `docs/spec.md` under `## Frozen behavior` (or `## Blocks`). Pick the next integer; pad to 3 digits.
2. **Ask the user, one field at a time**, in this order:
   - Title (≤6 words)
   - Rule (one line, imperative or invariant — "X must Y", "On Z, system does W")
   - Rationale (1–2 sentences — the *why*: constraint, prior bug, decision)
   - Test (concrete pointer if it exists; "manual" if not yet)
   - Status (default `proposed` until the test passes; `frozen` only when binding)
   - Decision link (`D-NNN` if relevant; "—" if not)
3. **Render** the block using the exact format above. No prose around it.
4. **Insert** into `docs/spec.md`:
   - Under `## Frozen behavior` (or `## Blocks` if that's the project's heading)
   - Preserve `B-NNN` ordering — append at the end of the section
5. **Stop.** Do not commit. Do not bump VERSION. The Block insert is one piece of step 1 of the next `gogogo!` 5-step workflow; the user will trigger the full sequence when ready.

## When NOT to use this skill

- **Editing an existing Block.** Frozen blocks change via Decision-log entry + status flip to `superseded`, then a new Block supersedes them. Direct edits silently break downstream references.
- **Bulk spec import.** If migrating many rules at once, do it as a single planned edit, not a skill loop.
- **Capturing implementation details.** Internal mechanics belong in `docs/architecture.md` or code comments. Blocks are *product behavior*, observable from outside.
- **Open questions.** Use `## Open project-level decisions` checklist for those, not Blocks.

## Edge cases

- **No `## Frozen behavior` section yet** — create it directly above `## Decision log`, then insert B-001.
- **User unsure about a field** — accept `—` (em dash) for anything but `Title` and `Rule`. Those two are mandatory; the rest can be filled later.
- **Status promotion** — if a Block moves `proposed → draft → frozen` later, that's a normal edit (allowed since it's not changing *meaning*), and it should ride in the `gogogo!` commit that adds the proving test.
