#!/usr/bin/env bash
# Usage: ask.sh <think|do|check|run> <brief-file> <tag> [minutes=10] [workdir=$PWD]
#   think/check = read-only, do = workspace-write sandbox (no localhost/browser/Docker/.git writes).
#   run = NO sandbox; refuses unless ASK_CODEX_RUN_OK=1 (set only after the user approved it for this task).
# Env: ASK_CODEX_EFFORT=low|medium|high|xhigh overrides the default (think/check=high, do/run=medium).
# Prints only codex's final message (capped); full log stays in /tmp/codex-<tag>.log.
set -euo pipefail
MODE="${1:?think|do|check|run}"; BRIEF="${2:?brief file}"; TAG="${3:?tag}"; T="${4:-10}"; WD="${5:-$PWD}"
HERE="$(cd "$(dirname "$0")/.." && pwd)"
case "$MODE" in
  think|check) FLAGS=(-s read-only);       EFFORT="${ASK_CODEX_EFFORT:-high}" ;;
  do)          FLAGS=(-s workspace-write); EFFORT="${ASK_CODEX_EFFORT:-medium}" ;;
  run) [[ "${ASK_CODEX_RUN_OK:-}" == 1 ]] || { echo "run mode is unsandboxed: set ASK_CODEX_RUN_OK=1 only with the user's approval" >&2; exit 2; }
       FLAGS=(--dangerously-bypass-approvals-and-sandbox); EFFORT="${ASK_CODEX_EFFORT:-medium}" ;;
  *) echo "mode must be think|do|check|run" >&2; exit 2 ;;
esac
OUT="/tmp/codex-${TAG}.md"; LOG="/tmp/codex-${TAG}.log"; BODY="/tmp/codex-${TAG}-brief.md"; rm -f "$OUT"
{ cat "$BRIEF"
  [[ "$MODE" == run ]] && { echo; cat "$HERE/rules-unsandboxed.md"; }
  printf '\n## Final message\n≤25 lines, facts only: files changed, commands run with their results, anything unverified or uncertain. No narration, no plans, no restating the task.\nDo not commit, push, or switch branches.\n'
} > "$BODY"
cd "$WD"
perl -e 'alarm shift; exec @ARGV' "$((T*60))" codex exec "${FLAGS[@]}" -c "model_reasoning_effort=\"$EFFORT\"" --ephemeral -o "$OUT" - < "$BODY" > "$LOG" 2>&1 \
  || { echo "codex failed/timed out — tail of $LOG:" >&2; tail -n 30 "$LOG" >&2; exit 1; }
[[ -s "$OUT" ]] || { echo "EMPTY reply — tail of $LOG:" >&2; tail -n 30 "$LOG" >&2; exit 1; }
head -c 6000 "$OUT"
