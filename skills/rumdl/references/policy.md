# rumdl: choosing the policy

A `.rumdl.toml` makes four decisions: where the Markdown is rendered, which rules run, how lines are broken, and which files are in scope.
Make each one on purpose, and write the reason as a comment next to it.

## Contents

- [Flavor](#flavor)
- [Opt-in rules](#opt-in-rules)
- [Line length](#line-length)
- [Style rules with a choice](#style-rules-with-a-choice)
- [Scope](#scope)
- [Migrating from markdownlint](#migrating-from-markdownlint)
- [A starting config](#a-starting-config)

## Flavor

The flavor tells rumdl which syntax the renderer understands, so it does not flag valid syntax as an error.
Pick it by where the files are read.

| Files are read on | Flavor |
| --- | --- |
| GitHub or GitLab, as plain repository docs | `gfm` |
| An MkDocs or Material for MkDocs site | `mkdocs` |
| MDX components | `mdx` (detected from `.mdx`) |
| Quarto or R Markdown | `quarto` (detected from `.qmd`, `.Rmd`) |
| Pandoc, Hugo, Jekyll (kramdown), MyST or Sphinx, Obsidian, an Azure DevOps wiki | the flavor of that name |

A repository often has two renderers, for example GitHub for the README and MkDocs for `docs/`.
Set the main one in `[global] flavor` and the other in `[per-file-flavor]`.
`rumdl` reads the list of flavors and the rules each one changes from `docs/flavors.md`: check it for the installed version.

## Opt-in rules

These rules are off by default because they enforce a choice that not every project makes.
Turn one on with `extend-enable` (not `enable`, which replaces the default set) only when its condition holds.
The list below is for rumdl 0.3.5; run `rumdl rule` and read `rules.md#opt-in-rules` for the installed version.

| Rule | What it enforces | Enable when |
| --- | --- | --- |
| MD060 | Table formatting | The docs have many tables. Pick `style = "compact"` when tables are edited often (one edit does not re-pad the table), `"aligned"` when they are read as source |
| MD063 | Heading capitalization | The house style names a heading case, and you will review every fix by hand (see [pitfalls](pitfalls.md#md063-heading-case)) |
| MD072 | Sorted frontmatter keys | Frontmatter has no meaningful order |
| MD073 | Table of contents is current | The files use rumdl's TOC markers |
| MD074 | MkDocs nav lists every page | The flavor is `mkdocs` |
| MD080 | Heading anchors do not collide | The renderer does not add `-1` suffixes to duplicate anchors. GitHub does, and Keep a Changelog repeats `### Added` on purpose |
| MD082 | No empty sections | Stubs are not intentional. With a Keep a Changelog file, set `allow-parent-headings = true` |
| MD083 | No mojibake | You have seen encoding damage |
| MD084 | No invisible characters | The files are instructions for agents (skills, `AGENTS.md`): hidden characters can smuggle text past a reviewer. Expect false positives in right-to-left text |
| MD085 | Paragraph continuation indent | Nobody indents continuation lines on purpose |
| MD087 | Unused disable comments | The files have inline disable comments |
| MD088 | ASCII or typographic quotes and dashes | The house style picks one |
| MD089 | Spacing between CJK and Latin text | The docs mix CJK and Latin text |
| MD090 | No horizontal rule before a heading | The files are not slide decks |
| MD091 | No Markdown inside block HTML | The renderer does not parse Markdown there |
| MD093 | No code or emphasis in headings | Headings never name a command or a file. Leave it off for CLI and API docs |
| MD095 | No confusable characters in link targets | Links point to external sites a reader may trust: this catches look-alike domains |
| MD096 | Sorted table rows | A table has a named sort column |

Use `--enable all` only to survey: it shows every rule that could fire, with its default options, which are often the wrong ones for the repository.

## Line length

MD013 decides how prose is broken into lines.
This decision rewrites the most lines, so ask the user before you apply it.

| Strategy | Config | Good for | Cost |
| --- | --- | --- | --- |
| Wrap at a width | `line-length = 80` (or 100, 120), `reflow = true` | Files read in a terminal or a narrow editor | A one-word edit can re-wrap a whole paragraph; a diff shows many lines |
| One sentence per line | `line-length = 0`, `reflow = true`, `reflow-mode = "sentence-per-line"` | Docs reviewed as pull requests | Line counts grow; tests that budget lines must count words instead |
| Semantic line breaks | `reflow-mode = "semantic-line-breaks"` | Long technical sentences | Harder to predict; read `md013.md` first |
| No reflow, a generous limit | `line-length = 200`, `reflow = false` | Repositories that will not accept a mass reformat | Long lines stay long |

Rendered output is the same in every strategy: Markdown joins the lines of a paragraph.

Two MD013 options matter whatever the strategy:

- `code-blocks = false` when code blocks hold real program output, which must stay as printed.
- `tables = false` is the default; a table row cannot be wrapped.

## Style rules with a choice

Some default rules enforce one of several styles: list markers (MD004), ordered list numbers (MD029), code block style (MD046), fence characters (MD048), emphasis and strong markers (MD049, MD050), table pipes (MD055).
Their default is usually `consistent`: the first style found in a file wins.
Set an explicit style only when the files disagree, and pick the style most of them already use, so the fix touches the fewest lines.
Count with `rumdl check --statistics`.

## Scope

rumdl respects `.gitignore` by default (`respect-gitignore = true`).
Then decide, file by file, about the rest:

| Kind of file | Decision |
| --- | --- |
| Snapshot fixtures, golden files, anything a test compares byte for byte | `exclude` |
| Generated docs (API references, CLI references produced by a script) | `exclude`, or lint the generator's template instead |
| Vendored docs copied from another project | `exclude` |
| Test fixtures that only need to be valid Markdown | Keep, and re-run the tests after the fix |
| A GitHub issue or pull request template | Keep, with `[per-file-ignores]` for MD041 (it starts with a comment) |
| `CHANGELOG.md` in Keep a Changelog format | Keep; see MD080 and MD082 above |

## Migrating from markdownlint

rumdl reads an existing markdownlint config (`.markdownlint.json`, `.markdownlint-cli2.jsonc` and the other names) when it finds no rumdl config, so a first run needs no conversion.
To make rumdl the owner, convert it: `rumdl import .markdownlint.json --dry-run` shows the `.rumdl.toml` it would write, and the same command without `--dry-run` writes it.
The import cannot know which rumdl-only rules you want; add them from the table above.
Delete the markdownlint config in the same change, so two tools do not disagree.

## A starting config

For repository docs read on GitHub and reviewed as pull requests:

```toml
[global]
# The docs are read on GitHub.
flavor = "gfm"
# Tables are frequent and edited often.
extend-enable = ["MD060"]

[MD013]
# One sentence per line: a word change is a one-line diff.
line-length = 0
reflow = true
reflow-mode = "sentence-per-line"
# Code blocks hold real program output.
code-blocks = false

[MD060]
style = "compact"

[per-file-ignores]
# GitHub templates start with an HTML comment.
".github/pull_request_template.md" = ["MD041"]
```

Adapt it to what the survey found; do not copy it unchanged.
