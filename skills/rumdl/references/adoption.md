# rumdl: adopting it in a repository

How to go from no Markdown linting to a passing gate, with a history a reviewer can trust.

## Contents

- [Measure before you choose](#measure-before-you-choose)
- [Fix order](#fix-order)
- [Review the formatting pass](#review-the-formatting-pass)
- [Fit the repository's own checks](#fit-the-repositorys-own-checks)
- [Commits and blame](#commits-and-blame)
- [Report](#report)

## Measure before you choose

Measure on a scratch copy, so a candidate config never touches the working tree.
Copy the tracked files, not only the Markdown: link checks need the files the links point to.

```bash
scratch=$(mktemp -d)
git ls-files -co --exclude-standard | tar -cf - -T - | tar -xf - -C "$scratch"
cp candidate.rumdl.toml "$scratch/.rumdl.toml"
cd "$scratch"
rumdl check --statistics .          # findings per rule, before
rumdl fmt .                         # apply every fix
rumdl check .                       # what is left needs a hand fix
```

For each candidate, compare:

| Measure | How |
| --- | --- |
| Findings per rule | `rumdl check --statistics .` |
| Findings left after `rumdl fmt` | `rumdl check .` on the copy |
| Lines changed by the fix | `git diff --stat` (initialize a repository in the copy first, or diff against the original tree) |
| Word changes, which must be few and deliberate | the word diff in [Review the formatting pass](#review-the-formatting-pass) |
| Damage to the repository's own checks | run its test suite in the copy |

A good config leaves only a few findings that need judgment.
If hundreds remain, a rule or an option does not fit the repository: change the config, not the files.

## Fix order

1. **Add the config and the recipes**, with the check reporting only.
2. **Fix by hand what `rumdl fmt` cannot fix, or would fix wrongly.**
   Run `rumdl check .` and read what has no `[*]` marker: those findings have no auto-fix.
   Typical ones: emphasis used as a heading (MD036), a missing first heading (MD041), duplicate headings.
   Also fix first anything the auto-fix would damage (see [pitfalls](pitfalls.md)): reword the text so the fix has nothing to break.
3. **Run `rumdl fmt .`** and commit the result alone.
4. **Verify** that `rumdl check .` passes and that the repository's tests still pass.

Hand fixes come first because they change meaning and need a reviewer's attention.
The formatting pass comes last because it is mechanical and can be reproduced: anyone can re-run it and get the same tree.

## Review the formatting pass

A formatting pass must change layout, not words.
This command shows only changed tokens, ignoring whitespace, table pipes, colons and dashes:

```bash
git diff --word-diff=porcelain --word-diff-regex='[^[:space:]|:-]+' -- '*.md' \
  | grep -E '^[-+][^-+]' | sort | uniq -c | sort -rn
```

Expect a short list: added fence languages (`text`), `$` prompts removed from commands, bare URLs wrapped in `<>`.
Look at every other line.
A changed word, a changed letter case or a changed code span is a finding to fix by hand (see [pitfalls](pitfalls.md)).

## Fit the repository's own checks

A formatting pass can break checks that read Markdown.

| Check | What breaks | Fix |
| --- | --- | --- |
| A budget in lines (README under N lines, skill files under N lines) | Sentence-per-line or a narrow width adds lines | Budget in words, and count only tokens with a letter or digit, so table pipes and list dashes do not count |
| A budget on a bullet's length | The bullet now continues on indented lines | Count the continuation lines as part of the bullet |
| A test that searches a doc for a string | Reflow splits the string across two lines | Search for a shorter, unbreakable token, or join lines before searching |
| A snapshot or golden file | Any reformat | Exclude the file from rumdl |
| A generated file checked for staleness | The generator writes the old layout | Change the generator, or exclude the file |

Run the full test suite after the formatting pass, not only `rumdl check`.

## Commits and blame

Make two commits, or two pull requests:

1. The config, the recipes, the CI step, the hand fixes and any test changes.
2. `rumdl fmt` alone, with a message that says how to review it (`git show --word-diff`).

Merge them so that both reach the main branch as separate commits (a rebase or a merge commit, not a squash).
Then add the formatting commit to `.git-blame-ignore-revs`, so `git blame` shows who wrote each line, not who reformatted it:

```text
# style(docs): apply rumdl fmt to every Markdown file
<full 40-character hash of the commit on the main branch>
```

GitHub reads the file on its own.
Locally, run `git config blame.ignoreRevsFile .git-blame-ignore-revs` once.
Use the hash the commit has on the main branch: a rebase merge gives it a new one.

## Report

Tell the user:

- the config, and the reason for each choice;
- the number of findings before and after, per rule;
- what you fixed by hand, and why `rumdl fmt` could not;
- every auto-fix you corrected, with the file and line;
- every exception you added, and its layer;
- what the repository's tests needed.
