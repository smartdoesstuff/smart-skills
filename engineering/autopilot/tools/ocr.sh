#!/usr/bin/env bash
# tool: ocr — scanned PDF / image to markdown text via tokenme OCR (uploads the file) | usage: ocr.sh file.pdf|png|jpg > out.md | needs: curl jq, TOKENME_API_KEY
set -euo pipefail
F="${1:?pdf or image file}"; [[ -f "$F" ]] || { echo "no such file: $F" >&2; exit 2; }
KF="$HOME/.config/tokenme/api-key"; KEY="${TOKENME_API_KEY:-$([[ -f $KF ]] && cat "$KF" || true)}"
[[ -n "$KEY" ]] || { echo "tokenme key missing: export TOKENME_API_KEY or save it to $KF (chmod 600); ask the user" >&2; exit 3; }
[[ $(stat -f%z "$F" 2>/dev/null || stat -c%s "$F") -lt 20000000 ]] || { echo "file >20MB: split it first" >&2; exit 2; }
case "$F" in *[Ee][Nn][Vv]|*.pem|*.key) echo "refusing secret-looking file" >&2; exit 2 ;; esac
B="$(mktemp)"; trap 'rm -f "$B"' EXIT   # body via file, key via stdin config: nothing secret in argv
{ printf '{"model":"paxa/paxa-ocr-lite-v1","document":"'; base64 < "$F" | tr -d '\n'; printf '"}'; } > "$B"
R="$(printf 'header = "Authorization: Bearer %s"\nheader = "Content-Type: application/json"\n' "$KEY" |
  curl -sS -m 120 -K - --data-binary @"$B" -w '\n%{http_code}' https://api.tokenme.limited/api/v1/ocr)"
CODE="${R##*$'\n'}"; BODY="${R%$'\n'*}"
case "$CODE" in 200) ;; 401|403) echo "tokenme key rejected: ask the user to rotate/set it" >&2; exit 3 ;; *) echo "ocr HTTP $CODE: ${BODY:0:300}" >&2; exit 1 ;; esac
echo "$BODY" | jq -r '.pages[] | "\n--- page \(.page) ---\n\(.markdown)"' | head -c "${MAX_CHARS:-400000}"
