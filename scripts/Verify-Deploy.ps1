# Verify-Deploy.ps1
# Post-push verification: confirms the deployed app matches local HEAD.
# Invoked automatically by main-coordinator after any `git push` on a deployable branch.
#
# Usage (from coordinator or user):
#   powershell -File Verify-Deploy.ps1 -Url "https://priav5-production.up.railway.app" -Endpoint "/version"
#   powershell -File Verify-Deploy.ps1 -Url "https://priav5-production.up.railway.app" -WaitSeconds 45

param(
    [Parameter(Mandatory=$true)]
    [string]$Url,

    [string]$Endpoint = "/version",

    [int]$WaitSeconds = 30,

    [int]$TimeoutSeconds = 10
)

$ErrorActionPreference = "Stop"

# Get local HEAD short SHA
try {
    $localSha = (git rev-parse --short=7 HEAD).Trim()
} catch {
    Write-Host "ERROR: not in a git repo or git not found" -ForegroundColor Red
    exit 1
}

Write-Host "Local HEAD:  $localSha" -ForegroundColor Cyan
Write-Host "Waiting ${WaitSeconds}s for build..." -ForegroundColor Yellow
Start-Sleep -Seconds $WaitSeconds

$fullUrl = "$Url$Endpoint"
Write-Host "Fetching:    $fullUrl" -ForegroundColor Cyan

try {
    $response = Invoke-WebRequest -Uri $fullUrl -TimeoutSec $TimeoutSeconds -UseBasicParsing
    $deployedSha = $response.Content.Trim()
} catch {
    Write-Host "ERROR: could not reach $fullUrl ($($_.Exception.Message))" -ForegroundColor Red
    Write-Host "Coordinator should NOT declare deploy done." -ForegroundColor Red
    exit 2
}

Write-Host "Deployed:    $deployedSha" -ForegroundColor Cyan

# Accept match if deployed SHA contains local SHA (handles full vs short SHA)
if ($deployedSha -match $localSha -or $localSha -match $deployedSha) {
    Write-Host ""
    Write-Host "OK: deployed commit matches HEAD ($localSha)" -ForegroundColor Green
    exit 0
} else {
    Write-Host ""
    Write-Host "MISMATCH: deployed $deployedSha != local $localSha" -ForegroundColor Red
    Write-Host "Likely Railway stale-build cache. Trigger a redeploy or invalidate cache." -ForegroundColor Red
    exit 3
}
