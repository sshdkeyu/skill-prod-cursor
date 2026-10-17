# Architecture / Design Doc — <Title>

| Field | Value |
| --- | --- |
| **Status** | Draft / In Review / Approved / Superseded |
| **Author(s)** | |
| **Reviewers** | |
| **Created** | YYYY-MM-DD |
| **Last updated** | YYYY-MM-DD |
| **Related** | <links to tickets, RFCs, prior docs> |

---

## 1. Summary

<!-- 3–5 sentences. What are we building and why? A reader should understand the gist here. -->

## 2. Context & problem statement

<!-- What's the current situation? What problem are we solving? What happens if we do nothing? -->

## 3. Goals & non-goals

**Goals**

- 

**Non-goals** (explicitly out of scope)

- 

## 4. Requirements

**Functional**

- 

**Non-functional**

| Dimension | Target |
| --- | --- |
| Scale (DAU / RPS, peak) | |
| Latency (p50 / p99) | |
| Availability (SLO) | |
| Consistency | strong / eventual (per operation) |
| Durability / retention | |
| Security / compliance | |
| Budget | |

## 5. Estimates (back-of-the-envelope)

<!-- QPS (avg + peak), storage growth/yr, bandwidth, read:write ratio, cache working set. -->

## 6. Proposed design

### 6.1 High-level overview

<!-- Diagram + narrative. Components and how requests/data flow through them. -->

```text
<ASCII or link to diagram>
```

### 6.2 API / contract

<!-- Core operations, request/response shapes, error model. -->

### 6.3 Data model & access patterns

<!-- Entities, relationships, partition/shard keys, indexes, and the queries they serve. -->

### 6.4 Key components

<!-- For each major component: responsibility, tech choice, and why. -->

## 7. Alternatives considered

| Option | Pros | Cons | Why not chosen |
| --- | --- | --- | --- |
| A (chosen) | | | — |
| B | | | |
| C | | | |

## 8. Trade-offs

<!-- What did we optimize for? What did we deliberately sacrifice? -->

## 9. Reliability & operations

- **Failure modes:** what happens when each dependency/component fails?
- **Redundancy / failover:** multi-AZ/region, RPO/RTO.
- **Observability:** key metrics, logs, traces, alerts (on SLOs).
- **Rollout / rollback:** strategy, feature flags, migration ordering.
- **Capacity & scaling path:** what breaks first at 10×, and the plan.

## 10. Security & privacy

<!-- Trust boundaries, authN/Z, data classification, encryption, secrets, threat notes. -->

## 11. Cost

<!-- Estimated run cost + main cost drivers + how cost scales with usage. -->

## 12. Migration / rollout plan

<!-- Phased steps (expand → migrate → contract), data backfill, cutover, rollback. -->

## 13. Open questions & risks

- 

## 14. Appendix

<!-- ADR records, benchmarks, references. -->
