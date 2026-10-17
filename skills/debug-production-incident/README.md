# debug-production-incident

Structured triage → mitigation → root-cause flow for live production incidents. Restores service first, then finds the cause — with evidence, a running timeline, and reversible mitigations.

**Category:** ops · **Version:** 1.0.0 · **Platforms:** Claude Code, Cursor, Windsurf, Copilot, Cline, Codex CLI, Gemini CLI

## When to use

A running system is degraded or down (errors, latency spikes, outage) and you need a calm, structured way to stabilize it and then write the postmortem.

## Install

```bash
npx @skills-hub-ai/cli install debug-production-incident --target cursor
```

## Invoke

In chat: *"Use the debug-production-incident skill. p99 on `/checkout` jumped to 4s after the 14:02 deploy."*

See [`SKILL.md`](./SKILL.md) for the full playbook. Postmortems use [`incident-report-template.md`](../../.cursor/templates/incident-report-template.md).
