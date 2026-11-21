import 'just/preamble.just'

_default:
    @justz help

[doc('Full command reference, or the focused docs of one group or command (help [group] [term]); -b browses, -j emits JSON')]
[group('core')]
[no-exit-message]
help *ARGS:
    #!/usr/bin/env bash
    set -euo pipefail
    # No words: the full reference. Otherwise zoom, with -b, -j and -w.
    if [[ $# -eq 0 ]]; then exec justz help --expanded; fi
    exec justz help "$@"

[doc('Check the documentation against the justfile and the registry order')]
[group('core')]
check:
    @justz check
    @justz fmt --check

[doc('Lint the Markdown files with rumdl and the rules in .rumdl.toml')]
[group('core')]
md-lint:
    @command -v rumdl >/dev/null || { echo "rumdl not found: install it, see https://github.com/rvben/rumdl#installation" >&2; exit 1; }
    rumdl check .

[doc('Apply the rumdl fixes to the Markdown files (rewrites them)')]
[group('core')]
md-fix:
    @command -v rumdl >/dev/null || { echo "rumdl not found: install it, see https://github.com/rvben/rumdl#installation" >&2; exit 1; }
    rumdl fmt .

[doc('Check every skill: frontmatter, SKILL.md size, links that leave the skill, catalog entry')]
[group('core')]
skills-check:
    bash scripts/check/skills.sh

[doc('Everything CI runs: justfile docs, Markdown lint, skill checks')]
[group('core')]
ci: check md-lint skills-check
