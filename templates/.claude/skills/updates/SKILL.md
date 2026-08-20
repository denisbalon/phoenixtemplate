---
name: updates
description: Check which kit updates this project has not adopted yet. Fetches the phoenixtemplate adoption journal, runs each entry's check against this project, and reports only what is missing. Use when asked what is new in the kit, whether this project is up to date with the template, or to sync template rules. Reports and proposes only — never edits files on its own.
---

# updates — what has this project not adopted from the kit?

The kit (`phoenixtemplate`) publishes an **adoption journal** listing changes a project built from it should pick up. Most kit changes need no action and are deliberately absent from it. This skill answers one question: **what, if anything, is this project missing?**

## Steps

### 1. Fetch the journal

```sh
curl -fsSL --connect-timeout 10 --max-time 60 https://raw.githubusercontent.com/denisbalon/phoenixtemplate/main/ADOPTION.md
```

Use `curl` via Bash rather than WebFetch — WebFetch is frequently not permitted, and this is a plain public file. **Keep the timeouts.** `--connect-timeout 10 --max-time 60` are load-bearing, not decoration: without them a stalled DNS, TCP or TLS connection blocks the session indefinitely and the fail-and-stop behaviour below never runs, because `curl` never returns. A hang is worse than an error — an error you can act on. If the fetch fails (no network, a timeout, or the URL 404s), say so plainly and stop. **Do not** guess what the journal says or work from memory of a previous run; a stale answer here is worse than no answer.

### 2. Run each entry's Check

Every entry carries a one-line **Check** command intended to be run as-is in the project root. Run each one and record adopted / not adopted. Entries are IDed `A-NNN` in merge order, newest first.

If a Check refers to a file this project does not have, that is not a failure — note it and treat the entry as not applicable rather than not adopted.

### 3. Report

- **Nothing missing** → say exactly that, in one line, and stop. No table, no summary of what was checked, no restating entries that are already adopted. Being current is the common case and should be quiet.
- **Something missing** → list only the unadopted entries. For each: the ID, what it changes, which files it affects, and whether the entry marks it optional or says who should skip it.

Never present an entry as required when its **Skip if** clause applies to this project.

### 4. Propose, do not apply

Adoption is a normal state-mutating change: surface a concrete proposal naming the exact files and edits, and wait for `gogogo!`. This skill never edits a file itself.

Two things to carry into that proposal:

- **C4 regions must be replaced byte-exact**, and **only regions this project already has.** A project that deliberately dropped a region (because the rule does not apply to it) must not have it re-added — re-imposing a removed rule is a regression, not an update. Run `scripts/check-rule-consistency.sh` afterwards if the project has it; a partial replacement fails it.
- **Entries flagged as adopt-together must be adopted together.** Taking half of a change that spans versions can leave the project's prose contradicting the region that overrides it.

## Notes

- The journal is the source of truth for *what to adopt*; the kit's `CHANGELOG.md` is not — it records every kit change, the large majority of which consumers never touch.
- Record what this project has adopted as an entry ID (`adopted through A-002`), not a kit version. Version numbers do not order reliably: per-commit bumps plus rebase merges let a long-lived branch land commits numbered below what is already on the kit's `main`.
