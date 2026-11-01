#!/usr/bin/env bash
# Fails if any generated file differs from what src/rules.md would produce.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
"$root/scripts/build.sh" "$tmp"
status=0
for f in CLAUDE.md AGENTS.md skills/cogumi-rules/SKILL.md .cursor/rules/cogumi-rules.mdc; do
  if ! diff -q "$tmp/$f" "$root/$f" >/dev/null; then
    echo "OUT OF SYNC: $f (run scripts/build.sh)"; status=1
  fi
done
[ "$status" -eq 0 ] && echo "All generated files match src/rules.md"
exit "$status"
