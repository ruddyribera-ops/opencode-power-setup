---
name: Current sprint
description: Active sprint tracking — coordinator auto-updates this after each completed task, push, or session close
type: project
---

# Current Sprint

**Last updated:** 2026-04-21 (Phase 11 COMPLETE — G1-G6 curriculum, BarModel/WordProblem renderers)

## Active Work
- **Math Platform:** Phase 11 COMPLETE — G1-G6 curriculum seed (53 topics, 79 units, 101 lessons, 280 exercises), BarModel + WordProblem frontend renderers, PostgreSQL enum fix for new exercise types, smoke test passed
- **PRIA:** Phase F (optional, deferred) — e2e smoke test stability on Railway cold-start
- **Palma Coin:** deferred (secondary priority)

## Last Completed
- 2026-04-21 — Math Platform Phase 11: G1-G6 curriculum (20 new topics via TOPICS concatenation fix + seed), BarModel + WordProblem React components, `:::bar:` lesson block parsing, PostgreSQL `ALTER TYPE` for `bar_model`/`word_problem` enums, new exercise type rendering in exercise/lesson pages, smoke test API ✅
- 2026-04-21 — Math Platform Phase 10: parent portal (models, parent/teacher/student roles with correct UserRole enum, parent dashboard, link code generation, student link-parent flow), dark mode toggle + CSS variables, i18n infrastructure (translations.ts 4 locales, useTranslation hook), mobile nav, fixed 6 backend bugs: `UserRole.parent` missing from enum, `ParentStudentLink.student_id` FK constraint (0 as sentinel), `str(user.role)` vs `user.role` comparison bugs in parent/student routers, teachers router at `/api` prefix (not `/api/teachers`), missing `PATCH` HTTP method
- 2026-04-20 — Math Platform Phase 9: student dashboard mastery bars, teacher last_active + exercises_completed, lesson video embeds, `exercises_completed` fix (first-time correct only), `content_type` lesson column

## Post-Deploy Checklist (MANDATORY — runs automatically after any push)

After every `git push` to a branch that auto-deploys (Railway PRIAv5, Palma Coin):

1. [ ] Wait 30s for build
2. [ ] `curl https://<app>/version` or `/api/version` → returns HEAD SHA
3. [ ] `railway logs --tail 60` → no `ERROR` / `FATAL` / stack traces
4. [ ] Smoke-test critical path (login with seed creds + one main action)
5. [ ] If any step fails → do NOT declare done; surface exact output to user

## Next Up
- Seed test data via `scripts/seed_test_users.py` after each fresh deploy (needs wiring)
- Add `/health` endpoint if missing — checklist item #2 depends on it

## Blockers
- None

## Sprint Rules for the Coordinator

1. **Update this file** whenever a phase starts, a task completes, or a deploy happens
2. **Keep "Last Completed" to the 3 most recent items** — older entries get dropped
3. **Never declare a push "done"** until the post-deploy checklist is green
4. **Commit message format:** `type(scope): subject` — see `feedback_commit_convention.md`
