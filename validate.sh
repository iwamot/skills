#!/bin/bash
set -e

# mise
eval "$(mise activate bash)"
mise fmt
mise install

# Run shared lint tasks
mise run gha-lint

# Shell lint
shfmt -w -i 2 .
find . -type f -name '*.sh' -not -path './.git/*' -exec shellcheck {} +

# Lint SKILL.md files
skill-check . --no-security-scan --fail-on-warning --fix

# Validate skills against Agent Skills spec
gh skill publish --dry-run

# Check for uncommitted changes
git diff --exit-code
