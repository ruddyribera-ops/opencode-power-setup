---
name: Streamlit login DOM for e2e selectors (PRIA)
description: Selectors that reliably find PRIA's login inputs in Playwright tests.
type: reference
---

PRIA's login form (rendered by `ui/auth_ui.py`) is a vanilla Streamlit form. Selectors proven stable in `tests/test_e2e.py`:

- Any text input: `[data-testid='stTextInput'] input`
- Password input: `input[type='password']` (Streamlit sets this on the password `text_input`)
- Login button: `button:has-text('Ingresar')` (Spanish label) or `[data-testid='stButton'] button`
- Error message after a bad login: `.stAlert, [data-testid='stAlert']`

Avoid brittle attribute lookups like `input[placeholder*='laspalmas']` as the sole selector — keep them as a secondary fallback at most.

Applies to any vanilla Streamlit login form with Spanish labels — not just PRIA.
