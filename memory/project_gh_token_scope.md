---
name: GH CLI token cannot reach pria-app
description: Local gh token has no scopes for private repo ruddyribera-ops/pria-app — CLI calls 404. Git push/pull work via stored credentials.
type: project
---

`gh` CLI against `ruddyribera-ops/pria-app` returns HTTP 404 because the local token has no repo scopes. So `gh run list`, `gh pr create`, `gh secret set`, etc. all fail against this repo.

**Why:** the repo is private and the installed gh token wasn't granted repo scope; upgrading scopes requires a browser flow Ruddy handles himself.

**How to apply:**
- Don't try `gh` for monitoring CI, opening PRs, or managing secrets on this repo — it will 404. Use `git push` / `git fetch` (separate stored credentials) and ask Ruddy to confirm CI status via the web when needed.
- When secrets are required (e.g. `RAILWAY_TOKEN`), tell Ruddy to add them at github.com/ruddyribera-ops/pria-app/settings/secrets/actions.
- If GitHub access is ever required programmatically, suggest `gh auth login` with `repo` scope rather than working around it.
