---
name: js-modern-patterns
description: Modern ES2022+ and TypeScript patterns for cleaner, more efficient code
---

# JavaScript/TypeScript Modern Patterns

## Nullish Coalescing & Optional Chaining

```typescript
// Nullish coalescing — use default only for null/undefined
const name = user.name ?? 'Anonymous';
const count = items.length ?? 0;

// Optional chaining — safe property access
const street = user?.address?.street ?? 'Unknown';
const firstItem = array?.[0]?.name;

// Combine for deep safe access
const city = user?.address?.city ?? 'Unknown';
```

## TypeScript: Prefer `interface` over `type` for Objects

```typescript
// Better: interface allows declaration merging, extends
interface User {
  id: string;
  name: string;
  email: string;
}

interface Admin extends User {
  permissions: string[];
}

// Avoid: type is inflexible
type UserType = {
  id: string;
  name: string;
};
```

## TypeScript: Discriminated Unions for State

```typescript
// Good: exhaustive state handling
type RequestState<T> =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'error'; error: Error };

function handleState<T>(state: RequestState<T>) {
  switch (state.status) {
    case 'idle': return 'Ready';
    case 'loading': return 'Loading...';
    case 'success': return `Data: ${state.data}`;
    case 'error': return `Error: ${state.error.message}`;
  }
}
```

## TypeScript: `satisfies` Operator (TypeScript 4.9+)

```typescript
// Good: validates shape WITHOUT widening type
const config = {
  port: 3000,
  host: 'localhost',
  timeout: 5000,
} satisfies Config;

// config is typed as { port: number; host: string; timeout: number }
// NOT widened to Record<string, number | string>
```

## Async Patterns

```typescript
// Sequential promise execution (when order matters)
const results = await Promise.all([
  fetch('/api/users'),
  fetch('/api/posts'),
  fetch('/api/comments'),
]);

// Parallel with error handling
const [users, posts] = await Promise.allSettled([
  fetch('/api/users').then(r => r.json()),
  fetch('/api/posts').then(r => r.json()),
]).then(([users, posts]) => [
  users.status === 'fulfilled' ? users.value : [],
  posts.status === 'fulfilled' ? posts.value : [],
]);

// Timeout wrapper
async function withTimeout<T>(promise: Promise<T>, ms: number): Promise<T> {
  const timeout = new Promise((_, reject) =>
    setTimeout(() => reject(new Error('Timeout')), ms)
  );
  return Promise.race([promise, timeout]);
}
```

## Array Methods: `reduce` for Transformations

```typescript
// Good: transform array to object/map
const usersById = users.reduce((acc, user) => {
  acc[user.id] = user;
  return acc;
}, {} as Record<string, User>);

// Group by property
const usersByRole = users.reduce((acc, user) => {
  (acc[user.role] ??= []).push(user);
  return acc;
}, {} as Record<string, User[]>);
```

## Immutability Patterns

```typescript
// Update object without mutation
const updatedUser = { ...user, name: 'New Name' };

// Nested update (shallow copy)
const updatedState = {
  ...state,
  user: { ...state.user, name: 'New Name' },
};

// Array: replace item by index
const updatedItems = items.map((item, i) =>
  i === index ? { ...item, ...updates } : item
);

// Array: remove without mutation
const withoutItem = items.filter((_, i) => i !== index);
```

## Utility Types

```typescript
// Common utility types
type Partial<T> = { [P in keyof T]?: T[P] };
type Required<T> = { [P in keyof T]-?: T[P] };
type Pick<T, K extends keyof T> = { [P in K]: T[P] };
type Omit<T, K extends keyof T> = { [P in Exclude<keyof T, K>]: T[P] };

// Practical examples
type CreateUserDto = Pick<User, 'name' | 'email'>;
type UpdateUserDto = Partial<Pick<User, 'name' | 'email'>>;
type UserPreview = Omit<User, 'password' | 'salt'>;
```

## Error Handling

```typescript
// Good: typed error handling
async function fetchUser(id: string): Promise<User> {
  try {
    const response = await fetch(`/api/users/${id}`);
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }
    return response.json();
  } catch (error) {
    if (error instanceof Error) {
      throw error; // Re-throw known errors
    }
    throw new Error('Unknown error occurred');
  }
}

// Good: Result type pattern (like Rust)
type Result<T, E = Error> =
  | { success: true; data: T }
  | { success: false; error: E };

function divide(a: number, b: number): Result<number, string> {
  if (b === 0) return { success: false, error: 'Division by zero' };
  return { success: true, data: a / b };
}
```

## Modules: Named Exports Preferred

```typescript
// Better: named exports (tree-shakeable)
export function helper() { ... }
export const constant = 42;

// Avoid: default exports (hard to refactor)
export default function main() { ... }

// Import consistency
import { helper, constant } from './utils';
```

## React Patterns

```typescript
// Good: stable callback reference
const handleClick = useCallback(() => {
  doSomething(value);
}, [value]);

// Good: memoized computation
const expensiveValue = useMemo(() =>
  items.reduce((sum, item) => sum + item.price, 0),
  [items]
);

// Good: controlled input
const [value, setValue] = useState('');
<input value={value} onChange={e => setValue(e.target.value)} />
```
