---
name: E2E tests against Railway should wait for selectors, not timers (PRIA)
description: Fixed timeouts flake on Railway cold starts; prefer wait_for_selector in Playwright tests.
type: feedback
---

When writing or editing Playwright tests targeting Railway deploys (PRIA's `tests/test_e2e.py`), don't rely on `page.wait_for_timeout(2_000)` / `3_000` for initial page render. Railway cold starts can push first-paint past any fixed budget and produce intermittent failures.

**Why:** `test_app_loads_no_errors` failed once with `No input fields found on login page` on a cold hit, then passed immediately on retry — classic timer-vs-cold-start flake. Replacing the timer with `page.wait_for_selector("[data-testid='stTextInput'] input", timeout=30_000)` made it stable across runs.

**How to apply:**
- For initial page load on Streamlit: use `page.goto(..., wait_until="networkidle", timeout=30_000)` then `page.wait_for_selector("[data-testid='stTextInput'] input", timeout=30_000)`.
- Timers are fine for *post-action* waits (after a click, while Streamlit rerenders) — not the source of flake.
- Any time a new e2e test starts by opening the app, add an explicit selector wait, not a timer.
- Generalizes to any Streamlit-on-Railway project, not just PRIA.
