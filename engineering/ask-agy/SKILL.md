---
name: ask-agy
description: Hands a bounded task to the `agy` CLI (YOLO mode, no permission prompts) while Claude plans and verifies — implementing a multi-file change in phases, read-only exploration or inventory of a codebase, or browser/Docker rehearsals on throwaway stacks. Use when the user says "ask agy", "use agy", "have agy implement/inspect/run this".
---

# Ask Agy

Claude decides and verifies; agy does one bounded phase and writes a short report file. Claude reads only that report. agy always runs YOLO (`--dangerously-skip-permissions`): it can run commands and edit anything in the workdir, so keep each phase small and verify the diff.

Pick the helper: text-only lookup/draft → `ask-tkm` (cheapest) · second opinion/review or tiny edit → `ask-codex` · multi-file build, codebase inventory, browser/Docker run → here.

## Workflow
1. `which agy`. Missing → tell the user.
2. Write the body to the scratchpad, ≤300 words, paths not contents, CLAUDE.md by path:
   `## Context` repo + 1–3 known facts · `## Task` numbered concrete steps (exploration: exact questions + output file) · `## Out of scope` only if creep is likely · `## Verify` command(s). One phase = one concern, ≤5 files.
3. `bash {base}/scripts/ask.sh <body> <minutes> <tag> [workdir]` with `run_in_background: true`. Minutes: fix ~3, multi-file 5–10, browser 20–30. It prints only the report (≤60 lines).
4. Verify, don't trust: `git diff --stat` vs reported files; read `git diff -- <files>` only; re-run the verify command; check leftovers (`pgrep`, ports, databases).
5. Decide: ok → next phase (carry only file list + one-line decisions) · small defect → follow-up body (defect in 1–3 lines) · wrong approach/blocked → stop, tell the user.
6. agy never commits; Claude commits under the project's git rules.

## Models
Default `gemini-3.8-flash-medium`; `AGY_KIND=vision|complex` → `gemini-4-argon-high`; `AGY_MODEL=<id>` overrides (`agy models`). `AGY_EFFORT=low|medium|high` swaps the model's effort suffix: low for inventories, high for design-sensitive work. One retry on `gemini-4-argon-medium` on quota errors. Never pick a Claude model (not usable on this account). Out of credits (exit 2) → `ask-codex` do mode.

## Gotchas
- Worded as attacks/audits ("vulnerability audit") it may refuse: say "code review for correctness and missing authorization checks".
- After a timeout the report is partial; trust artifacts (screenshots, files) over prose.
- Not for one-line fixes or open-ended "look into X": give concrete questions.

## Never go idle
- After dispatch keep working on the next independent step in the same turn; the harness re-invokes you on exit. If nothing is left, Monitor `until [ -f /tmp/agy-<tag>.done ]; do sleep 5; done`. 0% CPU or an empty log is not "stuck" (agy logs at the end).
- Act on a finished run immediately. Check `/tmp/agy-<tag>-report.md` and `git status` before any kill; never kill a run within its timeout.
- One dispatch per phase; never batch unrelated fixes; never paste file contents or agy narration into prompts.
