---
name: relay-end
description: End-of-session handoff for the 2-file relay convention (AGENTS.md + STATE.md). Updates STATE.md — Current state, Decisions log (dated, no numbering), Watch-list, Milestones, Roadmap, optional Session entry. Verifies state with fresh git + test evidence before drafting. Pauses for user review before committing.
allowed-tools: Read, Edit, Write, Bash, Grep, Glob
---

# relay-end — single-file end-of-session handoff

You are wrapping a working session. Goal: leave `STATE.md` in a state where the next agent (fresh session, possibly different model, no conversation history) can resume without losing context. `AGENTS.md` is rarely touched (only when a new always-on rule lands).

**You do NOT start coding.** This skill is docs-only. If the user asks for both relay + a code fix in the same turn, do the code first, THEN invoke relay-end after the code is committed.

## Scope filter — what belongs in STATE.md

STATE.md is **project-specific working memory**. A working session often contains off-project conversation (tooling, skill setup, asides). **None of that belongs.** Recording it pollutes future sessions.

Walk this checklist for each commit / decision / conversation thread in the session range:

- [ ] Touched project source files (not just relay docs / tooling)? → IN
- [ ] Locked design / UX / scope decision the user committed to? → IN
- [ ] Reviewer finding + fix? → IN
- [ ] New watch-list risk or always-on rule? → IN (rule → AGENTS.md; risk → STATE.md watch-list)
- [ ] Tooling / skill / CI / editor discussion with no project-file commit? → OUT
- [ ] Off-topic chat or aside? → OUT
- [ ] Re-derivation of something already in AGENTS.md or STATE.md? → OUT (cite, don't repeat)

**Test:** *would a fresh agent picking up the project a month from now need this?* If unsure, lean toward skipping; over-recording is the worse failure.

If the session was almost entirely off-project, relay-end's touch is just a Current-state bump. That's correct. Don't pad.

## Step-by-step

### 1. Pre-flight

Use `Glob` to confirm `AGENTS.md` and `STATE.md` exist at the project root. If either is missing, stop: "Project doesn't have the 2-file relay convention scaffolded. Run `/relay-scaffold` first."

### 2. Check the working tree — bundle or block

```bash
git status --short
```

Three cases:

- **Clean tree:** proceed.
- **Uncommitted code from this session:** offer to bundle into the relay-end commit. Ask: "Working tree has uncommitted changes in <files>. Bundle into the relay-end commit, or commit them separately first?"
- **Uncommitted changes unrelated to this session** (different branch's WIP, half-finished experiment): stop and tell the user to commit/stash separately first.

### 3. Identify the session's commit range

```bash
git log --oneline -30
```

Look for the most recent commit matching `docs:.*relay-end` (or similar marker). That commit's SHA is the session's start; everything since is what needs documenting.

If no prior relay-end commit exists (first relay-end on this project), ask the user where to draw the line.

### 4. Capture fresh state evidence

You're about to claim "tests N/N" and "Current state X" in STATE.md. **Verify with fresh evidence before drafting** — don't trust prior session's claims.

```bash
git log -1 --format='%H %s'
```

If the project has tests (check STATE.md "Useful commands" or AGENTS.md):

```bash
<test command> 2>&1 | tail -10
```

If tests fail, **stop and surface** — relay-end should not draft a "tests passing" claim on a red tree. Ask the user how to proceed (fix first, or document the regression in watch-list).

### 5. Read STATE.md (and AGENTS.md only if a new always-on rule landed)

You only need to read STATE.md in full. Skim AGENTS.md only if this session produced a new always-on rule that needs to be added (rare).

### 6. Edit STATE.md — six sections, in order

**(a) Starter prompt.** Usually no change. Update `{PROJECT_NAME}` / `{PROJECT_PATH}` only if those shifted.

**(b) Current state — the canonical snapshot.** Overwrite the block in place:
- Commit: new SHA (first 7+ chars)
- Tests: new count (from step 4, fresh)
- Last landed: 1-2 sentence summary of what shipped this session
- Next: next milestone / task. Append composition hints if applicable: `(needs brainstorming first)` / `(≥3 steps — plan first)` / `(TDD applies)`. These are English directives — they work whether or not the next agent has superpowers installed
- Pending verification: any manual checks the user owes, or "none"
- Working tree: "clean" (post relay-end commit)

**(c) Watch-list.** Three tasks:

1. **Add** new ⚠️ / 🚧 / 🟡 entries that surfaced this session
2. **Remove** items the session resolved — don't comment-out, just delete. The resolution is captured in the Decisions log + git history. HTML-commented `<!-- RESOLVED -->` blocks accumulate as clutter; fresh agents waste context reading them
3. **Update** any item whose status / mitigation plan shifted

Symbols: 🚧 in-progress / deferred, ⚠️ known risk with mitigation, 🟡 low-priority observation.

**(d) Decisions log — prepend dated blocks at the top.** For each landmark this session (milestone implementation, reviewer fix-pass, locked design/UX decisions), prepend:

```
### YYYY-MM-DD — <bold one-line summary>

<4-8 sentences with commit refs and file:line refs where relevant. What was decided, what was rejected and why, anything a fresh agent would need to continue.>
```

**No numbering, no renumbering.** Dated headings are inherently ordered. Newest at the top.

If the section exceeds ~20 entries, suggest archiving older blocks to `STATE_archive/decisions-YYYY-QN.md`.

**(e) Milestones shipped.** If this session closed a significant milestone (phase, sprint, feature, vertical-slice), append a bullet:

```
- ✅ **<milestone name>** (YYYY-MM-DD, commit `abc1234`) — <1-2 sentence summary + key files/decisions>
```

Skip if the session was incremental polish without a clean milestone boundary.

**(f) Roadmap.** Strip any milestone you completed. Append new sub-tasks that surfaced.

**(g) Session log — OPTIONAL, skip by default.** Only add a Session block if the session involved substantial prose that doesn't fit decision-block format (long debates with rejected alternatives in detail, significant user-preference shifts). Most sessions don't need this.

If the section exceeds ~10 entries, suggest archiving older sessions to `STATE_archive/sessions-YYYY-QN.md`.

### 7. Edit AGENTS.md (rare — only for new always-on rules)

Skip unless this session surfaced a NEW always-on rule (a pattern that any future session in any project state must honor). Add it to AGENTS.md "Always-on rules," "Core conventions / locked decisions," or "What NOT to do" as appropriate.

The bar is high. Pre-existing engineering wisdom doesn't belong here.

### 8. Show the diff summary

```bash
git diff --stat AGENTS.md STATE.md
```

Tell the user: line counts changed per file. Offer to dump the full diff for inspection.

### 9. Pause for user review

**Do not commit yet.** Ask: "Drafted STATE.md updates (and AGENTS.md if applicable). Want me to commit, or inspect / edit first?"

### 10. Commit on user confirmation

When user confirms:

```bash
git add AGENTS.md STATE.md && git commit -m "$(cat <<'EOF'
docs: relay-end <session topic> → <next milestone>

<short summary of what landed — mirror prior relay-end commits>

Working tree clean for next session.
EOF
)"
```

If your environment supports a co-author trailer, append per convention.

## Things you must do

- **Verify with fresh evidence before drafting.** Run `git log -1` and the test command. Don't carry over prior claims.
- **Use dated headings, never numbers.** `### YYYY-MM-DD — summary` is inherently ordered. Numbering is dead.
- **Walk the scope filter checklist before drafting.** Off-project content pollutes every future session.
- **Strip resolved watch-list items.** Don't leave them as HTML-commented clutter.
- **One file edit (STATE.md) by default.** AGENTS.md only when a new always-on rule lands.
- **Pause before commit.** User inspects diff; safety net for tone drift.

## Things you must NOT do

- **Don't start coding.** Docs-only.
- **Don't paraphrase commit messages from `git log`.** Copy exact subject lines into decision-block detail — grep-ability across STATE.md ↔ git history matters.
- **Don't auto-pick the relay boundary.** If `git log` doesn't show a clear prior relay-end commit, ASK the user where the session started.
- **Don't draft "tests N/N passing" on a red tree.** If step 4 shows failures, stop and surface.
- **Don't write a Session log block by default.** Decisions log is enough for 95% of sessions.
- **Don't keep resolved-comment HTML blocks** (`<!-- RESOLVED ... -->`) in watch-list. Delete resolved items outright.
- **Don't auto-bump version numbers** — that's a user decision (semver), not relay's concern.
- **Don't add new always-on rules to AGENTS.md unprompted.** The bar is "applies to every future session in any state."

## Reference: STATE.md sections (in order)

1. **Starter prompt** — paste-ready block for fresh sessions
2. **Current state** — canonical snapshot (commit SHA, tests, last landed, next, pending)
3. **Watch-list** — active risks (no resolved-comment clutter)
4. **Decisions log** — dated blocks, newest first
5. **Milestones shipped** — historical anchor; one bullet per milestone
6. **Roadmap** — what's not yet done
7. **Open questions**
8. **Useful commands**
9. **Session log** (optional, usually empty)

## Composition with superpowers (if installed)

Composition hints in STATE.md "Next" line are English directives — they work whether or not the next session has superpowers installed. If installed, the relevant skill (`brainstorming` / `writing-plans` / `test-driven-development` / `verification-before-completion`) will fire on those keywords; otherwise the agent applies the discipline inline.
