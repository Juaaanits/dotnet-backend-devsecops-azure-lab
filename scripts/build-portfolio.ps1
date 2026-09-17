param(
    [switch]$Pdf
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$outputDirectory = Join-Path $repoRoot "artifacts\portfolio"
$markdownOutput = Join-Path $outputDirectory "sakenny-technical-case-study.md"
$htmlOutput = Join-Path $outputDirectory "sakenny-technical-case-study.html"
$pdfOutput = Join-Path $outputDirectory "sakenny-technical-case-study.pdf"

$chapters = @(
    "docs\SAKENNY_TECHNICAL_CASE_STUDY.md",
    "docs\LOCAL_SETUP_AND_VALIDATION.md",
    "docs\API_TEST_RUNBOOK.md",
    "docs\AUTOMATED_QA_AND_CONTAINER_RUNBOOK.md",
    "docs\KNOWN_ISSUES_AND_FIX_PLAN.md",
    "docs\SQL_SERVER_TEST_NOTES.md",
    "docs\OBSERVABILITY_SQL_SERVER_GRAFANA.md",
    "docs\DEVOPS_DEVSECOPS_CHECKLIST.md",
    "docs\QA_DEVSECOPS_CLOUD_ROADMAP.md",
    "docs\TERRAFORM_AZURE_DEPLOYMENT.md",
    "docs\FINAL_PROJECT_STATUS.md",
    "docs\REFERENCE_LINKS.md"
)

New-Item -ItemType Directory -Force $outputDirectory | Out-Null
$content = foreach ($chapter in $chapters) {
    $path = Join-Path $repoRoot $chapter
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Portfolio chapter not found: $chapter"
    }

    Get-Content -Raw -LiteralPath $path
    "`r`n`r`n" + '<div style="page-break-after: always;"></div>' + "`r`n"
}

Set-Content -LiteralPath $markdownOutput -Value ($content -join "`r`n") -Encoding utf8
Write-Host "Combined Markdown: $markdownOutput"

$pandoc = Get-Command pandoc -ErrorAction SilentlyContinue
if ($pandoc) {
    & $pandoc.Source $markdownOutput --standalone --toc --number-sections --metadata title="Sakenny Backend QA, DevSecOps, and Cloud Engineering Lab" --output $htmlOutput
    Write-Host "Portfolio HTML: $htmlOutput"

    if ($Pdf) {
        & $pandoc.Source $markdownOutput --standalone --toc --number-sections --metadata title="Sakenny Backend QA, DevSecOps, and Cloud Engineering Lab" --output $pdfOutput
        Write-Host "Portfolio PDF: $pdfOutput"
    }
} else {
    Write-Host "Pandoc is not installed. The combined Markdown is ready for import into a Markdown/PDF tool."
}
