---
description: AWS cloud standards — least-privilege IAM, networking, resilience, tagging, cost-aware infra.
globs:
  - "**/*.tf"
  - "**/*.tfvars"
  - "**/*.yaml"
  - "**/*.yml"
  - "**/serverless.*"
  - "**/template.json"
  - "**/cdk/**"
---

# 05 · Cloud (AWS)

Infrastructure is code: it must be reviewable, least-privilege, resilient, and cost-aware.
These standards apply to IaC (Terraform/CloudFormation/CDK/SAM) and runtime config.

## Identity & access (IAM)

- **Least privilege, always.** Scope actions and resources; no `"Action": "*"` or `"Resource": "*"` outside narrow, justified cases.
- Prefer **roles** over long-lived access keys; use IAM Roles for service-to-service (IRSA on EKS, instance/task roles).
- No credentials in code, AMIs, or env files — use Secrets Manager / SSM Parameter Store.
- Use conditions (source VPC, MFA, tags) to constrain powerful permissions.
- Separate accounts/environments (prod vs non-prod) with guardrails (SCPs).

## Networking

- Private subnets for compute and data; public only for load balancers/NAT.
- Security groups are least-open: reference SGs, not `0.0.0.0/0`, except for public ingress on 443.
- Terminate TLS at the edge; encrypt internal traffic where feasible.
- Use VPC endpoints for AWS service traffic to avoid the public internet.

## Data & encryption

- Encrypt at rest (KMS) for S3, EBS, RDS, DynamoDB, snapshots, and queues.
- Enforce TLS in transit; disable plaintext endpoints.
- S3: block public access by default; enable versioning + lifecycle; least-privilege bucket policies.
- Back up stateful stores; test restores. Define RPO/RTO explicitly.

## Resilience & scalability

- Multi-AZ for anything stateful (RDS, ElastiCache) and load-balanced compute.
- Use Auto Scaling driven by real metrics; set sane min/max.
- Set timeouts, retries (SDK built-ins), and DLQs for async (SQS/SNS/EventBridge/Lambda).
- Design for instance/AZ failure; no single points of failure in prod.

## Observability & ops

- Centralize logs (CloudWatch Logs) with retention policies (don't keep forever by default).
- Emit metrics + alarms on SLOs; enable CloudTrail and Config for audit.
- Tag everything: `Environment`, `Owner`, `CostCenter`, `Service`, `ManagedBy`.

## Cost awareness

- Right-size before scaling out; prefer managed/serverless when it lowers TCO.
- Use lifecycle policies (S3 tiering, log retention) and clean up orphaned resources (unattached EBS, idle NAT, old snapshots).
- Consider Savings Plans / Reserved capacity for steady-state workloads.
- Flag expensive choices (NAT gateways, cross-AZ traffic, large always-on instances) in review.

## IaC hygiene

- Everything in version control; no click-ops in prod (drift is a bug).
- Plan/diff reviewed before apply; state stored remotely and locked.
- Modules are parameterized and reusable; no hardcoded account IDs/regions.

## Cloud review checklist

- [ ] IAM scoped to least privilege (no wildcard action+resource).
- [ ] No hardcoded secrets; roles used for auth.
- [ ] Encryption at rest + in transit enabled.
- [ ] Multi-AZ / failure handling for stateful and prod compute.
- [ ] Resources tagged (owner, env, cost center).
- [ ] Obvious cost traps flagged.
- [ ] Change delivered via reviewed IaC, not console.
