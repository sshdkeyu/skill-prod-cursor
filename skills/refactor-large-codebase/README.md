# refactor-large-codebase

Safely change code at scale without altering behavior. Small, verifiable, reversible steps with a test safety net and the expand → migrate → contract pattern.

**Category:** build · **Version:** 1.0.0 · **Platforms:** Claude Code, Cursor, Windsurf, Copilot, Cline, Codex CLI, Gemini CLI

## When to use

Large renames, extracting modules, breaking up god classes, migrating frameworks/APIs, or paying down structural debt across many files.

## Install

```bash
npx @skills-hub-ai/cli install refactor-large-codebase --target cursor
```

## Invoke

In chat: *"Use the refactor-large-codebase skill to split `UserService` into auth and profile modules."*

See [`SKILL.md`](./SKILL.md) for the full playbook.
