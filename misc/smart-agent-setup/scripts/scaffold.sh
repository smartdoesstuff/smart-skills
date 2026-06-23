#!/usr/bin/env bash
# Scaffolds .claude/CLAUDE.md + symlinks + docs/plans structure + service stubs
# from a small vars file, instead of Claude writing full file contents.
#
# Usage: scaffold.sh /path/to/vars.sh
#
# vars.sh must set (see vars.example.sh):
#   NAME DESC TEAM HARD_RULES SERVICES COMMIT MAIN_BRANCH INTEG_BRANCH RELEASE
#   SYMLINKS (comma list, optional)  OMIT (comma list of: planning,git,instructionfiles, optional)
set -euo pipefail

VARS_FILE="${1:?usage: scaffold.sh vars.sh}"
# shellcheck disable=SC1090
source "$VARS_FILE"

BASE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/templates"
omit() { [[ ",${OMIT:-}," == *",$1,"* ]]; }

mkdir -p .claude docs/plans/done docs/specs docs/requirements
touch docs/plans/done/.gitkeep docs/specs/.gitkeep docs/requirements/.gitkeep

# --- static templates: copy, never regenerate via Claude output ---
[[ -f docs/plans/_styles.css ]] || cp "$BASE/_styles.css" docs/plans/_styles.css
[[ -f docs/plans/_template.html ]] || cp "$BASE/_template.html" docs/plans/_template.html

# --- symlinks ---
IFS=',' read -ra LINKS <<< "${SYMLINKS:-AGENTS.md,GEMINI.md,.cursorrules}"
for link in "${LINKS[@]}"; do
  [[ -L "$link" && "$(readlink "$link")" == ".claude/CLAUDE.md" ]] && continue
  ln -sf .claude/CLAUDE.md "$link"
  echo "linked $link -> .claude/CLAUDE.md"
done

# --- service stubs + instruction-files table ---
IFS=',' read -ra SVCS <<< "${SERVICES:-}"
INSTR_TABLE=""
SVC_LIST=""
n=1
for svc in "${SVCS[@]}"; do
  nn=$(printf "%02d" "$n")
  f=".claude/${nn}-${svc}.md"
  SVC_LIST+="${SVC_LIST:+ · }$svc"
  INSTR_TABLE+="| [${nn}-${svc}.md](${nn}-${svc}.md) | ${svc} — TODO: describe |"$'\n'
  if [[ ! -f "$f" ]]; then
    cat > "$f" <<EOF
# ${nn} — ${svc}

## Overview
TODO: describe responsibilities.

## Key files
TODO: list important paths.

## Patterns
TODO: conventions and anti-patterns.
EOF
    echo "wrote $f"
  fi
  n=$((n+1))
done

# --- CLAUDE.md ---
if [[ -f .claude/CLAUDE.md ]]; then
  echo "SKIP: .claude/CLAUDE.md exists — merge missing sections manually" >&2
  exit 1
fi

{
  echo "# ${NAME} — Claude Instructions"
  echo
  echo "${DESC}. ${TEAM}. **Maintainability over cleverness.**"
  echo
  echo "## Hard Rules"
  echo
  echo "${HARD_RULES}"
  echo
  echo "## Before Implementing"
  echo
  echo "1. Identify affected service: ${SVC_LIST}"
  echo "2. Read the relevant instruction file below."
  echo "3. Keep service boundaries clear."

  if ! omit planning; then
    echo
    echo "## Planning"
    echo
    echo '**Locations (never place files elsewhere):**'
    echo '- `docs/plans/` — active/upcoming (`.html`)'
    echo '- `docs/plans/done/` — completed, move here after implementation'
    echo '- `docs/specs/` — design specs (`.html`)'
    echo '- `docs/requirements/` — requirement group files (`.html`), one per role/category'
    echo
    echo '**After finishing a feature:** move the plan file from `docs/plans/` → `docs/plans/done/`. After moving, update the CSS link from `href="_styles.css"` → `href="../_styles.css"`.'
    echo
    echo '**Format:** `.html` files using `docs/plans/_template.html`. CSS lives in `docs/plans/_styles.css` (linked, not inline).'
    echo
    echo '### Naming conventions'
    echo
    echo '| Type | Pattern | Example |'
    echo '|------|---------|---------|'
    echo '| Spec | `S{NNN}-{YYYY-MM-DD}-{title}.html` | `S001-2026-01-01-name.html` |'
    echo '| Plan | `P{NNN}-{YYYY-MM-DD}-{title}.html` | `P001-2026-01-01-name.html` |'
    echo '| Requirement group | `{group}.html` | `FR-admin.html`, `NFR.html` |'
    echo
    echo '- `NNN` is sequential and global. Assign by date order (older = lower). Plans in `done/` keep their P-number.'
    echo
    echo '### When writing a plan'
    echo
    echo '- File goes in `docs/plans/` with the `P{NNN}` prefix.'
    echo '- Required `<head>` meta tags: `tasks`, `spec`, `requirements`.'
    echo '- Code examples = type signatures + pseudocode only. No full implementations.'
    echo '- No `Self-Review` section. Max ~6 tasks per file.'
    echo
    echo '### Requirements files (`docs/requirements/`)'
    echo
    echo 'Starting groups: `FR-general.html` · `NFR.html`'
  fi

  if ! omit instructionfiles; then
    echo
    echo "## Instruction files"
    echo
    echo "| File | Read when working on… |"
    echo "|------|----------------------|"
    printf '%s' "$INSTR_TABLE"
  fi

  if ! omit git; then
    echo
    echo "## Git"
    echo
    echo "Commit messages: ${COMMIT}. Don't commit \`dist/\`, \`node_modules/\`, \`.env\`."
    echo
    echo '**Branches:**'
    echo "- \`${MAIN_BRANCH}\` — stable releases only; never commit directly"
    echo "- \`${INTEG_BRANCH}\` — integration branch; never commit directly"
    echo "- \`feat/…\` / \`fix/…\` — branch from \`${INTEG_BRANCH}\` (default)"
    echo
    echo "**PR targets:** \`feat/fix\` → \`${INTEG_BRANCH}\`."
    echo
    echo "**Release:** ${RELEASE}"
  fi
} > .claude/CLAUDE.md

echo "wrote .claude/CLAUDE.md"
