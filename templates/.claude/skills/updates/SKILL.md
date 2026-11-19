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

### 2. Read the watermark, then Check only what is newer

The project records an **adoption watermark** — the highest journal entry it has already **decided** on (adopted *or* deliberately skipped) — in `.claude/kit-adopted-through` (B-057). Read it first:

```sh
grep -oE 'A-[0-9]+' .claude/kit-adopted-through 2>/dev/null | sort -t- -k2 -n | tail -1
```

- **A watermark exists** (e.g. `A-015`) → every entry at or below it is **settled**: do **not** run its Check, do not mention it. Run the Check **only for entries strictly above** the watermark (`A-016`, `A-017`, …). This is the whole point — settled decisions, including deliberate skips, must not re-surface as "unadopted" every run.
- **No file, or it is empty** (a project created before B-057, or one that never adopted it) → fall back to the pre-watermark behavior: run **every** entry's Check. The proposal in step 4 will create the file.

Entries are IDed `A-NNN` in merge order, newest first. For each entry above the watermark, run its one-line **Check** as-is in the project root and record adopted / not adopted.

If a Check refers to a file this project does not have, that is not a failure — note it and treat the entry as not applicable rather than not adopted.

### 3. Report

Report only over the entries **above the watermark** (or all entries, in the no-watermark fallback).

- **Nothing new** → say exactly that, in one line, and stop. No table, no summary of what was checked, no restating settled entries. Being current is the common case and should be quiet. (If the watermark is already at the newest entry, there is nothing to Check — say so and stop.)
- **Something missing** → list only the unadopted entries above the watermark. For each: the ID, what it changes, which files it affects, and whether the entry marks it optional or says who should skip it.

Never present an entry as required when its **Skip if** clause applies to this project.

### 4. Propose, do not apply

Adoption is a normal state-mutating change: surface a concrete proposal naming the exact files and edits, and wait for `gogogo!`. This skill never edits a file itself.

The proposal has **two parts**, and both are gated by the one `gogogo!`:

1. The concrete adoptions — the files and edits for each entry the user chooses to adopt.
2. **Advance the watermark.** Write the new watermark into `.claude/kit-adopted-through` (creating the file if absent). The watermark is **decided-through**, not adopted-through, and it advances **only across the contiguous prefix of entries explicitly decided this run** — starting just above the old watermark and stopping at the first entry the user did **not** decide. A deliberate **skip** is a decision ("I don't want this") and does **not** stop the advance; a **defer** ("not now" — the user neither adopts nor skips) is **not** a decision and **halts** the advance at the entry below it, leaving the deferred entry (and everything above it) to surface again next run. Never write a later ID just because a later entry was adopted — that would bury the undecided entry in between. Worked examples over `A-016..A-018`:
   - adopt A-016, **skip** A-017, adopt A-018 → watermark `A-018` (all three decided).
   - adopt A-016, **defer** A-017, adopt A-018 → watermark `A-016` (A-017 is undecided and stops the prefix, even though A-018 was adopted — A-017 **and** A-018 re-surface next run).
   - **defer** A-016 entirely → watermark unchanged.

Two things to carry into the adoption part of that proposal:

- **C4 regions must be replaced byte-exact**, and **only regions this project already has.** A project that deliberately dropped a region (because the rule does not apply to it) must not have it re-added — re-imposing a removed rule is a regression, not an update. Run `scripts/check-rule-consistency.sh` afterwards if the project has it; a partial replacement fails it.
- **Entries flagged as adopt-together must be adopted together.** Taking half of a change that spans versions can leave the project's prose contradicting the region that overrides it.

## Notes

- The journal is the source of truth for *what to adopt*; the kit's `CHANGELOG.md` is not — it records every kit change, the large majority of which consumers never touch.
- The watermark is recorded as an entry **ID** (`A-015`), never a kit version. Version numbers do not order reliably: per-commit bumps plus rebase merges let a long-lived branch land commits numbered below what is already on the kit's `main`.
- If the user later changes their mind about a **skipped** entry (now below the watermark, so no longer surfaced), they lower the watermark by hand, or read the journal entry directly — the journal is always fully readable.
