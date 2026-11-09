#!/usr/bin/env bash
# tool: find-files — local retrieval: files matching a regex, ranked by hit count, for feeding ask-tkm | usage: find-files.sh 'regex' [dir] [top-N=12] | needs: rg
set -euo pipefail
P="${1:?regex}"; D="${2:-.}"; N="${3:-12}"
command -v rg >/dev/null || { echo "rg missing (brew install ripgrep)" >&2; exit 2; }
rg -c --no-messages -S "$P" "$D" | awk -F: '{print $NF"\t"substr($0,1,length($0)-length($NF)-1)}' | sort -rn | head -n "$N" | cut -f2
