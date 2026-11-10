# smart-skills

**Smart's** personal agent skills — "smart" is my name, not a description of the skills.

Inspired by [9arm-skills](https://github.com/9arm/9arm-skills).

---

## Layout

Skills live under bucket folders:

- `engineering/` — daily code work
- `management/` — professional communication and management workflows
- `research/` — research writing and notebook workflows
- `productivity/` — daily non-code workflow tools
- `misc/` — kept around but rarely used
- `personal/` — tied to my own setup, not promoted
- `in-progress/` — drafts not yet ready to ship
- `deprecated/` — no longer used

Each skill is its own directory containing a `SKILL.md` (with YAML frontmatter — `name` and `description`) and any bundled scripts or reference files.

---

## Install

### Link (local)

Symlinks every shippable skill into `~/.claude/skills/` (Claude Code) and `~/.codex/skills/` (Codex). Skips any tool that isn't installed.

```bash
./scripts/link-skills.sh
```

Re-run this whenever you add or rename a skill.

### Via npx (global)

Install globally across all agents (Claude Code, Codex, Antigravity, Gemini CLI, GitHub Copilot, etc.) with the [skills CLI](https://skills.sh/):

```bash
npx skills add smartdoesstuff/smart-skills -g
```

### Via npm (project-level)

Install the skill pack as a project dependency, then sync its skills into the selected agents:

```bash
npm install --save-dev @smartdoesstuff/smart-skills
npx skills experimental_sync -y
```

The npm sync command is experimental and installs project-level skills. For global installation across projects, use the GitHub command above.


---

## Scripts

```bash
./scripts/list-skills.sh   # table of skills, descriptions, and install status per agent
./scripts/link-skills.sh   # symlink skills into installed agent dirs
```

## npm publishing

The public package `@smartdoesstuff/smart-skills` contains each shippable skill directory under `dist/skills/`. Build and inspect it with:

```bash
node scripts/build-npm-package.mjs
npm pack --dry-run
```

After the first public release (`npm publish --access public`), configure npm Trusted Publishing for GitHub user `smartdoesstuff`, repository `smart-skills`, and workflow `publish-npm.yml`:

```bash
npm trust github @smartdoesstuff/smart-skills --file publish-npm.yml --repo smartdoesstuff/smart-skills --allow-publish
```

The workflow uses OIDC, publishes a new `1.0.x` version when skills change on `main`, and skips a version already published. npm requires an authenticated account with two-factor authentication enabled to publish and configure trusted publishing.

---

## Skills

### Engineering

- **[address-pr-review](./engineering/address-pr-review/SKILL.md)** — Address, respond to, or action bot/AI review comments (Copilot, CodeRabbit, etc.) on a GitHub PR.
- **[ask-codex](./engineering/ask-codex/SKILL.md)** — Claude delegates a scoped think/check/do/run job to the Codex CLI and verifies the result; `scripts/ask.sh` caps the reply.
- **[ask-agy](./engineering/ask-agy/SKILL.md)** — Claude plans and reviews, the `agy` CLI implements in YOLO mode: phased dispatch via `scripts/ask.sh` with a fixed-format report contract to keep both sides' context usage low.
- **[autopilot](./engineering/autopilot/SKILL.md)** — hands-off orchestrator: plans a goal, routes each step to ask-tkm / ask-codex / ask-agy, pulls sources via a drop-in `tools/` registry (PDF, OCR, docs, web, GitHub, SQL, local search), verifies, and stops only for commits/deletes/risky actions.
- **[ask-tkm](./engineering/ask-tkm/SKILL.md)** — cheap text-only offload (find / think / draft) to tokenme-hosted Qwen/DeepSeek via `scripts/ask.py`; prefix-cache friendly, tells the user how to set up the API key when missing.
- **[finish-feature](./engineering/finish-feature/SKILL.md)** — Ship a completed fix or feature branch to development: detects package manager (bun/pnpm/yarn/npm), runs tests, creates branch, commits, pushes, and opens a PR targeting `development`.
- **[gqm-coach](./engineering/gqm-coach/SKILL.md)** — Facilitate interactive, research-backed GQM sessions: clarify the evaluation goal, derive questions together, and define metrics with linked paper references.
- **[github-issue-triage-and-fix](./engineering/github-issue-triage-and-fix/SKILL.md)** — Inspect, triage, prioritize, group, or fix open GitHub issues from a repo's backlog.

### Research

- **[research-writing-style](./research/research-writing-style/SKILL.md)** — Write or edit research notebooks, reports, and summaries in a natural, Thai-first, non-AI-sounding voice grounded in actual outputs.

### Management

- **[email-writing](./management/email-writing/SKILL.md)** — Co-write and review professional emails with a practical Who–What–When–Why–How checklist, including calendar and attachment consistency.

### Productivity

_(none yet)_

### Misc

- **[smart-agent-setup](./misc/smart-agent-setup/SKILL.md)** — Wizard to scaffold or audit a new project's agent config files (CLAUDE.md, symlinks), git rules, planning doc structure, and per-service instruction files, via `scripts/scaffold.sh`.

---

## Adding a skill

1. Create `engineering/<skill-name>/SKILL.md` (or the appropriate bucket).
2. Add a frontmatter block with `name` and `description`.
3. Run `./scripts/link-skills.sh` to activate it.
4. Add an entry to the **Skills** section above.
