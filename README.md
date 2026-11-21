# agent-skills

Agent skills for developer tools: the judgment a tool's `--help` does not give.
Each skill teaches when and why to use a tool's options, the traps its automatic fixes fall into, and how to adopt it in a repository without a messy history.
Facts stay in the tool's own docs; the skill points to them.

## Install

With the [skills CLI](https://github.com/vercel-labs/skills), for any agent it supports:

```bash
npx skills add igorlino/agent-skills                 # every skill
npx skills add igorlino/agent-skills --skill rumdl   # one skill
```

In Claude Code, as a plugin:

```text
/plugin marketplace add igorlino/agent-skills
/plugin install agent-skills@agent-skills
```

## Skills

| Skill | For |
| --- | --- |
| [rumdl](skills/rumdl/SKILL.md) | Adopting, tuning and reviewing the rumdl Markdown linter in a repository |

[CATALOG.md](CATALOG.md) says, for each skill, what it teaches, the gap it fills against other public skills, and what it leaves out.

## Quality bar

- Every claim about a tool is checked against a named version of it, and the skill says which.
- A skill does not copy the tool's docs: it links to them and to the tool's own commands.
- A skill is self-contained: it links only to its own files or to full URLs.
- `just ci` checks the frontmatter, the size of each `SKILL.md`, the Markdown and the justfile.

## License

[MIT](LICENSE)
