#!/usr/bin/env bash
# Generates every tool-specific rules file from src/rules.md (the single source).
# Usage: scripts/build.sh [output-root]   (default: repository root)
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
out="${1:-$root}"
src="$root/src/rules.md"

desc="Engineering guidelines for AI coding agents. Use whenever writing, reviewing, testing or refactoring code to surface assumptions, keep changes simple and surgical, design for change, test real user flows, search before writing, and prove the work before saying done."
intro="Behavioral guidelines to reduce common LLM coding mistakes and cut refactoring. Merge with project-specific instructions as needed."

mkdir -p "$out/skills/cogumi-rules" "$out/.cursor/rules"

emit() { # title, file
  { printf '# %s\n\n%s\n\n' "$1" "$intro"; cat "$src"; } > "$2"
}

emit "CLAUDE.md" "$out/CLAUDE.md"
emit "AGENTS.md" "$out/AGENTS.md"

{
  printf -- '---\nname: cogumi-rules\ndescription: %s\nlicense: MIT\n---\n\n' "$desc"
  printf '# Cogumi Rules\n\n%s\n\n' "$intro"
  cat "$src"
} > "$out/skills/cogumi-rules/SKILL.md"

{
  printf -- '---\ndescription: %s\nalwaysApply: true\n---\n\n' "$desc"
  printf '# Cogumi rules\n\n%s\n\n' "$intro"
  cat "$src"
} > "$out/.cursor/rules/cogumi-rules.mdc"
