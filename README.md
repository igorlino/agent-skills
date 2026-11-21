# agent-skills

Skills for coding agents such as Claude Code, Codex and Cursor.
Each one teaches your agent to use a developer tool the way an experienced maintainer would: choose settings that fit your repository, check what automatic fixes change, and ask you before rewriting many files.

## Skills

| Skill | What your agent can do with it | Install from |
| --- | --- | --- |
| [rumdl](skills/rumdl/SKILL.md) | Set up, extend or review Markdown linting with [rumdl](https://github.com/rvben/rumdl) | this repository |
| [justz-cli](https://github.com/igorlino/justz/tree/main/skills/justz-cli) | Run and troubleshoot the [justz](https://github.com/igorlino/justz) CLI on top of `just` | `igorlino/justz` |
| [justfile-authoring](https://github.com/igorlino/justz/tree/main/skills/justfile-authoring) | Write discoverable, documented justfiles | `igorlino/justz` |

The justz skills live in the justz repository, so they are versioned with the tool.
[CATALOG.md](CATALOG.md) describes each skill in detail.

## Install

With the [skills CLI](https://github.com/vercel-labs/skills) (Node.js 22.20 or later), for Claude Code, Codex, Cursor and the other agents it supports:

```bash
npx skills add igorlino/agent-skills --skill rumdl               # into this project
npx skills add igorlino/agent-skills --skill rumdl -g            # for every project
npx skills add igorlino/justz --skill justfile-authoring         # a skill from another repository
npx skills use igorlino/agent-skills@rumdl --agent claude-code   # try it once, without installing
```

In Claude Code, as a plugin:

```text
/plugin marketplace add igorlino/agent-skills
/plugin install agent-skills@agent-skills
/plugin install justz@agent-skills        # the justz skills, from the same marketplace
```

| To | Run |
| --- | --- |
| See whether an installed skill has a newer version | `npx skills check` |
| Update it | `npx skills update rumdl` |
| Remove it | `npx skills remove rumdl` |

## Use

There is nothing to run.
Ask your agent in your own words, and it loads the skill when the request matches:

- "Add Markdown linting with rumdl to this repository."
- "This repo only checks links with rumdl; lint style too."
- "Review our `.rumdl.toml`."
- "rumdl passes locally but fails in CI."

Without the skill, an agent tends to turn on every rule and apply every automatic fix.
In one real run that meant 1,422 findings, headings rewritten in title case, and a test that failed after the reformat.
With the skill, the agent:

1. looks at your repository first: its existing checks, its tests, its generated files;
2. compares a few configurations on a copy, and asks you about the ones that rewrite many files;
3. fixes by hand what the automatic fix would get wrong;
4. commits the automatic reformat on its own, so you can review it at a glance.

## How the skills are made

- **Judgment, not a copy of the docs.**
  A skill links to the tool's docs and commands for facts, so it does not go stale with the next release.
- **Verified on a named version.**
  Every claim, and every pitfall, was reproduced on the version in `metadata.tested-with`.
- **Tested by a fresh agent.**
  An agent with only the skill runs a scenario from [evals/](evals/) on a repository it has not seen, and reports where the skill was unclear; those gaps are fixed before release.
- **Self-contained.**
  A skill links only to its own files or to full URLs, because it is installed without this repository.

## For agents

- Each skill is `skills/<name>/SKILL.md`: frontmatter with `name`, `description`, `compatibility` and `metadata.tested-with`, then a workflow, rules and a table of `references/` to load when needed.
- Load a reference only when `SKILL.md` points to it.
- When the installed tool disagrees with a skill, trust the tool, and report the difference as an issue.
- To change this repository, read [AGENTS.md](AGENTS.md).

## Feedback and contributing

| You have | Do this |
| --- | --- |
| A claim in a skill that is wrong for your tool version | Open an [issue](https://github.com/igorlino/agent-skills/issues) with the tool version, the command and what it printed |
| A tool that needs a skill | Open an issue: say what agents get wrong with it today |
| A change to make | Read [AGENTS.md](AGENTS.md); `just` lists the commands, and `just ci` must pass (needs `just`, [justz](https://github.com/igorlino/justz) and rumdl) |

## License

[MIT](LICENSE)
