#!/usr/bin/env bash
# Appends the static AGY_REPORT contract to a task body, dispatches to agy,
# and prints only the extracted report — so Claude never retypes the
# footer/awk boilerplate per phase and never reads agy's full narration.
#
# Usage: dispatch.sh <task-body-file> <timeout-minutes> <phase-tag>
#   task-body-file: Claude-written file with Context/Task/Out of scope/Verify
#                    sections only — no report footer.
#   phase-tag: short id used for log/report filenames, e.g. phase-1
set -euo pipefail

BODY="${1:?usage: dispatch.sh <task-body-file> <timeout-min> <phase-tag>}"
TIMEOUT="${2:?missing timeout minutes}"
TAG="${3:?missing phase tag}"

LOG="/tmp/agy-${TAG}.log"
PROMPT="/tmp/agy-${TAG}-prompt.md"

cat "$BODY" > "$PROMPT"
cat >> "$PROMPT" <<'EOF'

## Report format (required, exact — end your response with this and nothing after it)

===AGY_REPORT===
Files changed: <comma-separated paths>
Decisions: <bullets, only non-obvious choices — "none" if none>
Blockers: <bullets, or "none">
Tests: <pass/fail + command run>
===END===

Keep everything before the report brief. Do not repeat the report content elsewhere in your response.
EOF

agy -p "$(cat "$PROMPT")" --print-timeout "${TIMEOUT}m" > "$LOG"

REPORT=$(awk '/===AGY_REPORT===/,/===END===/' "$LOG")
if [[ -z "$REPORT" ]]; then
  echo "EMPTY REPORT — tail of $LOG:" >&2
  tail -n 40 "$LOG" >&2
  exit 1
fi
echo "$REPORT"
