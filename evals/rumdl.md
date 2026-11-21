# Evals: rumdl

Scenarios to test the `rumdl` skill in a fresh agent session that has only the skill installed.
Run each on a repository the agent has not seen, and compare its work with the expected behavior.
A scenario passes when the agent does every item under "Expect" and nothing under "Must not".

## 1. Adopt rumdl in a repository with no Markdown linting

**Prompt:** "Add Markdown linting with rumdl to this repository, and make it pass."

**Expect:**

- Surveys first: existing Markdown tools, CI, task runner, tests that read Markdown, generated and fixture files, house style.
- Measures two or more candidate configs on a scratch copy before it writes `.rumdl.toml`.
- Asks before it applies the line-length strategy or heading case to the whole repository.
- Enables an opt-in rule only with a reason in a config comment.
- Fixes by hand the findings without `[*]`, and rewords text that MD038 or MD063 would damage, before it runs `rumdl fmt`.
- Puts the `rumdl fmt` output in a commit of its own, and checks it with a word-level diff.
- Runs the repository's own tests after the formatting pass.
- Gates CI with `rumdl check` and a pinned rumdl version.
- Reports findings before and after, hand fixes, corrected auto-fixes and exceptions.

**Must not:**

- Use `--enable all` as the config.
- Gate CI with `rumdl fmt`.
- Squash the formatting commit into the hand fixes.
- Quote a rule count or a default from memory.

## 2. Review a config someone else wrote

**Prompt:** "Review this .rumdl.toml" with a config that enables every opt-in rule, sets `line-length = 80` with `code-blocks = true`, and has no comments.

**Expect:**

- Asks or checks where the docs are rendered, and whether code blocks hold program output.
- Names each opt-in rule that does not fit, with the condition from the skill.
- Points out that wrapping code blocks changes pasted output.
- Suggests a comment per choice.

## 3. Local results differ from CI

**Prompt:** "rumdl passes on my machine but fails in CI."

**Expect:**

- Runs `rumdl config file` and `rumdl config`, and compares the loaded config with CI's.
- Checks for a user-level config, a markdownlint config and wrapper flags such as `--no-config`.
- Checks that CI and local use the same rumdl version.

## 4. One exception

**Prompt:** "MD013 flags one long line in a table cell in docs/api.md; make it pass."

**Expect:**

- Reads the finding first: tables are not checked by default, so it confirms the config and the line.
- Prefers fixing the text; otherwise uses an inline comment on that line, not a global change.
