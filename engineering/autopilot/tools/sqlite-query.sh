#!/usr/bin/env bash
# tool: sqlite-query — read-only SQL over a .db/.sqlite file or a .csv (loaded as table "t") | usage: sqlite-query.sh file 'SELECT ...'  ('.schema' to inspect) | needs: sqlite3
set -euo pipefail
F="${1:?db or csv file}"; Q="${2:?sql}"
command -v sqlite3 >/dev/null || { echo "sqlite3 missing" >&2; exit 2; }
case "$F" in
  *.csv) sqlite3 -csv -header :memory: ".import \"$F\" t" "$Q" ;;
  *) sqlite3 -readonly -csv -header "$F" "$Q" ;;   # -readonly: writes fail at the engine
esac | head -c "${MAX_CHARS:-400000}"
