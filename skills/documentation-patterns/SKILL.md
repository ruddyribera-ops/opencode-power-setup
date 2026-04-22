---
name: documentation-patterns
---

## Documentation Patterns

### JSDoc/TSDoc Comment Standards

Use JSDoc (for JavaScript) or TSDoc (for TypeScript) for all function, class, and interface definitions. Include:

- @param for each parameter with type and description.
- @returns for return value with type and description.
- @example for usage examples.
- @throws for potential errors.

### README Structure Template

`markdown
# Project Name

## Description

Brief overview of the project, its purpose, and what it does.

## Features

- List of key features.

## Getting Started

### Prerequisites

- Any software or tools required.

### Installation

`ash
# Installation commands
`

### Usage

`ash
# How to run the project
`

## Project Structure

Brief explanation of the main directories and files.

## Contributing

Guidelines for contributions.

## License

[License Name](LICENSE)
`

### How to Write a Good Function Description

- **Concise**: Get straight to the point.
- **Purpose-driven**: Explain *what* the function does, not *how*.
- **Side effects**: Mention any side effects or external dependencies.
- **Inputs/Outputs**: Clearly define parameters and return values.

### When to Document vs. When Code Should Be Self-Explanatory

- **Document**: Complex algorithms, public APIs, business logic, anything non-obvious.
- **Self-explanatory**: Simple getters/setters, obvious utility functions, well-named variables/functions.

**Rule of thumb**: If a new developer would need more than a few seconds to understand it, document it.
