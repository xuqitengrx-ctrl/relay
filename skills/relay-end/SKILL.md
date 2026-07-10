---
name: relay-end
description: End-of-session handoff for the 2-file relay convention (AGENTS.md + STATE.md). Updates STATE.md — Current state, Decisions log (dated, no numbering), Watch-list, Milestones, Roadmap, optional Session entry. Verifies state with fresh git + test evidence before drafting. Pauses for user review before committing.
allowed-tools: Read, Edit, Write, Bash, Grep, Glob
---

# relay-end — single-file end-of-session handoff

You are wrapping a working session. Goal: leave `STATE.md` in a state where the next agent (fresh session, possibly different model, no conversation history) can resume without losing context. `AGENTS.md` is rarely touched (only when a new always-on rule lands).

**You do NOT start coding.** This skill is docs-only. If the user asks for both relay + a code fix in the same turn, do the code first, THEN invoke relay-end after the code is committed.

## Session-focus argument (optional)

If the user passed arguments to this skill invocation, treat them as a description of what the **next** session will focus on. Use it to bias the `Next` line and `Suggested skills` field (step 6b) toward that focus, and to prioritize which watch-list/roadmap items to surface or add. Args tailor *what's foregrounded* — the verification and scope-filter steps below still run in full regardless.

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

**Then apply the recoverability test, even to items that passed the checklist above:** would a fresh agent need this to avoid re-deriving it or repeating a mistake — or is it already recoverable by reading the code, or by running `git log` / `git show` on the commit? If recoverable, leave it out, even if it technically touched project source. STATE.md is for the *why* and the *rejected alternative* — not a changelog of *what* happened. Most over-recording comes from restating what a commit already says verbatim in its own message.

**Test:** *would a fresh agent picking up the project a month from now need this?* If unsure, lean toward skipping; over-recording is the worse failure.

If the session was almost entirely off-project, relay-end's touch is just a Current-state bump. That's correct. Don't pad.

## STATE.md size budget

`relay-start` reads `STATE.md` in full every session — its token cost scales with the file's total accumulated size, not with what's actually relevant to the next task. An unrotated file makes every future session pay for the *whole project's history*, forever. Target steady state: ~250-350 lines total. This is why the rotations in step 6 below (decisions log, session log, milestones) are **automatic, not suggestions** — don't skip them because the file "still reads fine"; the cost lands on a fresh agent's context window, not on an eye scanning it in an editor. Step 8 measures the outcome (`wc -l`) every session, so a budget miss is caught the moment it happens, not five sessions later.

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

**Parallel sessions:** if other sessions or worktrees are active on this repo, their relay-ends will conflict with yours at merge (both prepend at the top of the decisions log). Resolution is mechanical — keep both dated blocks, newest first — but flag it so the user merges deliberately rather than discovering the conflict later.

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

### 6. Edit STATE.md — eight sections, in order

**One home per item, across sections.** A deferred task lives in the roadmap OR the watch-list, not both; a question lives in Open questions, not also as a 🟡 watch-list item. Duplicates drift independently and double the read cost — if two sections must reference the same thing, one holds the content, the other at most a pointer.

**(a) Starter prompt.** Usually no change. Update `{PROJECT_NAME}` / `{PROJECT_PATH}` only if those shifted.

**(b) Current state — the canonical snapshot.** Overwrite the block in place:
- Commit: new SHA (first 7+ chars)
- Tests: new count (from step 4, fresh)
- Last landed: 1-2 sentence summary of what shipped this session
- Next: next milestone / task, in one line
- Suggested skills: 0-3 entries in the form `<skill-name> (<short reason>)`. Check what's actually installed in the current environment before naming one — don't assume any fixed vocabulary or plugin. Write `none` if the next task is plainly mechanical. These are English directives — even without the skill installed, a fresh agent can read the reason and apply the same discipline inline. Don't pad this list to look thorough — 0 honest entries beats 3 filler ones
- Pending verification: first close out the *previous* block's items — confirmed done → drop; still owed → carry forward explicitly. Never silently drop one. Then add any new manual checks the user owes, or "none"
- Working tree: "clean" (post relay-end commit)

**(c) Watch-list.** Three tasks:

1. **Add** new ⚠️ / 🚧 / 🟡 entries that surfaced this session
2. **Remove** items the session resolved — don't comment-out, just delete. The resolution is captured in the Decisions log + git history. HTML-commented `<!-- RESOLVED -->` blocks accumulate as clutter; fresh agents waste context reading them
3. **Update** any item whose status / mitigation plan shifted
4. **Age-check** items carried unchanged across many sessions: still real? still shaping near-term work? If it only matters to a far-future milestone, fold it into that roadmap entry instead of paying its read cost every session; if it no longer matters, delete it

Symbols: 🚧 in-progress / deferred, ⚠️ known risk with mitigation, 🟡 low-priority observation.

**(d) Decisions log — one dated block per session, prepended at the top.** Consolidate everything this session decided under a single dated heading; each decision is a sub-bullet:

```
### YYYY-MM-DD — <session summary in a few words>

- <decision>, over <rejected alternative>, because <reason> (`abc123`)
- <decision 2> (`def456`)
```

**Default to one line per decision.** Expand a bullet to 2-4 sentences only when the one-liner would leave an obvious follow-up unanswered — a genuine rejected alternative, a non-obvious trade-off, or something a reviewer already pushed back on once. Test: *if I only wrote the one-liner, would anyone need to ask "wait, why not X"?* No → keep it one line. Yes → add the short paragraph, still under the same dated heading.

**No numbering, no renumbering.** Dated headings are inherently ordered. Newest at the top.

**Supersede in place.** If this session reversed or replaced an earlier logged decision, don't leave the two contradicting each other — delete the old bullet if fully obsolete, or write the new one as "supersedes YYYY-MM-DD <topic>" and cut the old one down to whatever residual why still holds. Rotation by age won't catch this: a wrong entry can sit in the visible top-5 for months. Two live entries giving opposite guidance is worse than either alone.

**Rotation is automatic, not optional.** If the section exceeds ~20 entries after this session's block is prepended, archive the oldest down to ~12 into `STATE_archive/decisions-YYYY-QN.md` as part of this same edit — don't ask first; the archive file is part of the diff the user reviews at steps 8-9 like everything else. See also **Compaction mode** below for retroactively reformatting entries written before this rule existed.

**(e) Milestones shipped.** If this session closed a significant milestone (phase, sprint, feature, vertical-slice), append a bullet:

```
- ✅ **<milestone name>** (YYYY-MM-DD, commit `abc1234`) — <1-2 sentence summary + key files/decisions>
```

Skip if the session was incremental polish without a clean milestone boundary.

**Rotation:** past ~15 entries, collapse the oldest into a single grouped line — e.g. "Earlier milestones (2026-01–03): core pipeline, auth, billing — see git tags / `git log --oneline`." No separate archive file needed here; git history already preserves the detail losslessly, unlike decisions (which capture *why*, not just *what*).

**(f) Roadmap.** Strip any milestone you completed. Append new sub-tasks that surfaced. Age-check the rest: an item untouched for many sessions gets re-confirmed as still wanted or deleted — a stale roadmap misleads the next agent about what's actually next.

**(g) Open questions.** Same discipline as watch-list: when a question resolves, delete it — the answer lives in whatever decision resolved it, not in a leftover "RESOLVED" note. Add new questions only if they'll block or shape a near-term task.

**(h) Session log — OPTIONAL, skip by default.** Only add a Session block if the session involved substantial prose that doesn't fit decision-block format (long debates with rejected alternatives in detail, significant user-preference shifts). Most sessions don't need this.

Same automatic rotation as the decisions log: past ~10 entries, archive the oldest down to ~5 into `STATE_archive/sessions-YYYY-QN.md` as part of this edit — don't ask first.

### 7. Edit AGENTS.md (rare — only for new always-on rules)

Skip unless this session surfaced a NEW always-on rule (a pattern that any future session in any project state must honor). Add it to AGENTS.md "Always-on rules," "Core conventions / locked decisions," or "What NOT to do" as appropriate.

The bar is high. Pre-existing engineering wisdom doesn't belong here.

When you do touch AGENTS.md, also scan its existing rules for any now enforced by a test, lint rule, or type — propose cutting those in the same edit. AGENTS.md is read in full every session and has no rotation; deletion is its only size control.

### 8. Self-check the size budget, then show the diff

```bash
wc -l STATE.md && git diff --stat AGENTS.md STATE.md
```

If STATE.md exceeds ~350 lines after your edit, cut from what *you* added this session first — re-apply the one-liner rule and scope filter to your own additions. If it's still over because pre-existing entries are fat, don't silently rewrite them — report it and suggest a compaction pass. Either way, tell the user the line count against the budget alongside the per-file diff stat, and offer to dump the full diff for inspection.

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

## Compaction mode (on request only)

Not part of the default flow above — this runs only when the user explicitly asks to compact, slim down, or clean up STATE.md (e.g. "compact STATE.md", `/relay-end compact`). It exists to retroactively apply the recoverability test and one-liner format (see Scope filter, and step 6d) to entries written before those rules existed, or that have simply drifted verbose over time.

1. Read the full current STATE.md.
2. Apply the recoverability test + one-liner/paragraph rule to every entry across all sections (decisions log, watch-list, milestones, open questions, session log).
3. Classify each entry: keep as-is (already minimal), compact to a one-liner (a paragraph that fails the "would anyone ask a follow-up" test), or cut entirely (fails the recoverability test outright — pure restatement of a commit, recoverable via `git log`).
4. Move cut entries to `STATE_archive/pre-compact-YYYY-MM-DD.md` rather than deleting them outright — this pass rewrites content from past sessions the current agent didn't author, so it should stay reversible.
5. Show a before/after diff: `git diff --stat STATE.md`, plus a one-line entry-count summary (e.g. "decisions 34 → 12, milestones 22 → 9 (8 collapsed into a grouped line)").
6. Pause for user review before writing — same discipline as normal relay-end. Do not auto-commit.
7. On confirmation, commit as `docs: compact STATE.md (<before> → <after> lines)`.

Compaction never touches AGENTS.md and never rewrites git history — it only rewrites STATE.md's own content.

## Things you must do

- **Verify with fresh evidence before drafting.** Run `git log -1` and the test command. Don't carry over prior claims.
- **Use dated headings, never numbers.** `### YYYY-MM-DD — summary` is inherently ordered. Numbering is dead.
- **Walk the scope filter checklist AND the recoverability test before drafting.** Off-project content pollutes every future session; so does anything already recoverable from `git log`/code, even if it's on-project.
- **Default decision-log entries to one line.** Expand only when a follow-up question ("why not X") would otherwise go unanswered.
- **Strip resolved watch-list and open-question items.** Don't leave them as HTML-commented clutter or "RESOLVED" notes.
- **Rotate decisions log / session log automatically past threshold.** Archive, don't just suggest archiving — see STATE.md size budget above.
- **Self-check the size after editing.** `wc -l STATE.md`; over ~350 lines → trim your own additions first, then suggest compaction if historical entries are the cause.
- **One file edit (STATE.md) by default.** AGENTS.md only when a new always-on rule lands.
- **Pause before commit.** User inspects diff; safety net for tone drift.

## Things you must NOT do

- **Don't start coding.** Docs-only.
- **Don't paraphrase commit messages from `git log`.** Copy exact subject lines into decision-block detail — grep-ability across STATE.md ↔ git history matters.
- **Don't auto-pick the relay boundary.** If `git log` doesn't show a clear prior relay-end commit, ASK the user where the session started.
- **Don't draft "tests N/N passing" on a red tree.** If step 4 shows failures, stop and surface.
- **Don't write a Session log block by default.** Decisions log is enough for 95% of sessions.
- **Don't write one dated block per commit.** Consolidate a session's decisions under one dated heading.
- **Don't keep resolved-comment HTML blocks** (`<!-- RESOLVED ... -->`) in watch-list or open questions. Delete resolved items outright.
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

## Composition with other skills (if any are installed)

The "Suggested skills" line you write in STATE.md "Current state" is a plain-English pointer, not a dependency on any specific plugin. Populate it with whatever's genuinely relevant AND actually installed in the environment — check, don't assume a fixed set. If nothing relevant is installed, write `none`; the reason you'd have given is enough for the next agent to apply the same discipline inline instead of invoking a dedicated skill.
