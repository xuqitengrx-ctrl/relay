---
name: relay-scaffold
description: Bootstrap the 2-file relay convention for context management on any project. Creates AGENTS.md (stable rules) and STATE.md (living state) at the project root. Run once per project; relay-start and relay-end work out of the box after. Idempotent.
allowed-tools: Read, Write, Bash, Glob
---

# relay-scaffold — bootstrap the 2-file relay convention

Creates exactly two files at the project root. Touch nothing else.

| File | Holds | Cadence |
|---|---|---|
| `AGENTS.md` | Non-negotiables, locked decisions, conventions | Rare |
| `STATE.md` | Snapshot, watch-list, decisions, milestones, roadmap | Every relay-end |

**The templates ship nearly empty on purpose.** Project content accumulates as the project lives;
pre-filling it invents facts. Bracketed hints are for whoever populates the section — delete each
hint as its section fills, so instruction text never becomes permanent freight in a file that every
future session reads in full.

## Steps

**1. Pre-flight.** `pwd && ls -la`. Confirm a project root (`.git/` at minimum). No `.git/` → ask
whether to init or whether you're in the wrong directory.

**2. Detect.** Glob for `AGENTS.md` and `STATE.md`. Either exists → ask overwrite / skip / merge,
default **skip**. Another convention in place (`MEMORY.md`, `CONTEXT.md`, `NOTES.md`) → say what's
there and offer to skip or scaffold alongside. **Never auto-migrate**; consolidation is the user's
call, not this skill's scope.

**3. Ask three questions**, all skippable: what the project is (1–2 sentences), tech stack
one-liner, and whether a `DESIGN.md` and/or `IMPLEMENTATION_PLAN.md` should join the read-order.

**4. Write both files** from the templates below, substituting:

| Placeholder | Source |
|---|---|
| `{PROJECT_NAME}` | 1–3 words, from the user or the cwd basename |
| `{PROJECT_PATH}` | absolute path from `pwd` |
| `{PROJECT_DESCRIPTION}` / `{TECH_STACK}` | Q1 / Q2, or `[fill in]` |
| `{IF_DESIGN: …}` / `{IF_PLAN: …}` | keep the inner text if Q3 said yes, else drop the whole span |
| `{TODAY}` | `YYYY-MM-DD` |

**5. Commit — ask first.** `git status --short`; if unrelated changes are pending, ask whether to
commit the two files separately. Otherwise
`git add AGENTS.md STATE.md && git commit -m "docs: scaffold 2-file relay convention (AGENTS / STATE)"`.

**6. Point at what's next:** `/relay-start` opens a session, `/relay-end` closes one, and both
files fill in as work lands.

---

# Templates

## Template: AGENTS.md

```markdown
# AGENTS.md — Stable rules for agents working on this project

> Non-negotiables and locked decisions. Living state is in `STATE.md`.
> Read order: this file, then `STATE.md`{IF_DESIGN: , then `DESIGN.md`}{IF_PLAN: , then `IMPLEMENTATION_PLAN.md` (relevant phase only)}.

## What this project is

{PROJECT_DESCRIPTION}

## Tools, framework, idioms

{TECH_STACK}

## Core conventions / locked decisions

[Reserve for what would NOT be rediscovered by reading the code — storage/namespacing rules,
cross-project import policy, architectural locks, tooling choices. Short bold heading, then one to
three sentences. Delete this hint once populated.]

## What NOT to do

[One line each: the action, and the failure it caused. Cut any entry once a test, lint rule or type
enforces it — at that point the tooling is the record. Delete this hint once populated.]

## Always-on rules

1. **3-strike protocol.** After three failed attempts at the same root cause, stop. Record what
   was tried and what failed, check the `STATE.md` watch-list for a prior note, then surface it.
2. **Save findings before they're lost.** After two substantial discoveries, ask whether they
   belong in the watch-list or as a comment in the affected file. Context is not storage.
3. **Plan before ≥3-step work.** Re-read the decisions log and watch-list{IF_PLAN: and the relevant
   plan phase} before any task crossing three files or three logical steps.
4. **Independent review per milestone.** Dispatch a reviewer with fresh context before starting the
   next milestone. Give it the commit range and the spec; ask for severity-ranked findings.

## Repository layout

[Tree sketch, one line per top-level dir. Delete this hint once populated.]

## Personal context (the user)

[Optional: role, working preferences, constraints.]

## When you ship a meaningful change

1. Update `STATE.md` decisions log and watch-list if relevant.
{IF_DESIGN: 2. Update `DESIGN.md` if the spec changed.}
{IF_PLAN: 3. Update `IMPLEMENTATION_PLAN.md` if the build sequence shifted.}
4. Run tests before committing.
```

## Template: STATE.md

```markdown
# STATE.md — Living state

> Updated every relay-end. Stable rules are in `AGENTS.md`.
> Target ~250–350 lines: every `relay-start` reads this file in full.

## Starter prompt (paste to fresh sessions)

```
Continue work on {PROJECT_NAME} at {PROJECT_PATH}.

Read in this order:
  1. AGENTS.md  — stable rules, conventions, locked decisions
  2. STATE.md   — current state, decisions, watch-list, milestones, roadmap

Verify with:
  git log -1 --format='%H %s'
  git status --short

Summarize in 5-8 lines: SHA, what's done, what's next, drift if any.
Wait for direction before coding.
```

## Current state

- **Commit:** [SHA]
- **Tests:** [N/N, or omit]
- **Last landed:** [1-2 sentences]
- **Next:** [one line]
- **Suggested skills:** [0-3 installed skills with a short reason, or `none`]
- **Pending verification:** [manual checks the user owes, or `none`]
- **Working tree:** clean

## Watch-list

[🚧 deferred · ⚠️ risk · 🟡 minor. Each: symbol, bold short name, what it is, what mitigates it.
Delete an item when it resolves. Delete this hint once populated.]

## Decisions

[Newest first. One dated block per session:

### YYYY-MM-DD — <a few words>

- <decision> (`abc123`)

One line each. Leave out anything `git log` or the code already answers.
Delete this hint once populated.]

## Milestones shipped

[- ✅ **<name>** (YYYY-MM-DD, `abc1234`) — one or two sentences. Delete this hint once populated.]

## Roadmap

[What's not yet done. Strip entries as they land.]

## Open questions

[Only what will shape a near-term task. Delete a question when it resolves.]

## Useful commands

[Test, build, lint — the ones a fresh session needs.]
```
