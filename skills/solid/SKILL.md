---
name: solid
description: >
  Production development playbook for application code. Use when implementing
  a feature, fixing a bug, or reshaping modules. Applies tests, SOLID, and
  smell checks. Rules 01 and 04 stay the floor. Do not use for incident
  triage, API-contract review, or cloud-cost work.
---

# Production code

Write the change a teammate can ship and debug later. Rule `01` (quality) and rule `04` (architecture) are the floor. This skill is the order of work on top of them.

Use it for application code: a feature, a bugfix, or a local reshape. For a large move across many callers, follow `refactor-large-codebase` for the steps and this skill for the shape of the code. For a diff review, use `code-review-expert`. For an HTTP contract, use `api-design-assistant`.

## Order of work

1. Name the behavior and the production invariant that must still hold.
2. Pin it with a test before the production edit:
   - New behavior: a failing test first. See [references/tdd.md](references/tdd.md).
   - Bugfix: a regression test that fails before the fix.
   - Untested code you are only moving: a characterization test that locks current behavior.
3. Make it pass with the simplest real implementation. A hardcoded return is a step inside the loop, not a commit.
4. Clean up only what the change exposed. Extract a function when its name needs "and", or when nesting passes about three levels. Extract duplication on the third copy.

## Design questions

Ask these of the code you are about to add. Split when the answer is yes, not when a line counter trips.

| Question | If yes |
| --- | --- |
| Does this module have two reasons to change? | Split it. See [references/solid-principles.md](references/solid-principles.md). |
| Can a caller pass a value this domain rejects (money without a currency, a malformed email)? | Give that value a type and validate it at the edge. A bare id string can stay a string. |
| Does a high-level module construct its own database, clock, or HTTP client? | Inject it. No singleton and no hidden global. |
| Is this a new interface, factory, or pattern for a case that exists once? | Don't add it. Wait for the third copy. |

Open [references/code-smells.md](references/code-smells.md) when a module is hard to change. A smell is a prompt to look, not a quota. Open [references/object-design.md](references/object-design.md) or [references/complexity.md](references/complexity.md) only when you are choosing what a type is responsible for.

## What not to do

- Do not wrap every primitive in a class.
- Do not split a clear function to satisfy a line limit.
- Do not introduce a pattern from a catalog. This skill has no pattern list on purpose.
- Do not swallow errors or skip the unhappy path. Rule `01` names the cases: null, empty, timeout, duplicate, boundary.

## Done when

- The new or fixed behavior has a test, including one failure path.
- The diff does not change behavior you did not intend to change.
- You can name what you refused to abstract.
