---
name: ask-codex
description: Delegates a scoped piece of work to the Codex CLI while Claude keeps ownership — second opinion or design check (think), code review of a diff or plan (check), a small self-contained edit or test file (do), or authoring/iterating browser E2E specs with the real test runner (run, user-approved only). Use when the user says "ask codex", "have codex review/check/write this", or "let codex try this part".
---

# Ask Codex

Claude owns the task and the verification; Codex does one scoped job and returns a short report.

Pick the helper: text-only lookup/draft → `ask-tkm` (cheapest) · review, second opinion, small sandboxed edit, E2E specs → here · multi-file build or codebase inventory → `ask-agy`.

| Mode | For | Sandbox | Default effort |
|---|---|---|---|
| `think` | design choice, root-cause hypothesis, tradeoffs | read-only | high |
| `check` | review a diff/plan/claim for bugs and missed cases | read-only | high |
| `do` | one self-contained edit or test file | workspace-write | medium |
| `run` | write AND run browser/E2E specs until green | **none** | medium |

`run` is unsandboxed (can reach the whole machine). Use it only for E2E/test authoring and only after the user approved it; run with `ASK_CODEX_RUN_OK=1`. The script appends `rules-unsandboxed.md` itself. Never use it for app code.

## Workflow
1. `which codex`. Missing → tell the user.
2. Write the brief to the scratchpad (not /tmp). Include only what Codex lacks: goal, file **paths** (never contents), constraints, what you already ruled out, the exact question or deliverable, the verify command. Say what failed before and attach the real failure output as a file path.
3. Run: `bash {base}/scripts/ask.sh <mode> <brief> <tag> [minutes] [workdir]` — in the background for long jobs. `workdir` is the worktree Codex must edit (default: current dir). The script appends the ≤25-line final-message contract and caps the reply.
4. Judge, don't relay. think/check: verify each claim in the code before acting. do/run: read `git diff -- <files>` and re-run the verify command yourself (real DB/browser if Codex could not).
5. Report to the user: what was asked, what Codex found, what you accepted or rejected.

## Gotchas (each cost a round before)
- Sandboxed Codex cannot reach localhost, a browser, Docker, the network for `bun install`, or write `.git` (no `git merge`, no commit). Run installs/merges yourself first; give it failure output instead of asking it to reproduce.
- It edits only inside its working directory: pass the worktree as `workdir`, never the main checkout.
- Do not start it on a tree with unresolved merge conflicts.
- Redirected output files get a one-line banner if the command died — check the file really contains results before attaching it.
- Raise effort (`ASK_CODEX_EFFORT=high`) only for subtle debugging; lower it (`low`) for mechanical edits.
- It tends to skip listed tests and report only lint/typecheck. Name each required test in the brief and check the final message lists them; if missing, run them yourself.
- Tests it writes without running are wrong about UI text and ids: attach page snapshots or use `run`.

## Rules
- One question per call. No more than one Codex↔Claude round before telling the user.
- Codex never commits or pushes; Claude does, under the project's git rules.
