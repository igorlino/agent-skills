# AGENTS.md

Instructions for coding agents that work in this repository.

## What this is

A collection of agent skills, published on [skills.sh](https://skills.sh) and as a Claude Code plugin.
Each skill lives in `skills/<name>/` and is installed on its own, without the rest of the repository.

## Running tasks (just)

This repository uses the `rich` variant of [justz](https://github.com/igorlino/justz): the command docs live in `config/commands.json`, and `justz` renders and checks them.
It needs `just`, `justz` and `rumdl`.

| Task | Command |
| --- | --- |
| List the commands | `just` |
| Everything CI runs | `just ci` |
| Lint the Markdown files | `just md-lint` |
| Fix the Markdown files | `just md-fix` |
| Check every skill package | `just skills-check` |

Run `just ci` before you say a change is done.
After you add or change a recipe, update `config/commands.json`, then run `justz fmt` and `justz check`.

## Layout

| Path | Content |
| --- | --- |
| `skills/<name>/SKILL.md` | The entry point of a skill: frontmatter, workflow, rules, a table of references |
| `skills/<name>/references/` | The longer material, loaded only when needed |
| `CATALOG.md` | Every skill: what it teaches, the gap it fills, what it leaves out |
| `evals/<name>.md` | Scenarios to test a skill in a fresh session |
| `scripts/check/skills.sh` | The checks of `just skills-check` |
| `.claude-plugin/` | The Claude Code plugin and marketplace manifests |

## Rules for a skill

- **Pass the triage first.**
  A skill teaches judgment.
  A procedure a script can run with certainty is a script or a recipe, not a skill.
- **Do not copy the tool's docs.**
  Link to them, and to the tool's own commands (`<tool> explain`, `<tool> config --defaults`).
  A copied count or default goes stale with the next release.
- **Verify every claim on a named version** of the tool, and record it in `metadata.tested-with`.
  Reproduce a pitfall before you write it down.
- **Keep a skill self-contained.**
  Link only to its own files, or to a full URL.
  `just skills-check` fails on a link that leaves the skill directory.
- **Keep `SKILL.md` an entry point**, under 500 lines: workflow, rules and a table of references.
  Long material goes in `references/`, each with a table of contents.
- **Write the description as triggers**: when to use the skill and when not to, at most 1024 characters.
  Do not summarize the workflow in it.
- **Bump `metadata.version`** (SemVer) when a skill changes, and update its `CATALOG.md` entry.
- **Test a new skill in a fresh session** with only the skill and a scenario from `evals/`, on a repository it has not seen.

## Commits

Conventional Commits, with the skill as the scope: `feat(rumdl): ...`, `fix(rumdl): ...`, `docs: ...`, `chore: ...`.
