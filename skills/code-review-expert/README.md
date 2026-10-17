# code-review-expert

Rigorous, severity-ranked review of a diff, PR, or file — correctness, security, performance, design, readability, tests, and operability. Specific, prioritized, and actionable feedback.

**Category:** review · **Version:** 1.0.0 · **Platforms:** Claude Code, Cursor, Windsurf, Copilot, Cline, Codex CLI, Gemini CLI

## When to use

You want a thorough check of a change with findings ranked Critical → High → Medium → Low → Nit and a clear merge recommendation.

## Install

```bash
npx @skills-hub-ai/cli install code-review-expert --target cursor
```

## Invoke

In chat: *"Use the code-review-expert skill on my staged diff."*

See [`SKILL.md`](./SKILL.md) for the full checklist. Full written reviews use [`pr-review-template.md`](../../.cursor/templates/pr-review-template.md).
