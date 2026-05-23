# Metrics Guide

Track built-in and custom metrics to monitor your codebase health.

## Built-in Metrics

Unentropy includes pre-configured metric templates that work out of the box. Reference them with minimal configuration using the `$ref` property:

```json
{
  "metrics": {
    "loc": {
      "$ref": "loc"
    },
    "coverage": {
      "$ref": "coverage",
      "command": "@collect coverage-lcov ./coverage/lcov.info"
    }
  }
}
```

The `command` property can be any shell command that outputs a single number to be tracked. `@collect` is a shortcut for running built-in collectors.

### Coverage Metrics

Unentropy supports three coverage report formats.

#### Available Coverage Formats

| | LCOV | Cobertura | Clover |
|---|---|---|---|
| **Collector** | `@collect coverage-lcov` | `@collect coverage-cobertura` | `@collect coverage-clover` |
| **File format** | `.lcov` / `lcov.info` | `.xml` (Cobertura XML) | `.xml` (Clover XML) |
| **Typical tools** | Jest, Istanbul, nyc | PHPUnit, gcovr, OpenCppCoverage | PHPUnit, OpenClover |
| **Syntax** | `<path>` (single file) | `<paths...>` (single or multiple) | `<paths...>` (single or multiple) |
| **Multi-report merge** | Not supported | Supported | Supported |
| **Coverage types** | `line`, `branch`, `function` | `line`, `branch`, `function` | `line`, `branch`, `function` |

#### LCOV

Track coverage from LCOV reports (Jest, Istanbul, nyc):

```json
{
  "metrics": {
    "coverage": {
      "$ref": "coverage",
      "command": "@collect coverage-lcov ./coverage/lcov.info"
    },
    "branch-coverage": {
      "$ref": "coverage",
      "name": "Branch Coverage",
      "command": "@collect coverage-lcov ./coverage/lcov.info --type branch"
    },
    "func-coverage": {
      "$ref": "coverage",
      "name": "Function Coverage",
      "command": "@collect coverage-lcov ./coverage/lcov.info --type function"
    }
  }
}
```

- **Unit**: Percent
- **Note**: Requires coverage report generation before metric collection

#### Cobertura

Track coverage from Cobertura XML reports (PHPUnit, gcovr). Unlike LCOV, Cobertura supports merging multiple reports — useful when tests run in parallel CI jobs.

```json
{
  "metrics": {
    "coverage": {
      "$ref": "coverage",
      "command": "@collect coverage-cobertura ./coverage/coverage.xml"
    }
  }
}
```

Pass multiple paths to merge:

```json
{
  "metrics": {
    "coverage": {
      "$ref": "coverage",
      "command": "@collect coverage-clover ./coverage/clover.xml"
    }
  }
}
```

Or use a glob for sharded output:

```json
{
  "metrics": {
    "coverage": {
      "$ref": "coverage",
      "command": "@collect coverage-cobertura ./coverage/*-cobertura.xml"
    }
  }
}
```

Also supports `--type branch` and `--type function`:

```json
{
  "metrics": {
    "branch-coverage": {
      "$ref": "coverage",
      "name": "Branch Coverage",
      "command": "@collect coverage-cobertura ./coverage/*-cobertura.xml --type branch"
    }
  }
}
```

The merge sums covered and valid counts across all reports, then recomputes the percentage — producing a correctly weighted combined rate.

- **Unit**: Percent
- **Note**: Requires coverage report generation before metric collection

#### Clover

Track coverage from Clover XML reports (PHPUnit `--coverage-clover`, OpenClover). Like Cobertura, Clover supports merging multiple reports.

```json
{
  "metrics": {
    "coverage": {
      "$ref": "coverage",
      "command": "@collect coverage-clover ./coverage/clover.xml"
    }
  }
}
```

Pass multiple paths to merge:

```json
{
  "metrics": {
    "coverage": {
      "$ref": "coverage",
      "command": "@collect coverage-clover ./coverage/report1.xml ./coverage/report2.xml"
    }
  }
}
```

Or use a glob for sharded output:

```json
{
  "metrics": {
    "coverage": {
      "$ref": "coverage",
      "command": "@collect coverage-clover ./coverage/*-clover.xml"
    }
  }
}
```

Also supports `--type branch` and `--type function`:

```json
{
  "metrics": {
    "branch-coverage": {
      "$ref": "coverage",
      "name": "Branch Coverage",
      "command": "@collect coverage-clover ./coverage/*-clover.xml --type branch"
    }
  }
}
```

The merge uses per-file, per-line deduplication for line coverage (unions line numbers across reports so overlapping coverage isn't double-counted), and project-level summation for branch and function coverage.

- **Unit**: Percent
- **Note**: Requires coverage report generation before metric collection

### Code Size Metrics

#### Lines of Code

Count lines of code in your project:

```json
{
  "metrics": {
    "loc": {
      "$ref": "loc"
    }
  }
}
```

This uses the default command `@collect loc .` which counts all lines in your project. Internally, Unentropy uses the [scc](https://github.com/boyter/scc) tool to do the counting.

**Customize the path or language:**

```json
{
  "metrics": {
    "src-loc": {
      "$ref": "loc",
      "command": "@collect loc ./src --language TypeScript"
    }
  }
}
```

- **Unit**: Integer (displays as `4,521`)

#### Bundle Size

Track production build artifact size:

```json
{
  "metrics": {
    "bundle": {
      "$ref": "size",
      "command": "@collect size ./dist"
    }
  }
}
```

Supports glob patterns for specific files:

```json
{
  "metrics": {
    "js-bundle": {
      "$ref": "size",
      "command": "@collect size ./dist/**/*.js"
    }
  }
}
```

- **Unit**: Bytes (auto-scales to KB, MB, GB)

### Performance Metrics

#### Build Time

Track how long your builds take:

```json
{
  "metrics": {
    "build-time": {
      "$ref": "build-time",
      "command": "command-that-outputs-milliseconds"
    }
  }
}
```

- **Unit**: Duration (auto-scales to ms, s, m, h)
- **Note**: No default command — too project-specific

#### Test Suite Duration

Track test execution time:

```json
{
  "metrics": {
    "test-time": {
      "$ref": "test-time",
      "command": "command-that-outputs-test-duration-ms"
    }
  }
}
```

- **Unit**: Duration

### Dependency Metrics

#### Dependency Count

Track the number of direct dependencies:

```json
{
  "metrics": {
    "deps": {
      "$ref": "dependencies-count",
      "command": "jq '.dependencies | length' package.json"
    }
  }
}
```

- **Unit**: Integer

## Custom Metrics

Define metrics specific to your project needs:

```json
{
  "metrics": {
    "api-endpoints": {
      "type": "numeric",
      "name": "API Endpoints",
      "description": "Number of exported API functions",
      "unit": "integer",
      "command": "grep -r 'export.*function' src/api | wc -l"
    }
  }
}
```

### Custom Metric Properties

- **type**: `numeric` (required)
- **name**: Display name in reports (required)
- **description**: What this metric tracks (optional)
- **unit**: How to format values (optional, see Unit Types)
- **command**: Shell command that outputs the metric value (required)

### Unit Types

Choose the right unit for proper formatting:

| Unit | Example | Use Case |
|------|---------|----------|
| `percent` | `85.5%` | Coverage, ratios |
| `integer` | `1,234` | Counts, LOC |
| `bytes` | `1.5 MB` | File sizes, bundles |
| `duration` | `1m 30s` | Build/test time |
| `decimal` | `3.14` | Generic numbers |

## Customizing Built-in Metrics

### Override Display Name

Customize how metrics appear in reports:

```json
{
  "metrics": {
    "test-coverage": {
      "$ref": "coverage",
      "name": "Test Coverage",
      "command": "@collect coverage-lcov ./coverage/lcov.info"
    }
  }
}
```

### Multiple Variations

Track the same type of metric for different paths:

```json
{
  "metrics": {
    "src-loc": {
      "$ref": "loc",
      "name": "Source Code Lines",
      "command": "@collect loc ./src"
    },
    "test-loc": {
      "$ref": "loc",
      "name": "Test Code Lines",
      "command": "@collect loc ./tests"
    }
  }
}
```

Each gets a unique ID from its object key, so they can be tracked separately in reports and quality gates.

## The @collect Shortcut

Built-in collectors run faster than shell commands because they execute in-process.

### Available Collectors

#### `@collect loc <path>`

Count lines of code using the SCC tool:

```bash
@collect loc ./src
@collect loc . --language TypeScript
@collect loc ./app --language "PHP,JavaScript"
```

#### `@collect size <path1> [<path2>] [<path3>] [...]`

Calculate total file size (supports glob patterns):

```bash
@collect size ./dist
@collect size ./dist/**/*.js
@collect size ./build/*.wasm
@collect size ./build ./dist
```

#### `@collect coverage-lcov <path>`

Extract coverage from LCOV format:

```bash
@collect coverage-lcov ./coverage/lcov.info
@collect coverage-lcov ./coverage/lcov.info --type branch
@collect coverage-lcov ./coverage/lcov.info --type function
```

**Options**:

- `--type <line|branch|function>` — Coverage type to extract (default: `line`)

#### `@collect coverage-clover <paths...>`

Extract and merge coverage from Clover XML format (PHPUnit `--coverage-clover`, OpenClover):

```bash
@collect coverage-clover ./coverage/clover.xml
@collect coverage-clover ./coverage/report1.xml ./coverage/report2.xml
@collect coverage-clover ./coverage/*-clover.xml --type branch
```

**Options**:

- `--type <line|branch|function>` — Coverage type to extract (default: `line`)
- Accepts multiple paths — line coverage uses per-file line deduplication; branch and function coverage use project-level summation

#### `@collect coverage-cobertura <paths...>`

Extract and merge coverage from Cobertura XML format:

```bash
@collect coverage-cobertura ./coverage/coverage.xml
@collect coverage-cobertura ./coverage/report1.xml ./coverage/report2.xml
@collect coverage-cobertura ./coverage/*-cobertura.xml --type branch
```

**Options**:

- `--type <line|branch|function>` — Coverage type to extract (default: `line`)
- Accepts multiple paths — coverage data is merged by summing covered/valid counts across all reports

## Example Configurations

### JavaScript/TypeScript Project

```json
{
  "metrics": {
    "loc": {
      "$ref": "loc",
      "command": "@collect loc ./src --language TypeScript"
    },
    "coverage": {
      "$ref": "coverage",
      "command": "@collect coverage-lcov ./coverage/lcov.info"
    },
    "bundle": {
      "$ref": "size",
      "command": "@collect size ./dist/**/*.js"
    }
  }
}
```

### PHP Project

```json
{
  "metrics": {
    "loc": {
      "$ref": "loc",
      "command": "@collect loc ./src --language PHP"
    },
    "coverage": {
      "$ref": "coverage",
      "command": "@collect coverage-cobertura ./coverage/coverage.xml"
    }
  }
}
```

### Go Project

```json
{
  "metrics": {
    "loc": {
      "$ref": "loc",
      "command": "@collect loc . --language Go"
    },
    "binary-size": {
      "$ref": "size",
      "command": "@collect size ./bin/app"
    }
  }
}
```

## Validating Configuration

Check your configuration before pushing to CI:

```bash
bunx unentropy verify
```

This validates:

- JSON syntax
- Required fields present
- Valid metric references
- Unit types correct

## Testing Metric Collection

Verify all metrics collect successfully:

```bash
bunx unentropy test
```

Example output:

```
✓ Config schema valid

Collecting metrics:

  ✓ loc (integer)         4,521         0.8s
  ✓ coverage (percent)    87.3%         2.1s
  ✓ bundle (bytes)        240 KB        0.2s

All 3 metrics collected successfully.
```

Note that `test` runs locally, so — depending on your configuration — you may need to run tests or build artifacts first. Code size (loc) metrics require the scc tool to be installed.
