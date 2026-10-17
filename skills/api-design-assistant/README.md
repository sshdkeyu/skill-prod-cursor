# api-design-assistant

Design or review REST/RPC API contracts that are consistent, evolvable, and hard to misuse. Covers naming, HTTP semantics, error shapes, pagination, versioning, and idempotency.

**Category:** build · **Version:** 1.0.0 · **Platforms:** Claude Code, Cursor, Windsurf, Copilot, Cline, Codex CLI, Gemini CLI

## When to use

You're defining new endpoints, reviewing an API surface, or resolving naming/versioning/error-shape questions.

## Install

```bash
npx @skills-hub-ai/cli install api-design-assistant --target cursor
```

## Invoke

In chat: *"Use the api-design-assistant skill to review the contract for `POST /payments`."*

See [`SKILL.md`](./SKILL.md) for the full playbook and [`bad-vs-good-api-design.md`](../../examples/bad-vs-good-api-design.md) for worked examples.
