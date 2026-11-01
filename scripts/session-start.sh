#!/usr/bin/env bash
# Claude Code SessionStart hook: puts the Cogumi rules (and project facts, if present) in context.
set -euo pipefail
plugin_root="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
cat "$plugin_root/CLAUDE.md"
project_file="${CLAUDE_PROJECT_DIR:-$PWD}/cogumi-project.md"
if [ -f "$project_file" ]; then
  printf '\n\n# Project facts (cogumi-project.md)\n\n'
  cat "$project_file"
fi
