#!/usr/bin/env bash
# tool: gh-text — GitHub issue/PR text with comments, or open issue list | usage: gh-text.sh issue|pr <num> [owner/repo]  |  gh-text.sh list [owner/repo] | needs: gh (logged in)
set -euo pipefail
command -v gh >/dev/null || { echo "gh missing (brew install gh)" >&2; exit 2; }
K="${1:?issue|pr|list}"; R=(); 
case "$K" in
  issue|pr) N="${2:?number}"; [[ -n "${3:-}" ]] && R=(-R "$3"); # --comments prints nothing when stdout is not a TTY (gh quirk), so format --json ourselves
                gh "$K" view "$N" --json title,state,author,body,comments ${R[@]+"${R[@]}"} -q \
                '"# \(.title) [\(.state)] by \(.author.login)\n\n\(.body)\n" + (.comments | map("\n--- \(.author.login) ---\n\(.body)") | join("\n"))' ;;
  list) [[ -n "${2:-}" ]] && R=(-R "$2"); gh issue list -L 50 ${R[@]+"${R[@]}"} ;;
  *) echo "issue|pr|list" >&2; exit 2 ;;
esac | head -c "${MAX_CHARS:-400000}"
