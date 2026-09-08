---
name: agent-cli
description: Design or review a command-line tool that coding agents will call from a shell. Covers the instruction paragraph for CLAUDE.md/AGENTS.md, error messages that carry the next step, exit codes split by which layer failed, output shapes declared as a contract, and the README structure that goes with them. Use when the user is writing a new CLI for agents, or asks to review, tighten, or "make agent-friendly" an existing CLI's --help, errors, README, or instruction paragraph.
license: MIT
---

# agent-cli

Design or review a CLI whose main caller is a coding agent driving a shell. The judgment below decides what the instruction paragraph carries, what an error line owes its reader, and where the output contract is drawn. The procedure turns a finished CLI into findings, each with the observed line and the proposed line.

## Judgment

Return to these when a call is not obvious. Each stands on its own; the examples all come from one tool (`sub1`, a CLI that replaces one block of text in a file).

- **The instruction paragraph carries three things: that the tool exists, when to reach for it, and the shape of a call.** Everything else arrives in the output of the call that needed it. Test: if the paragraph and stderr would tell the agent different next steps in the same situation, the paragraph is wrong.
- **An error line is `<what>; <remediation>`, and the remediation is copy-ready.** Fill in the real value (`pass -n 3`, not `pass -n N`). When there is nothing to do, leave the `; ` tail off rather than inventing advice: `old and new blocks are identical` ends there, because changing the new block is the only move.
- **Exit codes split by which layer failed, and so does the identifier prefix.** Input error: the call itself is wrong, so no target is named. Target error: the target as given (a path, a package name). The identifier is never normalized, because the agent matches it against what it typed. One tool, one identifier: every line names the target the same way, so a line the agent has not seen before still matches the argument it typed.
- **Keep fact and guess on separate lines, and label the guess.** Diagnosis first, location in a trailing parenthesis: `hint: file line 4 starts with 1 tab, old block line 2 with 4 spaces (near line 3)`.
- **Declare the stable part of each output line, and say what is not stable.** The body before `(` is contract; parenthetical notes and the `; ` tail are prose. Do this before 1.0, not after.
- **Do not guess on the agent's behalf.** No fuzzy matching, no "did you mean" that could be mistaken for success. Fail, say why, say what differs.
- **Name no other product.** A claim that only holds against a named tool goes when the name goes: dropping "unlike <other tool>'s patch command" also drops "already replaces exact text", because that command matches loosely and the claim was only ever true as a comparison.
- **Skip what does not apply.** JSON output, `--no-color`, `--quiet`, completions and `--timeout` belong to CLIs with long output, colour, subcommands or network waits. A linter warning about one of these is a note, not a task.

## README skeleton

Each section answers a question the one before it raises.

1. **Opening** — one-line purpose, "Built for coding agents that ...", and one real invocation with its real output.
2. **Why** — the measured motivation (how often an agent hand-wrote the equivalent), then "X is that script, made into a command", then who it is not for.
3. **Setup** — install, the instruction paragraph in a fenced block ready to paste into CLAUDE.md or AGENTS.md, and a flag that prints the same paragraph (`--instructions`). An e2e test keeps the two equal.
4. **What the agent sees** — one success, then every failure the agent will actually meet, each with its real stderr.
5. **Reference** — `--help` verbatim, then bullets for what `--help` has no room for: matching rules, atomic write, terminator collisions.
6. **Output** — the stable shapes as a table, and the parts that ride on top and are not stable.
7. **Out of scope.**

## `--help` shape

Line 1 is the contract: `name — what it does, exactly`. Then `Usage:`. Then `Examples:` under its own heading, not buried inside usage. Then options, then any marks the output can carry, then `Exit codes:` with one line per code, remediation included.

## Procedure

Steps 1-3 gather evidence, 4-6 produce findings, 7 reports. Do not skip to the report: the matrix in step 2 is what makes the rest checkable.

1. **Read before running.** README, `--help`, `--instructions`. List every claim that could be false: "never writes", "byte-exact", "exit 1 means ...".
2. **Build the real binary and probe the failure matrix.** Run each of these and record the exact stderr and exit code:
   - no arguments; a malformed argument; a target that does not exist; a target the user cannot read or write
   - empty stdin; stdin cut short mid-input; stdin on a TTY (`script -qec '<cmd>' /dev/null`)
   - every flag combination the README says does not apply

   Write the matrix as a table before proposing anything.
3. **Check each README claim against the matrix.** Where they differ, quote the observed behaviour, never the intended one. An item written from intent ("confirm this still holds") gets "fixed" the wrong way at implementation time.
4. **Run the linter.** `bash scripts/agent_lint.sh PATH_TO_BINARY` (see Troubleshooting for its errors). Triage every non-PASS into adopt / skip-with-reason / false positive. The reasons are the deliverable; the score is not. Its active checks execute the target as a subprocess, so run it from an empty scratch directory; keep `--no-probe` for a target that reaches the network or spends a rate limit, and say in the report that the active checks were skipped. A passive run leaves about a third of the checks unevaluated, the one on actionable error messages among them.
5. **Diff the instruction paragraph against stderr.** For each failure in the matrix: what does the paragraph tell the agent to do, and what does stderr tell it? Any disagreement is a finding, and the paragraph is usually the side that is wrong.
6. **Count the copies of the instruction paragraph** (source, README, the user's global CLAUDE.md, anywhere else it was pasted) and say which copies no test protects.
7. **Report** in the language the user wrote in. Findings first, each with the observed line and the proposed line; then the lint triage table; then what was checked and found fine. Group the proposals by conventional-commit type: `feat!:` for exit codes and output shapes, `feat:` for messages, `docs:` for README and help text.

## Troubleshooting

Relay the script's message verbatim and suggest the matching remediation.

| Error from `scripts/agent_lint.sh` | Remediation to suggest |
|---|---|
| `no binary given; ...` | Build the CLI and pass the built binary, not the source directory |
| `not an executable file; ...` | Build the CLI first (`go build`, `cargo build`, ...) and pass the produced file |
| `cli-agent-lint not found; ...` | Relay the install command and ask before running it; it is a persistent change to the user's environment |

The script exits with the linter's own status when it ran: `0` when every check passed, `1` when at least one fail-severity check did not. Neither is a reason to stop; both need step 4's triage.

## What this skill does not do

- It proposes diffs. It does not edit the target repo's README, or the user's global CLAUDE.md, without being asked.
- It carries no time-bound facts about any agent harness (feature flags, prompt wording). Those go stale and belong in the user's own notes.
