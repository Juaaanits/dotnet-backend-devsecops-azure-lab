# Final Project Status and Evidence Matrix

Status date: 2026-09-17

This page is the source of truth for what is implemented, what was verified, and what still requires an external environment. “Implemented” is not treated as “deployed.”

## Completion Matrix

| Capability | Implementation | Verification status |
| --- | --- | --- |
| .NET restore/build CI | Complete | Previously passed in GitHub Actions; updated workflow awaits branch run |
| xUnit regression suite | Complete | 11 tests passed locally with 0 failures |
| Postman API collection | Complete | JSON parsed; end-to-end run requires the API stack |
| Newman CLI/JUnit | Complete | Workflow and script added; execution requires Docker/API |
| SQL Server/Azurite/API Compose stack | Complete | Compose configuration validated; local Docker daemon unavailable during final pass |
| Grafana SQL observability | Complete | Previously validated with saved screenshots |
| CodeQL SAST | Complete | Previously merged and passing after code scanning was enabled |
| Gitleaks | Complete | Previously merged |
| Trivy container gate | Complete | Workflow added; first GitHub run pending |
| Dependabot | Complete | NuGet and GitHub Actions monitoring active |
| Terraform Azure baseline | Complete | `fmt`, `init -backend=false`, and `validate` passed |
| Azure deployment workflow | Complete | Manual OIDC workflow added; no cloud deployment claimed |
| Azure resources | Not provisioned | Requires subscription, credentials, budget approval, plan review, and apply |

## Security Fixes Completed

```text
Authentication now executes before authorization.
Type and Service mutations require Admin.
Anonymous first-Admin registration is closed.
Bootstrap Admin requires explicit configuration.
BlobService no longer performs storage network I/O in its constructor.
Local and CI secrets are supplied through environment configuration.
Azure design stores runtime secrets in Key Vault and uses managed identity.
Grafana uses a dedicated monitoring login rather than sysadmin.
ASP.NET Core and EF Core packages were updated to the patched 8.0.31 release line.
The API image pins patched .NET 8 images and upgrades the affected PCRE2 runtime package.
```

## Automated QA Scope

The xUnit suite checks authorization declarations and storage construction. The 16-request Postman collection checks health, registration/login, anonymous/User/Admin/Host authorization, role promotion, owned properties, dashboard access, lookup creation, and public property listing.

These tests provide a useful smoke gate but are not complete product coverage. Payments, refresh tokens, image-upload payloads, bookings, race conditions, destructive lookup flows, and detailed validation errors require additional suites.

## Verification Record

```text
Terraform formatting: passed
Terraform initialization without backend: passed
Terraform validation: passed
Docker Compose interpolation/configuration: passed
Postman collection JSON parsing: passed
.NET Release test run: passed, 11 tests, 0 failures, 0 skipped
NuGet vulnerability audit: no vulnerable packages reported by configured sources
Docker image and full Compose runtime: pending because Docker Desktop could not start
Newman against the Compose API: pending for the same local runtime dependency
Azure plan/apply/runtime smoke: intentionally pending external credentials and budget approval
```

## Definition of Done for This Portfolio Phase

The repository is complete as a local engineering and cloud-readiness portfolio phase when code and docs are committed, pull-request checks pass, and the first Newman/Trivy GitHub runs are retained. Actual Azure deployment is a separate, cost-bearing execution phase and must not be implied on a resume until performed and evidenced.

## Recommended Study Order

1. Read `SAKENNY_TECHNICAL_CASE_STUDY.md` for the narrative.
2. Reproduce `LOCAL_SETUP_AND_VALIDATION.md`.
3. Trace each test in `AUTOMATED_QA_AND_CONTAINER_RUNBOOK.md`.
4. Review each workflow under `.github/workflows` and explain its permissions.
5. Study the least-privilege SQL setup in `OBSERVABILITY_SQL_SERVER_GRAFANA.md`.
6. Run Terraform validation and read `TERRAFORM_AZURE_DEPLOYMENT.md` before considering an apply.
7. Use `KNOWN_ISSUES_AND_FIX_PLAN.md` for the next technical-debt iteration.

## Resume-Safe Summary

- Built an automated QA and DevSecOps baseline around an inherited ASP.NET Core 8 and SQL Server API using xUnit, Postman/Newman, GitHub Actions, CodeQL, Gitleaks, Dependabot, Trivy, Docker Compose, and role-based 401/403/200 checks.
- Provisioned least-privilege Grafana SQL Server monitoring and authored validated Terraform for an Azure App Service, Azure SQL, Blob Storage, Key Vault, managed identity, and Application Insights architecture, while keeping deployment status and external prerequisites explicit.
