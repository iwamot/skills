#!/usr/bin/env bash
# Emit raw inputs for a renovate-coverage audit:
#  - the open "Dependency Dashboard" issue body, and
#  - every line in this repo's Renovate-managed files that contains a
#    version-like token (semver / year-based / git SHA-40).
# Coverage judgement is left to the agent reading this output.

set -euo pipefail

# Preflight checks
if [ "${BASH_VERSINFO[0]:-0}" -lt 4 ]; then
  echo "ERROR: bash 4.0+ required (current: ${BASH_VERSION:-unknown})." >&2
  echo "On macOS, install a newer bash via: brew install bash" >&2
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "ERROR: 'gh' CLI not found." >&2
  echo "Install: https://cli.github.com/" >&2
  exit 1
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "ERROR: not inside a git repository. cd into the target repo first." >&2
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "ERROR: 'gh' is not authenticated. Run: gh auth login" >&2
  exit 1
fi

dashboard=$(gh issue list --search "Dependency Dashboard in:title" --state open \
  --json body --jq '.[0].body // ""' 2>/dev/null || echo "")

if [ -z "$dashboard" ]; then
  echo "ERROR: open 'Dependency Dashboard' issue not found." >&2
  echo "Ensure Renovate's 'dependencyDashboard: true' is set and the issue title contains 'Dependency Dashboard'." >&2
  exit 1
fi

mapfile -t files < <(find . \( \
  -path './.github/workflows/*.yml' -o \
  -path './.github/workflows/*.yaml' -o \
  -path './.github/actions/*/action.yml' -o \
  -path './.github/actions/*/action.yaml' -o \
  -name 'Dockerfile' -o -name 'Dockerfile.*' -o -name '*.Dockerfile' -o \
  -name 'compose.yml' -o -name 'compose.yaml' -o \
  -name 'docker-compose*.yml' -o -name 'docker-compose*.yaml' -o \
  -name 'mise.toml' -o -name '.mise.toml' -o -name '.tool-versions' -o \
  -name 'package.json' -o -name 'requirements*.txt' -o \
  -name 'pyproject.toml' -o -name 'go.mod' -o -name '*.tf' \
  \) -not -path './node_modules/*' -not -path './.git/*' 2>/dev/null | sort)

if [ ${#files[@]} -eq 0 ]; then
  echo "No Renovate-managed files found in this repo." >&2
  exit 0
fi

pattern='[0-9]+\.[0-9]+(\.[0-9]+)?|[0-9a-f]{40}'

echo "=== Dependency Dashboard ==="
printf '%s\n' "$dashboard"
echo
echo "=== Candidate lines (file:line:content) ==="
grep -nHE "$pattern" "${files[@]}" 2>/dev/null || true
