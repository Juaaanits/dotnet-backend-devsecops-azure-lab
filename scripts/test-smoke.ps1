$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$collection = Join-Path $repoRoot "postman\Sakenny.postman_collection.json"
$environment = Join-Path $repoRoot "postman\Sakenny.postman_environment.json.example"
$artifactDirectory = Join-Path $repoRoot "artifacts\newman"

New-Item -ItemType Directory -Force $artifactDirectory | Out-Null
npx --yes newman run $collection `
    --environment $environment `
    --reporters cli,junit `
    --reporter-junit-export (Join-Path $artifactDirectory "newman-smoke.xml")
