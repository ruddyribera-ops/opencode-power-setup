---
name: testing-standards
description: Test writing standards, naming conventions, and coverage guidance
---

# Testing Standards

## Test Structure (AAA Pattern)
```
Arrange — set up test data and dependencies
Act     — call the function/method being tested
Assert  — verify the expected outcome
```

## Naming Convention
`describe("ComponentName", () => {`
`  it("should [expected behavior] when [condition]", () => {`

## What to Test
- Happy path: normal expected input/output
- Edge cases: empty, null, zero, maximum values
- Error cases: invalid input, network failure, missing data
- State changes: before/after mutations

## What NOT to Test
- Implementation details (test behavior, not code)
- Third-party library internals
- Trivial getters/setters

## Coverage Targets
- Business logic: 90%+
- Utility functions: 80%+
- UI components: 60%+ (focus on interactions)
- Don't chase 100% — test what matters

## Test File Location
- Co-located: `src/auth/auth.test.ts` next to `src/auth/auth.ts`
- Or centralized: `tests/auth/auth.test.ts`
- Pick one convention per project and stick to it

## Running Tests
```bash
npm test          # JavaScript/TypeScript
pytest          # Python
go test ./...    # Go
cargo test       # Rust
```