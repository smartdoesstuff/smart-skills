---
name: delegate-to-agy
description: Use when the user wants the `agy` CLI to implement code while Claude plans and reviews — phrases like "use agy", "delegate to agy", "have agy implement/build/fix this" — or any multi-file coding task where Claude should act as planner/reviewer instead of writing the implementation itself.
---

# Delegate to Agy

Claude plans, `agy` implements, Claude reviews. Each side gets only what it needs — agy gets one phase with no repeated context, Claude reads back a fixed-format report instead of agy's full tool-call narration.

## When to use

- User says "use agy" / "delegate this" / "agy implement it"
- Multi-file feature or fix where you'd otherwise write the code yourself

**Don't use for:** single-line fixes (just edit it), exploratory/research questions (agy needs a concrete spec, not "look into X").

## Phase sizing

A phase = one coherent, independently-verifiable change cluster — ideally ≤5 files, one concern. Split when the task mixes unrelated concerns or exceeds that. Each phase gets its own dispatch + review cycle; don't batch unrelated fixes into one phase.

## Workflow

0. **Preflight** — `which agy`. Not installed? Stop and tell the user; don't substitute a different tool silently.

1. **Plan** (Claude, no agy) — fill `templates/plan.md`. Keep the whole plan ≤300 words, bullets not prose. This plan is an ephemeral working doc, not a project artifact — default to a scratch file (e.g. `/tmp/<task-slug>-plan.md`). Only put it in the project's own plan location if that convention is plain Markdown; don't force it into a formal spec/plan system with its own format or required metadata (e.g. HTML templates) — that's for durable, human-reviewed docs, not a throwaway dispatch plan.

2. **Dispatch one phase** — write only the body (Context/Task/Out of scope/Verify — `templates/dispatch-task.md` minus its report section) to a scratch file (e.g. `/tmp/phase-N-body.md`). Point at files by path; never paste file contents into the prompt. Point agy at project instruction files (`CLAUDE.md` etc.) by path too — it reads them itself. Run:
   ```bash
   bash {base}/scripts/dispatch.sh /tmp/phase-N-body.md <Xm> phase-N
   ```
   This appends the report-format contract, dispatches to agy, and prints just the extracted report (or the log tail + exit 1 on a missing/empty report — re-dispatch with a sharper reminder or treat as blocked). Size `<Xm>` to the phase (small fix ~3, multi-file phase 5–10). `{base}` = path shown at skill load.

   **Never pass `--dangerously-skip-permissions`** — agy already self-approves its own tool calls in `--print` mode, and Claude Code's own permission gate blocks that flag as creating an unsupervised agent loop. It's both unnecessary and will get denied.

3. **Review** (Claude) — follow `templates/review-output.md`. Verify, don't trust: cross-check agy's reported file list against `git diff --stat`, read the diff for touched files only (`git diff -- <files>`, not `cat`), and re-run the verification command yourself rather than trusting agy's "Tests: pass" line — for things with no test suite, that means actually running the app, not just checking it compiles. Decide: approve and move on, send a scoped follow-up for a defect, or stop and report to the user if blocked/wrong approach.

4. **Next phase** — fill `templates/next-phase.md`. Carry forward only the prior phase's file list + one-line decisions, never the prior prompt or full diff. Point agy back at the plan file for the next phase's spec.

5. **After the last phase** — agy never commits (every dispatch says so). Claude commits/opens the PR itself once the final phase is reviewed and approved, same as any other task.

## Quick reference

| Step | Template | Claude reads |
|---|---|---|
| Plan | `templates/plan.md` | — |
| Dispatch | `templates/dispatch-task.md` body + `scripts/dispatch.sh` | extracted report only |
| Review | `templates/review-output.md` | report + targeted `git diff` |
| Next phase | `templates/next-phase.md` | prior report's file list only |

## Rules (why they exist)

- Never paste full file contents into an agy prompt → bloats agy's context; give paths and let it read them.
- Never feed agy's narration back into the next prompt → bloats Claude's context; carry forward only the extracted report.
- One phase = one dispatch = one review; no batching unrelated fixes → keeps a checkpoint to course-correct if agy drifts.
- Verify with commands, not by re-reading whole files → re-running `tests`/`typecheck` catches silent regressions that trusting agy's "Tests: pass" line would miss.
- Keep the plan on disk as the single source of truth, referenced by path → avoids re-pasting it every phase.
- Never pass `--dangerously-skip-permissions` → agy already self-approves tool calls in `--print` mode, and Claude Code's permission gate denies the flag anyway.
