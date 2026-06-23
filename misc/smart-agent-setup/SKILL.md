---
name: smart-agent-setup
description: Use when setting up a new project with agent config files (CLAUDE.md, symlinks), git rules, planning doc structure, and per-service instruction files — or auditing an existing project for missing pieces.
---

# Smart Agent Setup

One question at a time. Execute only after user confirms.

## Phase 1 — Detect

```bash
ls -la && ls .claude/ 2>/dev/null && ls docs/ 2>/dev/null
```

Print ✓ ok / ✗ missing / ⚠ wrong for:
- `.claude/CLAUDE.md`
- `AGENTS.md`, `GEMINI.md`, `.cursorrules` (must be symlinks → `.claude/CLAUDE.md`)
- `docs/plans/`, `docs/plans/done/`, `docs/specs/`, `docs/requirements/`
- `.claude/01-*.md` service files

Only scaffold missing or broken items.

## Phase 2 — Wizard

Ask each question, wait for answer, then ask the next.

1. **Symlinks** — which files should point to CLAUDE.md? Default: `AGENTS.md` `GEMINI.md` `.cursorrules` — keep all, remove some, or add custom names?
2. **Sections** — all CLAUDE.md sections, or pick? Options: Hard Rules / Before Implementing / Git / Planning / Instruction Files
3. **Project name**
4. **Description** — one sentence
5. **Tech stack** — e.g. `React + Bun + Elysia`
6. **Team size** — A) Solo  B) Small (2–5)  C) Large (6+)
7. **Extra rules** — any constraints (package manager, DB, APIs)? Or "no". Then ask: "Anything else for CLAUDE.md?"
8. *(If pick in Q2)* **Which sections?**
9. *(If Git chosen)* ask one at a time: branch strategy · commit style · protected branches · PR target · release strategy
10. *(If Instruction Files chosen)* how many services? name each one.

## Phase 3 — Confirm & Execute

List all files to create. Ask **"Confirm? (yes/no)"** — write nothing until yes.

Don't generate file contents yourself — write a small vars file from the wizard answers, then run the scaffold script. It copies the static templates, writes symlinks, service stubs, and `.claude/CLAUDE.md` in one shot.

1. Write `/tmp/whs-vars.sh` from `{base}/templates/vars.example.sh` (same shape, filled with wizard answers — `HARD_RULES` is a `$'...\n...'` bullet string, `SERVICES`/`SYMLINKS`/`OMIT` are comma lists, no spaces)
2. Run: `bash {base}/scripts/scaffold.sh /tmp/whs-vars.sh`
3. Read script output — it prints each file written/linked/skipped. If it exits 1 (CLAUDE.md already exists), merge missing sections manually instead.

`{base}` = path shown at skill load: `Base directory for this skill: /path/to/skill`

## Safety

- Existing `.claude/CLAUDE.md` → only add missing sections, never overwrite.
- Existing correct symlinks → skip.
- Existing `docs/plans/` templates → skip.
- Confirm before any write.
