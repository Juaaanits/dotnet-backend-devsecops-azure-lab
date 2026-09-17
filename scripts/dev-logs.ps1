$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
Push-Location $repoRoot
try { docker compose logs --follow api sqlserver azurite grafana } finally { Pop-Location }
