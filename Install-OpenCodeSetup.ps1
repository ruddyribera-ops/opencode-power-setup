# OpenCode Power User Setup
# One-click installer for project-aware AI tooling

param(
    [switch]$SkipMCPs
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "OpenCode Power User Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check OpenCode
Write-Host "[1/6] Checking OpenCode..." -ForegroundColor Yellow
$opencodePath = (Get-Command opencode -ErrorAction SilentlyContinue).Source
if (-not $opencodePath) {
    Write-Host "ERROR: OpenCode not installed" -ForegroundColor Red
    exit 1
}
Write-Host "OK: Found at $opencodePath" -ForegroundColor Green

# Directories
$OpenCodeDir = "$HOME\.config\opencode"
$ScriptDir = "$OpenCodeDir\scripts"
$MemoryDir = "$OpenCodeDir\memory"
$TemplateDir = "$OpenCodeDir\project-template"

Write-Host "[2/6] Creating directories..." -ForegroundColor Yellow
$dirs = @($OpenCodeDir, $ScriptDir, $MemoryDir, "$TemplateDir\.opencode\memory", "$OpenCodeDir\skills")
foreach ($dir in $dirs) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}
Write-Host "OK" -ForegroundColor Green

# Copy files
Write-Host "[3/6] Copying config files..." -ForegroundColor Yellow
$RootDir = $PSScriptRoot

if (Test-Path "$RootDir\MEMORY.md") {
    Copy-Item "$RootDir\MEMORY.md" "$MemoryDir\MEMORY.md" -Force -ErrorAction SilentlyContinue
    Write-Host "Copied: MEMORY.md" -ForegroundColor Green
}
if (Test-Path "$RootDir\SKILL_TEMPLATE.md") {
    Copy-Item "$RootDir\SKILL_TEMPLATE.md" "$OpenCodeDir\SKILL_TEMPLATE.md" -Force -ErrorAction SilentlyContinue
    Write-Host "Copied: SKILL_TEMPLATE.md" -ForegroundColor Green
}
if (Test-Path "$RootDir\MCP_ALTERNATIVES.md") {
    Copy-Item "$RootDir\MCP_ALTERNATIVES.md" "$OpenCodeDir\MCP_ALTERNATIVES.md" -Force -ErrorAction SilentlyContinue
    Write-Host "Copied: MCP_ALTERNATIVES.md" -ForegroundColor Green
}

# Copy scripts
Write-Host "[4/6] Copying scripts..." -ForegroundColor Yellow
if (Test-Path "$RootDir\scripts\Init-Project.ps1") {
    Copy-Item "$RootDir\scripts\Init-Project.ps1" "$ScriptDir\Init-Project.ps1" -Force -ErrorAction SilentlyContinue
    Write-Host "Copied: Init-Project.ps1" -ForegroundColor Green
}
if (Test-Path "$RootDir\scripts\Optimize-OpenCode.ps1") {
    Copy-Item "$RootDir\scripts\Optimize-OpenCode.ps1" "$ScriptDir\Optimize-OpenCode.ps1" -Force -ErrorAction SilentlyContinue
    Write-Host "Copied: Optimize-OpenCode.ps1" -ForegroundColor Green
}

# Copy sample memories
Write-Host "[5/6] Copying sample memories..." -ForegroundColor Yellow
if (Test-Path "$RootDir\memory\user_sample.md") {
    $dst = "$MemoryDir\user_sample.md"
    if (-not (Test-Path $dst)) {
        Copy-Item "$RootDir\memory\user_sample.md" $dst -Force -ErrorAction SilentlyContinue
        Write-Host "Copied: user_sample.md" -ForegroundColor Green
    } else {
        Write-Host "Skip: user_sample.md (exists)" -ForegroundColor Gray
    }
}
if (Test-Path "$RootDir\memory\project_sample.md") {
    $dst = "$MemoryDir\project_sample.md"
    if (-not (Test-Path $dst)) {
        Copy-Item "$RootDir\memory\project_sample.md" $dst -Force -ErrorAction SilentlyContinue
        Write-Host "Copied: project_sample.md" -ForegroundColor Green
    } else {
        Write-Host "Skip: project_sample.md (exists)" -ForegroundColor Gray
    }
}

# Optimize
if (-not $SkipMCPs) {
    Write-Host "[6/6] Optimizing MCPs..." -ForegroundColor Yellow
    $jsonPath = "$OpenCodeDir\opencode.json"
    if (Test-Path $jsonPath) {
        $json = Get-Content $jsonPath -Raw | ConvertFrom-Json
        $json.mcp.memory.enabled = $false
        $json.mcp."sequential-thinking".enabled = $false
        $json | ConvertTo-Json -Depth 10 | Set-Content $jsonPath -NoNewline
        Write-Host "Disabled: memory, sequential-thinking MCPs" -ForegroundColor Green
    }
}

# Done
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "SETUP COMPLETE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Config: $OpenCodeDir" -ForegroundColor White
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Edit $MemoryDir\user_sample.md" -ForegroundColor Gray
Write-Host "  2. Run: opencode" -ForegroundColor Gray
Write-Host "  3. Try: /remember" -ForegroundColor Gray
Write-Host ""
