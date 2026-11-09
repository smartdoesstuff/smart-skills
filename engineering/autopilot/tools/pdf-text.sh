#!/usr/bin/env bash
# tool: pdf-text — PDF to plain text on stdout, layout kept | usage: pdf-text.sh file.pdf [first-page] [last-page] > out.txt | needs: pdftotext
set -euo pipefail
F="${1:?pdf file}"; A="${2:-1}"; Z="${3:-}"
command -v pdftotext >/dev/null || { echo "pdftotext missing (brew install poppler)" >&2; exit 2; }
echo "[$(pdfinfo "$F" 2>/dev/null | grep -E '^Pages' | tr -s ' ')]" >&2
pdftotext -layout -f "$A" ${Z:+-l "$Z"} "$F" - | head -c "${MAX_CHARS:-400000}"
