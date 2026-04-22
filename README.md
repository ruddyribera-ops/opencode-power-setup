# OpenCode Custom Resources — One-Click Installer

Script que empaqueta y distribuye los recursos personalizados de OpenCode CLI para compartir con otros usuarios.

## Estructura del Distribuidor

```
opencode-distrib/
├── Install-CustomResources.ps1  # Installer (PowerShell)
├── README.md                    # Este archivo
├── AGENTS.md                    # Reglas globales
├── SKILL_TEMPLATE.md            # Template para crear skills
├── MCP_ALTERNATIVES.md          # Optimizacion de MCPs
├── skills/                      # 19 Skills personalizados
│   ├── api-patterns/SKILL.md
│   ├── auth-patterns/SKILL.md
│   ├── code-review/SKILL.md
│   ├── data-analysis/SKILL.md
│   ├── database-patterns/SKILL.md
│   ├── deployment-patterns/SKILL.md
│   ├── desktop-manager/SKILL.md
│   ├── documentation-patterns/SKILL.md
│   ├── git-workflow/SKILL.md
│   ├── js-modern-patterns/SKILL.md
│   ├── msoffice-tools/SKILL.md
│   ├── ocr-tools/SKILL.md
│   ├── performance-optimization/SKILL.md
│   ├── python-patterns/SKILL.md
│   ├── realtime-patterns/SKILL.md
│   ├── security-basics/SKILL.md
│   ├── testing-standards/SKILL.md
│   ├── ui-design/SKILL.md
│   └── ci-cd-patterns/SKILL.md
├── agents/                      # 7 Agents personalizados
│   ├── architecture-advisor.md
│   ├── bug-fixer.md
│   ├── code-analyzer.md
│   ├── code-builder.md
│   ├── code-explainer.md
│   ├── main-coordinator.md
│   └── standup-summary.md
├── memory/                      # 21 Memorias
│   ├── MEMORY.md               # Indice
│   ├── feedback_*.md           # Reglas aprendidas
│   ├── project_*.md            # Facts de proyectos
│   ├── reference_*.md          # Enlaces externos
│   └── user_*.md              # Perfil de usuario
├── scripts/                     # 3 Scripts
│   ├── Init-Project.ps1        # Bootstrap proyecto
│   ├── Optimize-OpenCode.ps1   # Optimizar MCPs
│   └── Verify-Deploy.ps1       # Verificar deploy
└── project-template/           # Template para nuevos proyectos
    ├── AGENTS.md
    ├── opencode.json
    └── .opencode/memory/MEMORY.md
```

## Recursos Incluidos

### Skills (19)
Patrones especializados para cada dominio:

| Skill | Purpose |
|-------|---------|
| `api-patterns` | REST API design, error handling |
| `auth-patterns` | Password hashing, JWT, sessions |
| `code-review` | Security, performance checklists |
| `data-analysis` | CSV, JSON, pandas patterns |
| `database-patterns` | SQL/SQLite migrations |
| `deployment-patterns` | Docker, Railway, containers |
| `desktop-manager` | Desktop cleanup via natural language |
| `documentation-patterns` | README, docs, JSDoc |
| `git-workflow` | Conventional commits, branch strategy |
| `js-modern-patterns` | ES2022+, TypeScript patterns |
| `msoffice-tools` | Word, Excel, PowerPoint generation |
| `ocr-tools` | OCR con Tesseract/EasyOCR |
| `performance-optimization` | Bundle size, caching |
| `python-patterns` | FastAPI, Pydantic, async |
| `realtime-patterns` | WebSocket, SSE, polling |
| `security-basics` | OWASP, XSS/SQLi/CSRF |
| `testing-standards` | Test naming, coverage |
| `ui-design` | Typography, spacing, accessibility |
| `ci-cd-patterns` | GitHub Actions pipelines |

### Agents (7)
Especialistas que OpenCode usa automaticamente:

| Agent | Purpose |
|-------|---------|
| `main-coordinator` | Router principal |
| `code-builder` | Escribe/modifica code |
| `bug-fixer` | Debug y fixes |
| `code-analyzer` | Analiza estructura |
| `code-explainer` | Explica codigo |
| `architecture-advisor` | Asesora en decisiones tech |
| `standup-summary` | Genera standups |

### Scripts
- `Init-Project.ps1` — Bootstrap nuevo proyecto con `.opencode/`
- `Optimize-OpenCode.ps1` — Deshabilita MCPs pesados
- `Verify-Deploy.ps1` — Verifica deploy en Railway

## Instalacion

### Opcion 1: One-liner (desde repo)
```powershell
irm https://raw.githubusercontent.com/ruddyrbn/opencode-power-setup/main/Install-CustomResources.ps1 | iex
```

### Opcion 2: Manual
```powershell
git clone https://github.com/ruddyrbn/opencode-power-setup.git
cd opencode-power-setup
.\Install-CustomResources.ps1
```

### Opcion 3: Distribuir archivos manualmente
Copiar la carpeta `opencode-distrib` al equipo destino y ejecutar `Install-CustomResources.ps1`.

## Flags Opcionales

```powershell
.\Install-CustomResources.ps1 -SkipMemories          # No instalar memorias
.\Install-CustomResources.ps1 -SkipProjectTemplate    # No instalar project-template
.\Install-CustomResources.ps1 -SkipMemories -SkipProjectTemplate  # Solo skills + agents + scripts
```

## Verificar Instalacion

```powershell
# Ver skills instalados
Get-ChildItem $HOME\.config\opencode\skills -Directory

# Ver agents instalados
Get-ChildItem $HOME\.config\opencode\agents -Filter *.md

# Ver scripts instalados
Get-ChildItem $HOME\.config\opencode\scripts -Filter *.ps1

# Probar OpenCode
opencode
```

## Rutas de Destino

| Recurso | Ruta |
|--------|------|
| Skills | `~/.config/opencode/skills/<name>/SKILL.md` |
| Agents | `~/.config/opencode/agents/<name>.md` |
| Scripts | `~/.config/opencode/scripts/<name>.ps1` |
| Memory | `~/.config/opencode/memory/<name>.md` |
| Project Template | `~/.config/opencode/project-template/` |
| AGENTS.md | `~/.config/opencode/AGENTS.md` |

## Requisitos

- OpenCode CLI instalado (`npm install -g @opencodeai/cli`)
- PowerShell 5.1+ (Windows)
- ~5MB de espacio libre

## FAQ

**P: Se sobrescriben archivos existentes?**
R: No. El installer solo copia archivos que no existen ya en el destino. Los archivos existentes se mantienen intactos.

**P: Como desinstalo?**
R: Eliminar las carpetas `skills/`, `agents/`, `scripts/`, `memory/` y `project-template/` de `$HOME\.config\opencode\`.

**P: Puedo agregar mis propios resources?**
R: Si. Agregar archivos a las carpetas correspondientes del distribuidor y volver a ejecutar el installer.

**P: Las memorias incluyen datos privados?**
R: Las memorias aqui incluidas son genéricas/de ejemplo. El usuario puede decidir si incluye sus memorias reales usando `-SkipMemories` o copiando solo `memory/MEMORY.md` (el indice sin los archivos de datos).

## Licencia

MIT — Autor: Ruddy Ribera
Repo: github.com/ruddyrbn/opencode-power-setup
