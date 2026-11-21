#!/usr/bin/env bash
# Check every skill package under skills/: the frontmatter fields, the size of
# SKILL.md, links that leave the skill directory, and a CATALOG.md entry.
# Usage: scripts/check/skills.sh [skills-dir]   (default: skills)
# Exit codes: 0 every skill passes, 1 a skill fails a check.
set -euo pipefail

root="$(cd "$(dirname "$0")/../.." && pwd)"
skills_dir="${1:-$root/skills}"
catalog="$root/CATALOG.md"
max_lines=500
max_desc=1024
fail=0

err() {
    echo "error $1: $2" >&2
    fail=1
}

# frontmatter prints the YAML between the first two --- lines of a file.
frontmatter() {
    awk 'NR == 1 && $0 != "---" { exit } NR > 1 && $0 == "---" { exit } NR > 1 { print }' "$1"
}

# field prints a top-level scalar field, joining a folded (>) or literal (|) block.
field() {
    awk -v key="$1" '
        $0 ~ "^" key ":" {
            sub("^" key ":[ ]*", "")
            if ($0 ~ /^[>|]-?$/) { block = 1; next }
            print; exit
        }
        block && /^[ ]+/ { sub(/^[ ]+/, ""); out = out (out ? " " : "") $0; next }
        block { print out; done = 1; exit }
        END { if (block && !done) print out }
    '
}

shopt -s nullglob
found=0
for skill_md in "$skills_dir"/*/SKILL.md; do
    found=1
    dir="$(dirname "$skill_md")"
    name="$(basename "$dir")"
    fm="$(frontmatter "$skill_md")"
    if [[ -z "$fm" ]]; then
        err "$name" "SKILL.md has no frontmatter between --- lines"
        continue
    fi

    fm_name="$(field name <<<"$fm")"
    [[ "$fm_name" == "$name" ]] || err "$name" "frontmatter name '$fm_name' differs from the directory name"
    [[ "$name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || err "$name" "the name must be lowercase letters, digits and single hyphens"

    desc="$(field description <<<"$fm")"
    if [[ -z "$desc" ]]; then
        err "$name" "description is missing"
    else
        (( ${#desc} <= max_desc )) || err "$name" "description has ${#desc} characters (limit $max_desc)"
        [[ "$desc" == *"Use when"* ]] || err "$name" "description has no positive trigger (\"Use when ...\")"
        [[ "$desc" == *"Do not use"* ]] || err "$name" "description has no negative trigger (\"Do not use ...\")"
    fi

    for key in author domain version; do
        grep -Eq "^  $key: *[^ ]" <<<"$fm" || err "$name" "metadata.$key is missing"
    done

    lines="$(wc -l <"$skill_md")"
    (( lines <= max_lines )) || err "$name" "SKILL.md has $lines lines (limit $max_lines): move material to references/"

    # A skill is installed on its own, so a relative link must stay inside it.
    while IFS= read -r hit; do
        err "$name" "link leaves the skill directory: $hit"
    done < <(grep -rnoE '\]\(\.\./[^)]*\)' "$dir" --include='*.md' | sed "s|^$dir/||")

    grep -Fq "skills/$name/" "$catalog" 2>/dev/null || err "$name" "CATALOG.md has no entry that links to skills/$name/"
done

if (( found == 0 )); then
    err "skills" "no skills/*/SKILL.md found under $skills_dir"
fi

if (( fail == 0 )); then
    echo "skills: every skill passes"
fi
exit "$fail"
