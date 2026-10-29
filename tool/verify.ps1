# Runs every automated quality check in order and stops at the first failure.
# Usage (from the project root):  powershell -ExecutionPolicy Bypass -File tool\verify.ps1
# Add -SkipBuild to skip the Android debug build (about 1-3 minutes).
param([switch]$SkipBuild)

$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)

function Step($name, [scriptblock]$cmd) {
    Write-Host "`n== $name" -ForegroundColor Cyan
    & $cmd
    if ($LASTEXITCODE -ne 0) {
        Write-Host "FAILED: $name (exit $LASTEXITCODE)" -ForegroundColor Red
        exit $LASTEXITCODE
    }
}

Step 'Dependencies' { flutter pub get --enforce-lockfile }
Step 'Formatting'   { dart format --output=none --set-exit-if-changed . }
Step 'Analysis'     { flutter analyze }
Step 'Tests'        { flutter test }
if (-not $SkipBuild) {
    Step 'Android debug build' { flutter build apk --debug }
}

Write-Host "`nAll checks passed." -ForegroundColor Green
