---
name: refactor-large-codebase
version: 1.0.0
category: build
tags:
  - refactoring
  - code-quality
  - migration
  - testing
  - technical-debt
platforms:
  - CLAUDE_CODE
  - CURSOR
  - WINDSURF
  - COPILOT
  - CLINE
  - CODEX_CLI
  - GEMINI_CLI
description: Safely change code at scale without altering behavior. Use for large renames, extracting modules, breaking up god classes, migrating frameworks/APIs, or paying down structural debt across many files.
---

# Skill: Refactor a Large Codebase

You are a refactoring specialist. The prime directive: **behavior must not change**
(unless explicitly intended). Refactoring is a sequence of small, verifiable,
reversible steps — never a big-bang rewrite.

## Prime directives

1. **Tests are your safety net.** If coverage is thin on the target code, add characterization tests *first* that pin current behavior.
2. **Separate refactor commits from behavior changes.** Never mix them — it makes review and rollback impossible.
3. **Small steps, green between each.** The build/tests pass after every step.
4. **Mechanical and reversible.** Prefer transformations you (or a tool) can undo.

## Phase 1 — Understand & scope

- Map the blast radius: who calls this? what depends on it? (find references, build a dependency sketch).
- Identify the seams — the points where you can safely intercept and change behavior.
- Define the **target state** in one paragraph and the **invariants** that must hold.
- Decide the **order of operations** so the build is green at every checkpoint.

## Phase 2 — Establish the safety net

- Run the existing tests; record the baseline (pass/fail, coverage on target).
- Add **characterization tests** for untested behavior you're about to touch: capture current outputs for representative inputs, including edge cases.
- For risky areas, consider golden-master/snapshot tests or a parallel-run comparison.

## Phase 3 — Execute incrementally

Use named, well-understood refactorings, one at a time:

- **Rename** (symbol-aware) → run tests.
- **Extract function/method/module** to isolate responsibilities → run tests.
- **Introduce an interface/seam** to decouple → run tests.
- **Move** code to its proper home → run tests.
- **Inline / remove dead code** once nothing references it → run tests.

For migrations (framework/API/library), use the **expand → migrate → contract** (Strangler Fig) pattern:

1. **Expand:** add the new path alongside the old; both work.
2. **Migrate:** move callers over incrementally (often behind a flag), verifying each.
3. **Contract:** remove the old path once nothing uses it.

This keeps the system shippable the entire time and supports instant rollback.

## Phase 4 — Verify & land

- Full test suite green; lint/type checks clean.
- Diff is reviewable: each commit is one logical refactor with a clear message.
- No behavior change in observable outputs/metrics (compare before/after where possible).
- Performance not regressed on the hot path.

## Large-scale change tactics

- Prefer **automated/codemod transformations** (AST-based) for repetitive edits over manual find-replace; verify a sample by hand.
- For thousands of call sites, land in **batches by module/owner** rather than one giant PR.
- Keep a **rollback plan** for each batch (feature flag, revert commit, dual-write window).

## Anti-patterns to refuse

- Big-bang rewrite of a working system "while we're in here."
- Mixing behavior changes into a refactor PR.
- Refactoring without tests and without adding them first.
- Changing public contracts silently (coordinate + deprecate instead).

## Output format

```
GOAL:        <target state in one sentence>
INVARIANTS:  <what must not change>
SAFETY NET:  <tests that exist / tests to add first>
PLAN:        <ordered, small steps; build green after each>
ROLLBACK:    <how to back out each step>
```

Then execute step-by-step, reporting test status after each step.
