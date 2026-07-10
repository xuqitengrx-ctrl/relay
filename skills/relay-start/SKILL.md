---
name: relay-start
description: Fresh-session orientation for the 2-file relay convention (AGENTS.md + STATE.md). Reads both files top-to-bottom, verifies git SHA + working tree, surfaces drift, summarizes in 5-8 lines, and waits for direction. Does not auto-code. Composes cleanly with other skills if installed, but doesn't depend on any specific plugin.
allowed-tools: Read, Bash, Grep, Glob
---

# relay-start — fresh-session orientation

You are picking up a project cold. Goal: arrive at a 5-to-8-line summary of current state, with any drift surfaced, and propose a concrete next step — without writing code or making assumptions.

**You do NOT start coding. You read, verify, summarize, and wait.**

## Session-focus argument (optional)

If the user passed arguments to this skill invocation, treat them as a description of what *this* session will focus on. Use it to prioritize which watch-list items, decisions, and roadmap entries to surface in the summary (step 6) — surface focus-relevant ones even if they'd otherwise fall outside the default top-3-5 window — and to sharpen the proposed next step (step 7). Verification steps (4/5) still run in full regardless of args.

## Step-by-step

### 1. Pre-flight

Use `Glob` to confirm `AGENTS.md` and `STATE.md` exist at the project root. If either is missing, stop: "This project doesn't have the 2-file relay convention scaffolded. Run `/relay-scaffold` first, or paste the starter prompt directly if you have one."

### 2. Read AGENTS.md (stable rules)

First check whether AGENTS.md's content is already in your context — many harnesses auto-inject it, or the project's CLAUDE.md is a copy/symlink of it. If so, don't Read it again; work from what's loaded. Otherwise `Read: AGENTS.md` (full). Note: core conventions / locked decisions, what-NOT-to-do failure modes, the always-on rules, repo layout.

This file should rarely surprise you across sessions — it's the stable half. If something looks out of place (a watch-list item, a "Last updated" snapshot, a commit SHA), there's drift between AGENTS.md and STATE.md. Flag it in step 6.

### 3. Read STATE.md (living state)

For a well-rotated file (see relay-end's STATE.md size budget), `Read: STATE.md` top-to-bottom in one shot — it's cheap. If the file looks large (gut check, or `wc -l STATE.md` past ~400), read surgically instead: full-read everything except the Decisions log, then for that section scan just the `### ` dated headings (`grep -n '^### ' STATE.md`) and read only the top 3-5 blocks in full. A bloated, unrotated decisions log is a sign relay-end's rotation was skipped or predates that rule — don't compensate by reading the whole thing anyway; flag it in step 6 instead. Sections in order:

1. **Starter prompt** — confirms read-order; you've done step 2 already
2. **Current state** — the canonical snapshot you'll verify in step 4. Note: claimed commit SHA, test count, what's done, what's next, pending verification, and the "Suggested skills" line
3. **Watch-list** — 🚧 / ⚠️ / 🟡 items that may block or shape the next task
4. **Decisions log** — top 3-5 dated blocks. Load-bearing for any task touching related code. Scan deeper only for deep-history topics. If a question needs history older than what's here, check `STATE_archive/*.md` if present
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
- Any non-"none" Pending verification items — ask whether the user has done them; nothing else in the loop ever closes these, so an unasked item persists forever
- The next milestone / task per STATE.md "Current state" — including any suggested skills listed there

5 lines minimum, 8 maximum.

Check the objective signal, not vibes: `wc -l STATE.md`, or count decisions-log headings (`grep -c '^### ' STATE.md`, restricted to that section). If total length exceeds ~350 lines, or the decisions log holds more than ~20 entries (meaning relay-end's automatic rotation was skipped or predates that rule), name the actual number and suggest a `relay-end` compaction pass. This is a soft nudge only — never block orientation on it.

### 7. Propose next step + honor suggested skills

Read STATE.md "Current state" → "Next" line, and the "Suggested skills" line alongside it. For each suggested skill, judge by what it would do, not its name:

- **Would run before any code is written** (scopes ambiguous requirements, plans multi-step work, sets up a test-first approach, or equivalent) → propose invoking it before coding: "Next is <task>. Will <do that> first (`<skill>` if installed, otherwise inline)." Do NOT propose to skip straight to implementation.
- **Would run alongside or after** (a review, a debugging aid, or equivalent) → mention it's relevant and available; let the user decide when to invoke it.

**"Suggested skills: none" or empty** → if the next task is plainly creative (new feature, ambiguous requirements), recommend scoping/discussing the approach before implementation anyway. If plainly mechanical (rename, refactor, dependency bump), propose direct execution. If ambiguous, ask.

**Default mode is auto OFF** for relay-start. Propose; don't execute. Even a "small fix" requires user confirmation here.

### 8. End with an explicit availability cue

Last line: a short prompt like "Ready when you are — confirm direction or redirect." or "Awaiting your call."

## Things you must do

- **Read in order: AGENTS.md → STATE.md.** Stable rules first, then living state on top.
- **Verify SHA + working tree.** Cheap checks; the safety net for stale STATE.md.
- **Cite specifics by date or symbol.** Concrete citations prove you read; vague mentions don't.
- **Honor suggested skills from relay-end.** If one that runs before coding is listed, don't propose to skip it.

## Things you must NOT do

- **Don't start coding before user confirms direction.** Even a "small fix" is a no.
- **Don't paraphrase STATE.md back at the user.** They wrote it. The summary's value is the verification + cited specifics, not a re-statement.
- **Don't skip SHA + working-tree verification** because "the prompt says clean tree." Always check.
- **Don't read every decision-log entry from scratch** unless the topic warrants. Top 3-5 + targeted lookups on demand.
- **Don't read every Session log entry** (if present) unless pursuing deep-history.

## When to flag drift loudly

- Working tree dirty when STATE.md claims clean → STOP, ask before proceeding (it may also be another live session's WIP — don't touch it)
- Test count mismatch (if you ran tests per step 4 triggers) → name the delta, ask
- Last commit SHA mismatch → list commits between STATE.md-SHA and HEAD, ask whether trusted
- Watch-list 🚧 item directly blocking proposed next step → flag with workaround or deferral
- AGENTS.md contains current-state content (commit SHA, Last updated table) → drift between AGENTS / STATE; flag for cleanup

## Composition with other skills (if any are installed)

This skill is the orientation entry point. STATE.md's "Suggested skills" line is the general mechanism for pointing at what's next — relay doesn't assume any particular plugin or fixed vocabulary. relay-end populates that line with whatever's genuinely relevant AND actually installed in the environment, or leaves it `none`. After step 7, invoke whichever of those the user confirms, if any.

relay-start does not preempt those skills; it precedes them. Once you've oriented and the user confirms direction, invoke whatever the "Suggested skills" line points at.

**If nothing relevant is installed:** the "Suggested skills" line still applies as a plain-English directive — read the reason given, and apply that same discipline inline before coding rather than skipping it. The relay convention is self-sufficient and does not require any other skill or plugin.
