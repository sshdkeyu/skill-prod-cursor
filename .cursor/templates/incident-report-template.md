# Incident Report (Postmortem) — <Short Title>

> Blameless. Focus on systems and process, not people. The goal is prevention, not punishment.

| Field | Value |
| --- | --- |
| **Incident ID** | INC-YYYY-NNNN |
| **Severity** | SEV1 / SEV2 / SEV3 |
| **Status** | Investigating / Mitigated / Resolved / Closed |
| **Date** | YYYY-MM-DD |
| **Duration** | <detection → resolution>, total <X>h <Y>m |
| **Author** | |
| **Incident commander** | |
| **Services affected** | |

---

## 1. Summary

<!-- 3–4 sentences a VP could read: what broke, who was impacted, how long, and the root cause in plain language. -->

## 2. Impact

- **User impact:** <what users experienced>
- **Scope:** <% of users / regions / requests affected>
- **Duration of impact:** <start → end>
- **Business impact:** <revenue, SLA/SLO breach, data integrity, reputation>
- **Data loss / corruption:** Yes / No — <details>

## 3. Timeline (all times UTC)

| Time | Event |
| --- | --- |
| HH:MM | <change / trigger> |
| HH:MM | First symptom / alert fired |
| HH:MM | Incident declared, IC assigned |
| HH:MM | Investigation: <key finding> |
| HH:MM | Mitigation applied: <action> |
| HH:MM | Service recovered / verified |
| HH:MM | Incident resolved |

## 4. Root cause analysis

**Trigger:** <the immediate change/event that set it off>

**Root cause:** <the underlying condition that allowed the trigger to cause an incident>

**Contributing factors:** <what made it worse, slower to detect, or slower to fix>

<!-- Use the "5 Whys" or a causal chain. Distinguish trigger vs root cause vs contributing factors. -->

## 5. Detection

- **How was it detected?** <alert / customer report / manual> 
- **Time to detect (TTD):** <onset → detection>
- **Was the alerting adequate?** <gaps>

## 6. Resolution & recovery

- **How was service restored?** <mitigation that worked>
- **Time to mitigate (TTM) / resolve (TTR):**
- **Why did it take as long as it did?**

## 7. What went well / what went poorly

**Went well**

- 

**Went poorly**

- 

## 8. Action items

| # | Action | Type (prevent / detect / mitigate) | Owner | Priority | Due | Status |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | | | | P1 | | Open |
| 2 | | | | | | |

> Each action should make recurrence less likely, detection faster, or impact smaller. Track to completion.

## 9. Lessons learned

<!-- Generalizable takeaways for the broader org. -->
