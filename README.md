# skills

Agent Skills by iwamot. Installable via [`gh skill install`](https://cli.github.com/manual/gh_skill_install).

## Available skills

| Skill | Purpose |
|-------|---------|
| `renovate-coverage` | Audit a repo for version-like strings present in Renovate-managed files but missing from the open Dependency Dashboard issue. |

## Install

```bash
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
