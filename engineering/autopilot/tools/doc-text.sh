#!/usr/bin/env bash
# tool: doc-text — docx/odt/epub/html/md/rtf to plain text on stdout | usage: doc-text.sh file > out.txt | needs: pandoc
set -euo pipefail
F="${1:?document file}"
command -v pandoc >/dev/null || { echo "pandoc missing (brew install pandoc)" >&2; exit 2; }
pandoc "$F" -t plain --wrap=none | head -c "${MAX_CHARS:-400000}"
