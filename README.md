# skills

Claude Code skills by iwamot, distributed as a [Claude Code plugin marketplace](https://docs.claude.com/en/docs/claude-code/plugin-marketplaces) and compatible with the [Agent Skills standard](https://agentskills.io) (`gh skill install`).

## Available skills

| Plugin | Skill | Purpose |
|--------|-------|---------|
| `renovate-tools` | `renovate-coverage` | Audit a repo for version-like strings present in Renovate-managed files but missing from the open Dependency Dashboard issue. |

## Install

### Claude Code (plugin marketplace)

```
/plugin marketplace add iwamot/skills
/plugin install renovate-tools@iwamot-skills
```

Pin to a tag:

```
/plugin marketplace add https://github.com/iwamot/skills.git#v0.1.0
```

### Agent Skills CLI (`gh skill`)

```bash
gh skill install iwamot/skills renovate-coverage
```

Pin to a tag:

```bash
gh skill install iwamot/skills renovate-coverage --pin v0.1.0
```

## Layout

```
.
├── .claude-plugin/marketplace.json   # marketplace + plugin declarations
├── skills/                           # skills, flat layout
│   └── renovate-coverage/
│       ├── SKILL.md
│       └── scripts/
├── mise.toml                         # dev tool pins (jq, node, shfmt, ...)
├── validate.sh                       # local validation entry point
└── .github/                          # CI workflows, Renovate config
```

## Local development

Clone the repo and symlink an individual skill into `~/.claude/skills/` for live editing in Claude Code:

```bash
git clone https://github.com/iwamot/skills ~/skills
ln -s ~/skills/skills/renovate-coverage ~/.claude/skills/renovate-coverage
```

Run validation locally:

```bash
mise install
bash validate.sh
```

`validate.sh` runs:

- `shfmt` + `shellcheck` for shell scripts
- `zizmor` for GitHub Actions
- `check-jsonschema` for `marketplace.json` against [SchemaStore](https://www.schemastore.org/json/)
- `skill-check` (community linter) for SKILL.md quality
- `gh skill publish --dry-run` against the Agent Skills spec

## License

[MIT](LICENSE)
