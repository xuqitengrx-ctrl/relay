# Relay — a 2-file context-management convention for AI coding agents

> Two markdown files at the project root carry everything an AI coding agent needs to resume a long-running project across sessions. Stable rules in `AGENTS.md`, living state in `STATE.md`. That's it.

## The problem

Long-running AI coding sessions lose context. Fresh sessions don't know:

- What's the current commit / test count / what just landed
- Which past decisions are locked (don't relitigate)
- Which traps the project has hit before (don't repeat)
- What's the next milestone, and does it need brainstorming or a plan first

Convention-less projects accumulate sprawling docs (MEMORY.md / CHAT.md / HANDOFF_PROMPT.md / NOTES.md / DECISIONS.md / ...) that drift apart, contradict each other, and force agents to read 200KB before doing anything useful.

## The convention

Two files at the project root. **Two.** Not four. Not seven.

| File | Purpose | Edit cadence |
|---|---|---|
| `AGENTS.md` | **Stable rules.** Conventions, locked decisions, repo layout, always-on rules. Read once per session. | Rare — only when a new always-on rule lands. |
| `STATE.md` | **Living state.** Current commit + test count, watch-list, decisions log, milestones, roadmap, useful commands. Read top-to-bottom on fresh session. | Every end-of-session handoff. |

That's the whole convention.

### Why two and not one

Stable / churn separation. AGENTS.md is read on every fresh session — keeping rules out of the churn means agents don't waste tokens re-reading what hasn't changed. STATE.md changes every session; keeping it separate means git diffs are clean and reviews are tractable.

### Why two and not four

Earlier conventions (AGENTS / MEMORY / CHAT / HANDOFF_PROMPT) duplicate ~40% of content across files, create three sources of truth for "current state," and require renumber-prone decision lists. **One stable doc + one living doc = no cross-file drift physically possible.**

## STATE.md sections (top-to-bottom)

1. **Starter prompt** — paste-ready block for fresh sessions
2. **Current state** — commit SHA, tests, last landed, next, pending verification
3. **Watch-list** — active risks (🚧 / ⚠️ / 🟡). Resolved items are deleted, not commented out
4. **Decisions log** — dated blocks, newest first. No numbering (renumbering is dead)
5. **Milestones shipped** — historical anchor; one bullet per milestone
6. **Roadmap** — what's not yet done
7. **Open questions**
8. **Useful commands**
9. **Session log** (optional, usually empty — decisions log absorbs the narrative)

Plus project-specific sections as needed (e.g., sister-project parity tables).

## Claude Code skills (this repo)

For [Claude Code](https://claude.com/claude-code) users, this repo bundles three skills that implement the convention:

| Skill | Trigger | What it does |
|---|---|---|
| `/relay-scaffold` | One-time per project | Creates `AGENTS.md` + `STATE.md` with canonical sections |
| `/relay-start` | Each fresh session | Reads both files, verifies state with git, summarizes in 5-8 lines, waits |
| `/relay-end` | Each end-of-session | Updates STATE.md (decisions log, watch-list, current state, milestones), pauses before commit |

The skills are Claude-Code-specific (use `SKILL.md` format, reference Claude's tool names). **The convention itself is agent-agnostic** — any AI coding tool that can read markdown and run git commands can use the 2-file structure. Contributors welcome to add Cursor rules / Codex instructions / etc.

## Install

### Claude Code (recommended)

**One-line install (POSIX):**

```bash
git clone https://github.com/xuqitengrx-ctrl/relay.git /tmp/relay && bash /tmp/relay/scripts/install.sh
```

**One-line install (Windows PowerShell):**

```powershell
git clone https://github.com/xuqitengrx-ctrl/relay.git $env:TEMP\relay; & $env:TEMP\relay\scripts\install.ps1
```

The scripts copy `skills/relay-*/` into `~/.claude/skills/` (or `$env:USERPROFILE\.claude\skills\` on Windows).

**Manual install:**

```bash
git clone https://github.com/xuqitengrx-ctrl/relay.git
cp -r relay/skills/* ~/.claude/skills/
```

Restart Claude Code (or `/reload` your session). The three slash commands are now available.

### Other AI coding agents (Cursor / Codex / etc.)

The skills aren't directly compatible (they use Claude Code's skill format), but the **convention is portable**. Adopt manually:

1. Run `examples/` files as templates — copy them into your project root, rename `{PROJECT_NAME}` etc.
2. Tell your agent to read `AGENTS.md` → `STATE.md` on fresh sessions, and update STATE.md at end-of-session.
3. Pin the key rules: dated decision blocks (no numbering), strip resolved watch-list items, fresh-evidence-before-handoff.

PRs welcome to add agent-specific implementations under `agents/<name>/`.

## Usage

### First time on a new project

```
/relay-scaffold
```

The skill asks 3 quick questions (what's the project, tech stack, any DESIGN.md / IMPLEMENTATION_PLAN.md), then writes `AGENTS.md` + `STATE.md` with stub placeholders. Populate the project-specific sections as the project evolves.

### Start of each fresh session

```
/relay-start
```

Or paste the starter prompt at the top of `STATE.md` into a new session. Either way the agent reads both files, verifies git state, summarizes in 5-8 lines, and waits for direction.

### End of each working session

```
/relay-end
```

The skill walks through the STATE.md edits — current state, decisions log (dated, prepended at top), watch-list (active items only), milestones, roadmap — and pauses for you to review the diff before committing.

## Examples

See `examples/AGENTS.md` and `examples/STATE.md` for sanitized populated samples. They're not authoritative templates — the canonical templates live inside `skills/relay-scaffold/SKILL.md`.

## Design principles

These are the non-negotiables behind the convention:

1. **Single source of truth.** Current state lives in exactly one place (top of STATE.md). Never duplicate to MEMORY / HANDOFF_PROMPT / CHAT / wherever.
2. **Stable / churn separation.** AGENTS.md rarely changes; STATE.md changes every session. Keep them in separate files so agents can cache the stable half.
3. **Dated headings, never numbering.** `### YYYY-MM-DD — summary` is inherently ordered. Numbered lists require renumbering on every prepend — that's the #1 source of relay bugs.
4. **Strip resolved items.** Don't leave HTML-commented `<!-- RESOLVED -->` clutter in watch-list. Resolution is captured in the decisions log + git history.
5. **Fresh-evidence verification.** Before claiming "tests N/N passing" or "commit X is current," run the commands. Don't carry over prior claims.
6. **Composition hints, not gates.** STATE.md "Next" line can carry English directives (`needs brainstorming first` / `≥3 steps — plan first` / `TDD applies`) that work whether the next agent has specialized skills or just applies the discipline inline.
7. **Scope filter.** Project-specific working memory only. Off-project chat (tooling, skill setup, philosophical asides) belongs in chat transcripts, not the relay docs.
8. **One file edit by default.** relay-end touches STATE.md. AGENTS.md only when a new always-on rule lands. Less to keep in sync.

## Contributing

Issues and PRs welcome. Especially valuable:

- **Other-agent implementations** — Cursor / Codex / Aider / Continue / Cline / etc.
- **Real-world examples** — populated AGENTS.md / STATE.md from your own projects (sanitized)
- **Convention refinements** — if you hit a friction point the current convention doesn't handle, surface it

## License

MIT. Use it however you like.
