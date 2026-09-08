#!/usr/bin/env bash
# Run cli-agent-lint against a built CLI binary and print the triage that goes
# with its output. Installing the linter is left to the caller, and so is every
# judgement about what it reports.
#
# Usage: agent_lint.sh PATH_TO_BINARY [extra cli-agent-lint flags...]
#
# Exit codes:
#   0  the linter ran and every check passed
#   1  the linter ran and at least one fail-severity check did not pass
#   2  this script was called wrong (no binary, or not an executable file)
#   3  cli-agent-lint is not installed
#   *  cli-agent-lint's own usage or runtime error, passed through

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "ERROR: no binary given; run: agent_lint.sh PATH_TO_BINARY" >&2
  exit 2
fi

bin=$1
shift

if [ ! -x "$bin" ]; then
  echo "ERROR: $bin: not an executable file; build the CLI first and pass the built binary" >&2
  exit 2
fi

if ! command -v cli-agent-lint >/dev/null 2>&1; then
  echo "ERROR: cli-agent-lint not found; install with: go install github.com/Camil-H/cli-agent-lint@v0.3.5" >&2
  echo "Then put its bin directory on PATH: export PATH=\"\$PATH:\$(go env GOPATH)/bin\"" >&2
  exit 3
fi

status=0
cli-agent-lint check --no-color "$@" "$bin" || status=$?

echo
case "$status" in
0)
  echo "cli-agent-lint exited 0: every check passed."
  ;;
1)
  echo "cli-agent-lint exited 1: at least one fail-severity check did not pass."
  ;;
*)
  echo "ERROR: cli-agent-lint exited $status; that is its own usage or runtime error, not a verdict on $bin" >&2
  exit "$status"
  ;;
esac

echo "Triage every non-PASS line above as one of: adopt / skip (reason) / false positive."
exit "$status"
