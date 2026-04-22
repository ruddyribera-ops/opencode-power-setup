---
type: project
created: 2026-04-18
tags: [bdm-app, bolivia, document-pipeline, gemini, react, express]
---

# Project — BDM App (Bosques del Mundo Bolivia)

## What It Is
Document processing pipeline using Google Gemini AI to generate annual reports from PDF/DOCX files uploaded by partner organizations (NGOs in Bolivia).

## Tech Stack
- **Frontend:** Vite + React 19 (ESM)
- **Backend:** Express.js (Node.js)
- **AI:** Google Gemini API via `callMotor()`
- **Deploy:** Railway (bdm-app-prod-production.up.railway.app)
- **Testing:** Vitest + React Testing Library + jsdom
- **CI:** GitHub Actions (`.github/workflows/ci.yml`)

## Repo
`https://github.com/ruddyribera-ops/bdm-app`

## Key Files
| Path | Purpose |
|------|---------|
| `src/App.jsx` | Main app (~449 lines, refactored from 1053) |
| `src/components/` | 7 extracted React components |
| `src/services/api.js` | `callMotor()` — Gemini API calls |
| `src/services/fileParser.js` | `readFile()` — PDF/DOCX extraction |
| `src/prompts/index.js` | AI prompt templates (PROMPTS as P) |
| `src/theme/index.js` | Theme constants (THEME as C) |
| `src/utils/auth.js` | Token management |
| `src/utils/exportHelpers.js` | Word/Markdown export |
| `server.js` | Express API (auth, generate, health) |
| `api/utils/rateLimiter.js` | Shared rate limiting |
| `docs/REFACTOR_BASELINE.md` | Architecture decisions + phases |
| `docs/ROLLBACK_RUNBOOK.md` | How to recover from bad deploy |
| `docs/ONBOARDING.md` | New dev setup guide |
| `scripts/backup-config.ps1` | Railway env var backup |

## Key Endpoints
| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/auth` | POST | Login with password → HMAC token |
| `/api/generate` | POST | Gemini AI call (requires Bearer token) |
| `/api/health` | GET | Health check + service status |
| `/api/version` | GET | Commit SHA for post-deploy verification |
| `/health` | GET | Simple health check |
| `/` | GET | Serves React SPA (static catch-all) |

## Refactor Phases (Complete)
- **Phase A** — Stabilize: health endpoint, ErrorBoundary, smoke check
- **Phase B** — Security: `.env.example`, rate limiter, env-based secrets
- **Phase C** — Modular: App.jsx 1053→449 lines (57%), 7 components extracted
- **Phase D** — Tests+CI: Vitest (35 tests), GitHub Actions CI
- **Phase E** — Ops: backup script, rollback runbook, onboarding, request logging
- **Phase F** — Not needed (app has no scale pain points)

## Current Known Issues
- **No mobile responsiveness** — fixed at 1024px only, no breakpoint below 768px
- **Browser-state only** — all sessions in localStorage/sessionStorage; no persistent server state

## Secrets (Environment Variables)
- `APP_PASSWORD` — Main app password
- `APP_SECRET` — HMAC signing secret
- `GEMINI_API_KEY` — Google AI API key
- `PORT` — Server port (default 3000)
- `RAILWAY_GIT_COMMIT_SHA` — Auto-set by Railway (used for `/api/version`)

## Source: BDM App refactor session 2026-04-18
