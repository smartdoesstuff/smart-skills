#!/usr/bin/env bash
# Prints the tool index: one line per tools/*.sh (its "# tool:" header). Add a tool = drop a file with that header.
grep -h -m1 '^# tool: ' "$(dirname "$0")"/*.sh | cut -c9-
