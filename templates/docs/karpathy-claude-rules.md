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

These rules apply *inside* the `gogogo!` 5-step sequence:

- **Step 1 (spec)** — Rule 1: state assumptions in the spec entry before any code.
- **Step 3 (code)** — Rules 2 + 3: minimal, surgical edits; resist scope creep.
- **Step 4 (commit)** — Rule 4: the commit message should reference the verification (test name, manual check, healthcheck) — not just the change.

If you catch yourself rationalizing past any of these, stop and ask.
