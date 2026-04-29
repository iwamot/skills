#!/bin/bash
set -e

# mise
eval "$(mise activate bash)"
mise fmt
mise install

# Run shared lint tasks
mise run gha-lint
mise run shell-lint

# Lint SKILL.md files
skill-check . --no-security-scan --fail-on-warning --fix

# Validate skills against Agent Skills spec
gh skill publish --dry-run

# Check for uncommitted changes
git diff --exit-code
