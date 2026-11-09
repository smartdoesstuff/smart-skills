---
name: autopilot
description: Hands-off orchestrator for a multi-step goal. Plans the steps, routes each one to the cheapest capable helper (ask-tkm for lookup/summaries/drafts, ask-codex for review and small edits, ask-agy for multi-file builds and inventories), pulls source material through its tools/ registry (PDF, documents, web pages, local search), verifies each result, and only stops for commits, pushes, deletions or other risky actions. Use when the user says "autopilot", "run this on its own", "ปล่อยไว้ได้เลย", or gives a large goal to work through unattended.
---

# Autopilot

Claude plans, routes and verifies; helpers do the bulk reading and writing. Goal: fewest Claude tokens for the same verified result.

## Loop
1. **Plan** to a scratchpad file `autopilot-plan.md`: ≤8 steps, each = one concern, its helper, its verify command. Edit the plan instead of re-deriving it.
2. **Route** each step (first match):

| Step is… | Helper |
|---|---|
| read/summarize/extract from files or sources, bulk lookup, draft a new file (tests, docs, boilerplate) | `ask-tkm` find / draft |
| a plan, diff or claim needing judgment | `ask-tkm think` first; `ask-codex check` if it matters |
| small self-contained edit, review of a diff | `ask-codex` do / check |
| multi-file change, codebase inventory, browser/Docker run | `ask-agy` |
| needs this conversation's context, security-sensitive, final decision | do it yourself |

3. **Fetch sources into files, not into your context.** `bash {base}/tools/list.sh` prints the tool index (one line each); run the tool, redirect to a scratchpad file, pass the file path to the helper. Chain: `tool > file` → `ask-tkm find <brief> <tag> file` → use the answer. For many candidate files: `find-files.sh` first, then hand the top ones to `ask-tkm`.
4. **Verify** every helper result yourself before the next step (cite-check lines, `git diff`, run tests). Run independent steps in parallel/background.
5. **Report** once at the end: table of step · helper · result · verified?. Mention anything rejected.

## Autonomy (user chose: act freely, stop at risk)
Allowed without asking: read, edit files, run tests/linters, `ask-*` calls, tools/.
**Stop and ask** before: `git commit/push/branch`, deleting files or databases, `ask-codex run` (unsandboxed), installing packages, touching anything outside the repo, sending files that may hold secrets to tokenme, network calls beyond the registry tools.
Limits: ≤8 steps, ≤2 retries per step (second failure → try the next helper up, once; then report). Never loop on the same failing step.

## Failure routing
- `ask-tkm` exit 3 (no/rejected key) → stop that branch, relay its setup steps to the user, continue steps that do not need it.
- `ask-agy` exit 2 (out of credits) → `ask-codex` do. Helper missing (`which`) → skip to the next in the table.
- Helper output contradicts the code → the code wins; discard the claim.

## Adding tools
Drop `tools/<name>.sh` with line 2 = `# tool: <name> — <what> | usage: ... | needs: <bins>`. It must print plain text to stdout, errors to stderr, exit 2 if a dependency is missing, and cap output (`MAX_CHARS`). `list.sh` picks it up; no other edit. Not built yet (add when needed; deps missing on this machine): YouTube transcripts (yt-dlp), xlsx (openpyxl/duckdb), a chunk+embed vector index for corpora too big for `find-files`. `ocr` uploads the file to tokenme: do not OCR anything confidential without asking.
