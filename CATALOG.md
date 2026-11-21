# Catalog

Every skill in this repository: what it is for, the gap it fills, and what it leaves out.
A skill is listed here only when it teaches something an agent cannot get from the tool's `--help` and docs on its own.

| Skill | Kind | For |
| --- | --- | --- |
| [rumdl](skills/rumdl/SKILL.md) | Tool | Adopting, tuning and reviewing the rumdl Markdown linter in a repository |

## Skills in other repositories

Skills that ship with a tool live in that tool's repository, so they are versioned with it.
Each repository describes its own skills; this table only points to them.

| Skill | For | Install |
| --- | --- | --- |
| [justz-cli](https://github.com/igorlino/justz/tree/main/skills/justz-cli) | Running and troubleshooting the `justz` CLI on top of `just` | `npx skills add igorlino/justz --skill justz-cli` |
| [justfile-authoring](https://github.com/igorlino/justz/tree/main/skills/justfile-authoring) | Authoring discoverable, documented justfiles | `npx skills add igorlino/justz --skill justfile-authoring` |

## rumdl

**Install:** `npx skills add igorlino/agent-skills --skill rumdl`

**Use it when** an agent adds Markdown linting to a project, writes or reviews a `.rumdl.toml`, or reviews what `rumdl fmt` changed.

**What it teaches:**

- How to choose a policy: the flavor by renderer, the opt-in rules with a condition for each, the line-length strategy and its trade-offs, and the file scope.
- Where an exception goes: the config, per-file settings or an inline comment.
- How to measure candidate configs on a scratch copy before touching the working tree.
- A fix order that keeps the history reviewable: hand fixes, then a formatting-only commit, a word-level diff to prove no words changed, and `.git-blame-ignore-revs`.
- Auto-fixes that change meaning, each reproduced on a named rumdl version.
- How to keep a repository's own checks working, such as line budgets and string searches in docs.
- Why a local run can differ from CI: user-level config, markdownlint fallback and wrapper flags.
- How to extend an existing narrow config without losing its link checks, and how to treat files that must stay byte-identical.

**The gap it fills.**
A survey of public rumdl skills on GitHub on 2026-11-21 found six.
They teach the CLI well: installation, `check` and `fmt`, inline suppression and CI.
None of them covers the decisions:

| Topic | Covered by the surveyed skills |
| --- | --- |
| Install, commands, `check` against `fmt` | Most of them |
| CI with the official action | Some of them |
| Why rumdl keeps rules opt-in, and when to enable each | None |
| Choosing a flavor per renderer | Mentioned, not taught |
| Sentence-per-line reflow and its effect on line budgets | None |
| Auto-fixes that change meaning | None |
| A fix order and a review method for the formatting pass | None |

Some also copy facts from rumdl's docs, such as the number of rules or flavors, and those go stale with each release.
This skill sends the agent to the installed binary (`rumdl explain`, `rumdl config --defaults`) and to rumdl's own docs for facts, and keeps only judgment in the skill.

**What it leaves out:** a reference of every rule and option, which rumdl's docs and `rumdl explain` already provide.
Editor and LSP setup.
Writing the prose itself.

**Tested with:** rumdl 0.3.5, and in a fresh agent session that extended a links-only rumdl setup to style linting on a repository it had not seen (scenario 5 in [evals/rumdl.md](evals/rumdl.md)).
