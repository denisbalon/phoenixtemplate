# Adoption journal

**What changed in the kit that a project already built from it should pick up.**

This is not a changelog — [`CHANGELOG.md`](CHANGELOG.md) records every kit change, most of which consumers never need to touch (doc sweeps, linter work, meta-repo housekeeping). This file lists only changes that require action in a **consuming project**, one entry per adoptable change.

**If there is no entry for something, there is nothing to adopt.** Silence here is a positive statement, not an omission.

## How to use it

From a session in a consuming project, run the skill:

```
/updates
```

It fetches this file, runs each entry's **Check** against the project you are in, and reports only what is missing — one line if nothing is. Nothing is applied automatically: read, decide, then adopt through the normal `gogogo!` flow.

### Don't have `/updates` yet?

The skill is itself something to adopt (entry A-003), so a project created before v1.48.0 cannot use it to learn about itself. Install it once, directly:

```sh
# for every project on this machine (recommended — one install, applies everywhere)
curl -fsSL https://raw.githubusercontent.com/denisbalon/phoenixtemplate/main/templates/.claude/skills/updates/SKILL.md \
  --create-dirs -o ~/.claude/skills/updates/SKILL.md

# or for this project only
curl -fsSL https://raw.githubusercontent.com/denisbalon/phoenixtemplate/main/templates/.claude/skills/updates/SKILL.md \
  --create-dirs -o .claude/skills/updates/SKILL.md
```

Projects bootstrapped from the kit at v1.48.0 or later already have it.

Failing that, this file is readable on its own — each entry's **Check** is a plain command you can run by hand.

## Rules

- **Entries are per adoptable change, not per commit or per version.** A rule introduced in one commit and swept across prose mirrors in the next is one entry, not two — adopting half of it leaves the project self-contradictory.
- **An entry is created when the change merges**, not when it is committed. Unmerged work is not adoptable, so it is not listed. A branch that sat unmerged for months gets its entry at merge time and appears after everything already merged, regardless of the version numbers it carries.
- **Entry IDs (`A-NNN`) are assigned in merge order** and never reused or renumbered. Record what you have adopted as an ID (`adopted through A-002`), not a kit version — with per-commit version bumps and rebase merges, a long-lived branch can land commits numbered below what is already on `main`, so version numbers do not reliably order.
- **Adoption is optional unless an entry says otherwise.** Skipping an entry must leave the project in a coherent state.
- **C4 regions:** replace only regions your project already has. Some projects deliberately drop a region that does not apply to them, and re-adding it re-imposes a rule they removed on purpose. C4 regions must match the kit **byte-exact** across every tier the project carries them in, or `scripts/check-rule-consistency.sh` fails.

---

## A-003 — `/updates` skill

**Merged:** 2026-08-18 · **Kit version:** v1.48.0 · **Spec:** B-047 in [`docs/spec.md`](docs/spec.md)

**What:** a `/updates` skill that reads this journal, runs each entry's Check against the project it is invoked in, and reports only what is not adopted — then proposes adoption through the normal `gogogo!` flow. It never edits a file itself. This is the intended way to consume this journal: you type `/updates`, not a URL.

**Affects:** `.claude/skills/updates/SKILL.md` (new file) and your project's manifest, if it keeps one.

**Check:** `test -f .claude/skills/updates/SKILL.md && echo adopted || echo not-adopted`

**Adopt:** copy [`templates/.claude/skills/updates/SKILL.md`](templates/.claude/skills/updates/SKILL.md) into place, either at `~/.claude/skills/updates/SKILL.md` (**user-level — applies to every project on that machine, one install**) or at `.claude/skills/updates/SKILL.md` for this project alone. If you run several projects from one machine, prefer user-level: the per-project copy has to be repeated and kept in step everywhere. If your project has a `manifest.yaml` and you took the per-project route, register it the way the other skill is registered. New projects bootstrapped from the kit get the per-project copy automatically — this entry exists for projects created before v1.48.0.

**Check (user-level):** `test -f ~/.claude/skills/updates/SKILL.md && echo adopted || echo not-adopted` — a user-level install satisfies this entry for every project on the machine, so the per-project Check above may report `not-adopted` while `/updates` works fine.

**Skip if:** you would rather check for kit updates by reading this file directly. Nothing else depends on the skill.

---

## A-002 — Host capabilities (optional)

**Merged:** 2026-08-18 · **Kit version:** v1.46.0 · **Spec:** B-046, D-030 in [`docs/spec.md`](docs/spec.md)

**What:** sessions discover capabilities the *host* provides but the project does not ship — moving files off the box, reaching another machine, driving an attached device — through a single index at `~/docs/README.md`. If the index exists, the session reads it and reads a listed doc on demand. If it does not exist, the host provides no capabilities and **the absence is completely silent**.

**Affects:** `CLAUDE.md` — a non-C4 section, so it is safe to paste and has no byte-exact requirement.

**Check:** `grep -c 'docs/README.md' CLAUDE.md` — `0` means not adopted.

**Adopt:** copy the `## Host capabilities (optional)` section from [`templates/CLAUDE.md`](templates/CLAUDE.md) into your `CLAUDE.md`, before `## Sensitive context`.

**Skip if:** the host your project runs on provides no capability docs. The rule is inert without a `~/docs/README.md`, so adopting it early is harmless and adopting it never costs nothing.

**Note:** v1.45.0 shipped an earlier form naming one capability directly (`~/docs/file-exchange.md`). It was replaced by the index form in v1.46.0 the following day and never existed as a state anyone could have adopted — **adopt v1.46.0 only**.

---

## A-001 — `review-post!` review-publishing token

**Merged:** 2026-08-17 · **Kit versions:** v1.44.0..v1.44.1 · **Spec:** B-045, D-029 in [`docs/spec.md`](docs/spec.md)

**What:** a second, deliberately narrow authorization token alongside `gogogo!`. `review-post!` authorizes reviewing **every PR open at the moment the command is received** and publishing each prepared review package immediately, with no separate `gogogo!`. Scope is hard-bounded to three artifact classes — per-commit comments, inline review comments, and one `event=COMMENT` overall review. It authorizes no PR creation, merge, close, approval, labels, description edits, issue actions, or local changes; those keep their existing gate.

**Affects:**
- `CLAUDE.md` and `CONTRIBUTING.md` — C4 regions `gate-clause` and `proposal-format` (**byte-exact**), plus the non-C4 review prose in both
- `docs/pr_review_instructions.md` — preamble paragraph and output-contract item 1

**Check:** `grep -c 'review-post' CLAUDE.md` — `0` means not adopted.

**Adopt:** replace the `gate-clause` and `proposal-format` C4 regions in every file your project carries them in, byte-exact from [`templates/CLAUDE.md`](templates/CLAUDE.md) / [`templates/CONTRIBUTING.md`](templates/CONTRIBUTING.md), then update the non-C4 review prose in the same files and the two passages in `docs/pr_review_instructions.md`. Run `scripts/check-rule-consistency.sh` afterwards — a partial replacement fails it.

**Adopt both versions together.** v1.44.0 introduced the rule in the C4 regions and the rubric; v1.44.1 swept the non-C4 prose mirrors that still described the old unconditional behaviour. Taking only v1.44.0 leaves your docs contradicting the region that overrides them.

**Skip if:** you want every review publish to stay behind an individual `gogogo!`. The trade is explicit and recorded in D-029 — one token publishes to an unbounded open-PR set with no per-PR checkpoint, which is the cost accepted in exchange for removing the confirmation round-trip on multi-PR review passes.
