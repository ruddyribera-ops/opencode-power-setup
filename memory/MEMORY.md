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

- [BDM App project facts](project_bdm-app.md) — BDM App (Bosques del Mundo Bolivia): Vite+React+Express+Gemini, Railway deploy, all key files/URLs
- [Palma Coin lessons: remote sync, Railway ephemeral fs, x-user-role spoofing, WS proxy, PG migration, idempotent seeds](feedback_palma_lessons.md)
- [Debug hypothesis discipline](feedback_debug_hypothesis.md) — inspect body + headers (`x-powered-by`, `server`) to locate which layer returned a 4xx/5xx before blaming infra
- [Divergent git remotes](feedback_git_divergent_remote.md) — handle force-push/squash remotes: fetch → inspect merge-base → decide (align or force-push) — never blind-rebase
- [Reference links](reference_links.md) — live URLs, GitHub, Railway, library docs
- [User preferences](user_preferences.md) — Spanish-first comms, direct style, BDM context established
- [User profile](user_profile.md) — Ruddy Ribera, Bolivia (GMT-4), Spanish-first, direct style
- [Active projects](project_active.md) — PRIA (EdTech Streamlit) + Palma Coin (Railway)
- [Current sprint](current_sprint.md) — live phase status; coordinator auto-updates after each task/push
- [Commit convention](feedback_commit_convention.md) — conventional-commit format; applied to every commit
- [Windows shell gotchas](feedback_windows_shell.md) — bash-on-Windows: `;` not `&&`, forward slashes, heredocs, CRLF/LF diff trap, PowerShell interop
- [Playwright MCP EACCESS](feedback_playwright_eaccess.md) — Windows Defender/scan blocks browser spawn inside OpenCode MCP; fix: add exclusion + clear temp
- [GH token scope gap](project_gh_token_scope.md) — gh CLI can't reach private pria-app; use git push + web UI for PRs/secrets
- [E2E waits on Railway](feedback_e2e_waits.md) — prefer wait_for_selector over fixed timeouts on cold-start Streamlit
- [Streamlit login DOM](reference_streamlit_login.md) — stable Playwright selectors for Streamlit login forms
- [Railway deploy surface](reference_railway.md) — PRIAv5 URLs, project/service IDs, deploy quirks

## Rules for Writing Memory

1. **Keep it short.** Each file should fit on one screen.
2. **State the rule first**, then `**Why:**` and `**How to apply:**` for feedback/project types.
3. **Update or delete** stale memories — don't let them pile up.
4. **Project-local memory wins** over global when both apply.
