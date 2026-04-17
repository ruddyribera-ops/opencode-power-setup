# OpenCode Power User Setup

One-click installer that transforms OpenCode into a project-aware AI assistant with memory, skills, and automation.

## What It Does

| Feature | Before | After |
|---------|--------|-------|
| **Memory** | None (forgets everything) | File-based, persists across sessions |
| **Project Context** | Generic | Reads your `.opencode/memory/` |
| **Skills** | Global only | Project-specific skills supported |
| **Commands** | Basic | `/remember`, `/init-project`, `/optimize` |
| **MCPs** | Heavy (~200MB) | Optimized (~70MB) |

## One-Line Install

```powershell
irm https://raw.githubusercontent.com/ruddyrbn/opencode-power-setup/main/Install-OpenCodeSetup.ps1 | iex
```

Or manually:

```powershell
git clone https://github.com/ruddyrbn/opencode-power-setup.git
cd opencode-power-setup
.\Install-OpenCodeSetup.ps1
```

## Requirements

- [OpenCode](https://opencode.ai) installed (`npm install -g @opencodeai/cli`)
- Windows (PowerShell) — macOS/Linux versions coming soon

## Quick Start

After install, run:

```bash
opencode
/remember      # Save your first rule
/init-project  # Initialize a new project
/optimize      # Free up RAM
```

## What's Included

- **Memory System** — File-based, no MCP needed
- **Project Templates** — `/init-project` bootstrap
- **Skill Template** — Create custom skills
- **MCP Alternatives** — Save ~130MB RAM

## Documentation

- [MEMORY.md](MEMORY.md) — How to use the memory system
- [MCP_ALTERNATIVES.md](MCP_ALTERNATIVES.md) — Optimize your setup
- [SKILL_TEMPLATE.md](SKILL_TEMPLATE.md) — Create custom skills

## Commands

| Command | Description |
|---------|-------------|
| `/remember` | Save a durable fact/rule |
| `/init-project` | Bootstrap new project with `.opencode/` |
| `/optimize` | Disable heavy MCPs |
| `/scan` | Analyze project structure |
| `/explain` | Explain code in plain language |

## File Structure

```
~/.config/opencode/
├── AGENTS.md              # Global rules
├── opencode.json          # Config + commands
├── memory/
│   ├── MEMORY.md          # Index
│   └── *.md               # Your memories
├── skills/
│   └── */                 # Custom skills
└── scripts/
    ├── Init-Project.ps1   # Bootstrap script
    └── Optimize-OpenCode.ps1
```

## Contributing

See [SKILL_TEMPLATE.md](SKILL_TEMPLATE.md) for how to add custom skills.

---

**License:** MIT  
**Author:** Ruddy Ribera  
**Repo:** github.com/ruddyrbn/opencode-power-setup
