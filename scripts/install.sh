#!/usr/bin/env bash
# Install relay skills into Claude Code's user-global skills directory.
# Idempotent: re-running upgrades the skills to the current repo state.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_SRC="${REPO_DIR}/skills"
SKILLS_DST="${HOME}/.claude/skills"

if [ ! -d "${SKILLS_SRC}" ]; then
  echo "Error: ${SKILLS_SRC} not found. Run this script from a clone of the relay repo." >&2
  exit 1
fi

mkdir -p "${SKILLS_DST}"

for skill in relay-scaffold relay-end relay-start; do
  src="${SKILLS_SRC}/${skill}"
  dst="${SKILLS_DST}/${skill}"
  if [ -d "${dst}" ]; then
    echo "Updating ${skill} (existing skill at ${dst})"
  else
    echo "Installing ${skill} -> ${dst}"
  fi
  mkdir -p "${dst}"
  cp "${src}/SKILL.md" "${dst}/SKILL.md"
done

echo ""
echo "Done. Three skills installed under ${SKILLS_DST}:"
echo "  - /relay-scaffold (one-time per project)"
echo "  - /relay-start    (each fresh session)"
echo "  - /relay-end      (each end-of-session)"
echo ""
echo "Restart Claude Code or /reload to pick up the skills."
