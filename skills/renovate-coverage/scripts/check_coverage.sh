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

# The title is matched whole, since an issue that only mentions the dashboard in
# its title would otherwise be read in its place.
dashboard=$(gh issue list --search "Dependency Dashboard in:title" --state open \
  --json title,body \
  --jq 'map(select(.title == "Dependency Dashboard"))[0].body // ""' 2>/dev/null || echo "")

if [ -z "$dashboard" ]; then
  echo "ERROR: open 'Dependency Dashboard' issue not found." >&2
  echo "Ensure Renovate's 'dependencyDashboard: true' is set and the issue title is exactly 'Dependency Dashboard'." >&2
  exit 1
fi

# Renovate reads what the repository holds, so only tracked files are candidates.
# Installed dependencies (node_modules at any depth, .venv) and build output stay
# out without listing them here.
mapfile -t files < <(git ls-files | grep -E \
  -e '^\.github/workflows/[^/]+\.ya?ml$' \
  -e '(^|/)action\.ya?ml$' \
  -e '(^|/)Dockerfile(\.[^/]+)?$' -e '(^|/)[^/]+\.Dockerfile$' \
  -e '(^|/)compose\.ya?ml$' -e '(^|/)docker-compose[^/]*\.ya?ml$' \
  -e '(^|/)\.?mise\.toml$' -e '(^|/)\.tool-versions$' \
  -e '(^|/)package\.json$' -e '(^|/)requirements[^/]*\.txt$' \
  -e '(^|/)pyproject\.toml$' -e '(^|/)go\.mod$' -e '\.tf$' |
  sed 's|^|./|' | sort)

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
