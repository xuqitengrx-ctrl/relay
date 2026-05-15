---
name: relay-scaffold
description: Bootstrap the 2-file relay convention for context management on any project. Creates AGENTS.md (stable rules) and STATE.md (living state) at the project root. Run once per project; relay-start and relay-end work out of the box after. Idempotent.
allowed-tools: Read, Write, Bash, Glob
---

# relay-scaffold — bootstrap the 2-file relay convention

You are setting up the two canonical files that relay-start and relay-end consume. After this skill runs, fresh sessions read these files to resume cleanly; end-of-session work updates STATE.md via relay-end.

The two files:

| File | Purpose | Edit cadence |
|---|---|---|
| `AGENTS.md` | Stable rules — conventions, locked decisions, always-on rules, repo layout. Read once per session. | Rare. |
| `STATE.md` | Living state — starter prompt, current snapshot, watch-list, decisions log, milestones, roadmap. | Every relay-end. |

**Why only two:** earlier 4-file conventions (AGENTS / MEMORY / CHAT / HANDOFF_PROMPT) duplicate ~40% of content across files, create three sources of truth for "current state," and require renumber-prone decision lists. The 2-file convention has one stable doc, one living doc, no cross-file drift physically possible.

**You do NOT touch any other project files.** This skill creates exactly two markdown files at the project root.

## Step-by-step

### 1. Pre-flight

```bash
pwd && ls -la
```

Confirm:
- The cwd looks like a project root (`README.md`, `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, etc., or at minimum `.git/`)
- If `.git/` is missing, ask: "Initialize git here, or am I in the wrong directory?"

### 2. Detect existing files

Use `Glob` to check for `AGENTS.md` and `STATE.md` at the project root.

If either exists, surface it and ask: "Overwrite, skip, or merge into existing?" Default to **skip** unless the user explicitly says overwrite.

If you find some other docs convention in place (e.g., `MEMORY.md`, `CONTEXT.md`, `NOTES.md`), don't auto-migrate. Tell the user what's there and ask whether to:
- Skip scaffolding (their convention is fine)
- Scaffold alongside (relay convention lives next to theirs)
- Manually consolidate later (one-time migration — not in this skill's scope)

### 3. Gather minimal context (3 questions, conversational)

1. **What is this project?** (1-2 sentences — feeds AGENTS.md "What this project is")
2. **Tech stack one-liner?** (optional — feeds AGENTS.md "Tools, framework, idioms")
3. **Does the project have a `DESIGN.md` / spec doc and/or `IMPLEMENTATION_PLAN.md` / build plan you want referenced in the read-order?** (yes/no each)

"Skip" is valid for all three; templates ship with `[fill in]` placeholders.

### 4. Create the two files

Use the templates below. Substitute:

| Placeholder | Source |
|---|---|
| `{PROJECT_NAME}` | Short identifier (1-3 words; user provides or derive from cwd basename) |
| `{PROJECT_PATH}` | Absolute path to project root (from `pwd`) |
| `{PROJECT_DESCRIPTION}` | Answer to Q1, or `[fill in]` |
| `{TECH_STACK}` | Answer to Q2, or `[fill in]` |
| `{HAS_DESIGN_DOC}` / `{HAS_PLAN_DOC}` | Booleans from Q3 — drive `{IF_DESIGN: …}` / `{IF_PLAN: …}` conditional lines |
| `{TODAY}` | Today's date in `YYYY-MM-DD` |

### 5. Initial commit (ask first)

```bash
git status --short
```

If working tree has unrelated changes, ask whether to commit the two new files alongside or separately. If fresh project:

```bash
git add AGENTS.md STATE.md && git commit -m "docs: scaffold 2-file relay convention (AGENTS / STATE)"
```

Don't commit without confirmation.

### 6. Surface next steps

> The 2-file relay convention is scaffolded. From here:
>
> 1. **Populate AGENTS.md project-specific sections** as content surfaces: "Core conventions / locked decisions," "What NOT to do," "Repository layout."
> 2. **Use `/relay-end` at end of each working session** to update STATE.md.
> 3. **Use `/relay-start` at start of each fresh session** to orient.
> 4. **Starter prompt for fresh sessions** is at the top of STATE.md — paste-ready.

## Things you must do

- **Pre-flight check.** Don't scaffold in an unrelated directory.
- **Respect existing files.** Ask before overwriting; default to skip.
- **Keep templates minimal.** Project-specific content populates as the project evolves.

## Things you must NOT do

- **Don't migrate existing docs conventions.** One-time migrations are user-driven — describe the target structure, let the user consolidate manually.
- **Don't commit without confirmation.**
- **Don't pre-fill domain content** (failure modes, watch-list entries, locked decisions). Those accumulate as the project lives.
- **Don't create extra files** (DESIGN.md, IMPLEMENTATION_PLAN.md, CONTRIBUTING.md, etc.). The scaffold is exactly two files.

---

# Templates

## Template: AGENTS.md

```markdown
# AGENTS.md — Stable rules for agents working on this project

> **Edit cadence:** rare. This file holds non-negotiables, locked decisions, and conventions that don't change session-to-session. Living state (current SHA, decisions log, watch-list, what's next) lives in `STATE.md` and is updated every relay-end.
>
> **Read order for fresh sessions:** this file (rules), then `STATE.md` (state){IF_DESIGN: , then `DESIGN.md` (spec)}{IF_PLAN: , then `IMPLEMENTATION_PLAN.md` (build plan, relevant phase only)}.

---

## What this project is

{PROJECT_DESCRIPTION}

---

## Tools, framework, idioms

{TECH_STACK}

---

## Core conventions / locked decisions

> Non-negotiables. Future maintenance depends on these. When a decision is locked (user says "don't revisit"), record it here so future sessions don't relitigate.

[Populate as decisions land. Each entry: short bold heading, then 1-3 sentences of rationale. Examples of patterns that prove load-bearing:
- Storage / namespacing conventions (e.g., prefix on shared keys to prevent collisions)
- Cross-project import policies (forbidden / read-only / contract-locked)
- Test conventions (TDD where applicable / what's tested vs manually verified)
- Tooling choices (no bundler / specific runner / no codegen)
- Architectural locks (single source of truth for X / canonical pattern for Y)
- Naming conventions for cross-cutting concerns]

---

## What NOT to do

[Populate as failure modes surface. Each entry: specific action that hurt + why. The goal is to prevent re-treading dead ends.

- Don't <action> — <past failure mode>
- Don't <action> — <past failure mode>]

---

## Always-on rules

1. **3-strike protocol.** After 3 failed attempts at the same root cause, stop. Document each attempt (what you tried, what failed, commit ref if you committed-then-reverted). Re-read STATE.md watch-list for a prior note. Then surface to the user.

2. **2-action findings save.** After 2 substantial discoveries (file inspections that surfaced non-obvious behavior, greps with new info, web fetches that resolved a question), pause and ask: *does what I just learned belong in STATE.md watch-list, or as a comment in the affected source file?* Discoveries lost to context are unrecoverable.

3. **Plan-first for ≥3-step work.** Before any task crossing ≥3 files or ≥3 logical steps, re-read STATE.md decisions log + watch-list{IF_PLAN: + the relevant phase in `IMPLEMENTATION_PLAN.md`}. Compose with `superpowers:writing-plans` if installed; otherwise plan inline before coding.

4. **Per-milestone reviewer discipline.** After every major milestone (phase, sprint, vertical-slice), dispatch an independent reviewer agent (Agent tool, general-purpose, model="opus", fresh context) before starting the next. Pass: commit range, relevant spec sections, hardening patterns followed. Ask for: spec compliance, cross-milestone consistency, invariants, test coverage, severity matrix (Critical / Important / Minor / Nit). This catches real Critical bugs unit tests miss. Don't skip.

---

## Project-specific debugging entries

[Populate as the project evolves. Examples:
1. **Don't know how X works?** Look at <reference>.
2. **Y returns unexpected output?** Already handled by Z; don't tighten further.
3. **Test fails because of W?** Refactor pattern V.]

---

## Repository layout

[Populate when structure stabilizes. Tree sketch of top-level dirs with one-line descriptions.]

---

## Personal context (the user)

[Optional. Role, languages, working preferences (terse vs explained, concrete recommendations vs option trees), cost/time constraints.]

---

## When you ship a meaningful change

1. Update `STATE.md` decisions log + watch-list if relevant.
{IF_DESIGN: 2. Update `DESIGN.md` if the spec changes; call out what changed in the commit.}
{IF_PLAN: 3. Update `IMPLEMENTATION_PLAN.md` if the build sequence shifts.}
4. Run tests before committing (if applicable).
5. Bump version (if versioned releases).
```

## Template: STATE.md

```markdown
# STATE.md — Living state

> **Edit cadence:** every relay-end. Single source of truth for current state, decisions log, watch-list, milestones, roadmap. Stable rules live in `AGENTS.md` (rarely edited).

---

## Starter prompt (paste to fresh sessions)

```
Continue work on {PROJECT_NAME} at {PROJECT_PATH}.

Read in this order:
  1. AGENTS.md  — stable rules, conventions, locked decisions, always-on rules
  2. STATE.md   — current state, decisions log, watch-list, milestones, roadmap (top-to-bottom)

Verify with:
  git log -1 --format='%H %s'
  git status --short

Summarize in 5-8 lines: SHA, what's done, what's next, drift if any.
Wait for direction before coding.

Default mode: auto OFF — discuss / propose before acting.
```

---

## Current state

- **Commit:** [SHA — bump every relay-end]
- **Tests:** [N/N if applicable, or omit line]
- **Last landed:** [milestone or session summary, 1-2 sentences]
- **Next:** [next milestone or task; append `(needs brainstorming first)` / `(≥3 steps — plan first)` / `(TDD applies)` as composition hints]
- **Pending verification:** [manual checks user owes, or "none"]
- **Working tree:** clean

---

## Watch-list

> Active risks, deferred items, sister-project drift. Symbols:
> - 🚧 in-progress / deferred but tracked
> - ⚠️ known risk with mitigation in place or planned
> - 🟡 noted observation, low priority
>
> When an item resolves, REMOVE it (the resolution is captured in the Decisions log + git history). Don't leave resolved items as HTML-commented-out clutter.

[Populate as risks surface. Each entry: `<symbol> **<short name>.** <description>. <mitigation or v-next plan>.`]

---

## Decisions log (newest first)

> Dated blocks, no numbering. Prepend new entries at top. Absorbs both structured-decision and narrative-why roles. Each block is the "why" — what was decided, what was rejected, commit refs.
>
> **Rotation:** when this section exceeds ~20 entries, archive older blocks (`STATE_archive/decisions-YYYY-QN.md`) and keep the last ~10-15 here.

[New entries land here. Template:

### YYYY-MM-DD — <bold one-line summary>

<4-8 sentences. Commit refs (`abc1234`), file:line where relevant. What was decided, alternatives rejected, anything a fresh agent would need to continue from here.>
]

---

## Milestones shipped

> Historical "what's done" anchor. One bullet per significant milestone (phase, sprint, feature, vertical-slice). Provides quick scan of trajectory without reading every decision-log entry.

[Populate as milestones land. Format:

- ✅ **<milestone name>** (YYYY-MM-DD, commit `abc1234`) — <1-2 sentence summary + key files/decisions>
]

---

## Roadmap (what's not yet done)

> Forward-looking. Pending milestones / tasks. Strip items as they land.

[Populate as scope is defined.]

---

## Open questions

[Populate as questions surface. Each: `🟡 **<topic>** — <question>. <context for resolution>.`]

---

## Useful commands

[Populate as tooling stabilizes.

```bash
# Run tests
<command>

# Build / run
<command>

# Lint / format / typecheck
<command>
```]

---

## Session log (optional, rotate past ~10 entries)

> **Most sessions don't need an entry here** — the decisions log captures the "why" with commit refs. Add a Session block ONLY when the session involved substantial prose that doesn't fit decision-block format (long debates, rejected alternatives with extensive detail, user-preference shifts).
>
> **Rotation:** when this section exceeds ~10 entries, archive older sessions into `STATE_archive/sessions-YYYY-QN.md` and keep the last ~5 here.

[Optional Session entries. Template:

### Session N — <topic> (YYYY-MM-DD)

<brief narrative — what this session accomplished, anything that needed prose to capture>
]
```
