---
name: audit
description: Run a full project audit — verify the spec's Blocks (rules) and active decisions against the code, run only the project's declared tests/lints, and emit a gated docs/audit-<id>.md with typed-evidence findings and a commit plan. Use when asked to audit the project, do a project-audit, sweep the spec against the code, or on the phrase "project-audit!". Kit-scoped: relies on the spec id grammar, the version/CHANGELOG convention, and the gogogo! write gate; nothing is written until the Phase-5 artifact commit passes the gate.
---

# audit — project-audit skill (kit, v2)

> **Scope: kit-specific.** This skill runs in projects built from the kit and relies on what the kit guarantees:
> one spec with rule/decision ids, a version marker + changelog convention, a write gate (`gogogo!`-style), a
> `docs/audit-*.md` convention, and declared test/lint commands. It is not portable to arbitrary repos and does
> not pretend to be. Written for a *weaker* model: every step is mechanical, every claim has typed evidence,
> every output is a schema to fill. Rationale for the rules lives in Appendix A, out of the execution path.

---

## 1. Prerequisites (verified in Phase 0; a missing one is finding F-000, and the audit still runs)

| id | requirement | how the skill finds it |
|---|---|---|
| P1 | spec file with id grammar | the file `CLAUDE.md` names as authoritative; ids matching the kit grammar (`B-\d{3}`, `D-\d{3}`) |
| P2 | declared test + lint commands | CI workflow file → `CONTRIBUTING.md` → `Makefile`/`scripts/README.md`, in that order; only commands **declared** there may run |
| P3 | version marker(s) + changelog format | `CONTRIBUTING.md` commit-shape section |
| P4 | write gate token | `CLAUDE.md` gate clause — a **workflow requirement**, never permission by itself |
| P5 | previous audit | newest `docs/audit-*.md` by the base SHA it records (not by filename date) |
| P6 | authority order | `CLAUDE.md`/`CONTRIBUTING.md` statement of which doc is authoritative; kit default: spec > standalone spec > runbook > code comment |

Placeholders used below: `{{SPEC}}`, `{{TEST_CMDS}}`, `{{LINT_CMDS}}`, `{{VERSION_FILES}}`, `{{GATE}}`,
`{{AUTHORITY}}`, `{{SCRATCH}}` (= the session scratchpad dir + `/audit-<RUN_ID>/`), `{{RUN_ID}}` (= `<YYYY-MM-DD>-<base-sha7>`).

---

## 2. Execution boundary (applies to every phase, every agent)

- **May run:** commands listed under P2, `git` read commands, `grep`/`find`/`sed -n`, `python -m py_compile`, `node --check`, `shellcheck`, `go vet`, and read-only remote inspection **only** on hosts `CLAUDE.md` names for it.
- **May not run:** any other script (a `--help`/`--dry-run` flag is not evidence of safety), any restart/deploy/write on a remote host, anything that touches a device, anything with network side effects beyond what a declared test does itself.
- **Writes:** `{{SCRATCH}}` freely; tracked files **never**, except the final artifact commit in Phase 5 through `{{GATE}}`.
- **Timeouts:** 10 min per declared command; a timeout is `timed_out`, not `failed`.
- **Logs:** every command's full output to `{{SCRATCH}}/cmd/<n>.log`; secrets redacted (`secret`, `token`, `key`, `password` values → `<redacted>`) before the log is written.

---

## 3. Phases

### Phase 0 — Snapshot + baseline
1. Record `BASE_SHA=$(git rev-parse HEAD)`, branch, and whether the worktree is dirty (`git status --porcelain`). A dirty worktree is recorded, never stashed or cleaned. `RUN_ID = <date>-<BASE_SHA:7>`.
2. Verify P1–P6; each missing one → `F-000-<n>` (`kind=missing-contract`).
3. Delta: if the previous audit's base SHA is an ancestor of `BASE_SHA` → `git diff --stat <prev>..<BASE_SHA>` and `git log <prev>..<BASE_SHA>`; else record "full audit — previous base not an ancestor / none".
4. Run every declared command **inside its declared working dir**, recording:

   | # | command | cwd | runtime | exit | outcome | skipped | log |
   |---|---|---|---|---|---|---|---|

   `outcome ∈ passed | failed | blocked | timed_out | not_run`. `blocked` = missing interpreter/dependency/service (diagnose from the log: `ModuleNotFoundError`, `command not found`, connection refused). `skipped` = count parsed from output when the runner prints one.
5. **Only `failed` becomes a finding** (kind `execution-failure`, evidence = command + diagnosed cause). `blocked`/`timed_out`/`not_run` go to the **Coverage** section as limits — visible, not findings, not silently dropped.
6. **Gate:** the baseline table exists with one row per declared command.

### Phase 1 — Sweep
Slices are lenses that **may overlap**; the orchestrator dedups by root cause. Each slice gets: the verbatim preamble (§4), its file list, its "done when".

| slice | doc side | code side | done when |
|---|---|---|---|
| A rules | every `B-` block in `{{SPEC}}` | the code its Test clause names | every block has a row `verified` / `finding` / `no-test-named` |
| B decisions | every `D-` entry **not marked superseded** | its "Implemented in" targets | every active entry has a row |
| C standalone specs | `docs/specs/**` | the component each describes | every numbered requirement has a row |
| D runbooks | `docs/runbooks/**` | every script/flag/path/port a runbook cites | every code block in every runbook checked |
| E units + deploy | service/timer units, deploy script | installed set (remote read-only if permitted) | every unit accounted for both ways |
| F env contract | `.env.example` | every `environ`/`getenv` read | every variable accounted for both ways |
| G handoff | README/NOTES/CONTRIBUTING | can a cold reader run tests, deploy, find state? | the seven handoff questions answered |
| H code | — | correctness bugs; then maintainability with a stated benefit | every file > 300 lines opened |

Worker output is **one artifact file** `{{SCRATCH}}/<slice>.md` with sections: `findings` (§5 rows), `leads`
(unverified), `consumers` (traces), `commands`, `files_reviewed`, `files_excluded`, `status: complete|partial`.
The worker's *message* is only: counts per section + the artifact path. If sub-agents are unavailable, the
orchestrator runs the slices **serially** with the same preamble.

**Gate:** the orchestrator has ingested every slice artifact (in bounded batches, never all at once) and every
finding row passes the evidence rule for its kind (§5). Rows that fail move to `leads`.

### Phase 2 — Classify
1. Dedup: merge rows that share a root cause (same code location, or same doc passage) even if worded differently; keep every merged row's evidence.
2. `side` from `{{AUTHORITY}}`: the higher-authority source states the intent → the other side is wrong. If the two sources are *both* silent or *both* explicit and contradictory with no higher authority → `side=undetermined`.
3. `decision_status`: `none` (fix is mechanical) · `pending` (a consequential choice exists: naming, policy, deprecation, migration, blast radius beyond one file) · later `answered`. A confirmed code defect can still be `pending` if *how* to fix it is a choice.
4. Severity by **demonstrated impact**: `critical` = a runtime/safety invariant broken (name the id if one exists; a serious defect without an id is still critical) · `major` = operator would act wrongly / real bug · `minor` = stale, harmless · `cosmetic`.

### Phase 3 — Decision pause (one, and only if `pending` rows exist)
Emit every `pending` row as a question (§6), batched, numbered. Wait. On silence: save the artifact as **draft**
(status line at the top), commit nothing, stop. Never implement an unresolved choice.

### Phase 4 — Plan
Every row with `decision_status ∈ {none, answered}` → a commit entry (§7). Rules: `execution-failure` rows first;
a code change and the doc text that describes it go in the **same** commit; doc-only rows batched per file;
≤ ~300 changed lines per commit; each commit rebase-safe on its own.

### Phase 5 — Emit
1. Write `docs/audit-{{RUN_ID}}.md` (§8).
2. `git checkout -b audit/{{RUN_ID}}` (refuse if the branch exists); `git add docs/audit-{{RUN_ID}}.md`; verify `git diff --cached --stat` lists **only** that file; commit through `{{GATE}}` with subject `docs: audit {{RUN_ID}} — <n> findings, <m> commits planned v<X.Y.Z>` following P3.
3. Record the artifact commit SHA in the artifact's header on the next line (audited SHA ≠ artifact SHA).

---

## 4. Worker preamble (copy VERBATIM; never paraphrase)

```
You audit ONE slice of this project. Rules:
1. TYPED EVIDENCE OR IT IS A LEAD. Each finding has a `kind` and the evidence that kind requires (table
   below). A claim missing its evidence goes to `leads` with what is missing and why you stopped — never
   into findings, never deleted.
2. RUN ONLY DECLARED COMMANDS (the list you were given). Reading a test is not running it. Record every
   command, cwd, exit code and log path in `commands`.
3. CONSUMER TRACE. For every value/flag/field/file you judge, list its producer and the consumers you found
   (grep by name, plus config indirection and generated code where you can) and STATE THE BOUNDARY you
   searched ("grep over hub/ scripts/; did not inspect Go generated code"). A fix right for one consumer
   and wrong for another → decision_status=pending.
4. READ-ONLY: no tracked-file edits, no commits, no remote mutation, no devices, no secrets in output.
5. HISTORY IS NOT AN ERROR: CHANGELOG, docs/archive/**, and spec entries MARKED superseded. A dated but
   ACTIVE decision is in scope — audit code against it.
6. SEVERITY by demonstrated impact (critical/major/minor/cosmetic). SIDE per the authority order you were
   given; if you cannot establish intent, side=undetermined.
7. If you are guessing about an external tool/API/library: write it as a lead after two attempts; stop.
8. OUTPUT: write ONE artifact file with sections findings / leads / consumers / commands / files_reviewed /
   files_excluded / status. Your message is counts + the path. Nothing else.

Evidence by kind:
  contradiction     : normative doc passage (path:line) + conflicting implementation (path:line)
  code-defect       : implementation (path:line) + a reproduction (command+output) OR a traced execution path
  missing-contract  : the expectation (path:line or rule id) + the search you ran (scope + pattern + result)
  execution-failure : command + exit + diagnosed cause (from the log), after ruling out blocked/timed_out
  handoff-gap       : the question a cold reader cannot answer + where they would look and what is absent

Finding row:  F-<slice><n> | kind | sev | side | claim ≤ 20 words | evidence (per kind) | consumer trace ref
Lead row:     L-<slice><n> | claim | missing evidence | why verification stopped
```

---

## 5. Merged finding schema (orchestrator)

| id | kind | sev | side | decision_status | slice(s) | claim | evidence | consumers (trace ref) | fix (one sentence, or "pending Q<n>") |
|---|---|---|---|---|---|---|---|---|---|

Good row: `F-E1 | contradiction | major | code | pending | E | liveness probe uses the v6-only echo, so a v4-only live session fails it | spec.md:474 (probe = "carries traffic"); reap.sh:40 (curl to ip_echo=api6) | reaper→sshd session→control channel→doctor→alerter (grep scripts/ hub/) | pending Q1: v4 fallback vs dual-stack echo`
Bad row (→ lead): `major | the reaper seems too aggressive | reap.sh` — no kind, no line, no trace, hedged.

---

## 6. Question shape

```
Q<n> (F-<id>, sev <sev>): <the unresolved consequential choice, one sentence>
   A: <concrete> — consequence: <one line>
   B: <concrete> — consequence: <one line>
   Recommendation: <A|B> — <one line of evidence>
```
Max 3 options. Never a question the repo answers. Answers are recorded verbatim.

---

## 7. Commit plan entry

```
### C<n>  <type>: <description>  v<X.Y.Z>
items:            F-…, F-…            side: doc|code|both
files:            <every path>
steps:            spec? → bump {{VERSION_FILES}} → CHANGELOG `## v<X.Y.Z> — <date>` → change (+ the doc text that describes it) → test
baseline_result:  <command> → <outcome now, from Phase 0 or run here>
post_fix_verify:  <exact command(s)>        expected_result: <exit 0 / specific line>
reviewer notes:   <what to challenge>
```

---

## 8. Artifact skeleton — `docs/audit-{{RUN_ID}}.md`

```
# Audit {{RUN_ID}} — base <BASE_SHA> (<branch>, v<X.Y.Z>, worktree clean|dirty)   status: complete | draft
artifact commit: <filled after Phase 5>
## Prerequisites            P1–P6 with found/missing
## Baseline                 table from Phase 0
## Coverage                 blocked/timed_out/not_run commands · slices complete/partial · files_excluded · search boundaries
## Delta                    <prev base>..<BASE_SHA> (<n> commits) | full audit because <reason>
## Questions                Q<n> … → answer: "<verbatim>"  (or "none pending")
## Findings                 table §5  (counts by sev, by kind, by side)
## Leads                    unverified, with what is missing
## Refactors                only with a stated concrete benefit; never scheduled by the skill
## Commit plan              entries §7, ordered
## Commands run             every command, cwd, exit, log path
## Self-check
- [ ] every finding row carries the evidence its kind requires
- [ ] every pending row has a question, and every question an answer (or status: draft)
- [ ] every finding with decision_status ∈ {none, answered} appears in exactly one commit entry
- [ ] every commit entry has baseline_result, post_fix_verify, expected_result
- [ ] Coverage lists every blocked/timed_out/not_run command and every partial slice
- [ ] no history file (CHANGELOG, archive, superseded entries) appears as a finding
- [ ] no unresolved {{placeholder}} remains in this file
- [ ] `git diff --cached --stat` lists only this file
```

---

## 9. Do-not list

- Do not fix anything in the audit commit; do not tidy while there.
- Do not run any command outside the declared list; do not treat `--dry-run`/`--help` as safe.
- Do not rewrite a higher-authority doc to match code; do not rewrite code to match a lower-authority doc.
- Do not report history as error; do not exclude a decision merely because it is dated.
- Do not ask what the repo answers; do not proceed on silence; do not choose for the owner.
- Do not report a test as passing unless you ran it in this session and recorded its outcome.
- Do not claim "all consumers found" — state the boundary searched.

---

## Appendix A — why (kept out of the execution path)

- **Run, don't read.** A 168-finding audit found four red test suites only by executing them; the readers had reported them green.
- **Typed evidence.** "Both citations always" made missing-test and runtime findings unwritable; leads were being deleted instead of reported.
- **Consumer trace.** A liveness probe that used an IPv6-only echo killed live IPv4-only tunnels every 35 s for 13 hours; it was obvious the moment the probe's consumers were listed.
- **Blocked ≠ failed.** A suite needing an uninstalled dependency was a coverage gap, not a defect.
- **Dated decisions stay active.** Excluding "dated" entries excluded the very decisions code must be checked against.
- **One decision pause.** A model that asks as it goes never finishes the sweep; a model that never asks decides for the owner.
- **Artifact-only commit.** An audit that half-executes fixes is worse than no audit; execution is the project's ordinary, gated cadence.
- **Verbatim preamble.** Paraphrased rules drift per slice; copied rules do not.

## Appendix B — dry-run cases before adopting into the kit

A repo with: (1) an environment-blocked test suite; (2) an active dated decision the code violates; (3) a pure code defect with no doc side; (4) a dirty worktree; (5) more findings than the worker cap; (6) a decision question the owner leaves unanswered. Each must yield an honest artifact: no lost findings, no claimed-but-unexecuted verification, draft status where appropriate.
