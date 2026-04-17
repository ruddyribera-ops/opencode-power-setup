# Optimize-OpenCode.ps1
# Disable heavy MCPs that have free/file-based replacements.
# Saves ~130MB RAM by disabling 'memory' (replaced by file-based memory)
# and 'sequential-thinking' (replaced by native prompting).
#
# Safe: edits opencode.json in place, creates a .bak backup first.
#
# Usage:
#   .\Optimize-OpenCode.ps1          # Apply optimization
#   .\Optimize-OpenCode.ps1 -Revert  # Re-enable the disabled MCPs

param(
    [switch]$Revert
)

$ErrorActionPreference = 'Stop'
$ConfigPath = "$HOME\.config\opencode\opencode.json"
$BackupPath = "$ConfigPath.bak"

if (-not (Test-Path $ConfigPath)) {
    Write-Host "ERROR: opencode.json not found at $ConfigPath" -ForegroundColor Red
    exit 1
}

Copy-Item $ConfigPath $BackupPath -Force
Write-Host "Backup: $BackupPath" -ForegroundColor Gray

$json = Get-Content $ConfigPath -Raw | ConvertFrom-Json

$targetState = if ($Revert) { $true } else { $false }
$action = if ($Revert) { "Enabling" } else { "Disabling" }

$mcpsToToggle = @('memory', 'sequential-thinking')

foreach ($mcp in $mcpsToToggle) {
    if ($json.mcp.PSObject.Properties.Name -contains $mcp) {
        $json.mcp.$mcp.enabled = $targetState
        Write-Host "  $action MCP: $mcp" -ForegroundColor Cyan
    }
}

$json | ConvertTo-Json -Depth 10 | Set-Content $ConfigPath -NoNewline

Write-Host ""
if ($Revert) {
    Write-Host "Reverted. MCPs re-enabled." -ForegroundColor Green
} else {
    Write-Host "Optimized. Estimated savings: ~130MB RAM." -ForegroundColor Green
    Write-Host "Memory replaced by file-based memory at ~/.config/opencode/memory/" -ForegroundColor Gray
    Write-Host "Sequential-thinking replaced by native 'think step by step' prompting." -ForegroundColor Gray
}
Write-Host "Restart OpenCode for changes to take effect." -ForegroundColor Yellow
