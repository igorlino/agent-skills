---
name: rumdl
description: >
  Teaches agents how to adopt, tune and review rumdl, the Rust Markdown linter and formatter, in a
  repository. Use when adding Markdown linting to a project, writing or reviewing a `.rumdl.toml`,
  choosing a Markdown flavor or which opt-in rules to enable, deciding between a line-length limit
  and sentence-per-line reflow, placing an exception in config, per-file settings or an inline
  comment, migrating from markdownlint, wiring rumdl into CI or a task runner, or reviewing what
  `rumdl fmt` or `rumdl check --fix` changed. Do not use for writing the prose of a document, or for
  a repository that standardizes on another Markdown tool (markdownlint-cli2, Prettier, mdformat)
  unless the task is moving to rumdl.
metadata:
  author: igorlino
  domain: markdown-linting
  version: "1.0.0"
  tested-with: "rumdl 0.3.5"
---

# rumdl

Running rumdl is easy; choosing its policy is where agents go wrong.
`--enable all` is a survey, not a policy: rumdl keeps a set of rules off by default on purpose, and some of its auto-fixes change meaning.
This skill is the judgment layer.
rumdl's own docs and CLI are the facts layer: read them, do not recall them.

## Read the installed version, not your memory

rumdl ships often, and rules, options and flavors change between minor versions.
Never quote a rule count, an option name or a default from memory.

| Question | Ask rumdl |
| --- | --- |
| Which version runs here, and which config file is loaded | `rumdl --version`, `rumdl config file` |
| The effective configuration | `rumdl config` |
| Every option of every rule, with its default | `rumdl config --defaults` |
| What a rule checks, its options and examples | `rumdl explain MD013` |
| The list of rules | `rumdl rule` |

| Topic | Page in the rumdl repository (`https://github.com/rvben/rumdl/blob/main/docs/`) |
| --- | --- |
| Opt-in rules and why each is off | `rules.md#opt-in-rules` |
| Flavors | `flavors.md` and `flavors/<name>.md` |
| `[global]`, include/exclude, `per-file-ignores`, `per-file-flavor` | `global-settings.md` |
| Inline comments | `inline-configuration.md` |
| Line length and reflow modes | `md013.md` |
| CI and pre-commit | `usage/ci-cd.md`, `usage/pre-commit.md` |

When the docs and the installed binary disagree, the binary wins: the docs on `main` may describe an unreleased version.

## Workflow: adopt rumdl in a repository

1. **Survey the repository** before you write any config.
   List: existing Markdown tools and their config, the CI workflow, the task runner, tests that read Markdown files (line or word budgets, string matches, snapshots), generated, vendored and fixture files, and the house style (heading case, wrapping, table style).
2. **Measure on a scratch copy.**
   Try two or three candidate configs, run `rumdl fmt`, and compare what remains and what the diff looks like.
   See [references/adoption.md](references/adoption.md#measure-before-you-choose).
3. **Write the policy** in `.rumdl.toml`, one comment per choice that says why.
   See [references/policy.md](references/policy.md).
4. **Fix in a reviewable order**: hand fixes that change meaning first, then `rumdl fmt` alone in its own commit, then verify that it changed no words.
   See [references/adoption.md](references/adoption.md#fix-order).
5. **Gate it**: `rumdl check` in CI with a pinned version, plus a lint and a fix recipe in the task runner.
   See [references/ci.md](references/ci.md).
6. **Report** what you chose, what you fixed by hand, what the auto-fix got wrong, and every exception you added.

Ask the user before a choice that rewrites many files in a way they may not want: the line-length strategy and heading case are the usual two.

## Rules

- **Start from the default rule set.**
  Enable an opt-in rule only when its reason fits the repository, and write that reason in the config.
- **Fix the text when the finding is right.**
  Change the config only when the finding is wrong for the whole repository.
- **Put each exception in the narrowest layer that covers it**, with the reason next to it.
- **`rumdl check` gates, `rumdl fmt` fixes.**
  `rumdl fmt` exits 0 even when findings remain; `rumdl check` and `rumdl check --fix` exit 1.
- **Read every auto-fix that can change words, case or code spans.**
  See [references/pitfalls.md](references/pitfalls.md).
- **Keep the formatting pass in a commit of its own**, and list it in `.git-blame-ignore-revs`.
- **Pin the rumdl version in CI**, so an upgrade with new rules cannot fail an unrelated pull request.
- **Do not reformat files that other tools compare byte for byte**: snapshot fixtures, generated files, vendored docs.
  Exclude them.

## Where an exception goes

| Scope | Layer | Example |
| --- | --- | --- |
| The whole repository | `.rumdl.toml`: `[global]` or a rule section | `[MD013] code-blocks = false` |
| Files of another format or renderer | `[per-file-flavor]`, `[per-file-ignores]`, `exclude` | `".github/pull_request_template.md" = ["MD041"]` |
| One file | `<!-- rumdl-disable-file MD033 -->` or `<!-- rumdl-configure-file { ... } -->` at the top | a page that embeds HTML on purpose |
| One block or one line | `<!-- rumdl-disable MDxxx -->` ... `<!-- rumdl-enable MDxxx -->`, `<!-- rumdl-disable-next-line MDxxx -->` | one long URL in a table cell |

Inline comments are invisible when rendered but visible to every agent that reads the file.
If the same inline comment appears in three files, it belongs in the config.

## References

| File | Read it when |
| --- | --- |
| [references/policy.md](references/policy.md) | Choosing the flavor, the opt-in rules, the line-length strategy and the file scope |
| [references/adoption.md](references/adoption.md) | Measuring candidates, ordering the fixes, reviewing the diff, fitting existing tests |
| [references/pitfalls.md](references/pitfalls.md) | Reviewing what an auto-fix changed, or when a result surprises you |
| [references/ci.md](references/ci.md) | Installing rumdl in CI, pre-commit and a task runner |
