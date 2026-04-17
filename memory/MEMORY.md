# Memory Index — Global Knowledge

**Purpose:** Lightweight file-based memory. No MCP server required. Agents read this at session start.

## How It Works

1. Each memory is a small `.md` file with frontmatter.
2. This index points to all memories with a one-line hook.
3. Agents read `MEMORY.md` first, then fetch specific files only when relevant.
4. Projects can have their own local `.opencode/memory/MEMORY.md` that extends this one.

## Types

- `user_*.md` — who the user is, preferences, language, workflow
- `feedback_*.md` — rules learned ("always X", "never Y") + why + how to apply
- `project_*.md` — facts about active projects (deadlines, architecture, stakeholders)
- `reference_*.md` — pointers to external resources (URLs, IDs, channels)

## Active Memories

<!-- Keep each line under 150 chars. Format: - [Title](file.md) — one-line hook -->
- [User profile](user_profile.md) — Ruddy Ribera, Bolivia (GMT-4), Spanish-first, direct style
- [Active projects](project_active.md) — PRIA (EdTech Streamlit) + Palma Coin (Railway)

## Rules for Writing Memory

1. **Keep it short.** Each file should fit on one screen.
2. **State the rule first**, then `**Why:**` and `**How to apply:**` for feedback/project types.
3. **Update or delete** stale memories — don't let them pile up.
4. **Project-local memory wins** over global when both apply.
