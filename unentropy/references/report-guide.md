# Report Guide

Customize the appearance and layout of generated HTML reports.

## Theming

Control the color palette and light/dark mode of reports via the `report` object in `unentropy.json`.

### Built-in Themes

Unentropy ships with four professionally designed palettes, each with dark and light variants:

| Theme      | Accent Color | Character                |
| ---------- | ------------ | ------------------------ |
| `lattice`  | Cool blue    | Default, clean and calm  |
| `flux`     | Warm amber   | Energetic and warm       |
| `halftone` | Purple       | Distinctive and modern   |
| `specimen` | Green        | Fresh and natural        |

Select a theme:

```json
{
  "report": {
    "theme": "flux"
  }
}
```

### Custom Palettes

Override individual colors to match your brand:

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

Each palette defines 12 CSS variables:

| Variable           | Used for                  |
| ------------------ | ------------------------- |
| `--bg`             | Page background           |
| `--surface`        | Card backgrounds          |
| `--surface-card`   | Elevated card surfaces    |
| `--border`         | Default borders           |
| `--border-soft`    | Subtle dividers           |
| `--text`           | Primary text              |
| `--text-dim`       | Secondary text            |
| `--text-muted`     | Placeholder/disabled text |
| `--accent`         | Highlights and links      |
| `--up`             | Positive trend indicators |
| `--down`           | Negative trend indicators |
| `--warn`           | Warning states            |

You can override any subset; omitted variables fall back to Lattice defaults. Values must be 7-character hex colors (e.g., `#1c2230`).

### Mode

Control how the report selects between dark and light palettes:

```json
{
  "report": {
    "mode": "auto"
  }
}
```

| Mode     | Behavior                                           |
| -------- | -------------------------------------------------- |
| `auto`   | Respects system `prefers-color-scheme` (default)   |
| `dark`   | Always uses the dark variant                       |
| `light`  | Always uses the light variant                      |

Locking to a specific mode is useful when sharing screenshots or hosting reports where you want a consistent appearance regardless of the viewer's system settings.

## Layout

As your project grows, a flat grid of all metrics can become hard to navigate. You can organize reports into named sections and plot related metrics together on a single chart.

### Sections

Group related metrics under section headers:

```json
{
  "report": {
    "sections": [
      {
        "name": "Code Size",
        "description": "Source code and build artifact metrics",
        "charts": [
          { "metrics": "typescript-loc" },
          { "metrics": "javascript-loc" },
          { "metrics": "bundle" }
        ]
      },
      {
        "name": "Quality",
        "charts": [
          { "metrics": "coverage" },
          { "metrics": "test-count" }
        ]
      }
    ]
  }
}
```

Each section displays its name as a header with an optional description. Charts appear in the order defined. Metrics not referenced in any section are omitted from the report (they may still be used for quality gates).

### Multi-Metric Charts

Plot multiple related metrics on a single chart to compare them directly:

```json
{
  "report": {
    "sections": [
      {
        "name": "Refactoring Progress",
        "charts": [
          {
            "metrics": ["modern-classes", "legacy-classes"],
            "title": "Modern vs Legacy Class Count"
          }
        ]
      }
    ]
  }
}
```

This renders one chart card containing both metrics as separate lines with distinct colors and a legend. Metrics with incompatible units or vastly different scales automatically receive dual Y-axes so both series remain clearly visible.

### Custom Chart Titles

Override the default title derived from metric names:

```json
{
  "metrics": "bundle-size",
  "title": "Production Bundle Size"
}
```

### Backward Compatibility

Omitting the `report` block entirely preserves the original flat layout: every metric gets its own single-metric chart displayed in definition order.

## Example: Themed and Sectioned Report

```json
{
  "metrics": {
    "typescript-loc": {
      "$ref": "loc",
      "command": "@collect loc ./src --language TypeScript"
    },
    "javascript-loc": {
      "$ref": "loc",
      "command": "@collect loc ./src --language JavaScript"
    },
    "coverage": {
      "$ref": "coverage",
      "command": "@collect coverage-lcov ./coverage/lcov.info"
    },
    "bundle": {
      "$ref": "size",
      "command": "@collect size ./dist"
    }
  },
  "report": {
    "theme": "specimen",
    "mode": "auto",
    "sections": [
      {
        "name": "Code Size",
        "description": "Source code and build artifact metrics",
        "charts": [
          {
            "metrics": ["typescript-loc", "javascript-loc"],
            "title": "Lines of Code by Language"
          },
          { "metrics": "bundle", "title": "Production Bundle Size" }
        ]
      },
      {
        "name": "Quality",
        "charts": [
          { "metrics": "coverage" }
        ]
      }
    ]
  }
}
```

## Validation

Validate your configuration before pushing to CI:

```bash
bunx unentropy verify
```

Common report configuration errors:

### Empty Sections Array

```
Error: report.sections cannot be empty
Remove the report block or define at least one section
```

### Empty Section Charts

```
Error: Section "Code Size" has no charts
Each section must contain at least one chart
```

### Invalid Mode

```
Error: mode must be one of: auto, light, dark
Found: "system"
```

### Invalid Theme Color

```
Error: theme values must be 7-character hex (e.g. #1c2230)
Found: "#ff00f" at report.theme.dark.--accent
```

### Unknown Theme Name

```
Warning: Unknown theme "custom". Falling back to "lattice".
```
