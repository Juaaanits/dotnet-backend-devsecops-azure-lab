$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$envFile = Join-Path $repoRoot ".env"
if (-not (Test-Path $envFile)) {
    Copy-Item (Join-Path $repoRoot ".env.example") $envFile
    throw "Created .env. Replace every placeholder password, then run again."
}

$settings = @{}
Get-Content -LiteralPath $envFile | ForEach-Object {
    if ($_ -match '^\s*([^#][^=]*)=(.*)$') {
        $settings[$matches[1].Trim()] = $matches[2].Trim()
    }
}

$requiredSettings = @(
    "MSSQL_SA_PASSWORD",
    "GRAFANA_SQL_PASSWORD",
    "GF_SECURITY_ADMIN_PASSWORD",
    "AZURITE_ACCOUNT_KEY",
    "JWT_KEY",
    "BOOTSTRAP_ADMIN_PASSWORD"
)

$invalidSettings = $requiredSettings | Where-Object {
    -not $settings.ContainsKey($_) -or
    [string]::IsNullOrWhiteSpace($settings[$_]) -or
    $settings[$_] -like "ReplaceWith_*"
}

if ($invalidSettings) {
    throw "Set non-placeholder values in .env for: $($invalidSettings -join ', '). Generate AZURITE_ACCOUNT_KEY with: [Convert]::ToBase64String([Security.Cryptography.RandomNumberGenerator]::GetBytes(64))"
}
Push-Location $repoRoot
try {
    docker compose up --build -d
    docker compose ps
    Write-Host "API: http://localhost:5111/health"
    Write-Host "Swagger: http://localhost:5111/swagger"
    Write-Host "Grafana: http://localhost:3000"
} finally { Pop-Location }
