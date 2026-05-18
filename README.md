# Unentropy Skill

[![skills.sh](https://skills.sh/b/unentropy/skills)](https://skills.sh/unentropy/skills)

An Agent Skill for configuring [Unentropy](https://unentropy.dev) — track code metrics, enforce quality gates, and generate reports without external servers.

## Install

```bash
npx skills add https://github.com/unentropy/skills --skill unentropy
```

## What it does

This skill helps you configure `unentropy.json` to track code health metrics in your CI pipeline. It covers:

- **Metrics** — Built-in and custom metrics (coverage, LOC, bundle size, etc.)
- **Storage** — Artifact, S3-compatible, or local SQLite backends
- **Quality Gates** — Thresholds and modes (soft/hard) for pull request enforcement
- **CI Setup** — GitHub Actions workflows for tracking and gating
- **Validation** — Always validates JSON with `jq` after every config update

## When it triggers

The skill loads automatically when you ask to:

- "configure unentropy"
- "set up unentropy metrics"
- "create unentropy.json"
- "set up quality gates"
- "configure unentropy storage"
- "add unentropy to CI"

## What's inside

| Path | Description |
|------|-------------|
| `SKILL.md` | Core workflows, best practices, and the mandatory `jq` validation rule |
| `references/config-reference.md` | Complete `unentropy.json` schema and validation errors |
| `references/metrics-guide.md` | Built-in metrics, `@collect` shortcuts, per-language examples |
| `references/quality-gates-guide.md` | Threshold modes, PR comments, troubleshooting |
| `references/storage-guide.md` | Artifact, S3, and local storage setup |
| `references/cli-reference.md` | All CLI commands: `init`, `test`, `preview`, `verify` |
| `references/actions-reference.md` | GitHub Actions inputs/outputs |
| `references/getting-started.md` | Full walkthrough from init to first report |
| `examples/unentropy-js.json` | JavaScript/TypeScript config |
| `examples/unentropy-php.json` | PHP config |
| `examples/unentropy-go.json` | Go config |
| `examples/unentropy-python.json` | Python config |
| `scripts/validate-config.sh` | Validate syntax (`jq`) and schema (`unentropy verify`) |

## Learn more

- [Unentropy documentation](https://unentropy.dev)
- [Agent Skills format](https://agentskills.io)
- [skills.sh directory](https://skills.sh)
