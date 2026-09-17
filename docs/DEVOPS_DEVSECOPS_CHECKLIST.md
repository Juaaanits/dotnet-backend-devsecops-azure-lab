# DevOps and DevSecOps Checklist

This checklist tracks the permanent DevOps and DevSecOps work for the Sakenny backend lab. It replaces the temporary one-hour plan and keeps the completed evidence, review notes, and next actions in one place.

## Current Baseline

Completed:

```text
GitHub Actions .NET restore/build workflow added.
Workflow runs on push and pull request.
Workflow uses least-privilege contents: read permission.
Dependabot monitors GitHub Actions dependencies.
Dependabot monitors NuGet dependencies under /sakenny.
Initial Dependabot PR queue was processed until 0 open pull requests remained.
Duplicate Azure.Storage.Blobs package reference was cleaned after dependency conflict resolution.
CodeQL C# SAST scanning was added and merged.
Gitleaks secret scanning was added and merged.
SQL Server Grafana observability was added locally.
Postman/Newman smoke collection and JUnit reporting were added.
xUnit regression tests were added to the solution.
Docker Compose now orchestrates SQL Server, Azurite, API, SQL initialization, and Grafana.
Trivy container scanning workflow was added.
Terraform Azure baseline and validation workflow were added.
Manual OIDC Azure Web App deployment workflow was added.
```

Evidence:

```text
.NET CI workflow passed.
Dependabot opened GitHub Actions update PRs.
Dependabot opened NuGet update PRs.
Dependabot PRs showed 2/2 passing checks before review.
GitHub pull request queue was cleared to 0 open PRs.
CodeQL workflow completed after code scanning was enabled.
Grafana dashboard connected to the local SakennyDB SQL Server database.
```

Screenshot evidence:

```text
docs/evidence/github-pr-queue-cleared.png
```

## Implemented Files

```text
.github/workflows/dotnet-ci.yml
.github/workflows/codeql.yml
.github/workflows/gitleaks.yml
.github/dependabot.yml
docs/REFERENCE_LINKS.md
docs/OBSERVABILITY_SQL_SERVER_GRAFANA.md
monitoring/grafana/
postman/
tests/Sakenny.Tests/
docker-compose.yml
Dockerfile
infra/terraform/
.github/workflows/api-smoke.yml
.github/workflows/container-security.yml
.github/workflows/terraform.yml
.github/workflows/azure-deploy.yml
```

## Current CI Gate

The CI baseline now includes:

```text
Restore NuGet dependencies.
Build the .NET 8 solution in Release mode.
Run xUnit and retain TRX output.
Run Postman/Newman against SQL Server and Azurite service containers.
Scan source with CodeQL and Gitleaks.
Build and scan the container with Trivy.
Validate Terraform formatting and configuration.
```

Why this was the correct first gate:

```text
It is visible on GitHub.
It does not require Azure resources.
It does not require SQL Server or Azurite in CI yet.
It proves build automation.
It creates a base for future test, SAST, secret scan, and container scan stages.
```

## Dependabot Review Process

Review order:

```text
1. GitHub Actions version bumps.
2. Azure SDK patch/minor NuGet updates.
3. Major package updates last.
```

Review rules:

```text
Only merge one dependency PR at a time.
Wait for CI to pass before merging.
Treat major version updates as higher risk.
Run local Swagger smoke tests after high-risk package updates.
Watch for package conflict resolution mistakes.
```

## Post-Merge Audit Finding

Finding:

```text
origin/main contained duplicate Azure.Storage.Blobs PackageReference entries after Dependabot conflict resolution.
```

Correct target state:

```xml
<PackageReference Include="Azure.Storage.Blobs" Version="12.29.2" />
```

Cleanup:

```text
Completed. The older Azure.Storage.Blobs 12.22.2 entry was removed.
Only Azure.Storage.Blobs 12.29.2 remains.
The project was validated by CI after the cleanup.
```

## Observability Baseline

Completed:

```text
Grafana runs locally through Docker Compose.
MSSQL datasource is provisioned from environment variables.
Dashboard JSON is stored in monitoring/grafana/dashboards.
Local secrets are excluded through monitoring/grafana/.env.
Read-only SQL Server login grafana_reader was used instead of sysadmin.
Scoped msdb SELECT grants fixed SQL Agent history panel permissions.
```

Evidence:

```text
docs/evidence/grafana-sql-dashboard-overview.png
docs/evidence/grafana-sql-dashboard-security-monitoring.png
docs/evidence/grafana-sql-dashboard-index-health.png
```

## Next DevSecOps Checklist

Immediate:

```text
Push the final branch and retain the first Newman, xUnit, Trivy, and Terraform workflow evidence.
Review scanner findings instead of suppressing them automatically.
Pin container image versions after the first successful compatibility run.
```

Next:

```text
Use Grafana screenshots during API smoke/load tests to record SQL Server behavior.
Start SQL Server performance baseline notes for property listing/filter endpoints.
```

Later:

```text
Add database-backed integration tests with WebApplicationFactory/Testcontainers.
Add OWASP ZAP baseline scan after a deployed/stable local target exists.
Review and apply Terraform only with an approved Azure subscription and budget.
Add remote Terraform state, private endpoints, alerts, backup/restore testing, and deployment approvals.
```

## Resume Summary

Use this in a portfolio, interview, or LinkedIn project post:

```text
Added a GitHub Actions CI quality gate for the .NET 8 backend, enabled Dependabot monitoring for GitHub Actions and NuGet dependencies, added CodeQL SAST scanning, cleaned a dependency conflict, and added a local Grafana SQL Server dashboard using a dedicated read-only monitoring login.
```

## Branch Cleanup Checklist

After related PRs are merged:

```bash
git switch main
git pull
git branch -d docs/record-dependabot-evidence
git fetch --prune
```

If Git says a local branch is not fully merged, do not force-delete it until the matching GitHub PR is confirmed merged.
