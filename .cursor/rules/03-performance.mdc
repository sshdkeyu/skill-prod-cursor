---
description: Performance standards — algorithmic cost, queries, caching, memory, profiling-first.
alwaysApply: true
---

# 03 · Performance

Make it correct, make it clear, then make it fast — and prove it with numbers.

## Mindset

- **Measure before optimizing.** Profile to find the real bottleneck; don't guess.
- Optimize the hot path; ignore the cold path until data says otherwise.
- State the expected scale (RPS, data size, concurrency) before choosing a design.
- Premature optimization that hurts readability is a bug, not a feature.

## Algorithmic cost

- Know the Big-O of the code you write; avoid accidental `O(n²)` (nested loops over collections).
- Use the right data structure: hash map for lookups, set for membership, heap for top-k.
- Avoid repeated work: hoist invariant computation out of loops; memoize pure, expensive calls.

## Data access (the usual culprit)

- **Eliminate N+1 queries.** Batch, join, or use `IN`/dataloader patterns.
- Select only the columns you need; never `SELECT *` in hot paths.
- Ensure queries are index-backed; check the query plan for full scans.
- Paginate large result sets (keyset/seek pagination over large offsets).
- Push filtering/aggregation to the database, not the application layer.

## Caching

- Cache the expensive and the frequently-read; define TTL and invalidation up front.
- Beware stampedes: use request coalescing / locks on cache miss.
- Make cache keys explicit and collision-free; version them on schema change.
- Never cache per-user data under a shared key.

## Concurrency & I/O

- Use async/non-blocking I/O for network-bound work; bound concurrency with pools/semaphores.
- Set timeouts on every external call; add retries with backoff + jitter (and idempotency).
- Don't block the event loop / request thread on CPU-heavy work — offload it.

## Memory & resources

- Stream large payloads; don't load entire files/result sets into memory.
- Release resources promptly; watch for leaks (unbounded caches, listeners, connections).
- Reuse expensive objects (connection pools, compiled regexes/clients).

## Front-end (when applicable)

- Minimize bundle size; code-split and lazy-load.
- Avoid layout thrash and unnecessary re-renders; memoize hot components.
- Defer/parallelize network requests; show progressive content.

## Performance checklist

- [ ] Hot path identified (ideally by a profile/benchmark).
- [ ] No N+1 queries; queries are index-backed.
- [ ] External calls have timeouts + bounded retries.
- [ ] No unbounded memory growth.
- [ ] Caching has a defined invalidation strategy.
- [ ] A benchmark or metric demonstrates the improvement.
