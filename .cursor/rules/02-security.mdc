---
description: Security standards — input validation, authN/Z, secrets, OWASP, supply chain.
alwaysApply: true
---

# 02 · Security

Assume every input is hostile and every dependency is a liability until proven otherwise.

## Trust boundaries & input validation

- Validate, sanitize, and **type** all input crossing a trust boundary (HTTP, queue, file, env, CLI).
- Allow-list, don't deny-list. Define what's valid; reject everything else.
- Enforce size/length/range limits to prevent resource exhaustion.
- Treat deserialization of untrusted data as dangerous; use safe parsers.

## Injection (the perennial #1)

- **SQL/NoSQL:** parameterized queries / prepared statements only. Never string-concatenate queries.
- **Command:** avoid shelling out; if unavoidable, use arg arrays, never a shell string.
- **Template/HTML:** context-aware output encoding; rely on the framework's auto-escaping.
- **Path:** canonicalize and confine to an allowed base directory (no `../` traversal).

## Authentication & authorization

- Authenticate at the edge; **authorize on every request** (no "the UI hides it" security).
- Enforce least privilege; deny by default.
- Check object-level ownership (prevent IDOR / broken object-level authorization).
- Use vetted libraries for sessions/JWT; never roll your own crypto or auth.
- Hash passwords with a slow, salted KDF (argon2/bcrypt/scrypt). Never MD5/SHA-1.

## Secrets & sensitive data

- No secrets in source, logs, error messages, or client-side code.
- Load secrets from a manager/vault or injected env; rotate regularly.
- Encrypt sensitive data in transit (TLS) and at rest.
- Log identifiers, not contents: never log passwords, tokens, full PANs, or PII.
- Scrub/redact PII in telemetry and exception reports.

## Web & API hardening

- Set security headers (CSP, HSTS, X-Content-Type-Options, etc.).
- Protect state-changing requests (CSRF tokens or same-site cookies + origin checks).
- Apply rate limiting and request size limits on public endpoints.
- Configure CORS narrowly; never reflect arbitrary origins with credentials.

## Cryptography

- Use well-reviewed libraries and modern algorithms (AES-GCM, ChaCha20-Poly1305).
- Use a CSPRNG for anything security-relevant; never `Math.random()` for tokens.
- Never hardcode keys/IVs; generate IVs/nonces per message.

## Supply chain

- Pin and lock dependencies; verify integrity (lockfile hashes).
- Run dependency vulnerability scanning in CI; triage criticals before merge.
- Minimize and review new dependencies and their transitive tree.

## Review checklist

- [ ] All external input validated and bounded.
- [ ] No injection vectors (SQL, command, path, template).
- [ ] Authorization enforced per request and per object.
- [ ] No secrets/PII in code, logs, or responses.
- [ ] Crypto uses vetted libs + CSPRNG.
- [ ] Dependencies pinned and scanned.
