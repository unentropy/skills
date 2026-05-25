---
name: unentropy
description: This skill should be used when the user asks to "configure unentropy", "set up unentropy metrics", "create unentropy.json", "set up quality gates", "configure unentropy storage", "add unentropy to CI", "unentropy validation", or when working with the unentropy.json configuration file, GitHub Actions workflows for unentropy, or unentropy metric collection.
version: 0.2.0
---

# Unentropy Skill

Configure unentropy.json to track code metrics in CI pipelines. Unentropy stores metrics locally (SQLite) without external servers or vendor lock-in.

## Core Concepts

Unentropy operates through four layers:

1. **Metrics**: Commands that output numeric or label values on every build
2. **Storage**: Where the SQLite database lives (artifact, S3, or local)
3. **Quality Gates**: Threshold rules that compare PR metrics against main branch baseline
4. **Report**: HTML visualization of metrics with theming and optional sectioned layout

## Workflow: Initialize Project

Start with the scaffolding command:

```bash
bunx unentropy init
```

To override auto-detection, specify the project type:

```bash
bunx unentropy init --type javascript
bunx unentropy init --type php
bunx unentropy init --type go
bunx unentropy init --type python
```

To preview without writing files:

```bash
bunx unentropy init --dry-run
```

## Workflow: Configure Metrics

Define metrics in the `metrics` object of `unentropy.json`. Each key is a unique metric ID (`^[a-z0-9-]+$`, 1-64 characters).

### Use Built-in Templates

Reference built-in metrics with `$ref` to inherit defaults:

```json
{
  "metrics": {
    "coverage": {
      "$ref": "coverage",
      "command": "@collect coverage-lcov ./coverage/lcov.info"
    },
    "loc": {
      "$ref": "loc"
    },
    "bundle": {
      "$ref": "size",
      "command": "@collect size ./dist"
    }
  }
}
```

Available `$ref` templates:

| Template | Purpose | Default Unit |
|----------|---------|--------------|
| `coverage` | Test coverage | `percent` |
| `loc` | Lines of code | `integer` |
| `size` | File/bundle size | `bytes` |
| `build-time` | Build duration | `duration` |
| `test-time` | Test duration | `duration` |
| `dependencies-count` | Dependency count | `integer` |

### Use @collect Shortcuts

Built-in collectors run in-process and are faster than shell commands:

- `@collect loc <path> [--language <lang>]` — Count lines of code via SCC
- `@collect size <path> [<path2> ...]` — Calculate total file size (supports globs)
- `@collect coverage-lcov <path> [--type line|branch|function]` — Extract LCOV coverage
- `@collect coverage-clover <paths...> [--type line|branch|function]` — Extract and merge Clover XML coverage
- `@collect coverage-cobertura <paths...> [--type line|branch|function]` — Extract and merge Cobertura XML

### Define Custom Metrics

For project-specific needs, define metrics without `$ref`:

```json
{
  "api-endpoints": {
    "type": "numeric",
    "name": "API Endpoints",
    "description": "Number of exported API functions",
    "command": "grep -r 'export.*function' src/api | wc -l",
    "unit": "integer"
  }
}
```

Required fields for custom metrics: `type` (`numeric` or `label`), `command`.

### Unit Types

Choose units for correct formatting:

| Unit | Example | Use Case |
|------|---------|----------|
| `percent` | `87.5%` | Coverage, ratios |
| `integer` | `1,234` | Counts, LOC |
| `bytes` | `1.5 MB` | File sizes, bundles |
| `duration` | `1m 30s` | Build/test time |
| `decimal` | `3.14` | Generic numbers |

## Workflow: Configure Storage

Set where the SQLite database persists across runs.

### Artifact Storage (Default)

No configuration needed, or explicitly:

```json
{
  "storage": {
    "type": "sqlite-artifact",
    "artifactName": "unentropy-metrics",
    "branch": "main"
  }
}
```

- Retention: 90 days (GitHub default)
- Best for: Quick setup, single repository

### S3-Compatible Storage

For long-term history or multi-repo tracking:

```json
{
  "storage": {
    "type": "sqlite-s3"
  }
}
```

Provide credentials in the workflow (never in the config file):

```yaml
- uses: unentropy/track-metrics-action@v1
  with:
    storage-type: sqlite-s3
    s3-endpoint: ${{ secrets.S3_ENDPOINT }}
    s3-access-key-id: ${{ secrets.S3_ACCESS_KEY_ID }}
    s3-secret-access-key: ${{ secrets.S3_SECRET_ACCESS_KEY }}
    s3-bucket: my-metrics-bucket
    s3-region: us-east-1
```

### Local Storage

For development only:

```json
{
  "storage": {
    "type": "sqlite-local"
  }
}
```

Database stored at `./unentropy.db`.

## Workflow: Configure Quality Gates

Set thresholds in the `qualityGate` object to enforce metric standards on pull requests.

### Quality Gate Mode

```json
{
  "qualityGate": {
    "mode": "soft",
    "thresholds": [...]
  }
}
```

Modes:

- `off` — Disabled (no evaluation)
- `soft` — Evaluates and posts PR comments, never fails build (default, recommended for tuning)
- `hard` — Fails build when thresholds are violated

### Threshold Types

```json
{
  "thresholds": [
    {
      "metric": "coverage",
      "mode": "min",
      "target": 80
    },
    {
      "metric": "bundle",
      "mode": "max",
      "target": 500000
    },
    {
      "metric": "loc",
      "mode": "no-regression"
    },
      {
        "metric": "bundle",
        "mode": "delta-max-drop",
        "maxDropPercent": 5
      }
  ]
}
```

Threshold modes:

- `min` — Metric must not drop below target (e.g., coverage >= 80%)
- `max` — Metric must not exceed target (e.g., bundle <= 500KB)
- `no-regression` — Metric must not decrease from baseline (no target needed)
- `delta-max-drop` — Metric can increase, but not more than `maxDropPercent` percentage (e.g., 5% max increase)

The quality gate passes only if all thresholds pass.

## Workflow: Configure Report Appearance

Set the visual theme and color mode for generated HTML reports.

### Built-in Themes

```json
{
  "report": {
    "theme": "flux",
    "mode": "auto"
  }
}
```

Available themes: `lattice` (default), `flux`, `halftone`, `specimen`.

### Custom Palette

Override individual colors to match branding:

```json
{
  "report": {
    "theme": {
      "dark": { "--accent": "#ff00ff" },
      "light": { "--accent": "#aa00aa" }
    }
  }
}
```

Omitted variables fall back to Lattice defaults. Values must be 7-character hex colors.

### Mode

| Mode | Behavior |
|------|----------|
| `auto` | Respects system `prefers-color-scheme` (default) |
| `dark` | Always uses the dark variant |
| `light` | Always uses the light variant |

## Workflow: Configure Report Layout

Organize metrics into named sections and plot related metrics together.

### Sections

Group metrics under headers:

```json
{
  "report": {
    "sections": [
      {
        "name": "Code Size",
        "description": "Source and build artifact metrics",
        "charts": [
          { "metrics": "typescript-loc" },
          { "metrics": "bundle" }
        ]
      }
    ]
  }
}
```

### Multi-Metric Charts

Compare related metrics on one chart:

```json
{
  "report": {
    "sections": [
      {
        "name": "Refactoring",
        "charts": [
          {
            "metrics": ["modern-classes", "legacy-classes"],
            "title": "Modern vs Legacy"
          }
        ]
      }
    ]
  }
}
```

Metrics with different units automatically receive dual Y-axes.

### Custom Chart Titles

Override auto-derived titles:

```json
{ "metrics": "bundle-size", "title": "Production Bundle Size" }
```

Omitting `report` entirely preserves the original flat layout (one chart per metric).

## Critical Rule: Validate JSON After Every Update

**Always validate `unentropy.json` syntax immediately after creating or modifying the file.**

If `jq` is available on the system, run:

```bash
jq . unentropy.json > /dev/null
```

If `jq` is not available, use Python:

```bash
python3 -c "import json; json.load(open('unentropy.json'))"
```

After syntax validation, run the full schema check:

```bash
bunx unentropy verify
```

If the configuration is invalid, fix errors before proceeding. Never commit an unvalidated `unentropy.json`.

## Workflow: Validate and Test Locally

Verify the complete setup before pushing to CI:

```bash
# Validate JSON syntax (mandatory first step)
jq . unentropy.json > /dev/null

# Validate schema
bunx unentropy verify

# Test metric collection (runs commands, does not persist data)
bunx unentropy test

# Preview the HTML report
bunx unentropy preview
```

Increase timeout for slow metrics:

```bash
bunx unentropy test --timeout 60000
```

## Workflow: Set Up CI Workflows

### Main Branch Tracking

Create `.github/workflows/metrics.yml`:

```yaml
name: Track Metrics
on:
  push:
    branches: [main]

permissions:
  contents: read
  actions: read
  pages: write
  id-token: write

jobs:
  track-metrics:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install dependencies
        run: bun install
      - name: Run tests with coverage
        run: bun test --coverage --coverage-reporter=lcov
      - name: Track metrics
        uses: unentropy/track-metrics-action@v1
      - uses: actions/upload-pages-artifact@v3
        with:
          path: unentropy-report
      - name: Deploy to GitHub Pages
        uses: actions/deploy-pages@v4
        id: report_deployment
    environment:
      name: github-pages
      url: ${{ steps.report_deployment.outputs.page_url }}
```

### Pull Request Quality Gate

Create `.github/workflows/quality-gate.yml`:

```yaml
name: Quality Gate
on:
  pull_request:

permissions:
  contents: read
  actions: read
  pull-requests: write

jobs:
  quality-gate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install dependencies
        run: bun install
      - name: Run tests with coverage
        run: bun test --coverage --coverage-reporter=lcov
      - name: Quality Gate Check
        uses: unentropy/quality-gate-action@v1
```

> **Note**: The `pull-requests: write` permission is required to post comments on PRs.

## Best Practices

- Start quality gates in `soft` mode, observe PR comments for several weeks, then switch to `hard`
- Use `no-regression` mode when unsure of the right absolute threshold
- Use `delta-max-drop` for metrics that naturally grow (LOC, bundle size)
- Focus gating on key metrics: coverage, bundle size, build time
- Run `jq . unentropy.json > /dev/null` after every manual edit
- Keep metric IDs consistent once referenced in quality gates

## Additional Resources

### Reference Files

For detailed documentation, consult:

- **`references/config-reference.md`** — Complete `unentropy.json` schema, all fields, validation rules, and error examples
- **`references/metrics-guide.md`** — Built-in and custom metrics, `@collect` commands, unit types, per-language examples
- **`references/quality-gates-guide.md`** — Threshold modes, PR comments, troubleshooting missing baselines and strict thresholds
- **`references/storage-guide.md`** — Artifact, S3, and local storage setup, provider examples (AWS, R2, DigitalOcean), data migration
- **`references/cli-reference.md`** — All CLI commands: `init`, `test`, `preview`, `verify`, global options, and common workflows
- **`references/actions-reference.md`** — GitHub Actions inputs/outputs for `track-metrics` and `quality-gate`
- **`references/report-guide.md`** — Report theming, layout customization with sections and multi-metric charts, validation
- **`references/getting-started.md`** — Full getting-started walkthrough including project type detection and workflow setup

### Example Configurations

Working `unentropy.json` files for different project types:

- **`examples/unentropy-js.json`** — JavaScript/TypeScript (coverage, bundle size, LOC)
- **`examples/unentropy-php.json`** — PHP (Clover coverage, LOC)
- **`examples/unentropy-go.json`** — Go (LOC, binary size)
- **`examples/unentropy-python.json`** — Python (coverage, LOC, dependency count)

### Scripts

- **`scripts/validate-config.sh`** — Validate `unentropy.json` syntax with `jq` and schema with `bunx unentropy verify`
