# OpenCode Power User Setup

One-click installer that transforms OpenCode into a project-aware AI assistant with memory, skills, and automation.

## The Story

I'm a K-12 technology teacher in Santa Cruz, Bolivia. I have no formal programming background. Everything I know is self-taught through YouTube videos and trial and error.

After 2 years of using ChatGPT, Gemini, and every AI tool I could find, I kept running into the same problems:
- AI tools forget everything between sessions
- Context windows get exhausted
- Token limits hit right when conversations get useful
- Premium tools cost $20/month for features I barely use

I found OpenCode and loved it. But it kept getting stuck in loops and burning through tokens. Then I found a video about editing `claude.md` to make Claude more efficient.

**Could I do this for OpenCode?**

I asked OpenCode (using Opus 4.6) to create a custom setup — and it worked.

**From discovering OpenCode to building the one-click installer: 3 days.**

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
- Windows (PowerShell)

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
- **Cleanup Scripts** — Organize folders, clean disks, free RAM

## Why This Matters

Most AI CLI tools forget everything between sessions. This setup makes OpenCode **remember your projects, your rules, and your patterns**.

I want anyone who tries this to realize something:

**You have something that performs just as good — if not better — than premium tools. For absolutely free.**

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

## The Message

If I can build this — as a K-12 teacher with no programming background — so can you.

The tools are already there. The AI is already there. What you need is:
1. A problem worth solving
2. The willingness to ask questions
3. The persistence to keep trying

---

**License:** MIT  
**Author:** Ruddy D. Ribera S.  
**Location:** Santa Cruz, Bolivia  
**Repo:** https://github.com/ruddyribera-ops/opencode-power-setup
