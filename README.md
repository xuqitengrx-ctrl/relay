# Relay

**Your AI coding agent forgets where it was. Again. Relay fixes that.**

Two markdown files at your project root carry every scrap of context a fresh session needs to pick up exactly where the last one left off. No re-explaining the project. No relitigating decisions you locked three sessions ago. No re-discovering the bug you already fixed.

```
your-project/
├── AGENTS.md          ← the rules. Read once.
├── STATE.md           ← the now. Read every session.
└── (your code)
```

That's the whole thing.

---

## Why you'll want this

You know that moment. Your agent finishes a long session, you close the window, you come back tomorrow with a fresh session and you're typing this for the fourth time:

> "Okay so this is a Rust project, we use SQLite not Tantivy, don't add async because we decided last week, the WAL mode thing is a known issue, current branch is on the tag-rename refactor, last commit was a3f9c12, tests are at 187..."

Relay collapses that monologue into: "Read AGENTS.md and STATE.md." Your agent does its homework, summarizes in 5–8 lines, and asks what's next. Every fresh session. Every machine. Every agent that can read markdown.

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

Three skills land in `~/.claude/skills/`. Restart Claude Code or `/reload`. You're done.

---

## The workflow

### Day one on a project: `/relay-scaffold`

The skill asks three quick questions — what's this thing, your stack, any DESIGN.md or IMPLEMENTATION_PLAN.md you want referenced — then writes both files with canonical sections and stub placeholders. Five minutes.

### Start of every session: `/relay-start`

```
Continue work on acme-notes at /home/me/code/acme-notes.

Read in this order:
  1. AGENTS.md
  2. STATE.md

Verify with:
  git log -1 --format='%H %s'
  git status --short

Summarize in 5-8 lines. Wait for direction.
```

The agent reads both files, runs the verification, and reports back. If git shows commits past what STATE.md claims, you'll hear about it. If the working tree is dirty when it shouldn't be, you'll hear about it. Then it waits — `auto OFF` by default, because you don't want a fresh session diving into changes before you've confirmed direction.

### End of every session: `/relay-end`

The agent walks through the STATE.md edits — updates current state, prepends a dated decision block, edits the watch-list (resolved items get deleted, not commented out), adds a milestone bullet if you closed one, updates the roadmap. Then it stops, shows you the diff, and asks if it should commit.

You inspect. You approve. It commits. Done.

---

## What goes in each file

### `AGENTS.md` — the rules

Edited rarely. Read once per session. Contains:

- **What this project is.** One paragraph. The elevator pitch.
- **Stack.** Languages, frameworks, key dependencies, the things you'd tell a new contractor on day one.
- **Core conventions / locked decisions.** Non-negotiables. The choices the user said "don't revisit." Storage namespacing, forbidden imports, naming conventions, architectural locks.
- **What NOT to do.** Failure modes you've hit before. Each entry: specific action + why it hurt. Stops fresh agents from re-treading dead ends.
- **Always-on rules.** Four defaults that ship with the convention:
  - **3-strike protocol** — after 3 failed attempts at the same root cause, stop and surface
  - **2-action save** — after 2 substantial discoveries, write them down before they evaporate
  - **Plan-first for ≥3-step work** — re-read state + watch-list before touching code
  - **Per-milestone reviewer** — dispatch an independent agent with fresh context after every milestone
- **Repo layout.** Top-level tree with one-line descriptions.
- **Personal context.** Optional — your role, preferences, constraints. Helps the agent tailor explanations.

### `STATE.md` — the now

Edited every session. Read top-to-bottom on fresh sessions. Sections in order:

1. **Starter prompt** — paste-ready block for fresh sessions
2. **Current state** — commit SHA, test count, what just landed, what's next, anything you owe a manual check
3. **Watch-list** — active risks only. `🚧` deferred, `⚠️` known risk with mitigation, `🟡` low-priority observation. Resolved items get *deleted*, not buried in HTML comments
4. **Decisions log** — dated blocks, newest first. The "why" behind every locked choice
5. **Milestones shipped** — one bullet per phase / sprint / feature. Quick trajectory scan
6. **Roadmap** — what's not yet done
7. **Open questions** — anything unresolved
8. **Useful commands** — tests, build, lint, the stuff you keep grep'ing your shell history for
9. **Session log** — optional, usually empty. The decisions log covers 95% of the "why"

---

## The design choices behind it

These aren't arbitrary. Each one is a reaction to a specific failure mode.

**Single source of truth.** Current state lives in *one place* — the top of STATE.md. Duplicate it anywhere else and you've created two sources of truth, which is zero sources of truth.

**Stable / churn separation.** Rules in AGENTS.md don't move. State in STATE.md moves every session. Splitting them means the stable half stays cache-hot across sessions and your git diffs stay readable.

**Dated headings, never numbering.** `### 2026-05-15 — summary` is inherently ordered. Numbered lists need renumbering on every prepend — that's the number-one source of relay bookkeeping bugs.

**Strip resolved items.** When a watch-list risk resolves, delete it. The fix is in the decisions log and git history; leaving HTML-commented `<!-- RESOLVED -->` blocks behind just clutters every future read.

**Fresh-evidence verification.** Before claiming "tests 187/187 passing," the agent runs the tests. Before claiming `commit a3f9c12 is current`, it runs `git log -1`. No carrying over stale claims from the previous session.

**Composition hints, not gates.** The "Next" line can carry English directives — `(needs brainstorming first)`, `(≥3 steps — plan first)`, `(TDD applies)` — that work whether the next agent has specialized skills installed or just applies the discipline inline.

**Scope filter.** Project-specific working memory only. Off-project chat — tooling discussions, philosophical asides, debates about other projects — doesn't pollute the relay docs. Each line in STATE.md is read cold by every fresh session; respect that cost.

---

## Composes with your existing tools

If you use [superpowers](https://github.com/anthropics/skills) or similar skill packages, Relay defers cleanly. `/relay-start` is the entry-point skill; once it's done orienting, normal skill-gate logic applies for whatever you direct next — brainstorming for new features, plan-first for multi-step work, TDD for production code.

Without those skills installed, the same hints in STATE.md "Next" still work as English directives. The convention is self-sufficient.

---

## Take a look at a real one

`examples/AGENTS.md` and `examples/STATE.md` show what populated files look like a few phases into a real project (a fictional Rust note-taking CLI). Not authoritative templates — those live in the scaffold skill — but they're the fastest way to see the convention in action.

---

## Using a non-Claude-Code agent?

The skills in this repo use Claude Code's `SKILL.md` format. The convention itself is just markdown. Any agent that reads markdown and runs git commands can use it:

1. Copy `examples/AGENTS.md` and `examples/STATE.md` into your project root
2. Tell your agent to read `AGENTS.md` → `STATE.md` on fresh sessions
3. At end-of-session: bump current state, prepend a dated decision block, edit the watch-list

PRs welcome for Cursor rules, Codex instructions, Aider conventions, Cline integrations, anything else. Drop them under `agents/<name>/`.

---

## Contributing

Issues and PRs welcome. Most valuable:

- **Agent-specific implementations** — Cursor, Codex, Aider, Continue, Cline, you name it
- **Real-world examples** — populated AGENTS.md / STATE.md from your own projects, sanitized
- **Convention refinements** — when you hit a friction point the current shape doesn't handle, surface it. Especially valuable: cases where the convention forced you into awkward workarounds

---

## License

MIT. Use it however you like.
