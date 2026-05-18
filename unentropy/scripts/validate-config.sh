#!/bin/bash
# Validate unentropy.json configuration
# Usage: validate-config.sh [path-to-config]
# Defaults to unentropy.json in current directory

set -euo pipefail

CONFIG_FILE="${1:-unentropy.json}"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Configuration file not found: $CONFIG_FILE"
    exit 1
fi

echo "Validating $CONFIG_FILE..."

# Step 1: JSON syntax validation with jq
if command -v jq &> /dev/null; then
    echo "  → Checking JSON syntax with jq..."
    if jq . "$CONFIG_FILE" > /dev/null 2>&1; then
        echo "  ✓ JSON syntax is valid"
    else
        echo "  ✗ JSON syntax is invalid"
        jq . "$CONFIG_FILE" > /dev/null
        exit 1
    fi
else
    echo "  ⚠ jq not found, skipping JSON syntax check"
    echo "    Install jq for automatic JSON validation"
fi

# Step 2: Schema validation with unentropy CLI
if command -v bunx &> /dev/null; then
    echo "  → Running unentropy schema validation..."
    if bunx unentropy verify "$CONFIG_FILE"; then
        echo "  ✓ Schema validation passed"
    else
        echo "  ✗ Schema validation failed"
        exit 1
    fi
elif command -v npx &> /dev/null; then
    echo "  → Running unentropy schema validation..."
    if npx unentropy verify "$CONFIG_FILE"; then
        echo "  ✓ Schema validation passed"
    else
        echo "  ✗ Schema validation failed"
        exit 1
    fi
else
    echo "  ⚠ Neither bunx nor npx found, skipping schema validation"
    echo "    Install unentropy CLI for schema validation"
fi

echo ""
echo "✓ Configuration validation complete"
