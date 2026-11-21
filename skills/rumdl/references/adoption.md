# rumdl: adopting it in a repository

How to go from no Markdown linting, or links-only linting, to a passing gate, with a history a reviewer can trust.

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
Commit the baseline and then the candidate config in the copy, so a `git checkout .` or `git stash` later cannot silently undo the config and give wrong numbers.

```bash
scratch=$(mktemp -d)
git ls-files -co --exclude-standard | tar -cf - -T - | tar -xf - -C "$scratch"
cd "$scratch"
git init -q && git add -A && git commit -qm baseline
cp /path/to/candidate.rumdl.toml .rumdl.toml && git add -A && git commit -qm candidate
rumdl check --statistics .          # findings per rule, before
rumdl fmt .                         # apply every fix
rumdl check .                       # what is left needs a hand fix
git diff --stat                     # lines the fix changed
```

For the next candidate, reset the copy to the `baseline` commit first.
For each candidate, compare:

| Measure | How |
| --- | --- |
| Findings per rule | `rumdl check --statistics .` |
| Findings left after `rumdl fmt` | `rumdl check .` on the copy |
| Lines and files changed by the fix | `git diff --stat` |
| Word changes, which must be few and deliberate | the word diff in [Review the formatting pass](#review-the-formatting-pass) |
| Damage to the repository's own checks | run its test suite in the copy |

A good config leaves only a few findings that need judgment.
If hundreds remain, a rule or an option does not fit the repository: change the config, not the files.

## Fix order

1. **Read what the scratch run left over.**
   After `rumdl fmt` on the copy, `rumdl check .` lists the findings that need a hand fix.
   Read them there, not before the fix: some appear only after it.
   For example, once a fix adds the missing blank lines around a bold line, MD036 sees it as emphasis used as a heading.
2. **Add the config and the commands** in the real tree.
3. **Hand-fix those findings in the real tree**, and reword any text the auto-fix would damage (see `references/pitfalls.md`).
   Typical ones: emphasis used as a heading (MD036), a missing first heading (MD041), duplicate headings (MD024).
4. **Run `rumdl fmt .`** and commit the result alone.
5. **Verify** that `rumdl check .` passes and that the repository's tests still pass.

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
A token that appears once with `-` and once with `+` only moved, for example when a list item becomes its own paragraph; skip it.
Look at every other line.
A changed word, a changed letter case or a changed code span is a finding to fix by hand (see `references/pitfalls.md`).
Then read the diff of the rules that change the rendered page (MD076 lists, MD090 horizontal rules) even though their words do not change.

## Fit the repository's own checks

A formatting pass, or a new policy, can break checks that read Markdown or the config.

| Check | What breaks | Fix |
| --- | --- | --- |
| A test or wrapper that asserts the old config (an `enable` list, a "style issues are not reported" test) | The new policy | Change the assertion to what still must hold, such as "every link rule stays on" |
| A budget in lines (README under N lines, skill files under N lines) | Sentence-per-line or a narrow width adds lines | Budget in words, and count only tokens with a letter or digit, so table pipes and list dashes do not count |
| A budget on a bullet's length | The bullet now continues on indented lines | Count the continuation lines as part of the bullet |
| A test that searches a doc for a string | Reflow splits the string across two lines | Search for a shorter, unbreakable token, or join lines before searching |
| A snapshot or golden file | Any reformat | Exclude the file from rumdl |
| A generated file checked for staleness | The generator writes the old layout | Change the generator, or exclude the file |

Run the full test suite after the formatting pass, not only `rumdl check`.
Note which tests failed before you started, so you report only what you broke.

## Commits and blame

Make three commits:

1. The config, the commands, the gate, the hand fixes and any test changes.
2. `rumdl fmt` alone, with a message that says how to review it (`git show --word-diff`).
3. `.git-blame-ignore-revs` with the hash of commit 2.

Commit 1 turns the gate on, so the repository's Markdown check fails until commit 2.
Say so in the message; if every commit must pass, turn the gate on in commit 3 instead.

Merge them so that commit 2 reaches the main branch on its own (a rebase or a merge commit, not a squash).
A rebase merge gives the commits new hashes: write the hash commit 2 has on the main branch, which may mean a follow-up commit after the merge.

```text
# style(docs): apply rumdl fmt to every Markdown file
<full 40-character hash of the commit on the main branch>
```

GitHub reads the file on its own.
Locally, run `git config blame.ignoreRevsFile .git-blame-ignore-revs` once.

## Report

Tell the user:

- the config, and the reason for each choice;
- the candidates you measured, with findings before and after and lines changed;
- what you fixed by hand, and why `rumdl fmt` could not;
- every auto-fix you corrected, and every fix that changes the rendered page;
- every exception you added, and its layer;
- what the repository's tests needed, and which failed before you started.
