#!/usr/bin/env bash
# Usage: ask.sh <task-body-file> <timeout-minutes> <tag> [workdir=$PWD]
# Appends the working rules + report contract to the body, runs agy headless, prints ONLY the report.
# Env: AGY_KIND=default|vision|complex picks the model (default gemini-3.8-flash-medium; vision gemini-4-argon-high; complex gemini-4-argon-high).
#      AGY_MODEL=<id> overrides AGY_KIND. On a quota/limit error the run is retried once on gemini-4-argon-medium.
#      AGY_EFFORT=low|medium|high|xhigh|max (optional).
# agy writes its report to /tmp/agy-<tag>-report.md (created early, so a timeout still leaves partial results).
set -euo pipefail
BODY="${1:?task body file}"; T="${2:?timeout minutes}"; TAG="${3:?tag}"; WD="${4:-$PWD}"
LOG="/tmp/agy-${TAG}.log"; PROMPT="/tmp/agy-${TAG}-prompt.md"; REPORT="/tmp/agy-${TAG}-report.md"
rm -f "$REPORT" "/tmp/agy-${TAG}.done"
trap 'date +%s > "/tmp/agy-${TAG}.done"' EXIT  # completion marker, also on failure/timeout
{ cat "$BODY"; cat <<EOT

## Working rules
- Create \`$REPORT\` FIRST (one line: "started") and update it as you go; your final answer is that file, so a timeout still leaves partial results.
- Repo files are read-only unless this task says otherwise. Never commit. Never touch files outside the working directory except /tmp and the scratch dirs named above.
- Servers, browsers and databases you start must be stopped/dropped before you finish (check with pgrep); leave nothing running.
- Frame findings as evidence: file:line, command output, screenshot path. Mark anything unverified "unverified".

## Report format (exact, ≤60 lines, in \`$REPORT\`)
Files changed: <paths or "none"> | Commands run + results: <bullets> | Findings/decisions: <bullets> | Blockers: <bullets or none> | Left running/cleanup: <none or what>
EOT
} > "$PROMPT"
case "${AGY_KIND:-default}" in
  vision) KIND_MODEL=gemini-4-argon-high ;;
  complex) KIND_MODEL=gemini-4-argon-high ;;
  *) KIND_MODEL=gemini-3.8-flash-medium ;;
esac
MODEL="${AGY_MODEL:-$KIND_MODEL}"; FALLBACK=gemini-4-argon-medium
run_agy() {  # $1 = model id
  ARGS=(-p "$(cat "$PROMPT")" --print-timeout "${T}m" --dangerously-skip-permissions --model "$1")  # user-approved: headless agy cannot prompt
  [[ -n "${AGY_EFFORT:-}" ]] && ARGS+=(--effort "$AGY_EFFORT")
  ( cd "$WD" && agy "${ARGS[@]}" > "$LOG" 2>&1 ) || true
}
run_agy "$MODEL"
# Out of quota: try once more on the fallback model (never loop).
if [[ "$MODEL" != "$FALLBACK" ]] && grep -qiE "quota|rate.?limit|resource.?exhausted|usage limit|429" "$LOG"; then
  echo "[agy $MODEL hit a limit; retrying on $FALLBACK]" >&2
  rm -f "$REPORT"; run_agy "$FALLBACK"
fi
# Out of credits on every model: say so plainly instead of returning a bare "started" report.
if grep -qiE "credits balance is too low|RESOURCE_EXHAUSTED" "$LOG"; then
  echo "AGY_OUT_OF_CREDITS: agy has no usage left (see $LOG). Hand the task to ask-codex (do mode)." >&2
  exit 2
fi
if [[ -s "$REPORT" ]]; then
  grep -q "print timeout" "$LOG" && echo "[agy hit its time limit — report may be partial]"
  head -n 60 "$REPORT"
else
  echo "NO REPORT FILE — tail of $LOG:" >&2; tail -n 30 "$LOG" >&2; exit 1
fi
