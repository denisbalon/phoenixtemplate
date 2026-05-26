# Karpathy's coding-with-Claude rules

Adapted from Andrej Karpathy's [Jan 26 2026 X-post](https://x.com/karpathy/status/2015883857489522876) on LLM coding pitfalls and the community-distilled [`andrej-karpathy-skills` CLAUDE.md](https://github.com/forrestchang/andrej-karpathy-skills).

LLMs (Claude included) consistently fail in four shapes. Each rule below pairs the failure mode with the counter-behavior the agent should adopt. Treat them as standing instructions; they're folded into [`CLAUDE.md`](../CLAUDE.md) so they apply to every session in this project.

---

## 1. Unexamined assumptions → Think before coding

**Failure:** the model invents an assumption (a parameter shape, a contract, a user intent) and runs along with it without checking.

**Counter:**
- State assumptions explicitly before acting on them.
- When the request is ambiguous, surface 2–3 plausible interpretations and ask which one — don't pick silently.
- Verify load-bearing facts (file exists, function signature, schema column) before depending on them.

### Web-search before iterate on external surfaces (B-036)

External surfaces — APIs, SDKs, 3rd-party services, library/framework versions — are the highest-risk subset of "load-bearing facts." Claude's training data has a cutoff and those surfaces drift constantly between minor versions; what was true at training time can be wrong now, and code-side iteration on external-behavior issues compounds the cost of an assumption error.

**Order of operations is search-then-iterate, not iterate-then-search.** Four concrete triggers:

1. **New external surface.** Before writing integration code against an unfamiliar API / SDK / service / library, propose a `WebSearch` for current docs, version-specific behavior, breaking changes vs. the training-data version.
2. **External error or exception.** Before attempting a code-side fix for any error/exception/unexpected behavior originating from an external surface, propose a `WebSearch` of the exact error string or symptom.
3. **N=2 trip-wire.** After 2 failed iterations of the same external-behavior fix, STOP iterating. Propose a `WebSearch` for the specific symptom. "Maybe one more code change" past N=2 is a forbidden pattern — that's the path to half-a-day-on-a-known-issue.
4. **Self-noticed guessing.** Any time Claude notices it's reasoning about external behavior without concrete documentation or test backing, STOP and propose a `WebSearch`.

`WebSearch` proposals are `[info]`-class (read-only) — the user picks bare `N` to proceed; no `gogogo!` needed. The lowest-friction path possible: one keystroke between "we should check this" and "the answer is on screen."

**Motivating incident (today):** real bug on another project, fought code-side for half a day, turned out to be a known upstream issue everyone works around. A `WebSearch` of the symptom early in that session would have surfaced the workaround in seconds. This rule exists so that failure mode doesn't repeat — across this project and every project that adopts the kit.

The rule applies **even when the relevant code looks in-training-data**. Library minor versions ship breaking changes routinely; the training snapshot is one point in time. Treat external-surface verification as a continuous obligation, not a one-time-at-training-cutoff check.

## 2. Overengineered solutions → Simplicity first

**Failure:** unnecessary abstractions, speculative configuration, dead code left behind, three-layer factories where a function would do.

**Counter:**
- Implement only what was asked. No "while I was here" cleanup, no "this might be useful later" hooks.
- Prefer the smallest reasonable change. Three similar lines beats a premature abstraction.
- Delete what you replace; don't leave commented-out blocks "just in case." Git remembers.

## 3. Unintended collateral changes → Surgical changes

**Failure:** edits to unrelated lines, comments quietly rewritten, formatting reflowed, helpers renamed mid-task.

**Counter:**
- Touch only what's necessary for the stated task.
- Match the file's existing style — don't introduce a new convention as a side effect.
- If you notice unrelated improvements worth making, mention them in chat; don't bundle them into the diff.

## 4. No verification → Goal-driven execution

**Failure:** the agent declares success without proving it. Code compiles is taken as code works.

**Counter:**
- Turn each task into a testable success criterion before writing the code.
- After implementing, actually run the test / hit the endpoint / read the output. Quoting the criterion back doesn't satisfy it.
- For UI work especially: opening the page in a browser counts; "the types pass" doesn't.

---

## The slogan

> Don't tell it what to do. Give it success criteria and watch it go.

LLMs are exceptionally good at looping until they meet a verifiable goal. The bottleneck is rarely capability — it's stating the goal clearly enough that the loop terminates on something real.

## How this fits the workflow

These rules apply *inside* the `gogogo!` on-branch 6-step sequence:

- **Step 2 (spec)** — Rule 1: state assumptions in the spec entry before any code.
- **Step 4 (code)** — Rules 2 + 3: minimal, surgical edits; resist scope creep.
- **Step 5 (commit + push)** — Rule 4: the commit message should reference the verification (test name, manual check, healthcheck) — not just the change.

If you catch yourself rationalizing past any of these, stop and ask.
