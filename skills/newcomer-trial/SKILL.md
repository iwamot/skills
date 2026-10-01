---
name: newcomer-trial
description: Run a first-use trial of a product by handing real tasks to subagents that have never seen it and may read only its public material (README, docs, examples, --help, diagnostics), then verify their reports with minimal reproductions and classify where users get stuck into docs, error messages, implementation bugs and design decisions. Use when the user asks for a first-use trial, a newcomer or onboarding check, a docs usability test, or to try a library, CLI, compiler or framework as someone who does not know it.
license: MIT
---

# newcomer-trial

Give subagents that do not know the product real tasks, let them work from the public material alone, and find where users get stuck from what they record. The parent prepares, writes the tasks, verifies and aggregates; it never shares what it already suspects, because that is exactly what the trial is meant to find independently.

## Inputs

All optional. Take them from the user's request; ask only when the request contradicts itself.

| Input | Default |
|---|---|
| Number of tasks | 3 |
| Focus area | none |
| Material the trial may read, and whether external links in it may be followed | README, docs, examples, runtime help and diagnostics; no external links |
| Tasks the user specifies, to include as given | none |
| Whether setup is part of the trial | no: the parent prepares dependencies |

## Procedure

### 1. Prepare

- Read README, docs and examples until you can state what the product is for, what the existing examples cover, and how to run it. Do not read source or tests unless you cannot get there without them.
- Find a way to run it that leaves tracked files untouched (`uv run --frozen`, an install into a scratch prefix, and so on). Put dependencies in an environment used only for the trial.
- If setup is not part of the trial, install the dependencies yourself and record each command and any problem it hit. The report must say that this setup was outside the newcomer trial. If setup is part of the trial, prepare nothing and let the subagents follow the docs.
- Record the starting conditions: `git status`, target version or commit, material scope, execution environment, and the model the subagents will use.

### 2. Write the tasks

- The default three tasks are:
  1. **Main path**: the first use exactly as the README's entry point describes it.
  2. **Combination**: several existing features used together.
  3. **Edge application**: something at the boundary that no existing example covers.
- Each task states the requirement as a user would, an input example, and a completion condition. Fix the behaviour; leave the implementation free.
- Check the docs that no task asks for something the product declares out of scope.
- Include the tasks the user specified, keeping their requirements unchanged; fill in a missing input example or completion condition yourself. Write the rest fresh every run, because a product tuned against the same tasks run after run gets tuned for those tasks.
- Save the task definitions to scratch.

### 3. Run subagents in parallel

- Start each subagent with no conversation history inherited. If the environment cannot do that, report the lost independence as a limitation.
- The first message has two parts and nothing else:
  - **Task-specific information**: the requirement, input example, completion condition, material scope, working directory, and only the environment details needed to run the product.
  - **The common trial rules**: [references/trial-rules.md](references/trial-rules.md), filled in and pasted verbatim.
- Leave out your own findings, known issues and improvement hypotheses.
- If you advise a subagent mid-run, record what you said and when. The report separates what it achieved unaided from what it achieved after the advice.

### 4. Aggregate

- Do not take reports at face value. Reproduce each major finding with a minimal case yourself and mark it confirmed or unconfirmed.
- Rank by four signals: shared across tasks, severity, effect on the main path, and certainty of reproduction. A severe bug found in one task alone still stays in.
- Classify each finding:
  - **Docs**: no worked example, hard to find.
  - **Error messages and checks**: the message does not say what to write, or a mistake passes silently.
  - **Implementation bugs**: behaviour differs from the docs or spec.
  - **Design decisions**: limits and trade-offs by design. Give options and a recommendation with reasons; the user decides.
- Keep what went well. It tells the user what must not break.
- Write the report in the language the user wrote in, using the structure below.

### 5. Clean up

- Compare `git status` with the starting record.
- Revert only changes certainly made by the subagents (a rewritten lockfile, for instance). Leave anything uncertain in place and list it in the report.

## Report structure

1. **Conditions**: target version or commit, material scope, execution environment, model, task definitions.
2. **Setup record**: what the parent prepared, the commands, and any problems. Omit when setup was part of the trial.
3. **Findings**: by category, ranked, each marked confirmed or unconfirmed, with the task(s) it came from and whether it was reached unaided or after advice.
4. **What went well.**
5. **Changes left in the working tree**: when any were left.
6. **Limitations**: always include these three.
   - The testers are AI. Prior knowledge or guessing can carry them past places where a person would stop, and testing with the same model used in development tends to share its blind spots.
   - Setup prepared by the parent was outside the newcomer trial (unless setup was part of the trial).
   - The findings are candidates for a roadmap, not the roadmap. The user sets the priorities.
