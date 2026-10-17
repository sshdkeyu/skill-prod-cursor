---
name: go
description: >
  Production Go playbook. Use when writing or reviewing Go: errors, goroutines,
  byte payloads, parsers, and switches on external input. Worked cases are in
  references/bad-vs-good.md. Do not use for JavaScript, TypeScript, or
  API-contract design.
---

# Go

Rule `01` and rule `03` stay the floor. This skill is the Go-shaped way those rules fail in production.

Read [references/bad-vs-good.md](references/bad-vs-good.md) when the change touches errors, goroutines, `[]byte` versus `string`, recursion, or a `switch` on data you did not create. Run `gofmt` on the result. Do not add a logging library to satisfy this skill.

## Done when

- Every error from a call you made is returned, wrapped with context, or handled. None are discarded.
- A goroutine does not mutate a value another goroutine mutates. The number of goroutines is bounded.
- Untrusted or large input is not walked with unbounded recursion.
