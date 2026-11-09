#!/usr/bin/env bash
# tool: fetch-url — web page to plain text on stdout (public URLs only, no login) | usage: fetch-url.sh https://... > out.txt | needs: curl pandoc
set -euo pipefail
U="${1:?url}"
case "$U" in https://*|http://*) ;; *) echo "http(s) URLs only" >&2; exit 2 ;; esac
command -v pandoc >/dev/null || { echo "pandoc missing (brew install pandoc)" >&2; exit 2; }
curl -fsSL -m 30 -A "Mozilla/5.0" "$U" | pandoc -f html -t plain --wrap=none | head -c "${MAX_CHARS:-400000}"
