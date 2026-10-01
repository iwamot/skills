# skills

[![release](https://img.shields.io/github/v/release/iwamot/skills)](https://github.com/iwamot/skills/releases)

Agent Skills by iwamot. Installable via [`gh skill install`](https://cli.github.com/manual/gh_skill_install).

## Available skills

| Skill | Purpose |
|-------|---------|
| `agent-cli` | Design or review a CLI that coding agents call from a shell: instruction paragraph, error messages with the next step, exit codes by layer, output contract, README structure. |
| `newcomer-trial` | Find where new users get stuck by having subagents that do not know a product carry out real tasks from its public material alone, then verify and classify what they hit. |
| `renovate-coverage` | Audit a repo for version-like strings present in Renovate-managed files but missing from the open Dependency Dashboard issue. |

## Install

```bash
gh skill install iwamot/skills agent-cli
gh skill install iwamot/skills newcomer-trial
gh skill install iwamot/skills renovate-coverage
```

Pin to a tag:

```bash
gh skill install iwamot/skills renovate-coverage --pin vX.Y.Z
```

## Local validation

```bash
mise install
bash validate.sh
```

## License

MIT
