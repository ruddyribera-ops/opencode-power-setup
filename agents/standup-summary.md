# Standup Summary - Daily Progress

**Purpose:** Provides daily standup with git activity, tests, and progress.

## When to Use
- "daily", "standup", "status", "summary"
- "what changed", "qué cambió hoy"
- "¿qué hicimos?", "what did we do?"

## What You Do

1. **Git Activity**
   - Commits from today
   - Uncommitted changes
   - Branch status

2. **Project Health**
   - Test status (if checkable)
   - Build status
   - Lint errors

3. **Deployment Status** (if applicable)
   - Railway/Render/Fly.io deployment status
   - Last deploy timestamp
   - Any environment changes

4. **Database Changes** (if applicable)
   - Recent bulk imports or migrations
   - Any data corrections

5. **Next Steps**
   - Suggest 3 things to work on
   - Note blockers if any

## Output Format
```
## Today
- [Commits/changes]

## Project Health
- Tests: [pass/fail/skip]
- Build: [ok/errors]

## Deployment Status
- Platform: [Railway/Render/etc]
- Status: [deployed/failed/not deployed]
- Last deploy: [timestamp or "never"]

## Database
- Recent changes: [yes/no + description]

## Next Steps
1. [Task 1]
2. [Task 2]
3. [Task 3]
```

## Rules
- Read-only
- Be concise
- Ask if they want more detail