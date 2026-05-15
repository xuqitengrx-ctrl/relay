---
name: relay-start
description: Fresh-session orientation for the 2-file relay convention (AGENTS.md + STATE.md). Reads both files top-to-bottom, verifies git SHA + working tree, surfaces drift, summarizes in 5-8 lines, and waits for direction. Does not auto-code. Composes cleanly with superpowers if installed.
allowed-tools: Read, Bash, Grep, Glob
---

# relay-start — fresh-session orientation

You are picking up a project cold. Goal: arrive at a 5-to-8-line summary of current state, with any drift surfaced, and propose a concrete next step — without writing code or making assumptions.

**You do NOT start coding. You read, verify, summarize, and wait.**

## Step-by-step

### 1. Pre-flight

Use `Glob` to confirm `AGENTS.md` and `STATE.md` exist at the project root. If either is missing, stop: "This project doesn't have the 2-file relay convention scaffolded. Run `/relay-scaffold` first, or paste the starter prompt directly if you have one."

### 2. Read AGENTS.md (stable rules)

`Read: AGENTS.md` (full). Note: core conventions / locked decisions, what-NOT-to-do failure modes, the four always-on rules (3-strike, 2-action save, plan-first, per-milestone reviewer), repo layout.

This file should rarely surprise you across sessions — it's the stable half. If something looks out of place (a watch-list item, a "Last updated" snapshot, a commit SHA), there's drift between AGENTS.md and STATE.md. Flag it in step 6.

### 3. Read STATE.md (living state)

`Read: STATE.md` top-to-bottom. Sections in order:

1. **Starter prompt** — confirms read-order; you've done step 2 already
2. **Current state** — the canonical snapshot you'll verify in step 4. Note: claimed commit SHA, test count, what's done, what's next, pending verification, composition hints in "Next"
3. **Watch-list** — 🚧 / ⚠️ / 🟡 items that may block or shape the next task
4. **Decisions log** — top 3-5 dated blocks. Load-bearing for any task touching related code. Scan deeper only for deep-history topics
5. **Milestones shipped** — quick trajectory scan
6. **Roadmap** — what's pending
7. **Open questions** — anything unresolved
8. **Useful commands** — for tests / build / lint
9. **Session log** (if present) — only consult on demand

### 4. Verify state with fresh evidence

Two cheap checks. Flag any mismatch BEFORE summarizing:

```bash
git log -1 --format='%H %s'
git status --short
```

Verify:
- **Last commit SHA** — first 7+ chars match STATE.md "Current state"? If not: someone committed after the last relay-end. Note new commits.
- **Working tree** — should be clean per STATE.md. If unstaged/uncommitted changes exist: surface them; user may have forgotten a relay-end, or it's deliberate WIP.

**Tests — DO NOT auto-run.** Trust the count in STATE.md unless:
- The SHA check failed (commits landed after relay-end → tests may have shifted)
- The user explicitly asks to verify
- You see test-file changes in the new commits from step 5

If any trigger fires, run the test command from STATE.md "Useful commands" and surface the delta.

### 5. Skim live state for drift not in STATE.md

```bash
git log --oneline -10
```

Look for: commits after STATE.md's stated SHA (auto-fixes, hotfixes), oddly-recent timestamps suggesting in-flight work from another tool/agent.

If you see new directories or files mentioned in commit messages, optionally check them with `Glob` — but don't go deep. The summary's purpose is to surface gaps, not investigate them.

### 6. Summarize in 5-8 lines

Tight summary. The user reads this to confirm you read correctly:

- Current commit SHA + test count (if applicable) + working-tree status
- The most-recent landed milestone + any reviewer fix-pass that followed
- The 1-2 most load-bearing decisions or watch-list items affecting the next chunk — **cite by date or symbol** (cited specifics prove you read; vague references don't)
- Any drift surfaced in step 4 / 5
- The next milestone / task per STATE.md "Current state" — including any composition hints (e.g., "needs brainstorming first", "≥3 steps — plan first")

5 lines minimum, 8 maximum.

### 7. Propose next step + honor composition hints

Read STATE.md "Current state" → "Next" line. It may include a composition hint:

- **"needs brainstorming first"** → propose: "Next is <task>. Will brainstorm before any implementation (`superpowers:brainstorming` if installed, otherwise inline)." Do NOT propose to start coding.
- **"≥3 steps — plan first"** → propose: "Next is <task>, ≥3 steps. Will write a plan first (`superpowers:writing-plans` if installed, otherwise inline plan)."
- **"TDD applies"** → mention: "Next is <task>. TDD discipline applies."
- **No hint** → if the next task is plainly creative (new feature, ambiguous requirements), recommend brainstorming. If plainly mechanical (rename, refactor, dependency bump), propose direct execution. If ambiguous, ask.

**Default mode is auto OFF** for relay-start. Propose; don't execute. Even a "small fix" requires user confirmation here.

### 8. End with an explicit availability cue

Last line: a short prompt like "Ready when you are — confirm direction or redirect." or "Awaiting your call."

## Things you must do

- **Read in order: AGENTS.md → STATE.md.** Stable rules first, then living state on top.
- **Verify SHA + working tree.** Cheap checks; the safety net for stale STATE.md.
- **Cite specifics by date or symbol.** Concrete citations prove you read; vague mentions don't.
- **Honor composition hints from relay-end.** If "Next" says "needs brainstorming," don't propose to skip it.

## Things you must NOT do

- **Don't start coding before user confirms direction.** Even a "small fix" is a no.
- **Don't paraphrase STATE.md back at the user.** They wrote it. The summary's value is the verification + cited specifics, not a re-statement.
- **Don't skip SHA + working-tree verification** because "the prompt says clean tree." Always check.
- **Don't read every decision-log entry from scratch** unless the topic warrants. Top 3-5 + targeted lookups on demand.
- **Don't read every Session log entry** (if present) unless pursuing deep-history.

## When to flag drift loudly

- Working tree dirty when STATE.md claims clean → STOP, ask before proceeding
- Test count mismatch (if you ran tests per step 4 triggers) → name the delta, ask
- Last commit SHA mismatch → list commits between STATE.md-SHA and HEAD, ask whether trusted
- Watch-list 🚧 item directly blocking proposed next step → flag with workaround or deferral
- AGENTS.md contains current-state content (commit SHA, Last updated table) → drift between AGENTS / STATE; flag for cleanup

## Composition with superpowers (if installed)

This skill is the orientation entry point. After step 7, normal skill-gate logic applies for whatever the user directs:

- `superpowers:brainstorming` — fires before new-feature implementation
- `superpowers:writing-plans` — fires before ≥3-step work
- `superpowers:test-driven-development` — fires for production-code changes
- `superpowers:systematic-debugging` — fires for any reported bug
- `superpowers:verification-before-completion` — fires before claiming work done

relay-start does not preempt these. It precedes them; once you've oriented and the user confirms direction, invoke whichever superpowers skill applies. The conflict with `using-superpowers` ("invoke skill before any response") is satisfied by relay-start itself being a skill — once it's running, you're compliant.

**Without superpowers installed:** the composition hints in STATE.md "Next" line (e.g., "needs brainstorming first") still apply as English directives — brainstorm / plan / verify inline before coding. The relay convention is self-sufficient and does not require superpowers.
