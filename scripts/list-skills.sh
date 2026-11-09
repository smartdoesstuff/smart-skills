#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"

# Auto-discover bucket dirs: any top-level dir containing a SKILL.md somewhere
SKIP_DIRS=(scripts .git node_modules deprecated in-progress)
BUCKETS=()
for dir in "$REPO"/*/; do
  name="$(basename "$dir")"
  skip=0
  for s in "${SKIP_DIRS[@]}"; do [ "$name" = "$s" ] && skip=1 && break; done
  [ $skip -eq 1 ] && continue
  find "$dir" -name SKILL.md -quit 2>/dev/null && BUCKETS+=("$dir")
done

if [ ${#BUCKETS[@]} -eq 0 ]; then
  echo "no skill buckets found under $REPO" >&2
  exit 1
fi

# Keep this registry in step with link-skills.sh.
# ponytail: parallel arrays for bash 3.2 compatibility
AGENT_NAMES=(claude codex gemini gemini-ag)
AGENT_DIRS=("$HOME/.claude/skills" "$HOME/.codex/skills" "$HOME/.gemini/config/skills" "$HOME/.gemini/antigravity-cli/skills")
AGENT_BINS=(claude codex gemini antigravity)

agent_state() {
  local i="$1"
  if command -v "${AGENT_BINS[$i]}" >/dev/null 2>&1 || [ -d "${AGENT_DIRS[$i]}" ]; then printf detected; else printf 'not found'; fi
}

skill_state() {
  local i="$1" name="$2" target="${AGENT_DIRS[$i]}/$name"
  if [ "$(agent_state "$i")" = 'not found' ]; then printf n/a
  elif [ -e "$target" ]; then printf installed
  elif [ -L "$target" ]; then printf 'broken link'
  else printf missing; fi
}

printf '\nAgents\n'
printf '%-12s  %-10s  %s\n' AGENT STATUS 'SKILLS DIRECTORY'
printf '%-12s  %-10s  %s\n' '------------' '----------' '-------------------------------'
for i in "${!AGENT_NAMES[@]}"; do
  printf '%-12s  %-10s  %s\n' "${AGENT_NAMES[$i]}" "$(agent_state "$i")" "${AGENT_DIRS[$i]}"
done

printf '\nSkills\n'
printf '%-12s  %-30s  %-48s' BUCKET SKILL DESCRIPTION
for agent in "${AGENT_NAMES[@]}"; do printf '  %-10s' "$agent"; done
printf '\n'
printf '%-12s  %-30s  %-48s' '------------' '------------------------------' '------------------------------------------------'
for agent in "${AGENT_NAMES[@]}"; do printf '  %-10s' '----------'; done
printf '\n'

find "${BUCKETS[@]}" -name SKILL.md \
  -not -path '*/node_modules/*' \
  -not -path '*/deprecated/*' \
  -not -path '*/in-progress/*' \
  -print0 |
sort -z |
while IFS= read -r -d '' skill_md; do
  skill_dir="$(dirname "$skill_md")"
  name="$(basename "$skill_dir")"
  bucket="$(basename "$(dirname "$skill_dir")")"

  # Extract description from SKILL.md frontmatter
  desc="$(awk '/^---/{f++; next} f==1 && /^description:/{sub(/^description:[[:space:]]*/, ""); print; exit}' "$skill_md")"
  [ ${#desc} -gt 48 ] && desc="${desc:0:45}..."

  printf '%-12s  %-30s  %-48s' "$bucket" "$name" "$desc"
  for i in "${!AGENT_NAMES[@]}"; do printf '  %-10s' "$(skill_state "$i" "$name")"; done
  printf '\n'
done
