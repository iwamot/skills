---
name: renovate-coverage
description: Detect Renovate Dependency Dashboard coverage gaps in a git repo. Cross-references version-like strings in Renovate-managed files (`.github/workflows/*.{yml,yaml}`, `Dockerfile*`, `compose*.{yml,yaml}`, `mise.toml`, `package.json`, `*.tf`, `go.mod`, `pyproject.toml`, `requirements*.txt`, etc.) against the open "Dependency Dashboard" issue's "Detected Dependencies" listing, and reports lines whose dependency is not tracked by Renovate. Use when the user asks to audit Renovate detection coverage or find dependencies that Renovate is not tracking.
license: MIT
---

# renovate-coverage

Audit the current repository for dependencies that Renovate is not tracking. The bundled script extracts the open "Dependency Dashboard" issue body and every line containing a version-like token from Renovate-managed files. The agent then judges, line by line, whether each candidate's dependency appears in the dashboard's "Detected Dependencies" listing.

## Prerequisites

- Run from the root of the target repository (the repo to audit, not this skill's repo)
- `gh` CLI authenticated (`gh auth status` succeeds)
- The target repo has Renovate enabled with an open "Dependency Dashboard" issue

## Procedure

### 1. Collect data

Run the bundled script from the user's target git repository:

```bash
bash scripts/check_coverage.sh
```

Output has two sections:

- `=== Dependency Dashboard ===` — full body of the open dashboard issue
- `=== Candidate lines (file:line:content) ===` — every line from Renovate-managed files that contains a version-like token

### 2. Judge each candidate

For each candidate line, determine whether the dependency it represents is already tracked by Renovate. Apply this reasoning:

1. **Identify the dependency**. Parse the candidate line in context. The package identifier may be on the same line (`"npm:renovate" = "43.150.0"`, `FROM alpine:3.22`, `iwamot/workflows@<sha>`), in a parent section header (`[tools.uv]\nversion = "0.11.8"`), or in a surrounding mapping (YAML/JSON nesting). Use the Read tool to inspect the file's structure when the line alone is ambiguous.
2. **Check the dashboard**. The "Detected Dependencies" section of the dashboard groups tracked dependencies by manager and file. A dependency is tracked if its identifier appears under any group there. The "Pending Status Checks" section is for already-tracked deps awaiting an update; it does not by itself prove tracking, but the same dep is also listed under "Detected Dependencies" when truly tracked.
3. **Recognize common non-tracked patterns**. The following are typically NOT real coverage gaps:
   - `min_version` in `mise.toml` / `.mise.toml` (mise's own version requirement, not a managed dep)
   - The project's own `version` field (`[project] version = "..."` in `pyproject.toml`, top-level `"version"` in `package.json`)
   - Version-like substrings inside descriptions, comments, examples, or default-value strings
   - Year-based dates (`2026.4.8`) that look like versions but aren't dependency versions
4. **Recognize real coverage gaps**. Likely-genuine gaps include:
   - `Dockerfile`'s `ARG FOO_VERSION=1.2.3` / `ENV FOO_VERSION=1.2.3` patterns (Renovate's dockerfile manager typically does not auto-extract these)
   - Versions held in custom fields outside any Renovate manager's `fileMatch` scope
   - Tools listed in non-standard files

### 3. Present results

- Reply in the same language the user used in their request
- Render only the truly untracked candidates as a markdown table: `file:line | dependency | snippet | reason`
- Render each row's `file:line` as a clickable markdown link
- Above the table, briefly state how many candidate lines the script produced and how many remain after triage
- If nothing remains, report that no untracked dependencies were found

### 4. Suggest follow-ups (only if the user asks)

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

- This audit is interactive and recall-oriented; do not gate CI on its output.
- The script's file pattern list covers common managers but is not exhaustive. To extend coverage, edit `scripts/check_coverage.sh`.
- The Dependency Dashboard's `regex` section may show duplicate entries for the same dep (a known Renovate bug); this does not affect this audit.
- If the user's local working tree is behind the default branch, the dashboard may reflect newer file content than what is checked locally. Suggest `git pull` if the candidate set looks unexpected.
