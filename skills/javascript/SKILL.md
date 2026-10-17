---
name: javascript
description: >
  Production JavaScript and TypeScript playbook. Use when writing or reviewing
  JS or TS: equality, types that disappear at runtime, async failures, parses,
  and untrusted HTML. Worked cases are in references/bad-vs-good.md. Where a
  loose JS tip conflicts with the TypeScript cases, follow the TypeScript case.
  Do not use for Go or for API-contract design.
---

# JavaScript and TypeScript

Rule `01` and rule `02` stay the floor. This skill is where JavaScript's coercions and TypeScript's erased types show up in production.

Read [references/bad-vs-good.md](references/bad-vs-good.md) when the change compares values, parses input, touches the DOM with user data, or annotates a type that came from outside the program. Prefer `for...of` over `forEach` when a TypeScript narrowing has to hold inside the loop.

## Done when

- Comparisons that decide control flow use `===` / `!==`, except a deliberate `== null` check for both `null` and `undefined`.
- Values from JSON, the DOM, or `catch` are narrowed before use. No `any`, `as`, or `!` without a runtime check next to it.
- A rejected promise is handled. User-controlled strings are not assigned to `innerHTML`.
