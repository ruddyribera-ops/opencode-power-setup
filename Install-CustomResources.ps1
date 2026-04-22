# OpenCode Custom Resources — One-Click Installer
# Instala: skills, agents, memories, scripts, project-template
# Run: powershell -File Install-CustomResources.ps1

param(
    [switch]$SkipMemories,          # No copiar memorias
    [switch]$SkipProjectTemplate    # No copiar project-template
)

$ErrorActionPreference = 'Stop'

$SourceDir = "$PSScriptRoot"
$OpenCodeDir = "$HOME\.config\opencode"

Write-Host ""
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host " OpenCode Custom Resources - One-Click Install" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""

# 1. Verificar OpenCode instalado
Write-Host "[1/7] Verificando instalacion de OpenCode..." -ForegroundColor Yellow

$opencodePath = (Get-Command opencode -ErrorAction SilentlyContinue).Source
if (-not $opencodePath) {
    Write-Host "  ERROR: OpenCode no encontrado. Instalar desde: https://opencode.ai" -ForegroundColor Red
    Write-Host "  O: npm install -g @opencodeai/cli" -ForegroundColor Gray
    exit 1
}
Write-Host "  OK: OpenCode encontrado en $opencodePath" -ForegroundColor Green

# 2. Crear estructura de carpetas
Write-Host "[2/7] Creando estructura de carpetas..." -ForegroundColor Yellow

$dirs = @(
    "$OpenCodeDir\skills",
    "$OpenCodeDir\agents",
    "$OpenCodeDir\scripts",
    "$OpenCodeDir\memory",
    "$OpenCodeDir\project-template\.opencode\memory",
    "$OpenCodeDir\project-template\.opencode\agents"
)

foreach ($dir in $dirs) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "  Creado: $(Split-Path $dir -Leaf)" -ForegroundColor Gray
    }
}

# 3. Copiar Skills
Write-Host "[3/7] Copiando Skills ($((Get-ChildItem $SourceDir\skills -Directory -ErrorAction SilentlyContinue).Count) encontrados)..." -ForegroundColor Yellow

$skillsSource = "$SourceDir\skills"
$skillsDest = "$OpenCodeDir\skills"
$skillsInstalled = 0

if (Test-Path $skillsSource) {
    $skillDirs = Get-ChildItem $skillsSource -Directory -ErrorAction SilentlyContinue
    foreach ($skillDir in $skillDirs) {
        $skillMdSource = "$($skillDir.FullName)\SKILL.md"
        if (Test-Path $skillMdSource) {
            $destPath = "$skillsDest\$($skillDir.Name)"
            if (-not (Test-Path $destPath)) {
                New-Item -ItemType Directory -Path $destPath -Force | Out-Null
            }
            Copy-Item $skillMdSource "$destPath\SKILL.md" -Force
            Write-Host "  Instalado: skills/$($skillDir.Name)" -ForegroundColor Green
            $skillsInstalled++
        }
    }
}

# 4. Copiar Agents
Write-Host "[4/7] Copiando Agents..." -ForegroundColor Yellow

$agentsSource = "$SourceDir\agents"
$agentsDest = "$OpenCodeDir\agents"
$agentsInstalled = 0

if (Test-Path $agentsSource) {
    $agentFiles = Get-ChildItem $agentsSource -Filter "*.md" -ErrorAction SilentlyContinue
    foreach ($agentFile in $agentFiles) {
        $destPath = "$agentsDest\$($agentFile.Name)"
        if (Test-Path $destPath) {
            Write-Host "  Saltado (existe): agents/$($agentFile.Name)" -ForegroundColor Gray
        } else {
            Copy-Item $agentFile.FullName $destPath -Force
            Write-Host "  Instalado: agents/$($agentFile.Name)" -ForegroundColor Green
            $agentsInstalled++
        }
    }
}

# 5. Copiar Scripts
Write-Host "[5/7] Copiando Scripts..." -ForegroundColor Yellow

$scriptsSource = "$SourceDir\scripts"
$scriptsDest = "$OpenCodeDir\scripts"

if (Test-Path $scriptsSource) {
    $scriptFiles = Get-ChildItem $scriptsSource -Filter "*.ps1" -ErrorAction SilentlyContinue
    foreach ($scriptFile in $scriptFiles) {
        $destPath = "$scriptsDest\$($scriptFile.Name)"
        Copy-Item $scriptFile.FullName $destPath -Force
        Write-Host "  Instalado: scripts/$($scriptFile.Name)" -ForegroundColor Green
    }
}

# 6. Copiar Memorias (opcional)
if (-not $SkipMemories) {
    Write-Host "[6/7] Copiando Memorias..." -ForegroundColor Yellow

    $memorySource = "$SourceDir\memory"
    $memoryDest = "$OpenCodeDir\memory"

    if (Test-Path $memorySource) {
        $memoryFiles = Get-ChildItem $memorySource -Filter "*.md" -ErrorAction SilentlyContinue
        foreach ($memFile in $memoryFiles) {
            $destPath = "$memoryDest\$($memFile.Name)"
            if (Test-Path $destPath) {
                Write-Host "  Saltado (existe): memory/$($memFile.Name)" -ForegroundColor Gray
            } else {
                Copy-Item $memFile.FullName $destPath -Force
                Write-Host "  Instalado: memory/$($memFile.Name)" -ForegroundColor Green
            }
        }
    }
}

# 7. Copiar Project Template (opcional)
if (-not $SkipProjectTemplate) {
    Write-Host "[7/7] Copiando Project Template..." -ForegroundColor Yellow

    $templateSource = "$SourceDir\project-template"
    $templateDest = "$OpenCodeDir\project-template"

    if (Test-Path "$templateSource\AGENTS.md") {
        Copy-Item "$templateSource\AGENTS.md" "$templateDest\AGENTS.md" -Force
        Write-Host "  Instalado: project-template/AGENTS.md" -ForegroundColor Green
    }
    if (Test-Path "$templateSource\opencode.json") {
        Copy-Item "$templateSource\opencode.json" "$templateDest\opencode.json" -Force
        Write-Host "  Instalado: project-template/opencode.json" -ForegroundColor Green
    }
    if (Test-Path "$templateSource\.opencode\memory\MEMORY.md") {
        $templateMemDir = "$OpenCodeDir\project-template\.opencode\memory"
        if (-not (Test-Path $templateMemDir)) {
            New-Item -ItemType Directory -Path $templateMemDir -Force | Out-Null
        }
        Copy-Item "$templateSource\.opencode\memory\MEMORY.md" "$templateMemDir\MEMORY.md" -Force
        Write-Host "  Instalado: project-template/.opencode/memory/MEMORY.md" -ForegroundColor Green
    }
}

# Copiar AGENTS.md raiz
$agentsMdSource = "$SourceDir\AGENTS.md"
if (Test-Path $agentsMdSource) {
    Copy-Item $agentsMdSource "$OpenCodeDir\AGENTS.md" -Force
    Write-Host "  Actualizado: AGENTS.md" -ForegroundColor Green
}

# Resumen
Write-Host ""
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "              INSTALACION COMPLETA" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Skills instalados: $skillsInstalled" -ForegroundColor White
Write-Host "Agents instalados: $agentsInstalled" -ForegroundColor White
Write-Host "Scripts instalados: $((Get-ChildItem $OpenCodeDir\scripts -Filter *.ps1 -ErrorAction SilentlyContinue).Count)" -ForegroundColor White
Write-Host ""

Write-Host "Para usar:" -ForegroundColor Yellow
Write-Host "  1. Ejecutar: opencode" -ForegroundColor Gray
Write-Host "  2. Los agents y skills estan disponibles automaticamente" -ForegroundColor Gray
Write-Host "  3. /init-project para bootstrapped un nuevo proyecto" -ForegroundColor Gray
Write-Host ""
