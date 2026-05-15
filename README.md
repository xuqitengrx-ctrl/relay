# Relay

**Zero-loss context handoff for AI coding agents.** Two markdown files at your project root carry everything a fresh session needs to pick up where the last one left off.

```
your-project/
├── AGENTS.md          ← stable rules, conventions, locked decisions
├── STATE.md           ← current state, decisions log, watch-list, roadmap
└── (your code)
```

That's the whole convention.

---

## Install

**Linux / macOS:**

```bash
git clone https://github.com/xuqitengrx-ctrl/relay.git /tmp/relay && bash /tmp/relay/scripts/install.sh
```

**Windows (PowerShell):**

```powershell
git clone https://github.com/xuqitengrx-ctrl/relay.git $env:TEMP\relay; & $env:TEMP\relay\scripts\install.ps1
```

Three skills land in `~/.claude/skills/`. Restart Claude Code or `/reload` to pick them up.

---

## Usage

### One-time per project

```
/relay-scaffold
```

Creates `AGENTS.md` and `STATE.md` at your project root with canonical sections. Asks three quick questions (what's the project, tech stack, any DESIGN.md or IMPLEMENTATION_PLAN.md to reference), then writes the files.

### Start of every fresh session

```
/relay-start
```

The agent reads both files, verifies state with `git log -1` + `git status`, summarizes in 5–8 lines, and waits for your direction. Never starts coding before you confirm.

### End of every working session

```
/relay-end
```

The agent updates `STATE.md` — current state snapshot, dated decisions log entry, watch-list edits, milestone bullet if you closed one — then pauses for you to review the diff before committing.

---

## What's in each file

### AGENTS.md (stable)

Read once per session. Edited rarely.

- **What this project is** — one paragraph
- **Tools, framework, idioms** — your stack one-liner
- **Core conventions / locked decisions** — non-negotiables; things the user said "don't revisit"
- **What NOT to do** — failure modes accumulated from past mistakes
- **Always-on rules** — 3-strike protocol, 2-action save, plan-first for ≥3-step work, per-milestone reviewer dispatch
- **Repository layout** — tree sketch of top-level dirs
- **Personal context** — optional, about you (role, preferences, constraints)

### STATE.md (living)

Read top-to-bottom on every fresh session. Updated every relay-end.

1. **Starter prompt** — paste-ready block for fresh sessions
2. **Current state** — commit SHA, tests, last landed, next, pending verification
3. **Watch-list** — active risks: `🚧` deferred, `⚠️` known risk with mitigation, `🟡` low-priority observation
4. **Decisions log** — dated blocks, newest first
5. **Milestones shipped** — historical anchor; one bullet per milestone
6. **Roadmap** — what's not yet done
7. **Open questions**
8. **Useful commands** — for tests, build, lint
9. **Session log** (optional, usually empty)

---

## Design principles

1. **Single source of truth.** Current state lives in exactly one place — the top of `STATE.md`.
2. **Stable / churn separation.** Rules in `AGENTS.md` rarely change; state in `STATE.md` changes every session. Agents cache the stable half.
3. **Dated headings, never numbering.** `### YYYY-MM-DD — summary` is inherently ordered. No renumbering on prepend.
4. **Strip resolved items.** When a watch-list item resolves, delete it. The resolution is captured in the decisions log and git history.
5. **Fresh-evidence verification.** Before claiming "tests N/N passing" or "commit X is current," run the commands. Don't carry over prior claims.
6. **Composition hints, not gates.** The "Next" line can carry English directives — `(needs brainstorming first)`, `(≥3 steps — plan first)`, `(TDD applies)` — that work whether the next agent has specialized skills or applies the discipline inline.
7. **Scope filter.** Project-specific working memory only. Off-project chat (tooling discussions, philosophical asides) doesn't belong in the relay docs.

---

## How it composes with other skills

If you use [superpowers](https://github.com/anthropics/skills) or similar skill packages, Relay defers cleanly:

- `/relay-start` is the entry-point skill. After orientation, normal skill-gate logic applies for whatever you direct next (brainstorming for new features, plan-first for multi-step work, TDD for production code).
- Composition hints in `STATE.md` "Next" trigger the right skills automatically on the next session.

Without other skills installed, the hints still apply as English directives — the convention is self-sufficient.

---

## Examples

See `examples/AGENTS.md` and `examples/STATE.md` for populated samples (a fictional Rust CLI note-taking app). They show what the files look like a few phases into a real project.

---

## For non-Claude-Code agents

The skills in this repo use Claude Code's `SKILL.md` format, but the **convention is portable**. Any AI coding agent that reads markdown and runs git commands can adopt it:

1. Copy `examples/AGENTS.md` and `examples/STATE.md` into your project root.
2. Tell your agent to read `AGENTS.md` → `STATE.md` on fresh sessions.
3. Update `STATE.md` at end-of-session: bump current state, prepend a dated decision block, edit watch-list.

PRs welcome to add agent-specific implementations under `agents/<name>/` (Cursor rules, Codex instructions, Aider conventions, etc.).

---

## Contributing

Issues and PRs welcome. Especially valuable:

- Agent-specific implementations (Cursor, Codex, Aider, Continue, Cline)
- Real-world populated examples from your own projects (sanitized)
- Convention refinements when you hit a friction point

---

## License

MIT.
