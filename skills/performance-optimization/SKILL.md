---
name: performance-optimization
--- 

## Performance Optimization Patterns and Best Practices

### Bundle Size Basics

- **Analyze Bundle**: Use tools like Webpack Bundle Analyzer to identify large modules.
- **Tree Shaking**: Remove unused code (dead code elimination) during bundling.
- **Code Splitting**: Break down your bundle into smaller chunks that can be loaded on demand (e.g., route-based splitting).
- **Minification/Uglification**: Reduce file size by removing whitespace, comments, and shortening variable names.

### Lazy Loading

- **Components**: Dynamically import components only when they are needed (e.g., React.lazy and Suspense).
- **Routes**: Lazy load entire routes to reduce initial page load time.
- **Images/Videos**: Use loading="lazy" attribute or Intersection Observer API to load media only when it enters the viewport.

### Avoiding Re-renders in React

- **React.memo**: Memoize functional components to prevent re-renders if props haven't changed.
- **useMemo**: Memoize expensive calculations.
- **useCallback**: Memoize functions to prevent unnecessary re-creation on re-renders.
- **Context Optimization**: Split large contexts into smaller, more focused ones.
- **Key Prop**: Use stable and unique key props for lists to optimize reconciliation.

### Database Query Efficiency

- **Indexing**: Add indexes to frequently queried columns.
- **Avoid N+1 Queries**: Fetch related data in a single query (e.g., JOINs, select_related/prefetch_related in Django).
- **Pagination**: Limit the number of results returned from a query.
- **Caching**: Cache frequently accessed query results.
- **Optimize WHERE clauses**: Ensure conditions use indexed columns.

### When to Cache and When Not To

- **When to Cache**: Data that changes infrequently, expensive computations, frequently accessed data.
- **When Not To**: Highly dynamic data, sensitive user-specific data (unless properly isolated), data that is rarely accessed.

**Types of Caching**: Browser cache, CDN cache, server-side cache (Redis, Memcached), database cache.
