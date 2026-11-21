# rumdl: pitfalls

Auto-fixes that change meaning, and results that surprise.
Each one was reproduced on rumdl 0.3.5.
Re-check on a newer version before you rely on it: a fixed bug is good news, and the advice to read the diff still holds.

## Contents

- [MD063 heading case](#md063-heading-case)
- [MD038 spaces in code spans](#md038-spaces-in-code-spans)
- [Changes that are usually fine](#changes-that-are-usually-fine)
- [Findings without an auto-fix](#findings-without-an-auto-fix)
- [`--enable all` uses default options](#--enable-all-uses-default-options)
- [`rumdl fmt` exits 0](#rumdl-fmt-exits-0)
- [Your run is not CI's run](#your-run-is-not-cis-run)

## MD063 heading case

MD063 is opt-in.
Its fix changes words in headings, so review each one.

With `style = "sentence-case"`:

| Before | After |
| --- | --- |
| `## 1. Install the tool` | `## 1. install the tool` |
| `## GitHub Actions setup` | `## GitHub actions setup` |

The first word after a number is lowercased, and the second word of a multi-word name is lowercased.
With the default `style = "title-case"`, a lowercase product name at the start of a heading gets a capital: `# justz` becomes `# Justz`.

`ignore-words` keeps listed words as written, and `preserve-cased-words = true` (the default) keeps words with an inner capital such as `macOS`.
Neither fixes the numbered headings.
If the docs number their headings, leave MD063 off, or fix the headings by hand and use the rule only to report.

## MD038 spaces in code spans

MD038 removes spaces at the edge of a code span.
That is right for a typo, and wrong when the space is the point:

```markdown
`tool.clean ` is not `tool.clean`.
```

becomes `` `tool.clean` is not `tool.clean`. ``, which is false.
Before the formatting pass, reword such sentences so they do not depend on the space: "`tool.clean` with a trailing space".

## Changes that are usually fine

These change a token, so they show up in the word diff, but they rarely change meaning.
Read them anyway.

| Rule | Change |
| --- | --- |
| MD040 | An unlabeled code fence gets the language `text` |
| MD014 | A `$` prompt is removed from commands shown without output |
| MD034 | A bare URL is wrapped in `<>` |

MD014 leaves a block alone when the prompt is followed by output, so a transcript keeps its `$`.

## Findings without an auto-fix

`rumdl check` marks fixable findings with `[*]`.
The rest need a decision:

| Rule | Finding | Usual fix |
| --- | --- | --- |
| MD036 | A bold or italic line used as a heading | Make it a real heading, or end it with punctuation (`**Fix:**`) so it reads as a label |
| MD041 | The file does not start with a top-level heading | Add one, or `per-file-ignores` for templates that start with a comment |
| MD024 | Duplicate heading text | Rename, or accept in a changelog |

## `--enable all` uses default options

`--enable all` turns on every opt-in rule with its default options, which are rarely the ones you would choose.
Examples on 0.3.5: MD013 at 80 columns including headings, and MD063 in title case.
Expect hundreds of findings that disappear once the policy is chosen.
Use it to see what could fire, never as the config.

## `rumdl fmt` exits 0

`rumdl fmt` applies the fixes and exits 0, even when findings without a fix remain.
`rumdl check` and `rumdl check --fix` exit 1 when any finding remains.
A CI gate must run `rumdl check`.

## Your run is not CI's run

rumdl finds its config by searching up from each file, and applies a user-level config (`~/.config/rumdl/` and the other locations in `configuration/index.md`) when the project has none.
It also reads a markdownlint config when there is no rumdl config.
So a run on your machine can use rules that CI does not see.

| Symptom | Check |
| --- | --- |
| Local and CI disagree | `rumdl config file` in both: the loaded file must be the project's `.rumdl.toml` |
| A wrapper script gives other results than `rumdl check .` | The wrapper may pass `--no-config`, `--enable` or `--config`, which replace the project config |
| A finding mentions a rule you did not enable | `rumdl config` shows the effective rule set, and where each value came from |
| A typo in `.rumdl.toml` is silently ignored | Run with `--deny-config-warnings`, which makes config warnings exit 2 |
