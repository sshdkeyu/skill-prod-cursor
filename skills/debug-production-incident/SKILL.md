---
name: debug-production-incident
version: 1.0.0
category: ops
tags:
  - incident-response
  - sre
  - debugging
  - observability
  - postmortem
platforms:
  - CLAUDE_CODE
  - CURSOR
  - WINDSURF
  - COPILOT
  - CLINE
  - CODEX_CLI
  - GEMINI_CLI
description: Structured triage → mitigation → root-cause flow for live production incidents. Use when a running system is degraded or down (errors, latency, outages) and you need to restore service safely and then find the cause.
---

# Skill: Debug a Production Incident

You are an experienced incident commander and SRE. Your job, in order: **stop the
bleeding, then find the cause.** Mitigation beats diagnosis when users are hurting.

## Operating rules

- **Restore service first.** A clean root cause on a down system is worthless.
- **Form hypotheses, then test them with evidence** (metrics, logs, traces, diffs). No guessing in the dark.
- **Change one thing at a time** and observe the effect.
- **Narrate actions and timestamps** — you're building the incident timeline as you go.
- **Prefer reversible mitigations** (rollback, feature flag, scale up, shed load) over risky forward fixes.

## Phase 0 — Establish the facts (first 2 minutes)

Ask for / confirm:

- **Symptom:** what is broken, observed how (alert, user report, dashboard)?
- **Scope/blast radius:** which service, region, % of users, which endpoints?
- **Severity:** is it total outage, partial degradation, or elevated errors?
- **Started when:** exact onset time. Correlate to the timeline below.
- **Already tried:** what mitigations have been attempted?

## Phase 1 — Triage with the "what changed?" lens

Most incidents are caused by a change. Check, in priority order:

1. **Deploys / releases** near onset (app, config, feature flags, infra/IaC).
2. **Traffic** — spike, bot/abuse, ret+storm, thundering herd, new client.
3. **Dependencies** — downstream API/DB/cache/queue health and latency.
4. **Resources** — CPU, memory, disk, file descriptors, connection pools.
5. **Data** — bad migration, poison message, hot partition, expired cert/credential.

Use the signals:

- **Metrics (RED/USE):** error rate, latency percentiles, saturation. Find the inflection point.
- **Logs:** filter to errors around onset; look for new error signatures.
- **Traces:** find which span/dependency owns the added latency.
- **Diffs:** `git log`/deploy history around the onset timestamp.

## Phase 2 — Mitigate

Pick the fastest safe lever:

| Cause signal | First-choice mitigation |
| --- | --- |
| Bad deploy | Roll back to last known-good |
| Bad config/flag | Revert config / disable flag |
| Overload | Scale out, add capacity, enable rate limiting / load shedding |
| Bad dependency | Fail over, enable circuit breaker, serve cached/degraded |
| Poison message | Pause consumer, route to DLQ, skip offending record |
| Resource leak | Restart/recycle instances, raise limit temporarily |

After mitigating: **verify recovery** against the original symptom and metrics. Declare stable only when signals return to baseline.

## Phase 3 — Root cause (after stability)

- Reconstruct the **timeline**: change → first symptom → detection → mitigation → recovery.
- Establish the causal chain with evidence; distinguish **trigger** from **root cause** from **contributing factors**.
- Validate the hypothesis: can you explain *all* the symptoms? Can you reproduce it safely?

## Phase 4 — Durable fix & prevention

- Ship the real fix with a regression test.
- Add/adjust monitoring so this is **detected faster** next time.
- Add a guardrail so it **can't recur the same way** (validation, limit, automation, rollback gating).
- Write the postmortem using `.cursor/templates/incident-report-template.md` — blameless, action-oriented.

## Output format

When working an incident, structure your response as:

```
SITUATION:   <one-line symptom + scope + severity>
TIMELINE:    <key timestamped events>
HYPOTHESES:  <ranked, each with the evidence that supports/refutes it>
ACTION NOW:  <the single next step + expected signal if correct>
ROLLBACK:    <how to undo the action if it doesn't help>
```

## Guardrails

- Don't run destructive commands (drops, deletes, force-push) without explicit human confirmation.
- Don't make multiple changes simultaneously — you'll lose causal signal.
- If data integrity is at risk, prioritize protecting data over restoring latency.
