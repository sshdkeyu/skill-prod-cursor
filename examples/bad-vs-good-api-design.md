# Example: Bad vs. Good API Design

A worked reference for the `api-design-assistant` skill. Each case shows a common
mistake, why it bites clients in production, and the corrected version.

---

## 1. Verbs in URLs and HTTP method misuse

**Bad**

```http
POST /api/getUser?id=42
POST /api/createOrder
POST /api/deleteOrder?id=99
GET  /api/updateUserEmail?id=42&email=a@b.com   # mutating with GET!
```

**Why it's bad:** URLs should name resources; HTTP methods are the verbs. Mutating on
`GET` is dangerous — `GET` is supposed to be safe and cacheable, so proxies, prefetchers,
and crawlers can trigger side effects.

**Good**

```http
GET    /v1/users/42
POST   /v1/orders
DELETE /v1/orders/99
PATCH  /v1/users/42        # body: { "email": "a@b.com" }
```

---

## 2. Inconsistent, leaky response shapes

**Bad**

```jsonc
// GET /users/42
{ "ID": 42, "UserName": "ada", "created": 1700000000, "pwd_hash": "..." }

// GET /orders/99 — different casing, different envelope, leaks internals
{ "order_id": "99", "Status": 1, "_dbShard": "shard-3" }
```

**Why it's bad:** Mixed casing forces every client to special-case fields. `status: 1`
is a magic number. It leaks internal fields (`pwd_hash`, `_dbShard`) — a security and
coupling problem.

**Good**

```jsonc
// GET /v1/users/42
{
  "data": {
    "id": "42",
    "username": "ada",
    "created_at": "2023-11-14T22:13:20Z"
  }
}

// GET /v1/orders/99
{
  "data": {
    "id": "99",
    "status": "pending",          // stable enum string, not a magic int
    "created_at": "2023-11-14T22:13:20Z"
  }
}
```

Consistent casing, ISO-8601 UTC timestamps, opaque string IDs, enum strings, a uniform
`data` envelope, and **no internal fields**.

---

## 3. Useless error responses

**Bad**

```http
HTTP/1.1 200 OK            # 200 for an error!
{ "success": false, "message": "error" }
```

**Why it's bad:** `200` for a failure breaks every client's error handling. The message
is not actionable and not machine-readable. No correlation ID for support.

**Good**

```http
HTTP/1.1 422 Unprocessable Entity
{
  "error": {
    "code": "validation_failed",
    "message": "One or more fields are invalid.",
    "details": [
      { "field": "email", "issue": "must be a valid email address" }
    ],
    "request_id": "req_01HZX9F8K3"
  }
}
```

Correct status code, stable `code` clients can branch on, field-level `details`, and a
`request_id` for correlation.

---

## 4. Offset pagination on large, live data

**Bad**

```http
GET /v1/events?page=50000&page_size=20
```

**Why it's bad:** `OFFSET 1000000` makes the database scan and discard a million rows —
slow and getting slower. Results also shift/duplicate when rows are inserted between page
loads.

**Good**

```http
GET /v1/events?limit=20&cursor=eyJpZCI6IjEyMzQ1In0

# response
{
  "data": [ /* ... */ ],
  "pagination": { "next_cursor": "eyJpZCI6IjEyMzY1In0", "has_more": true }
}
```

Keyset/cursor pagination stays fast at any depth and is stable under concurrent writes.

---

## 5. Breaking changes disguised as edits

**Bad:** Renaming `name` → `full_name`, or changing `amount` from dollars (float) to a
string, in place. Every existing client breaks the moment you deploy.

**Good:** Additive evolution.

- Add `full_name` alongside `name`; mark `name` deprecated in docs with a removal date.
- For money, introduce `amount_minor` (integer cents) + `currency` as new fields; keep
the old field until clients migrate, then remove behind a new version.
- Never silently change a field's type or meaning.

---

## 6. Non-idempotent creates without protection

**Bad**

```http
POST /v1/payments      # client retries on timeout → customer charged twice
```

**Good**

```http
POST /v1/payments
Idempotency-Key: 7c2a...     # server dedupes; retry returns the original result
```

A retried request with the same key returns the original outcome instead of creating a
duplicate — essential for payments, orders, and anything triggered by at-least-once delivery.

---

## Takeaways

| Principle | Rule of thumb |
| --- | --- |
| Resources, not actions | Nouns in URLs; HTTP method is the verb |
| Consistency | One casing, one envelope, one error shape — everywhere |
| Actionable errors | Right status + stable `code` + `request_id` |
| Scale-safe reads | Cursor pagination over offset |
| Evolvability | Additive changes; deprecate before removing |
| Safe retries | Idempotency keys for non-idempotent creates |
| Least exposure | Never leak internal/DB fields |
