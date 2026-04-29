---
name: renovate-coverage
description: Detect Renovate Dependency Dashboard coverage gaps in a git repo. Lists version-like strings (semver, year-based versions, git SHA-40) found in Renovate-managed files (`.github/workflows/*.{yml,yaml}`, `Dockerfile*`, `compose*.{yml,yaml}`, `mise.toml`, `package.json`, `*.tf`, `go.mod`, `pyproject.toml`, `requirements*.txt`, etc.) that do NOT appear in the open "Dependency Dashboard" issue body. Use when the user asks to audit Renovate detection coverage, find versions that Renovate is not tracking, or invokes /renovate-coverage.
license: MIT
---

# renovate-coverage

Audit the current repository for version-like strings that appear in Renovate-managed files but are missing from the Renovate "Dependency Dashboard" issue. Helps surface dependencies that Renovate is not tracking (e.g., values held in fields outside a manager's extraction scope, or values requiring a `customManager`).

## Prerequisites

- Run from the repository root
- `gh` CLI authenticated (`gh auth status` succeeds)
- Repo has Renovate enabled with an open "Dependency Dashboard" issue

## Procedure

### 1. Run the coverage check

```bash
bash ~/.claude/skills/renovate-coverage/scripts/check_coverage.sh
```

The script:

- Fetches the body of the open "Dependency Dashboard" issue via `gh`
- Finds files matching the common Renovate manager `fileMatch` patterns
- Greps version-like tokens (`[0-9]+\.[0-9]+(\.[0-9]+)?` or git SHA-40) from each file
- Outputs TSV rows for tokens whose exact string does NOT appear anywhere in the dashboard body: `file:line<TAB>version<TAB>snippet`

### 2. Present results

- Reply in the same language the user used in their request
- Render the script output as a markdown table: `file:line | version | snippet`
- Render each row as a clickable markdown link pointing to that file:line in the repo
- Above the table, state that recall is prioritized — false positives (dates, IPs, doc examples, comment SHAs, etc.) are expected and the user is asked to triage manually
- If the result is empty, report that no version strings outside the dashboard were found

### 3. Suggest follow-ups (only if the user asks)

For rows that look like genuine coverage gaps, options include:
- Add a `customManager` (regex) entry to the repo's Renovate config
- File or upvote a Renovate feature request if it is a missing built-in manager capability
- Mark intentionally untracked items in the user's notes

Do NOT auto-edit the Renovate config without explicit user approval.

## Troubleshooting

If the script exits non-zero, relay the error message to the user verbatim and suggest the matching remediation:

| Error from script | Remediation to suggest |
|---|---|
| `bash 4.0+ required` | Install a newer bash (e.g., `brew install bash` on macOS) and re-run via that interpreter |
| `'gh' CLI not found` | Install GitHub CLI from https://cli.github.com/ |
| `not inside a git repository` | `cd` into the target git repo and re-run |
| `'gh' is not authenticated` | Run `gh auth login` and re-run |
| `open 'Dependency Dashboard' issue not found` | Confirm Renovate is configured with `dependencyDashboard: true`, the issue is open (not closed), and its title contains "Dependency Dashboard". The dashboard is created on Renovate's next run after enabling. |
| `No Renovate-managed files found in this repo.` | Not an error — the repo simply has no files matching common Renovate `fileMatch` patterns. Confirm with the user before treating as a problem. |

For unexpected failures, present the raw script output and ask the user how to proceed rather than guessing.

## Notes

- This audit is recall-oriented; do not gate CI on its output.
- The script's file pattern list covers common managers but is not exhaustive. To extend coverage, edit `scripts/check_coverage.sh`.
- The Dependency Dashboard's `regex` section may show duplicate entries for the same dep (a known Renovate bug); this does not affect this audit, which only checks string presence in the body.
