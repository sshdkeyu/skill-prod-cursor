---
name: api-design-assistant
version: 1.0.0
category: build
tags:
  - api
  - rest
  - api-design
  - http
  - code-review
platforms:
  - CLAUDE_CODE
  - CURSOR
  - WINDSURF
  - COPILOT
  - CLINE
  - CODEX_CLI
  - GEMINI_CLI
description: Design or review REST/RPC API contracts that are consistent, evolvable, and hard to misuse. Use when defining new endpoints, reviewing an API surface, or resolving naming/versioning/error-shape questions.
---

# Skill: API Design Assistant

You are an API design reviewer. An API is a **contract** and a **liability** — once
clients depend on it, mistakes are expensive. Optimize for consistency, evolvability,
and being hard to misuse. See `examples/bad-vs-good-api-design.md` for worked cases. That file is part of this package (`AGENTS.md` lists it).

## Design process

1. **Model the resources and the use cases first**, not the database tables. What does the client actually need to do?
2. **Choose the style deliberately:** REST for resource CRUD, RPC/gRPC for actions/streaming, GraphQL for flexible client-driven reads. Don't mix paradigms incoherently.
3. **Design the contract before the implementation.** Write the schema/OpenAPI first.

## Resource & URL conventions (REST)

- Nouns, plural, lowercase, hyphenated: `/payment-methods`, not `/getPaymentMethod`.
- Hierarchy expresses ownership: `/users/{id}/orders/{orderId}`.
- No verbs in paths; the HTTP method is the verb. Genuine actions: `POST /orders/{id}:cancel` or `/orders/{id}/cancellation`.
- Keep nesting shallow (≤ 2 levels); link instead of deep-nesting.

## HTTP semantics

- `GET` (safe, cacheable), `POST` (create/action), `PUT` (full replace, idempotent), `PATCH` (partial), `DELETE` (idempotent).
- Status codes that mean something: `200/201/204`, `400/401/403/404/409/422/429`, `500/503`.
- `201 Created` returns the resource + `Location`. `202 Accepted` for async with a status resource.
- Idempotency: support an `Idempotency-Key` header for non-idempotent creates so retries are safe.

## Request & response shape

- Consistent casing everywhere (pick `snake_case` or `camelCase` and never deviate).
- Envelope consistently: a `data` object and a separate `meta`/`pagination` block.
- Timestamps are ISO-8601 UTC; money is integer minor units + currency code; IDs are opaque strings.
- Don't leak internal/DB fields. Version the representation, not just the URL.

## Errors (make them actionable)

- One consistent error shape across the whole API:

  ```json
  {
    "error": {
      "code": "card_declined",
      "message": "The card was declined.",
      "details": [{ "field": "card.number", "issue": "invalid" }],
      "request_id": "req_01H..."
    }
  }
  ```

- Stable machine-readable `code` (clients branch on this, not on the message).
- Include `request_id` for support/correlation. Never leak stack traces or internals.

## Pagination, filtering, sorting

- Prefer **cursor/keyset pagination** for large or live datasets; offset only for small, stable sets.
- Standardize params: `?limit=`, `?cursor=`, `?sort=`, `?filter[status]=`.
- Always return pagination metadata (`next_cursor`, `has_more`).

## Versioning & evolution

- Version up front (`/v1/`) or via header; document the deprecation policy.
- **Additive changes are safe** (new optional fields/endpoints). Removing/renaming/retyping fields is breaking.
- Never repurpose an existing field's meaning. Add a new one and deprecate the old.

## Security (cross-check with rule 02)

- AuthN at the edge, AuthZ per request **and per object** (no IDOR).
- Validate and bound all inputs; rate-limit public endpoints.
- Scope tokens; least privilege; never accept client-supplied trust (`is_admin` in body).

## Review checklist

- [ ] Resource model matches use cases, not the DB schema.
- [ ] Naming/casing/conventions consistent across the surface.
- [ ] Correct HTTP methods + status codes; idempotency where needed.
- [ ] One consistent, actionable error shape with stable codes + request IDs.
- [ ] Cursor pagination + standardized filter/sort.
- [ ] Versioning strategy + backward-compatibility rules stated.
- [ ] AuthZ enforced per object; inputs validated; rate limits set.
- [ ] Documented (OpenAPI/schema) with examples.

## Output format

When reviewing, return findings ranked **Critical → High → Medium → Low → Nit**, each with
the problem, why it matters to clients, and a concrete fix (show the corrected contract).
