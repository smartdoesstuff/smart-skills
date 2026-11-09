---
name: ask-tkm
description: Offloads cheap, text-only work to tokenme-hosted open models (Qwen, DeepSeek) while Claude keeps ownership — find/summarize facts from files (find), second opinion or plan check (think), or draft a whole new file such as tests, boilerplate, docs (draft). Use when the user says "ask tkm", "ask tokenme", "ask qwen", "send it to tokenme", or when a bulk read/summarize/boilerplate job would burn Claude tokens.
---

# Ask tkm

One API call to tokenme. The model cannot run tools or edit files; Claude reads the answer and acts. For edits that need tools use `ask-codex` or `ask-agy`.

| Mode | For | Default model | Thinking |
|---|---|---|---|
| `find` | extract/summarize/answer from given files, with file:line | qwen | off |
| `think` | review a plan/diff, weigh options, hypotheses | qwen | on |
| `draft` | write one complete new file to `--out` | qwen | off |

## Workflow
1. Write the brief (scratchpad, not /tmp): the exact question or file spec, constraints, output shape. No file contents; pass them as args.
2. `python3 {base}/scripts/ask.py <mode> <brief> <tag> [files...] [--out PATH]`. Exit 3 = no/rejected key: relay its setup steps to the user and stop.
3. Verify. find/think: spot-check cited lines before acting. draft: read it, run the tests/linter yourself; it is unreviewed output of a cheaper model.
4. Report what was asked, what came back, what you kept.

## Flags
- `--model qwen|deepseek|gemma|<full id>` (env `ASK_TKM_MODEL`). Auto-switches to deepseek (1M context) when input exceeds ~200k tokens; qwen/gemma cap at 262k. gemma is being retired.
- `--think` / `--nothink`. DeepSeek always thinks (measured: off gave a wrong 17×23; `reasoning_effort:low` returns empty), so it is slower per token than qwen --nothink.
- `--max N` output cap (default find 2000, think/draft 8000; reasoning tokens count). `--force` overwrites `--out`. `--dry` prints model/est. tokens without calling.
- Last stderr line shows `in / cached / out / reasoning` tokens.

## Getting the most per token
- Files first, question last (the script orders it): the prefix is cached, so several asks over the same files cost a fraction. Reuse the identical file list.
- Ask for one thing, name the output shape ("≤10 bullets, file:line"). Long thinking is the cost driver: use `find` unless reasoning is needed.
- Prefer `find` + `--nothink` for lookup, inventory, log triage. Use `think` only for judgment, and still verify it.
- Don't send what Claude already summarized; send paths.

## Rules
- Data leaves the machine. The script refuses `.env*`, keys, credentials; never paste secrets into a brief.
- Not for security-sensitive code, final decisions, or anything needing this chat's context.
- Key: `TOKENME_API_KEY` env or `~/.config/tokenme/api-key`. Never write a key into the repo or a brief.
