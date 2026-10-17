# Cursor Production Skills

> A curated, production-grade collection of Cursor **rules**, **skills**, **templates**, and **worked examples** for developers shipping software — writing code, reviewing diffs, designing APIs, refactoring safely, and debugging production incidents.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](#contributing)
[![Cursor](https://img.shields.io/badge/Made%20for-Cursor-000000.svg)](https://cursor.com)

This repo turns an AI coding assistant into a disciplined senior engineer. Drop it into any project and Cursor will follow consistent standards for quality, security, performance, architecture, and cloud cost — and it ships reusable "skills" for the highest-leverage engineering workflows.

---

## Why this exists

Most AI-assisted coding fails the same way: inconsistent standards, security blind spots, "works on my machine" performance, and architecture decisions made implicitly. This repo encodes the judgment of a staff-level engineer into version-controlled, reviewable artifacts so every interaction is grounded in the same expectations.

- **Rules** — always-on guardrails Cursor applies to every edit.
- **Skills** — invokable playbooks for specific high-stakes workflows.
- **Templates** — fill-in-the-blank docs for PRs, architecture, and incidents.
- **Examples** — concrete before/after references the model can learn from.

---

## Repository layout

```text
cursor-production-skills/
├── AGENTS.md                          # Read-this-first index for the agent
├── README.md
├── LICENSE
├── skills/
│   ├── production/                    # Door: tells the agent to read AGENTS.md
│   ├── debug-production-incident/
│   │   ├── SKILL.md
│   │   └── README.md
│   ├── api-design-assistant/
│   ├── refactor-large-codebase/
│   ├── code-review-expert/
│   ├── solid/
│   │   ├── SKILL.md
│   │   └── references/
│   ├── go/
│   │   ├── SKILL.md
│   │   └── references/bad-vs-good.md
│   ├── javascript/
│   │   ├── SKILL.md
│   │   └── references/bad-vs-good.md
│   └── data-access/
│       ├── SKILL.md
│       └── references/bad-vs-good.md
├── .cursor/
│   ├── rules/                         # Always-on engineering standards (.mdc)
│   │   ├── 00-global-standards.mdc
│   │   ├── 01-code-quality.mdc
│   │   ├── 02-security.mdc
│   │   ├── 03-performance.mdc
│   │   ├── 04-architecture.mdc
│   │   └── 05-cloud-aws.mdc
│   └── templates/                     # Reusable document scaffolds
│       ├── pr-review-template.md
│       ├── architecture-doc-template.md
│       └── incident-report-template.md
└── examples/                          # Worked, opinionated examples
    ├── bad-vs-good-api-design.md
    └── scaling-example.md
```

> **Choose what you install.** `install.sh` asks in the terminal. The default answer is no, so a component is copied only when you say yes. Selected rules then ask how they apply: always, intelligently, by glob, or only when @-mentioned.

---

## Quick start

From a clone, in the app repo's parent or after `cd` to the app:

```bash
bash /path/to/cursor-production-skills/install.sh
```

From any machine:

```bash
curl -fsSL https://sshdkeyu.github.io/skill-prod-cursor/i | bash
```

The questions still appear. The script reads them from the terminal, not from the pipe. Copying the whole tree by hand is the same set of files, without the questions:

```bash
cp AGENTS.md /path/to/app/AGENTS.md
cp -R skills /path/to/app/skills
cp -R examples /path/to/app/examples
cp -R .cursor/rules /path/to/app/.cursor/rules
cp -R .cursor/templates /path/to/app/.cursor/templates
```

---

## What's inside

### Rules (always-on)

| File | Enforces |
| --- | --- |
| `00-global-standards.mdc` | Communication style, definition of done, how the agent should behave |
| `01-code-quality.mdc` | Readability, naming, testing, error handling, dependency hygiene |
| `02-security.mdc` | Input validation, authN/Z, secrets, OWASP Top 10, supply chain |
| `03-performance.mdc` | Big-O awareness, N+1 queries, caching, memory, profiling-first |
| `04-architecture.mdc` | Boundaries, coupling, API contracts, idempotency, observability |
| `05-cloud-aws.mdc` | Least privilege IAM, networking, resilience, tagging, cost-aware infra |

### Skills (one package, read via `AGENTS.md`)

| Skill | Use it when… |
| --- | --- |
| `production` | The package door. Reads `AGENTS.md` and every file it lists before editing |
| `debug-production-incident` | A live system is degraded and you need a structured triage → mitigation → RCA flow |
| `api-design-assistant` | You're designing or reviewing a REST/RPC API contract |
| `refactor-large-codebase` | You need to safely change code at scale without breaking behavior |
| `code-review-expert` | You want a rigorous, severity-ranked review of a diff or PR |
| `solid` | You're implementing a feature, fixing a bug, or reshaping application code |
| `go` | You're writing or reviewing Go (errors, goroutines, parsers, byte payloads) |
| `javascript` | You're writing or reviewing JavaScript or TypeScript |
| `data-access` | A list loads a relation per row, or an endpoint is fast at 5 rows and slow at 50 |

### Templates

`pr-review-template.md`, `architecture-doc-template.md`, and `incident-report-template.md` give you consistent, complete documents every time.

### Examples

`bad-vs-good-api-design.md` and `scaling-example.md` are concrete references the model (and your team) can anchor on.

---

## Design principles

- **Evidence over assertion.** Decisions cite measurements, not vibes.
- **Severity-ranked output.** Findings are ordered by impact so humans act on what matters.
- **Reversibility & safety.** Prefer small, reversible steps; call out blast radius.
- **Production realism.** Everything assumes real traffic, real money, and real on-call.

---

## Compatibility

Built for [Cursor](https://cursor.com). The Markdown rules/skills are model-agnostic and are useful as context for other AI coding tools (Claude Code, Copilot, etc.) with minor path adjustments.

---

## Contributing

Contributions are welcome. Please:

1. Keep each rule/skill focused and self-contained.
2. Favor checklists and concrete heuristics over prose.
3. Include a worked example when adding a skill.
4. Open a PR using `.cursor/templates/pr-review-template.md`.

---

## License

[MIT](./LICENSE) © z, ...
