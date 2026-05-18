# CLI Reference

Complete reference for the Unentropy command-line interface.

## `init`

Generate configuration file with sensible defaults for your project type.

### Usage

```bash
bunx unentropy init [options]
```

### Behavior

1. Detects project type from marker files
2. Creates `unentropy.json` with appropriate metrics
3. Displays GitHub Actions workflow examples
4. Suggests next steps

### Options

#### `--type`, `-t`

Force specific project type.

```bash
bunx unentropy init --type php
```

**Values**: `javascript`, `php`, `go`, `python`

Use this when:

- Auto-detection picks the wrong type
- You have a multi-language project
- Marker files are in subdirectories

#### `--storage`, `-s`

Select storage backend.

```bash
bunx unentropy init --storage s3
```

**Values**: `artifact` (default), `s3`, `local`

- `artifact`: GitHub Actions artifacts (90-day retention)
- `s3`: S3-compatible storage (unlimited retention)
- `local`: Local file (development only)

#### `--force`, `-f`

Overwrite existing configuration.

```bash
bunx unentropy init --force
```

**Warning**: This replaces your existing `unentropy.json`. Back up custom changes first.

#### `--dry-run`

Preview configuration without writing files.

```bash
bunx unentropy init --dry-run
```

Displays what would be created without modifying anything.

### Project Type Detection

Unentropy detects your project type from these files:

| Type | Detection Files |
|------|-----------------|
| **JavaScript** | `package.json`, `tsconfig.json`, `bun.lockb`, `pnpm-lock.yaml`, `yarn.lock`, `package-lock.json` |
| **PHP** | `composer.json`, `composer.lock` |
| **Go** | `go.mod`, `go.sum` |
| **Python** | `pyproject.toml`, `setup.py`, `requirements.txt`, `Pipfile`, `setup.cfg` |

Priority order when multiple types detected: JavaScript > PHP > Go > Python

### Example Output

```
Detected project type: javascript (found: package.json, tsconfig.json)

✓ Created unentropy.json with 3 metrics:
  - lines-of-code (Lines of Code)
  - test-coverage (Test Coverage)
  - bundle (Bundle Size)

Next steps:
  1. Run 'bunx unentropy test' to verify metric collection
  2. Add the workflows below to your repository

TRACK METRICS (main branch):
...
```

### Exit Codes

- **0**: Success
- **1**: Configuration already exists (use `--force` to overwrite)
- **1**: Project type cannot be detected (use `--type` to specify)
- **1**: Invalid `--type` value

## `test`

Validate configuration and run metric collection locally without persisting data.

### Usage

```bash
bunx unentropy test [options]
```

### Behavior

1. Validates `unentropy.json` schema
2. Runs metric collection commands sequentially
3. Displays results with values, units, and timing
4. Exits with appropriate code based on results

### Options

#### `--config`, `-c`

Specify alternate configuration file.

```bash
bunx unentropy test --config custom-config.json
```

**Default**: `unentropy.json`

#### `--timeout`

Override per-metric timeout in milliseconds.

```bash
bunx unentropy test --timeout 60000
```

**Default**: 30000ms (30 seconds)

Per-metric timeouts in config take precedence when not specified.

### Example Output

Success:

```
✓ Config schema valid

Collecting metrics:

  ✓ lines-of-code (integer)    4,521         0.8s
  ✓ test-coverage (percent)    87.3%         2.1s
  ✓ bundle (bytes)             240 KB        0.2s

All 3 metrics collected successfully.
```

Failure:

```
✓ Config schema valid

Collecting metrics:

  ✓ lines-of-code (integer)    4,521         0.8s
  ✗ test-coverage (percent)    Failed        2.1s
    Error: coverage/lcov.info not found
  ✓ bundle (bytes)             240 KB        0.2s

2 of 3 metrics collected successfully.
```

### Exit Codes

- **0**: All metrics collected successfully
- **1**: Configuration validation failed
- **2**: One or more metrics failed to collect

## `preview`

Generate HTML report with empty/placeholder data to preview report structure.

### Usage

```bash
bunx unentropy preview [options]
```

### Behavior

1. Validates `unentropy.json` schema
2. Generates HTML report with all configured metrics
3. Shows metrics with no data (empty state)
4. Opens report in default browser

### Options

#### `--config`, `-c`

Specify alternate configuration file.

```bash
bunx unentropy preview --config custom-config.json
```

**Default**: `unentropy.json`

#### `--output`, `-o`

Specify output directory.

```bash
bunx unentropy preview --output ./reports/preview
```

**Default**: `unentropy-preview`

Creates directory if it doesn't exist. Report is written to `<output>/index.html`.

#### `--no-open`

Don't open browser automatically.

```bash
bunx unentropy preview --no-open
```

Report is generated but browser doesn't launch. Useful in headless/CI environments.

#### `--force`, `-f`

Overwrite existing non-empty output directory.

```bash
bunx unentropy preview --force
```

**Warning**: This deletes existing content in the output directory.

### Exit Codes

- **0**: Report generated successfully
- **1**: Configuration validation failed
- **1**: Output directory exists and is not empty (use `--force`)
- **1**: Report generation failed
- **1**: Configuration file not found

## `verify`

Validate configuration file schema and structure.

### Usage

```bash
bunx unentropy verify [config]
```

### Arguments

- **config** (optional): Path to configuration file. Defaults to `unentropy.json`.

### Behavior

Validates:

- JSON syntax
- Required fields present
- Valid metric definitions
- Storage configuration correct
- Threshold syntax valid

### Example Output

Success:

```
✓ Configuration is valid
```

Failure:

```
✗ Configuration validation failed:

Error: Invalid storage type "invalid-type"
  Expected: sqlite-local, sqlite-artifact, sqlite-s3
  Location: storage.type

Error: Missing required field "command" for metric "coverage"
  Location: metrics.coverage
```

### Exit Codes

- **0**: Configuration is valid
- **1**: Validation failed

## Global Options

These options work with all commands:

### `--help`, `-h`

Show help for a command.

```bash
bunx unentropy --help
bunx unentropy init --help
bunx unentropy test --help
```

### `--version`

Show Unentropy version.

```bash
bunx unentropy --version
```

## Common Workflows

### First-Time Setup

```bash
# Generate configuration
bunx unentropy init

# Verify it works
bunx unentropy test

# Preview report structure
bunx unentropy preview

# Add workflows to repository (copy from init output)
# Commit and push
```

### After Changing Configuration

```bash
# Validate changes
bunx unentropy verify

# Test metric collection
bunx unentropy test

# Preview report
bunx unentropy preview --force
```

### Debugging Metric Collection

```bash
# Test metric collection
bunx unentropy test

# Increase timeout for slow metrics
bunx unentropy test --timeout 60000
```

### Multi-Project Setup

```bash
# Project 1 (JavaScript)
cd project1
bunx unentropy init --type javascript

# Project 2 (PHP)
cd ../project2
bunx unentropy init --type php
```
