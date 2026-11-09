#!/usr/bin/env bash
# tool: fetch-url — web page to plain text on stdout (public URLs only, no login) | usage: fetch-url.sh https://... > out.txt | needs: curl pandoc
set -euo pipefail
U="${1:?url}"
case "$U" in https://*|http://*) ;; *) echo "http(s) URLs only" >&2; exit 2 ;; esac
H="${U#*://}"; H="${H%%[/:?#]*}"
case "$H" in localhost|127.*|10.*|192.168.*|169.254.*|172.1[6-9].*|172.2?.*|172.3[01].*|0.0.0.0|*.local|*.internal|\[*) echo "private/local host blocked" >&2; exit 2 ;; esac
command -v pandoc >/dev/null || { echo "pandoc missing (brew install pandoc)" >&2; exit 2; }
curl -fsSL -m 30 --max-redirs 3 --proto-redir =https -A "Mozilla/5.0" "$U" | pandoc -f html -t plain --wrap=none | head -c "${MAX_CHARS:-400000}"
