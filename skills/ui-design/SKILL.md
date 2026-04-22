---
name: ui-design
description: UI/UX design patterns — typography, spacing, color, accessibility, and framework-specific design systems (Tailwind, shadcn/ui, Streamlit theming)
---

# UI Design Patterns

## TL;DR — Top 5 Rules (Read First, Always Apply)

1. **All spacing must be a multiple of 4 or 8.** Use Tailwind defaults (`p-1` through `p-8`) — never custom pixels.
2. **Max 6 text sizes, max 2 fonts, max 1 alignment per section.** Hierarchy comes from size + weight + whitespace, not color.
3. **Semantic color tokens, never raw hex.** `--color-primary` not `#3b82f6`. Dark mode becomes a 2-line change.
4. **Body text contrast ≥ 4.5:1 (WCAG AA).** Light-gray on white almost always fails. Use `#6b7280` minimum on white.
5. **Design empty / loading / error states FIRST.** They're 80% of real UX. Skeleton loaders > spinners. Specific error messages > "Error occurred".

**Framework shortcuts:**
- **React/TS** → install `shadcn/ui` (`npx shadcn@latest init`). You own the code, it's accessible, Tailwind-based.
- **Streamlit** → set theme in `.streamlit/config.toml` once. Use `st.container(border=True)`, `st.columns()`, `st.tabs()`, `st.status()`. Never inject CSS per page.

---

Good-looking apps follow systems, not inspiration. Pick a design system, stick to tokens, and don't reinvent spacing.

## The 4/8 Spacing Grid

Every margin, padding, gap, and size should be a multiple of 4px (or 8px for layout-scale spacing). Breaks visual chaos:

```
Good (scales): 4, 8, 12, 16, 24, 32, 48, 64
Bad (random): 5, 13, 17, 22, 30, 45, 50
```

**Tailwind maps directly:** `p-1` = 4px, `p-2` = 8px, `p-4` = 16px, `p-6` = 24px, `p-8` = 32px. Use these, never custom pixels.

## Typography Scale

A readable type scale has 4–6 sizes total. Pick once, reuse everywhere:

| Role | Size (px) | Tailwind | Weight |
|------|-----------|----------|--------|
| Body | 16 | `text-base` | 400 |
| Small | 14 | `text-sm` | 400 |
| Large body | 18 | `text-lg` | 400 |
| H3 / subsection | 20 | `text-xl` | 600 |
| H2 / section | 24 | `text-2xl` | 600 |
| H1 / page title | 30–36 | `text-3xl`–`text-4xl` | 700 |

**Line height:** body text = 1.5–1.6. Headings = 1.2–1.3. Never a single `leading` value for everything.

**Font choice:** pick ONE body font and ONE heading font (they can be the same). System font stacks (`ui-sans-serif`) are fast and safe. Never mix 3+ fonts.

## Semantic Color Tokens (Not Raw Hex)

Name colors by *role*, not by *hue*. Role names survive redesigns; hex values don't.

```css
/* ❌ BAD — raw colors scattered */
.button { background: #3b82f6; color: white; }
.alert-error { background: #ef4444; }

/* ✅ GOOD — semantic tokens */
:root {
  --color-bg: #ffffff;
  --color-surface: #f9fafb;
  --color-text: #111827;
  --color-text-muted: #6b7280;
  --color-border: #e5e7eb;
  --color-primary: #3b82f6;
  --color-primary-hover: #2563eb;
  --color-success: #10b981;
  --color-warning: #f59e0b;
  --color-danger: #ef4444;
}
.button { background: var(--color-primary); color: white; }
.button:hover { background: var(--color-primary-hover); }
```

Dark mode becomes a 2-line change — override the tokens, everything else cascades:

```css
[data-theme="dark"] {
  --color-bg: #0f172a;
  --color-surface: #1e293b;
  --color-text: #f1f5f9;
  /* ... */
}
```

## Contrast Ratios (Accessibility — Non-Negotiable)

WCAG AA minimums:
- Body text: **4.5:1** contrast vs background
- Large text (18px+ bold or 24px+): **3:1**
- UI controls (buttons, inputs): **3:1** against adjacent colors

**Check tools:** https://webaim.org/resources/contrastchecker/ or browser devtools → Inspect → Contrast section.

**Most common violation:** light-gray text on white (`#ccc` on `#fff` = 1.6:1 — FAILS). Bump to `#6b7280` min.

## Component Library (Don't Build Buttons From Scratch)

For **React/TypeScript** projects → use **shadcn/ui** (copy-paste components, you own the code, Tailwind-based, accessible by default):

```bash
npx shadcn@latest init
npx shadcn@latest add button dialog input select
```

Why: components are tested, accessible (ARIA built-in), dark-mode aware, and *your code* — no runtime dependency. Alternative: Radix UI primitives (what shadcn wraps).

For **Streamlit** → use theming + component libraries:

```toml
# .streamlit/config.toml
[theme]
primaryColor = "#3b82f6"
backgroundColor = "#ffffff"
secondaryBackgroundColor = "#f9fafb"
textColor = "#111827"
font = "sans serif"
```

Streamlit-specific UI polish:
- `st.columns()` for layout — don't just stack `st.write()` calls
- `st.container(border=True)` for visual grouping
- `st.tabs()` for grouping related controls instead of long forms
- `st.status()` and `st.spinner()` for async feedback
- Custom CSS via `st.markdown("<style>...", unsafe_allow_html=True)` only as last resort — prefer config.toml

## Layout Principles

### Max-width on content
```css
.container { max-width: 72rem; margin: 0 auto; padding: 0 1.5rem; }
```
Text line length should cap at ~65–75 characters — readers fatigue on full-width paragraphs.

### Hierarchy via size + weight + spacing (not color)
```
H1 (32px, bold)
  space (24px)
  H2 (24px, semibold)
    space (16px)
    Body (16px, normal)
```
Color is the last tool for hierarchy — start with size, weight, and whitespace.

### Consistent alignment
- Pick one alignment per section (left is default and safest)
- Centered text = headlines + short phrases only, never paragraphs
- Form labels: left-align above the input, not to its left (mobile-friendly)

## Empty States, Loading, Errors

These are 80% of user experience. Never skip them:

- **Empty:** "No posts yet. Create your first →" (actionable, not "No data")
- **Loading:** skeleton loaders (gray boxes shaped like content) > spinners for perceived speed
- **Error:** specific + recoverable ("Couldn't save — check your connection and [try again]") > generic ("Error occurred")

## Anti-Patterns

### ❌ Custom everything
Users have deep expectations from years of using apps. A custom dropdown that doesn't support keyboard nav, a button that doesn't show focus state, a form that re-validates on every keystroke — these all feel wrong. Use battle-tested primitives.

### ❌ Color as the only signal
```html
<!-- BAD — colorblind users see nothing -->
<span style="color: red">Error</span>
<span style="color: green">Success</span>

<!-- GOOD — icon + color + text -->
<span>❌ Error: ...</span>
<span>✓ Success: ...</span>
```

### ❌ Hover as the only way to discover
Mobile has no hover. Any important action revealed only on hover is broken on touch devices. Always have a non-hover affordance (visible icon, permanent button).

### ❌ Mixing font-sizes inside the same paragraph
Jarring. Use weight (`font-semibold`) or italic for emphasis within text, not size.

### ❌ Too many typefaces
Max 2 fonts. Every extra font is another HTTP request, another cognitive style to track, and rarely looks better.

## Quick Audit Checklist (For Any UI)

- [ ] All spacing is a multiple of 4 or 8
- [ ] ≤ 6 text sizes total in the design
- [ ] Colors referenced by semantic tokens, not raw hex
- [ ] Body text contrast ≥ 4.5:1
- [ ] Max-width on content (content readable, not stretched across 4K screens)
- [ ] Loading, empty, and error states all designed (not afterthoughts)
- [ ] Focus states visible on every interactive element (tab through the UI and watch)
- [ ] Works at 320px wide (smallest modern phone)
- [ ] No information conveyed by color alone
- [ ] Dark mode (if offered) uses the same tokens, overridden at the `:root`

## Framework-Specific Notes

### Tailwind CSS
- Stick to default scale (`text-sm`, `p-4`) — don't write custom values unless the default doesn't exist
- Use `@apply` sparingly in CSS files — prefer utility classes in components
- Dark mode: `darkMode: 'class'` in `tailwind.config.js`, toggle via `<html class="dark">`

### React + shadcn/ui
- Install only components you use — each is copied into your repo, no runtime bloat
- Customize via Tailwind classes, not component overrides
- Use `lucide-react` for icons (shadcn's default) — tree-shakable, consistent style

### Streamlit
- Lean on `st.container()`, `st.columns()`, `st.tabs()` — they're well-designed defaults
- Set theme in `config.toml` once — don't inject CSS per page
- For forms, wrap in `st.form()` to batch submit (avoids re-running on every keystroke)
- Use `st.cache_data` / `st.cache_resource` to avoid re-rendering expensive UI

## When to Call a Real Designer

Skills take you to "clean, consistent, accessible." They don't take you to "memorable, branded, delightful."

- For internal tools, dashboards, and early-stage products → these patterns are enough
- For consumer-facing products with brand identity → hire a designer after MVP, once you know what the product actually is
