# AGENTS.md Examples

Reference examples for different project types.

## Example 1: Static Site (Astro/Starlight)

```markdown
# AGENTS.md

## What This Is

Documentation website built with Astro and Starlight. Static site generation only.

## Tech Stack

- **Runtime:** Bun (not npm/node)
- **Framework:** Astro 5.6+ with Starlight theme
- **Language:** TypeScript (strict mode)

## Quick Commands

```bash
bun dev        # Dev server at localhost:4321
bun build      # Build to ./dist/
bun preview    # Preview production build
bun astro check # Type check
```

## Project Map

```
src/
  content/docs/  # Markdown docs (auto-routed by Starlight)
  pages/         # Root pages (index.astro = homepage)
  layouts/       # Reusable Astro layouts
  assets/        # Images, SVGs (import to embed)
  styles/        # Global CSS
```

## Key Conventions

- Components: `PascalCase.astro`
- Pages/routes: `kebab-case.md`

## Verification

Run `bun build` before considering work complete. No test framework configured.
```

**Line count: 32**

---

## Example 2: Node.js API

```markdown
# AGENTS.md

## What This Is

REST API for user authentication and session management.

## Tech Stack

- **Runtime:** Node.js 20+
- **Framework:** Express with TypeScript
- **Database:** PostgreSQL via Prisma

## Quick Commands

```bash
npm run dev      # Dev server with hot reload
npm run build    # Compile TypeScript
npm test         # Run Jest tests
npm run db:push  # Push schema changes
```

## Project Map

```
src/
  routes/      # Express route handlers
  middleware/  # Auth, validation, error handling
  services/    # Business logic
  prisma/      # Schema and migrations
```

## Key Conventions

- All routes require authentication except `/auth/*`
- Use `services/` for business logic, not route handlers

## Verification

Run `npm test` for unit tests. Run `npm run build` to verify types.
```

**Line count: 34**

---

## Example 3: Monorepo

```markdown
# AGENTS.md

## What This Is

Fullstack app: React frontend + Node API + shared packages.

## Tech Stack

- **Package Manager:** pnpm with workspaces
- **Frontend:** React 18 + Vite
- **Backend:** Node.js + Fastify
- **Shared:** TypeScript types and utilities

## Quick Commands

```bash
pnpm dev         # Start all packages
pnpm build       # Build all packages
pnpm test        # Run all tests
pnpm lint        # Lint and format
```

## Project Map

```
packages/
  web/         # React frontend (localhost:3000)
  api/         # Fastify backend (localhost:4000)
  shared/      # Shared types and utilities
  config/      # Shared ESLint/TS configs
```

## Key Conventions

- Import from `@app/shared` for shared types
- API changes require matching frontend updates

## Verification

Run `pnpm build` from root. All packages must build without errors.
```

**Line count: 36**

---

## Example 4: Python ML Project

```markdown
# AGENTS.md

## What This Is

ML pipeline for text classification with training and inference.

## Tech Stack

- **Runtime:** Python 3.11+ with uv
- **ML:** PyTorch, Transformers
- **API:** FastAPI for inference endpoint

## Quick Commands

```bash
uv run train     # Train model
uv run evaluate  # Evaluate on test set
uv run serve     # Start inference API
uv run pytest    # Run tests
```

## Project Map

```
src/
  models/      # Model architectures
  data/        # Data loading and processing
  training/    # Training loops and configs
  api/         # FastAPI inference endpoint
configs/       # Hyperparameter YAML files
```

## Key Conventions

- Config files in `configs/` control all hyperparameters
- Models saved to `outputs/` with timestamp

## Verification

Run `uv run pytest`. For model changes, run `uv run evaluate`.
```

**Line count: 35**

---

## Key Observations

1. **All examples are 32-36 lines** - well under the 60-line target
2. **No style guidelines** - agents learn from code
3. **Clear verification** - every example specifies how to confirm success
4. **Minimal conventions** - only non-obvious, universal rules
5. **Accurate commands** - correct package manager and scripts
