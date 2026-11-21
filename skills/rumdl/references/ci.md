# rumdl: CI, pre-commit and the task runner

Run the same check in three places: the task runner (for people and agents), pre-commit (optional), and CI (the gate).
All three call `rumdl check` with the project's `.rumdl.toml` and no extra rule flags, so they agree.

## Contents

- [Task runner](#task-runner)
- [GitHub Actions](#github-actions)
- [Other CI systems](#other-ci-systems)
- [pre-commit](#pre-commit)
- [Upgrading rumdl](#upgrading-rumdl)

## Task runner

Two recipes: one that checks and one that fixes.
Fail with install advice when rumdl is missing, instead of a bare "command not found".

```just
# Lint the Markdown files with rumdl and the rules in .rumdl.toml
md-lint:
    @command -v rumdl >/dev/null || { echo "rumdl not found: install it, see https://github.com/rvben/rumdl#installation" >&2; exit 1; }
    rumdl check .

# Apply the rumdl fixes to the Markdown files (rewrites them)
md-fix:
    @command -v rumdl >/dev/null || { echo "rumdl not found: install it, see https://github.com/rvben/rumdl#installation" >&2; exit 1; }
    rumdl fmt .
```

Add the check to the recipe that runs everything CI runs, so a contributor sees a failure before CI does.
The same two targets work in a `Makefile` or as npm scripts.

## GitHub Actions

The official action installs rumdl on Linux, macOS and Windows runners.
Pin it to a commit, and pin the rumdl version, so a new release cannot fail an unrelated pull request.

When the task runner runs the check, install only:

```yaml
- uses: rvben/rumdl@<commit sha> # v0.3.5
  with:
    version: 0.3.5
    install-only: true
- run: just ci
```

When CI runs rumdl on its own, let the action run the check and annotate the pull request:

```yaml
- uses: rvben/rumdl@<commit sha> # v0.3.5
  with:
    version: 0.3.5
    report-type: annotations
```

Find the commit of a release tag (an annotated tag, hence the `^{}`) with `git ls-remote https://github.com/rvben/rumdl 'refs/tags/v0.3.5^{}'`.
Read `usage/ci-cd.md` in the rumdl repository for every input of the action.

## Other CI systems

Install rumdl with a package manager the runner already has (`pip install rumdl==0.3.5`, `cargo install rumdl --version 0.3.5`, `npm install -g rumdl@0.3.5`), then run `rumdl check .`.
`--output-format` selects a report format the CI system understands; `rumdl check --help` lists them for the installed version.

Add `--deny-config-warnings` in CI: a typo in `.rumdl.toml` then fails the build (exit 2) instead of being ignored with a warning.

## pre-commit

rumdl publishes hooks in `https://github.com/rvben/rumdl-pre-commit`:

```yaml
repos:
  - repo: https://github.com/rvben/rumdl-pre-commit
    rev: v0.3.5
    hooks:
      - id: rumdl        # lint only
```

The `rumdl-fmt` hook formats and exits 0 even when findings remain, so it cannot be the gate.
Keep `rev` equal to the version CI pins.

## Upgrading rumdl

A new version can add rules, change defaults or fix an auto-fix.
Upgrade in a pull request of its own:

1. Bump the version in CI, pre-commit and any install docs together.
2. Run `rumdl check .` and read every new finding.
3. If `rumdl fmt` changes files, commit that pass alone and add it to `.git-blame-ignore-revs`.
4. Re-check the pitfalls you rely on: a fixed bug may let you enable a rule you kept off.
