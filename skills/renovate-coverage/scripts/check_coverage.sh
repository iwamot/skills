#!/usr/bin/env bash
# List version-like strings in this repo's Renovate-managed files that do NOT
# appear in the open "Dependency Dashboard" issue body.

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

printf 'file:line\tversion\tsnippet\n'
for f in "${files[@]}"; do
  grep -nHE "$pattern" "$f" 2>/dev/null | while IFS= read -r hit; do
    path=$(printf '%s' "$hit" | cut -d: -f1)
    lineno=$(printf '%s' "$hit" | cut -d: -f2)
    content=$(printf '%s' "$hit" | cut -d: -f3- | tr -s ' \t' ' ' | sed 's/^ //')
    while IFS= read -r token; do
      [ -z "$token" ] && continue
      if ! printf '%s' "$dashboard" | grep -qF -- "$token"; then
        printf '%s:%s\t%s\t%s\n' "$path" "$lineno" "$token" "$content"
      fi
    done < <(printf '%s' "$content" | grep -oE "$pattern" | sort -u)
  done
done
