# Common tester rules

Paste the block below after the task-specific information. Replace each `<...>` with the value for this run. A line that starts with `[Only when ...]` is conditional: keep it, without the marker, only when the condition holds, and otherwise delete it. With no limits set, which is the default, delete the limits line.

````markdown
## Rules for this task

Work on this task as you normally would when a user asks you for it. We record how you find, understand, use and recover with this product, so a place where you got stuck or had to search is a useful result, not a failure.

### What you may use
- <Information access. Default: anything you would normally use, including the product's own material, existing code and config in the project you are working in, web search, external official documentation, and the product's implementation and tests.>
- If you come across development discussions about this product, or earlier evaluation reports of it, note where you found them and what you used from them.

### Where you work
- Local paths you may read, in addition to the sources above: <paths of the product repository and the using project>.
- Write only in <this tester's working directory>, and save everything you produce there.
- Do not read: <other testers' working directories and the parent's notes>.
- Do not change files in the original product repository or using project. A copy inside your working directory is yours to edit, including its tracked files.
- Do not deploy anything to an external environment.
- [Only when limits are set] Try at most <N> attempts / aim to finish within about <N> minutes. When you reach a limit, stop and report the state you are in.

### Environment problems
If you are stopped by environment or dependency setup, record it separately from the task result. Report, as far as you can confirm, whether the cause lies in:
- a constraint of the execution environment,
- missing or unclear product material, or
- a defect in how the product is distributed or in its dependencies.
Do not dig further than that.

### What to note as you go
Keep working naturally; do not stop to write a detailed log. The parent may not be able to see your command and tool history, so the final report's main path is where the path is recorded. At natural break points, or in the final report, add short notes on what a history would not show:
- why you chose an API or command, and where you hesitated between candidates,
- what you inferred from documentation rather than read directly,
- what you changed in response to an error or diagnostic,
- what remains uncertain.

Tie each note to what you actually read, did and saw. If you write a note in the final report and no longer remember why you made a choice, say so; do not fill the gap with a plausible guess. Use this form:

```text
Observation: README describes both "compile" and "build".
Decision: Used "compile" because its documented output matched the requested artifact.
Result: The command produced the required artifact.
```

### Final report
1. Completion: `success`, `partial` or `failure`, and what you produced against the completion condition.
2. Main path: the commands and actions that mattered, and the attempts that failed (with the actual error, verbatim).
3. Information sources, by category, and which one was decisive for each step that mattered and how you reached it:
   - **Product interface material**: README, docs, examples, help, public API declarations and types.
   - **Product implementation source**: the product's internal code or its own tests.
   - **External reference**: official docs of other products, public web material.
   - **Existing project context**: code, config and usage in the project you are working in.
   - **Runtime diagnostics**: execution results, error messages, compiler diagnostics.
   - **General knowledge**: no specific source.
4. If you read the product's implementation or tests: when, what you were trying to resolve, which files, and what you learned.
5. Decision notes, as above.
6. Whether you needed advice from the user or parent, and what changed after it.
7. What worked well: interfaces, examples or diagnostics that helped you find, understand or fix something.
````
