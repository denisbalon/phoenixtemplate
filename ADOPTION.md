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
curl -fsSL --connect-timeout 10 --max-time 60 https://raw.githubusercontent.com/denisbalon/phoenixtemplate/main/templates/.claude/skills/updates/SKILL.md \
  --create-dirs -o ~/.claude/skills/updates/SKILL.md

# or for this project only
curl -fsSL --connect-timeout 10 --max-time 60 https://raw.githubusercontent.com/denisbalon/phoenixtemplate/main/templates/.claude/skills/updates/SKILL.md \
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

## A-007 — `/review` dispatch skill

**Merged:** 2026-08-20 · **Kit version:** v1.52.0 · **Spec:** B-051, D-034 in [`docs/spec.md`](docs/spec.md)

**What:** a `/review` skill that lists the reviewer sessions on the host — deduplicated by GitHub repository, most recent per repo — **stops for you to name one**, checks it is not held by an interactive client, dispatches the review, and relays every finding **verbatim**. It never picks a session itself and never edits a file; adopting a finding is a separate gated proposal.

Supersedes B-010's "ships no Claude-side reviewer trigger" clause. Review is still user-initiated, the rubric is still reviewer-agnostic, and the kit still configures **no default reviewer** — the skill asks which session to use and cannot answer that itself.

**Affects:** `.claude/skills/review/SKILL.md` (new file) and your project's manifest, if it keeps one.

**Check:** `test -f .claude/skills/review/SKILL.md && echo adopted || echo not-adopted`

**Adopt:** copy [`templates/.claude/skills/review/SKILL.md`](templates/.claude/skills/review/SKILL.md) into place, either at `~/.claude/skills/review/SKILL.md` (**user-level — one install covers every project on that machine**) or `.claude/skills/review/SKILL.md` for this project alone. Prefer user-level if you run several projects from one machine. New projects bootstrapped at v1.52.0 or later get the per-project copy automatically.

**Check (user-level):** `test -f ~/.claude/skills/review/SKILL.md && echo adopted || echo not-adopted` — a user-level install satisfies this entry for every project on the machine, so the per-project Check above may report `not-adopted` while `/review` works fine.

**Skip if:** your reviewer cannot be invoked non-interactively, or you review manually. The skill assumes a resumable reviewer session addressable by id; without one it has nothing to dispatch into, and reviewing by hand as before costs you nothing.

---

## A-006 — proposals end with a command list, not a sentence

**Merged:** 2026-08-20 · **Kit version:** v1.50.0 · **Spec:** B-049, D-033 in [`docs/spec.md`](docs/spec.md)

**What:** the invitation line at the end of every numbered proposal becomes a **command list** — the valid inputs as inline-code spans on one comma-separated line, e.g. `` `1 gogogo!`, `2 gogogo!`, `1 2 gogogo!` or `3` `` — instead of prose the reader decodes into digits. Bounded to: every option individually, the all-`[change]` combination on a "Choose any" list, and any combination the proposal recommends. Never the power set. "Choose one" lists show no combinations; single suggestions show only `gogogo!`.

The three invitation forms and every gate condition are unchanged — this is purely how the line is rendered.

**Affects:** `WORKFLOW.md`, `CLAUDE.md` and `CONTRIBUTING.md` — the C4 `proposal-format` region (**byte-exact**). All three must move together; syncing a subset fails `scripts/check-rule-consistency.sh`.

**Check:** `grep -c 'The command line' CLAUDE.md` — `0` means not adopted.

**Adopt:** replace the `proposal-format` C4 region in every file your project carries it in, byte-exact from [`templates/CLAUDE.md`](templates/CLAUDE.md) / [`templates/CONTRIBUTING.md`](templates/CONTRIBUTING.md). Run `scripts/check-rule-consistency.sh` afterwards.

**Skip if:** your proposals are read rather than tapped, and the prose line causes you no friction. The change costs nothing to skip — the gate conditions are identical either way, so a project on the old rendering and one on the new behave the same; only the last line of a proposal looks different.

---

## A-005 — review requests bundle into PR-open and address-review

**Merged:** 2026-08-20 · **Kit version:** v1.49.0 · **Spec:** B-048, D-032 in [`docs/spec.md`](docs/spec.md)

**What:** where your project has a reviewer that can be invoked **non-interactively**, two nodes of the per-node cadence gain bundled sub-steps. PR-open becomes atomic over `gh pr create` → request review → relay findings verbatim; each address-review node becomes atomic over fix commit → push → `gh pr edit` → re-request review → relay. One `gogogo!` per node instead of two.

Four constraints bind it: the proposal names the exact reviewer target; any exclusivity constraint is checked *before* proposing rather than during execution; the blast radius is stated when the reviewer covers more than the PR at hand; and bundled fixes are limited to **mechanical** findings — anything needing interpretation stops and is surfaced unfixed.

**Affects:** `WORKFLOW.md`, `CLAUDE.md` and `CONTRIBUTING.md` — the C4 `proposal-format` region (**byte-exact**), plus the PR-open and address-review node descriptions in `WORKFLOW.md`'s on-branch workflow section. All three files must be updated together: the region is compared byte-for-byte across every tier the project carries, so syncing two of three fails `scripts/check-rule-consistency.sh`.

**Check:** `grep -c 'atomic over requesting review' CLAUDE.md` — `0` means not adopted.

**Adopt:** replace the `proposal-format` C4 region in every file your project carries it in — byte-exact from [`templates/CLAUDE.md`](templates/CLAUDE.md) / [`templates/CONTRIBUTING.md`](templates/CONTRIBUTING.md) — and update the PR-open and address-review node prose in your `WORKFLOW.md` to match, so the loaded region and the detailed workflow do not contradict each other. Run `scripts/check-rule-consistency.sh` afterwards; a partial replacement fails it.

**Skip if:** your review is manual or fully out-of-band. The rule is inert without a non-interactively invocable reviewer, so adopting it changes nothing for you — but skipping is equally fine, and skipping deliberately is better than adopting a rule you cannot exercise.

---

## A-004 — per-commit coverage: any one form suffices

**Merged:** 2026-08-20 · **Kit version:** v1.48.3 · **Spec:** B-043 in [`docs/spec.md`](docs/spec.md)

**What:** the review rubric's output contract now states directly that a commit is covered by **any one** of the three listed forms — inline comments carrying `commit_id`, a commit-level review, or an explicit clean-commit comment. Previously item 2 listed the three alternatives but never said one was enough, so "each commit gets at least one comment" could be read as requiring a commit-scoped comment *in addition to* inline findings. Also fixes a self-referential `(see 2)` pointer that should have read `(see 3)`.

**Affects:** `docs/pr_review_instructions.md` — output-contract item 2.

**Check:** `grep -c 'Any one of these satisfies coverage' docs/pr_review_instructions.md` — `0` means not adopted.

**Adopt:** replace output-contract item 2 with the version in [`templates/docs/pr_review_instructions.md`](templates/docs/pr_review_instructions.md). Prose only, no byte-exact requirement.

**Skip if:** you want your reviewers held to the stricter reading — a commit-scoped comment on every commit regardless of inline findings. That is more audit trail per review and is a legitimate choice; the kit simply no longer requires it.

---

## A-003 — `/updates` skill

**Merged:** 2026-08-18 · **Kit version:** v1.48.0 · **Spec:** B-047 in [`docs/spec.md`](docs/spec.md)

**What:** a `/updates` skill that reads this journal, runs each entry's Check against the project it is invoked in, and reports only what is not adopted — then proposes adoption through the normal `gogogo!` flow. It never edits a file itself. This is the intended way to consume this journal: you type `/updates`, not a URL.

**Affects:** `.claude/skills/updates/SKILL.md` (new file) and your project's manifest, if it keeps one.

**Check:** `test -f .claude/skills/updates/SKILL.md && echo adopted || echo not-adopted`

**Adopt:** copy [`templates/.claude/skills/updates/SKILL.md`](templates/.claude/skills/updates/SKILL.md) into place, either at `~/.claude/skills/updates/SKILL.md` (**user-level — applies to every project on that machine, one install**) or at `.claude/skills/updates/SKILL.md` for this project alone. If you run several projects from one machine, prefer user-level: the per-project copy has to be repeated and kept in step everywhere. If your project has a `manifest.yaml` and you took the per-project route, register it the way the other skill is registered. New projects bootstrapped from the kit get the per-project copy automatically — this entry exists for projects created before v1.48.0.

**Check (user-level):** `test -f ~/.claude/skills/updates/SKILL.md && echo adopted || echo not-adopted` — a user-level install satisfies this entry for every project on the machine, so the per-project Check above may report `not-adopted` while `/updates` works fine.

**Skip if:** you would rather check for kit updates by reading this file directly. Nothing else depends on the skill.

**Amended v1.48.2:** the skill's fetch and both install commands above now carry `--connect-timeout 10 --max-time 60`. If you adopted this entry before v1.48.2, re-copy the skill — an unbounded `curl` can hang a session indefinitely instead of failing cleanly.

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
