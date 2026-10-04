---
name: ai-usability-test
description: Test whether independent AI agents can successfully use a product by giving them realistic tasks without inherited product-specific development context, observing how they discover, interpret, use and recover through its interfaces, then independently verifying and classifying the friction they encounter. Use when evaluating the AI usability of a CLI, library, compiler, framework or other developer tool.
license: MIT
---

# ai-usability-test

AI usability testing treats AI agents as users, not as proxies for human users. The question is: can an independent AI agent use this product to accomplish realistic tasks without inheriting product-specific development context?

Give independent tester agents the kind of tasks a real user would hand to an AI agent, observe how the product's interfaces shape what they discover, how they interpret it, how they operate it and how they recover from failure, then verify what they report. The parent prepares, writes the tasks, verifies and aggregates. It never shares what it already knows or suspects about the product, because a parent that has worked with the author can fill gaps in the product's own explanations with the author's intent, known issues and past design discussions.

This skill is not a substitute for usability testing with people, an LLM benchmark, a model comparison, a documentation completeness check, a code quality review or an architecture review. Problems of those kinds that surface during a task may be recorded, but the report centres on the agent's experience with the product's interfaces.

## Inputs

All optional. Take them from the user's request; ask only when the request contradicts itself.

| Input | Default |
|---|---|
| Number of tasks | 3 |
| Focus area | none |
| Information access | what a real AI user can reach: product material, the using project's existing code and config, web search, external official docs, and the product's implementation and tests where normally accessible |
| Tasks the user specifies, to include as given | none |
| Setup | excluded: the parent prepares dependencies |
| Attempt or time limits | none beyond the harness's own |
| Fixed comparison tasks from an earlier run | none |

A narrower information access condition (for example "product docs only") is a separate condition. Name it as such in the report.

## Procedure

### 1. Prepare

- Read README, docs and examples until you can state what the product is for, what the existing examples cover, and how to run it.
- Decide whether setup is included or excluded, and record which.
  - **Setup excluded**: find a way to run the product that leaves tracked files untouched (`uv run --frozen`, an install into a scratch prefix, and so on), install the dependencies into an environment used only for the test, and record each command and any problem it hit. Give testers only the minimum needed to run the product.
  - **Setup included**: install nothing. Discovering the installation method, dependency requirements, environment configuration and first successful command become part of the evaluation.
- Lay out three kinds of location and give their paths to each tester:
  - **Readable**: the product repository and the using project, as the information access condition allows.
  - **Writable**: a working directory of the tester's own.
  - **Off limits**: the other testers' working directories and your own notes and task definitions.
  Keep the off-limits locations outside the readable ones, so that permitting a repository does not also expose another tester's work or the parent's notes.
- For a task that changes an existing project, copy the using project into each tester's working directory and give that copy as the thing to edit.
- Record the starting conditions: `git status`, target version or commit, the testers' model name or ID, agent harness, tools available to testers, information access condition, setup condition and any limits.

### 2. Write the tasks

- The default three tasks are:
  1. **Main path**: the product's primary use.
  2. **Combination**: several existing features used together.
  3. **Edge application**: something at the boundary that no existing example covers.
- Write each task in the words a real user would use when asking an AI agent: the request, an input example and an observable completion condition.
- Do not name APIs, commands, or places to look. Write "Create a workflow that invokes this Lambda function and returns its payload", not "Use `aws.lambda.invoke()` and `Output`".
- Check the docs that no task asks for something the product declares out of scope.
- Include the tasks the user specified, keeping their requirements unchanged; fill in a missing input example or completion condition yourself.
- Write exploration tasks fresh every run, because a product tuned against the same tasks run after run gets tuned for those tasks. To compare before and after a change, keep a small set of comparison tasks with fixed requirements and completion conditions, and still add fresh exploration tasks. Keep model, harness, tools, information access and setup the same across compared runs as far as possible, and record any difference.
- Save the task definitions where testers cannot read them.

### 3. Run testers in parallel

- Start each tester as an independent agent that inherits no product-specific conversation history from the parent (a fresh subagent, not a fork of the parent's context). Fresh context means not inheriting the parent's development context; the model may still know the product from pretraining, which is reported as a limitation.
- Note any instruction files or memory the tester's harness loads automatically, and whether they carry development context.
- If independent context cannot be arranged, do not report the run as an ordinary AI usability test. State what was run and how the testers may have been contaminated.
- The first message has two parts and nothing else:
  - **Task-specific information**: the request, input example, completion condition, working directory, and only the environment details needed to run the product.
  - **The common tester rules**: [references/trial-rules.md](references/trial-rules.md), filled in and pasted verbatim.
- Leave out conversations with the author, development discussions, unpublished design intent, known issues, earlier test results, improvement hypotheses, the author's preferences or expectations, your own assessment of the product, and any "please check X" steering.
- Avoid advising a tester mid-run. If you must, record what you said and when, and separate what it achieved before and after the advice.

### 4. Verify

- Do not take reports as fact. Check each task's completion independently against its artifacts and completion condition. A command that exits 0 has not necessarily met the request.
- Reconstruct the path from the tester's command, tool and action history and the material it consulted where you can. Keep facts you reconstructed separate from judgements and hesitations the tester reported. Do not fill in reasoning the history does not show.
- When the harness does not let you see the tester's history, label the path in the report as the tester's self-report. Your independent verification is then limited to the artifacts against the completion condition and the minimal reproductions of findings.
- Reproduce each major finding with a minimal case and mark it **confirmed** or **unconfirmed**.
- Do not discard friction a tester actually experienced because you know the design intent. When the cause cannot be confirmed, keep the observation and state your confidence in its cause and generality separately.
- Reading the product's implementation or tests does not by itself make a defect. Distinguish a task solved through the public interface from one solved only after reading internals, and from one solved by following existing code in the using project or external references.

### 5. Aggregate

- For each finding keep four parts apart: **tester observation**, **verification result**, **parent analysis**, **recommendation**.
- Classify each finding by where the fix belongs:
  - **Docs**: no worked example, hard to find, misleading.
  - **Error messages and checks**: the message does not say what to do next, or a mistake passes silently.
  - **Implementation bugs**: behaviour differs from the docs or spec.
  - **Design decisions**: limits and trade-offs by design. Give options and a recommendation with reasons; the author decides.
- Tag each finding with the AI usability qualities it affects:
  - **Discoverability**: could the agent find the feature or information it needed?
  - **Interpretability**: did it understand names, descriptions and outputs correctly?
  - **Recoverability**: could it correct a failure on its own?
- Record efficiency as observed cost in the task outcomes (attempts, failed attempts, material consulted, corrections after diagnostics), not as a separate quality. Where useful, say which quality problem drove the cost up. Token counts and wall-clock time are optional and read only alongside their conditions; do not treat them as an absolute benchmark across different conditions.
- Separate difficulty inherent in an external specification from friction the product's interface adds, as far as you can.
- Give severity by impact and recoverability, taking into account occurrence across tasks, effect on the main path and reproducibility. A severe finding from one task alone still stays in. No numeric scoring.
- Keep what worked well: interfaces that were easy to find, APIs whose names led to correct guesses, examples that helped, diagnostics that led to a self-correction. It tells the author what must not break.
- The author decides the priority of findings and the outcome of design decisions.
- Write the report in the language the user wrote in, using the structure below.

### 6. Clean up

- Compare `git status` with the starting record.
- Revert only changes certainly made by the testers (a rewritten lockfile, for instance). Leave anything uncertain in place and list it in the report.

## Report structure

1. **Conditions**: target version or commit; the testers' model name or ID, agent harness and tools; whether the parent could see the testers' history; fresh-context independence, including automatically loaded instruction files; information access condition; setup included or excluded; task definitions; attempt or time limits; for comparisons, which tasks are fixed and any condition that differs.
2. **Task outcomes**: per task, the tester's completion (`success` / `partial` / `failure`) and the parent's check against the completion condition; main actions and failed attempts, marked as reconstructed from history or self-reported; information sources by category, the decisive source and the path to it; when internals were read, when, why, which files and what was learned; observed cost; corrections after diagnostics; advice given and what changed after it; decision traces.
3. **Findings**: per finding, the tester observation; confirmed or unconfirmed; affected tasks; fix category; AI usability qualities; severity; verification; parent analysis; recommendation.
4. **What worked well**: where the agents found, understood, operated or self-corrected easily.
5. **Setup record**: what the parent prepared, the commands, and any problems. Omit when setup was included.
6. **Changes left in the working tree**: when any were left.
7. **Limitations**: always include these.
   - The results depend on the model, harness and tools used.
   - Pretraining cannot be controlled; the model may already know the product or similar ones.
   - This test does not directly evaluate usability for people.
   - What setup exclusion left out of the evaluation (when setup was excluded).
   - The findings are candidates for a roadmap, not the roadmap. The author sets the priorities.
   - Where they apply: lost independence, and the influence of external information or environment constraints.
