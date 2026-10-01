# Common trial rules

Paste the block below after the task-specific information. Replace each `<...>` with the value for this run; delete a line in brackets only when it does not apply.

```markdown
## Rules for this trial

You are trying this product for the first time, as a user would. Work only from the material listed here; your record is what we use to find where users get stuck, so a place where you got stuck is a useful result, not a failure.

### What you may read
- <Material scope. Default: README, docs/, examples/, the product's --help output and its diagnostic messages.>
- External links found in that material: <may be followed | must not be followed>.
- Do not read the implementation (<src/, tests/, ...>) unless this task says you may.

### Where you work
- Work in <scratch directory for this task> only. Do not change tracked files in the repository. Do not deploy anything to an external environment.
- Save everything you produce in that directory.

### How to proceed
- Start with the approach that feels most natural to you.
- If you cannot meet the completion condition, or you are unhappy with the output, also try other means the docs describe (escape hatches, lower-level APIs, and so on).
- If the product has a way to write tests, write tests with it as well.

### Limits
- Try at most 20 candidates (an implementation idea you actually ran to check).
- Aim to finish within about 30 minutes.
- When you reach either limit, stop and report the state you are in.

### Environment problems
If you are stopped by environment or dependency setup, record it separately from the task result. Report, as far as you can confirm, whether the cause lies in:
- a constraint of the execution environment,
- missing or unclear material, or
- a defect in how the product is distributed or in its dependencies.
Do not dig further than that.

### What to record as you go
The commands you ran, their exit codes, the relevant output, and the material you consulted.

### Final report
1. Whether the completion condition was met.
2. For each place you got stuck: what you tried, the actual error (verbatim), what you expected, how you resolved it (or that you gave up), and severity (blocker / annoying / minor). Include material that was hard to find.
3. A review of what you produced: compared with what someone experienced in this field would write by hand, what is unnatural, redundant or hard to read. Keep what you actually compared separate from your subjective impression.
4. How many candidates you tried, and whether you would choose this product over the existing means (writing it by hand, competing tools, and so on), with your reasons.
```
