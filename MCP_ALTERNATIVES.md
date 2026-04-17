# MCP Servers — Free & Lightweight Alternatives

Your current setup uses 5 MCP servers (all free/local npm packages). This document lists the tradeoffs and lighter alternatives if you want to reduce memory/CPU.

## Currently Enabled

| MCP | Memory Cost | What It Does | Lighter Alternative |
|-----|-------------|--------------|---------------------|
| `context7` | ~80MB Node proc | Live library docs | **Keep** — saves hours on unfamiliar libs |
| `sequential-thinking` | ~60MB Node proc | Structured reasoning | Native prompt: "think step by step" (no MCP needed) |
| `memory` | ~70MB Node proc | Knowledge graph | **File-based memory in `~/.config/opencode/memory/`** (already set up) |
| `github` | disabled | GitHub API access | `gh` CLI (already installed, zero memory when idle) |
| `pdf-toolkit` | ~90MB Node proc | PDF create/merge | Python `pypdf` + `reportlab` (only runs when invoked) |

## Recommendations (Ranked by Impact)

### Highest Impact: Disable `memory` MCP
Your file-based memory (`~/.config/opencode/memory/`) covers the same use case without a persistent Node process.

**How:** edit `opencode.json` → `"memory": { "enabled": false }`
**Save:** ~70MB RAM, one less background process

### Medium Impact: Disable `sequential-thinking` MCP
Native prompting ("think step by step before answering") works just as well for most cases.

**How:** edit `opencode.json` → `"sequential-thinking": { "enabled": false }`
**Save:** ~60MB RAM
**Tradeoff:** Loses a structured tool for very complex multi-step debugging — can re-enable on demand.

### Low Impact: Keep `context7` and `pdf-toolkit`
- `context7` is high-value (accurate library docs, avoids hallucinated APIs)
- `pdf-toolkit` only uses memory when actively invoked

### Already Optimal: `github` is disabled
Using `gh` CLI instead. Zero background cost.

## Totally Free MCP Alternatives (Optional)

If you ever want to extend further without paid services:

| Need | Free/Local Option |
|------|-------------------|
| Web scraping | `WebFetch` tool (built-in, no MCP needed) |
| Filesystem ops | Built-in file tools (no MCP needed) |
| Database query | Project-local scripts (`psql`, `sqlite3`) |
| Image processing | `Pillow` via Python (invoked on demand) |
| Scheduling | Windows Task Scheduler or GitHub Actions (zero cost) |

## One-Command Optimization

Run `Optimize-OpenCode.ps1` (created by this setup) to:
1. Disable `memory` MCP (replaced by file-based memory)
2. Disable `sequential-thinking` MCP (replaced by native prompting)
3. Keep `context7` and `pdf-toolkit` (high value)

Expected savings: **~130MB RAM, 2 fewer background Node processes**.
