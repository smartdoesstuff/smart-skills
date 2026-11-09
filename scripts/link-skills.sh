#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"

# ── agent registry ─────────────────────────────────────────────────────────
# ponytail: parallel arrays for bash 3.2 compat
AGENT_NAMES=(claude          codex          gemini                      gemini-ag                        )
AGENT_DIRS=(
  "$HOME/.claude/skills"
  "$HOME/.codex/skills"
  "$HOME/.gemini/config/skills"
  "$HOME/.gemini/antigravity-cli/skills"
)
AGENT_BINS=(claude            codex          gemini                      antigravity                      )
PLUGIN_DIR="$HOME/.claude/plugins/cache/local/smart-skills/1.0.0/skills"

# ── bucket discovery ───────────────────────────────────────────────────────
# ponytail: auto-discover — add a bucket dir and it just works
SKIP=(scripts .git node_modules deprecated in-progress)
BUCKETS=()
for dir in "$REPO"/*/; do
  d="$(basename "$dir")"
  skip=0
  for s in "${SKIP[@]}"; do [ "$d" = "$s" ] && { skip=1; break; }; done
  [ $skip -eq 1 ] && continue
  find "$dir" -name SKILL.md -quit 2>/dev/null && BUCKETS+=("$dir")
done
[ ${#BUCKETS[@]} -eq 0 ] && { echo "error: no skill buckets found under $REPO" >&2; exit 1; }

# ── collect all skills ─────────────────────────────────────────────────────
SKILL_DIRS=()
SKILL_LABELS=()
while IFS= read -r -d '' skill_md; do
  src="$(dirname "$skill_md")"
  name="$(basename "$src")"
  desc="$(awk '/^---/{f++; next} f==1 && /^description:/{sub(/^description:[[:space:]]*/, ""); print; exit}' "$skill_md")"
  SKILL_DIRS+=("$src")
  SKILL_LABELS+=("$(printf '%-28s  %s' "$name" "$desc")")
done < <(
  find "${BUCKETS[@]}" -name SKILL.md \
    -not -path '*/node_modules/*' \
    -not -path '*/deprecated/*' \
    -print0 | sort -z
)

# ── detect available agents ────────────────────────────────────────────────
AVAIL_NAMES=()
AVAIL_DIRS=()
for i in "${!AGENT_NAMES[@]}"; do
  if command -v "${AGENT_BINS[$i]}" &>/dev/null || [ -d "${AGENT_DIRS[$i]}" ]; then
    AVAIL_NAMES+=("${AGENT_NAMES[$i]}")
    AVAIL_DIRS+=("${AGENT_DIRS[$i]}")
  fi
done
[ ${#AVAIL_NAMES[@]} -eq 0 ] && { echo "error: no agents detected (install claude/codex/etc)" >&2; exit 1; }

# ── menu helpers ───────────────────────────────────────────────────────────
show_menu() {
  local prompt="$1"; shift
  printf '\n%s\n' "$prompt"
  local i=1
  for item in "$@"; do
    printf '  %2d) %s\n' $i "$item"
    i=$((i+1))
  done
  printf '  0) ALL\n'
  printf '> '
}

parse_nums() {
  # parse_nums INPUT MAX → prints valid 1-based indices, one per line
  local input="$1" max="$2"
  [ "$input" = "0" ] && { seq 1 "$max"; return; }
  for n in $input; do
    [[ "$n" =~ ^[0-9]+$ ]] && [ "$n" -ge 1 ] && [ "$n" -le "$max" ] && echo "$n"
  done || true
}

# ── select agents ──────────────────────────────────────────────────────────
show_menu "Select agents to link (space-separated, 0=all):" "${AVAIL_NAMES[@]}"
read -r agent_input

# guard against symlinks into this repo
SEL_AGENT_DIRS=()
while IFS= read -r n; do
  i=$((n-1))
  dest="${AVAIL_DIRS[$i]}"
  if [ -L "$dest" ]; then
    resolved="$(readlink -f "$dest")"
    case "$resolved" in "$REPO"|"$REPO"/*)
      echo "error: $dest symlinks into this repo ($resolved). Remove it and re-run." >&2
      exit 1
    esac
  fi
  SEL_AGENT_DIRS+=("$dest")
done < <(parse_nums "$agent_input" "${#AVAIL_NAMES[@]}")

[ ${#SEL_AGENT_DIRS[@]} -eq 0 ] && { echo "no agents selected."; exit 0; }

# ── select skills ──────────────────────────────────────────────────────────
show_menu "Select skills to link (space-separated, 0=all):" "${SKILL_LABELS[@]}"
read -r skill_input

SEL_SKILL_DIRS=()
while IFS= read -r n; do
  i=$((n-1))
  SEL_SKILL_DIRS+=("${SKILL_DIRS[$i]}")
done < <(parse_nums "$skill_input" "${#SKILL_DIRS[@]}")

[ ${#SEL_SKILL_DIRS[@]} -eq 0 ] && { echo "no skills selected."; exit 0; }

# ── link ───────────────────────────────────────────────────────────────────
do_link() {
  local src="$1" dest_base="$2"
  local name; name="$(basename "$src")"
  local target="$dest_base/$name"
  mkdir -p "$dest_base"
  [ -e "$target" ] && [ ! -L "$target" ] && rm -rf "$target"
  ln -sfn "$src" "$target"
  echo "  → $name"
}

for i in "${!SEL_AGENT_DIRS[@]}"; do
  dest="${SEL_AGENT_DIRS[$i]}"
  aname=""
  for j in "${!AVAIL_DIRS[@]}"; do
    [ "${AVAIL_DIRS[$j]}" = "$dest" ] && aname="${AVAIL_NAMES[$j]}" && break
  done
  echo
  echo "[$aname]"
  for src in "${SEL_SKILL_DIRS[@]}"; do
    do_link "$src" "$dest"
  done
  # claude: also sync plugin namespace
  if [ "$dest" = "$HOME/.claude/skills" ]; then
    echo
    echo "[claude-plugin]"
    for src in "${SEL_SKILL_DIRS[@]}"; do
      do_link "$src" "$PLUGIN_DIR"
    done
  fi
done

echo
echo "done — ${#SEL_SKILL_DIRS[@]} skill(s) linked to ${#SEL_AGENT_DIRS[@]} agent(s)."
