---
name: rumdl
description: >
  Use when adding or extending Markdown linting with rumdl, writing or reviewing a `.rumdl.toml`,
  choosing a flavor, opt-in rules or a line-length strategy, placing an exception, migrating from
  markdownlint, wiring rumdl into CI or a task runner, or reviewing what `rumdl fmt` changed. Do not
  use for writing a document's prose, or for a repository that standardizes on another Markdown
  tool unless the task is moving to rumdl.
compatibility: Requires the rumdl CLI (tested with 0.3.5) and git.
metadata:
  author: igorlino
  domain: markdown-linting
  version: "1.0.0"
  tested-with: "rumdl 0.3.5"
  tags: [markdown, lint, rumdl, documentation, ci]
---

# rumdl

Running rumdl is easy; choosing its policy is where agents go wrong.
`--enable all` is a survey, not a policy: rumdl keeps a set of rules off by default on purpose, and some of its auto-fixes change meaning.
This skill is the judgment layer.
rumdl's own docs and CLI are the facts layer: read them, do not recall them.

## Requirements

- rumdl on the `PATH`; the install methods are in rumdl's `docs/getting-started/installation.md`.
- git, for the scratch copy, the commits and the word diff.
- Permission to edit the repository's Markdown, config, CI and task runner: ask first if the task did not say so.

## Read the installed version, not your memory

rumdl ships often, and rules, options and flavors change between minor versions.
Never quote a rule count, an option name or a default from memory.

| Question | Ask rumdl |
| --- | --- |
| Which version runs here, and which config file is loaded | `rumdl --version`, `rumdl config file` |
| The effective configuration | `rumdl config` |
| Every option of every rule, with its default | `rumdl config --defaults` |
| What a rule checks, in one line, and the URL of its page | `rumdl explain MD013` |
| The list of rules | `rumdl rule` |

| Topic | Page in the rumdl repository (`https://github.com/rvben/rumdl/blob/main/docs/`) |
| --- | --- |
| Opt-in rules and why each is off | `rules.md#opt-in-rules` |
| One rule, its options and examples | `md013.md` (one page per rule) |
| Flavors | `flavors.md` and `flavors/<name>.md` |
| `[global]`, include/exclude, `per-file-ignores`, `per-file-flavor` | `global-settings.md` |
| Inline comments | `inline-configuration.md` |
| CI and pre-commit | `usage/ci-cd.md`, `usage/pre-commit.md` |

When the docs and the installed binary disagree, the binary wins: the docs on `main` may describe an unreleased version.
Without network access, read the options in `rumdl config --defaults` and test a behavior on a two-line file in a scratch directory.

## Workflow: adopt or extend rumdl in a repository

1. **Survey the repository** before you write any config.
   List:
   - the current rumdl or markdownlint config, and every test, wrapper or doc that asserts its contents;
   - the CI workflow, or the local gate when there is no CI;
   - the task runner, and any wrapper script that already runs rumdl;
   - tests that read Markdown files: line or word budgets, string matches, snapshots;
   - generated, vendored and fixture files, and files kept byte-identical with another repository;
   - the house style: heading case, wrapping, table style.
2. **Measure on a scratch copy.**
   Try two or three candidate configs, run `rumdl fmt` on the copy, and compare what remains and what the diff looks like.
   See [references/adoption.md](references/adoption.md#measure-before-you-choose).
3. **Write the policy** in `.rumdl.toml`, one comment per choice that says why.
   See [references/policy.md](references/policy.md).
4. **Fix in a reviewable order**: in the real tree, hand-fix what the scratch run left over, then run `rumdl fmt` alone in its own commit, then verify that it changed no words.
   See [references/adoption.md](references/adoption.md#fix-order).
5. **Gate it**: `rumdl check` in CI (or in the local gate) with a pinned rumdl version, plus a lint and a fix command in the task runner.
   See [references/ci-and-hooks.md](references/ci-and-hooks.md).
6. **Report** what you chose, what you fixed by hand, what the auto-fix got wrong, and every exception you added.

Ask the user before a choice that rewrites many files in a way they may not want.
The line-length strategy is always one.
Heading case (MD063) is one only when the house style names a case or the user asks for it; otherwise leave the rule off, which changes nothing, and mention it in the report.

## Rules

- **Start from the default rule set.**
  Enable an opt-in rule only when its reason fits the repository, and write that reason in the config.
- **Fix the text when the finding is right.**
  Change the config only when the finding is wrong for the whole repository.
- **Put each exception in the narrowest layer that covers it**, with the reason next to it.
- **`rumdl check` gates, `rumdl fmt` fixes.**
  `rumdl fmt` exits 0 even when findings remain; `rumdl check` and `rumdl check --fix` exit 1.
- **Read every auto-fix that can change words, case, code spans or the rendered page.**
  See [references/pitfalls.md](references/pitfalls.md).
- **Keep the formatting pass in a commit of its own**, and list it in `.git-blame-ignore-revs`.
- **Pin the rumdl version** wherever the gate runs, so an upgrade with new rules cannot fail an unrelated change.
- **Do not reformat files that must stay byte for byte**: snapshot fixtures, generated files, vendored docs, files shared with another repository.
  `exclude` also turns off their link checks; to keep those, ignore only the style rules that fire there with `[per-file-ignores]`.
- **Reuse what exists.**
  Extend a wrapper script or recipe that already runs rumdl before you add a new one.

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
| [references/policy.md](references/policy.md) | Choosing the flavor, the opt-in rules, the line-length strategy and the file scope, or migrating an existing config |
| [references/adoption.md](references/adoption.md) | Measuring candidates, ordering the fixes, reviewing the diff, fitting existing tests |
| [references/pitfalls.md](references/pitfalls.md) | Reviewing what an auto-fix changed, or when a result surprises you |
| [references/ci-and-hooks.md](references/ci-and-hooks.md) | Installing rumdl in CI, pre-commit and a task runner, or upgrading it |
