<!--# One-Hour DevOps and DevSecOps Plan -->

Use this when time is limited and the goal is to add visible DevOps/DevSecOps value without changing application behavior.

## Best Task To Prioritize

Priority task:

```text
Add a GitHub Actions .NET CI quality gate and Dependabot dependency monitoring.
```

Why this task is the best one-hour choice:

```text
It is visible on GitHub.
It does not require Azure resources.
It does not require SQL Server or Azurite to run in CI yet.
It proves build automation.
It starts the DevSecOps supply-chain story.
It creates a base for future test, SAST, secret scan, and container scan stages.
```

Do not prioritize these inside a one-hour window:

```text
Azure deployment
Terraform infrastructure
Docker Compose for the full stack
Full integration tests with SQL Server and Azurite
OWASP ZAP DAST
Container image scanning
```

Those are valuable, but they need more careful setup.

## Outcome For This Session

By the end of the hour, the repository should have:

```text
.github/workflows/dotnet-ci.yml
.github/dependabot.yml
One commit pushed to a feature branch
GitHub Actions run visible in the Actions tab
Dependabot configuration visible in the Security/Insights area
```

## Branch

Use Git Bash:

```bash
git switch -c devops/add-ci-quality-gate
```

## File 1: GitHub Actions CI

Create this file:

```text
.github/workflows/dotnet-ci.yml
```

Put this content:

```yaml
name: .NET CI

on:
  push:
    branches:
      - main
      - "devops/**"
      - "fix/**"
      - "feature/**"
  pull_request:
    branches:
      - main

permissions:
  contents: read

jobs:
  build:
    name: Restore and build backend
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v6

      - name: Setup .NET 8 SDK
        uses: actions/setup-dotnet@v5
        with:
          dotnet-version: "8.0.x"

      - name: Restore dependencies
        run: dotnet restore ./sakenny.sln

      - name: Build
        run: dotnet build ./sakenny.sln --configuration Release --no-restore
```

## Why This Workflow Is Designed This Way

`name: .NET CI`

```text
Gives the workflow a readable name in the GitHub Actions tab.
```

`on: push` and `on: pull_request`

```text
Runs the quality gate when code is pushed or reviewed through a pull request.
This is the foundation of CI.
```

`permissions: contents: read`

```text
Uses least privilege for the GitHub token.
The workflow only needs to read repository contents.
```

`runs-on: ubuntu-latest`

```text
Uses a GitHub-hosted Linux runner.
This is enough for restore/build and avoids depending on your Windows machine.
```

`actions/checkout@v6`

```text
Checks out the repository into the runner workspace.
Without this, the runner has no source code to build.
```

`actions/setup-dotnet@v5`

```text
Installs/selects the .NET SDK version used by the build.
The project targets .NET 8, so the workflow uses 8.0.x.
```

`dotnet restore`

```text
Downloads NuGet packages and validates dependency resolution.
```

`dotnet build --configuration Release --no-restore`

```text
Compiles the backend in Release mode.
The --no-restore flag proves restore was already completed in the previous step.
```

## File 2: Dependabot

Create this file:

```text
.github/dependabot.yml
```

Put this content:

```yaml
version: 2
updates:
  - package-ecosystem: "nuget"
    directory: "/sakenny"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 5
    labels:
      - "dependencies"
      - "nuget"
    commit-message:
      prefix: "deps"

  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 5
    labels:
      - "dependencies"
      - "github-actions"
    commit-message:
      prefix: "ci"
```

## Why This Dependabot Config Is Designed This Way

`package-ecosystem: "nuget"`

```text
Monitors .NET/NuGet package updates in the backend project.
```

`directory: "/sakenny"`

```text
The .csproj file is inside the sakenny folder, so Dependabot should inspect that directory.
```

`package-ecosystem: "github-actions"`

```text
Monitors GitHub Actions versions such as checkout and setup-dotnet.
```

`schedule: weekly`

```text
Keeps dependency update noise manageable for a portfolio project.
```

`open-pull-requests-limit: 5`

```text
Prevents too many automated PRs from opening at once.
```

## Validation Checklist

After adding the files:

```bash
git status --short
git add .github docs README.md
git commit -m "ci: add dotnet build quality gate and dependency monitoring"
git push -u origin devops/add-ci-quality-gate
```

Then open GitHub:

```text
Repository -> Actions
```

Expected:

```text
.NET CI workflow starts.
Restore step passes.
Build step passes.
```

Then open:

```text
Repository -> Insights -> Dependency graph
Repository -> Security
```

Expected:

```text
Dependabot configuration is recognized.
Future NuGet and GitHub Actions dependency update PRs can be created.
```

## If The Build Fails

Do not panic. A failing CI run is still useful engineering evidence.

Check:

```text
Did dotnet restore find the solution file?
Did dotnet build fail because of Linux path/case sensitivity?
Did the project require Windows-specific behavior?
Did warnings become errors?
Did package restore fail?
```

If the failure is real, document it in `docs/KNOWN_ISSUES_AND_FIX_PLAN.md` instead of hiding it.

## Recruiter-Facing Summary

Use this wording after the workflow passes:

```text
Added the first DevSecOps quality gate using GitHub Actions. The pipeline restores and builds the .NET 8 backend on every push and pull request, while Dependabot monitors NuGet and GitHub Actions dependencies for safer maintenance.
```

## Next Session

After this one-hour task, continue with:

```text
Add CodeQL code scanning
Add secret scanning guidance or Gitleaks
Add Postman/Newman smoke tests
Add Docker Compose for SQL Server and Azurite
Add Trivy scanning after a Dockerfile exists
```

