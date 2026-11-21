# agent-skills

Skills that teach coding agents the judgment a tool's `--help` leaves out: which options fit your repository, which automatic fixes change meaning, and how to adopt the tool without a messy history.

## What a skill changes

Ask an agent to "add Markdown linting with rumdl" to a repository.

| | Without the skill | With the `rumdl` skill |
| --- | --- | --- |
| Config | `--enable all`: 1,422 findings, many from rules rumdl keeps off on purpose | Two or three candidate configs measured on a scratch copy, a reason next to each choice |
| Automatic fixes | Applied as they come: `# justz` becomes `# Justz`, and a meaningful space disappears from `` `tool.clean ` `` | Text the fix would damage is reworded first, then a word-level diff checks that the formatting pass changed no words |
| Your tests | The reflow makes the README 178 lines, and a 150-line budget test fails | Tests that read Markdown are found in the survey and adapted before the fix |
| Review | Hand edits and hundreds of reformatted lines are easy to mix in one commit | Hand fixes first, then a formatting-only commit listed in `.git-blame-ignore-revs` |

The left column is what a first attempt on [justz](https://github.com/igorlino/justz) produced, measured on a scratch copy; the right column is what an agent with only the skill did on another repository.

## Skills

| Skill | Use it when | Needs | Tested with |
| --- | --- | --- | --- |
| [rumdl](skills/rumdl/SKILL.md) | Adding, extending or reviewing Markdown linting with rumdl | rumdl, git | rumdl 0.3.5 |

[CATALOG.md](CATALOG.md) has, for each skill, what it teaches, the gap it fills against other public skills, and what it leaves out.
It also lists skills that ship in a tool's own repository, such as the [justz](https://github.com/igorlino/justz) skills.

## Install

With the [skills CLI](https://github.com/vercel-labs/skills) (Node.js 22.20 or later), for Claude Code, Codex, Cursor and the other agents it supports:

```bash
npx skills add igorlino/agent-skills --skill rumdl        # into this project
npx skills add igorlino/agent-skills --skill rumdl -g     # for every project
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

There is no command to run.
The agent loads a skill when your request matches its description, for example:

- "Add Markdown linting with rumdl to this repository."
- "This repo only checks links with rumdl; lint style too."
- "Review our `.rumdl.toml`."
- "rumdl passes locally but fails in CI."

The skill makes the agent ask before a choice that rewrites many files, such as the line-length strategy.

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
