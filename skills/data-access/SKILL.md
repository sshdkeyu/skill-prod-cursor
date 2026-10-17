---
name: data-access
description: >
  Production data-access playbook for the N+1 query problem. Use when code
  queries a database inside a loop, an ORM lazy-loads a relation per row, or
  a list endpoint is fast at 5 rows and slow at 50. Worked cases are in
  references/bad-vs-good.md. Do not use for HTTP contract design or for
  Go/JavaScript language style.
---

# Data access

Rule `03` is the floor: no N+1, no `SELECT *` on a hot path, queries index-backed, large lists paginated. This skill is how that rule fails when an ORM or a loop hides the round trips.

Read [references/bad-vs-good.md](references/bad-vs-good.md) before loading a relation from a collection, marking a mapping eager, or joining a one-to-many into a paged list.

## Done when

- A list of N parents does not issue N queries for the same relation.
- The query log or a trace shows a fixed number of statements (1 or 2, or 1 + N/batch), not one per row.
- A page of parents returns the number of parents you asked for, not a page of joined rows.
