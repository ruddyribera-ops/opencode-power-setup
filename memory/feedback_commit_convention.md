---
name: Commit convention
description: Conventional-commit style — prefix every commit with type(scope). Used by coordinator and all specialists when creating commits.
type: feedback
---

# Commit Convention

Always use this exact shape:

```
type(scope): subject in imperative mood

optional body explaining WHY (not WHAT — the diff shows what)
```

## Types (pick one)

| Type | When to use |
|------|-------------|
| `feat` | New user-facing feature |
| `fix` | Bug fix |
| `refactor` | Code change that doesn't add/fix a feature |
| `test` | Adding or fixing tests only |
| `docs` | README, inline docs, comments |
| `ops` | Railway/Docker/infra/env config |
| `ci` | GitHub Actions / pipeline only |
| `chore` | Deps bump, lockfile, formatting — nothing else |

## Scope (optional but helpful)

- PRIA: `auth`, `ui`, `api`, `db`, `e2e`, `seed`, `deploy`
- Omit if change is cross-cutting

## Examples

```
feat(auth): add session timeout for teacher dashboard
fix(db): cast must_change_password to int for PG
test(e2e): replace fixed timeouts with wait_for_selector
ops(railway): expose /version endpoint with RAILWAY_GIT_COMMIT_SHA
chore: bump bcrypt to 4.1.2
```

**Why:** PRIA's git history stays scannable at a glance. `git log --oneline --grep='fix'` becomes useful. Release notes generate themselves.

**How to apply:** When creating ANY commit, the coordinator (or the specialist doing the commit) must follow this format. If the commit doesn't fit one of the types above, the change probably does more than one thing — split it first.
