# Example: Scaling a Read-Heavy Service

A worked reference for performance and architecture decisions. It walks
a URL-shortener-style service from one box to global scale, making each decision follow
from the **numbers** and the **bottleneck** — not from buzzwords.

---

## The problem

A URL shortener: `POST /urls` creates a short code; `GET /{code}` redirects to the long
URL. Sounds trivial — the interesting part is scale and the read/write asymmetry.

## Step 1 — Get the numbers (back-of-the-envelope)

Assume:

- 100M new URLs/month → writes ≈ `100M / (30 × 86400)` ≈ **~40 writes/sec** (avg).
- Read:write ratio of **100:1** (redirects dominate) → reads ≈ **~4,000 reads/sec** (avg).
- Peak ≈ 5× average → **~20,000 reads/sec peak**.
- Storage: 100M/mo × ~500 bytes × 12 mo ≈ **~600 GB/year**. Small.
- Working set: the hot URLs that get most traffic are a small fraction → **cache-friendly**.

**Conclusion from the numbers:** this is a *read-heavy, cache-friendly, modest-storage*
problem. That single observation drives almost every later decision.

---

## Step 2 — Start simple (and know when it breaks)

```text
Client → App server → Postgres (id → url)
```

- One app instance, one database. Short code = base62 of an auto-increment ID.
- This genuinely works to a few thousand RPS. **Don't over-engineer before you must.**
- **First bottleneck:** at ~20k read RPS, the single DB becomes the constraint and a
  single app box is a SPOF.

---

## Step 3 — Relieve reads with caching (biggest win, lowest cost)

Reads are 100× writes and the data is immutable once created — ideal for caching.

```text
Client → LB → App (N) → Redis (cache) → Postgres
```

- Cache `code → long_url` in Redis. Redirects become a single in-memory lookup.
- With even an 90% hit rate, DB read load drops ~10×.
- **Invalidation is trivial** here: entries are immutable, so use a long TTL; no stale-data problem.
- Guard against **cache stampede** on a cold/popular key with request coalescing.

> This step alone often removes the bottleneck for years. Caching beats sharding when the
> workload is read-heavy and cacheable.

---

## Step 4 — Scale the stateless tier horizontally

- App servers hold no session state → put them behind a load balancer and autoscale on RPS/CPU.
- Multi-AZ so one zone failing doesn't take the service down.
- This removes the SPOF and handles read fan-out cheaply.

---

## Step 5 — Scale the database for durability and write growth

Reads are mostly absorbed by cache; now protect the source of truth.

- **Read replicas** for cache-miss reads and analytics; writes go to the primary.
- **Avoid the auto-increment hot spot** for code generation at scale: a single global
  counter serializes writes. Options:
  - Pre-allocated **ID ranges** per app instance (each grabs a block of IDs).
  - A **distributed ID generator** (Snowflake-style) for monotonic-ish, sharded IDs.
- If write volume or storage eventually outgrows one primary, **shard by short code**
  (hash partitioning) so load spreads evenly and avoids hot partitions.

---

## Step 6 — Go global (latency)

- Redirects are latency-sensitive (users feel every 100ms). Put **read replicas/caches
  close to users** (multi-region) or serve hot redirects from a **CDN/edge**.
- Writes can stay centralized (they're rare) or use async replication to regions.
- Be explicit about consistency: a brand-new short code might take a moment to appear in
  a far region — **eventual consistency is acceptable** for this use case. Saying that out
  loud is the senior move.

---

## Final architecture

```text
                    ┌─────────── CDN / edge cache (hot redirects) ───────────┐
                    │                                                         │
Client ──► Global LB ──► App tier (stateless, multi-AZ, autoscaled)
                                 │
                                 ├──► Redis (code → url, long TTL)
                                 │
                                 └──► Postgres primary ──► read replicas
                                          (sharded by code if needed)
```

---

## How each layer maps to the bottleneck it solves

| Scale stage | Bottleneck | Lever | Why it's the right call |
| --- | --- | --- | --- |
| 1 box | none yet | keep it simple | Don't pay complexity tax early |
| ~thousands RPS | DB reads | Redis cache | Read-heavy + immutable = cache-perfect |
| SPOF / more RPS | single app box | LB + autoscale stateless tier | Cheap horizontal scaling |
| write/durability | single primary | replicas + sharded IDs | Removes write hot spot, spreads load |
| global latency | distance to users | edge/CDN + regional replicas | Redirects are latency-sensitive |

## Senior-level talking points

- **Numbers first:** the 100:1 read:write ratio justified caching before anything fancy.
- **Name the bottleneck at each step** and solve exactly that one.
- **Consistency is a choice:** eventual consistency is fine for redirects; say so explicitly.
- **What breaks at 10×?** Code-generation hot spot and single-primary writes — which is
  why sharded ID generation is pre-planned, not bolted on in a panic.
- **Don't over-engineer:** every layer was added only when the previous bottleneck was real.
