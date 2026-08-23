---
name: relay-start
description: Fresh-session orientation for the 2-file relay convention (AGENTS.md + STATE.md). Reads both files top-to-bottom, verifies git SHA + working tree, surfaces drift, summarizes in 5-8 lines, and waits for direction. Does not auto-code.
allowed-tools: Read, Bash, Grep, Glob
---

# relay-start — fresh-session orientation

Arrive at a 5–8 line summary of where the project stands, with any drift surfaced, and propose a
next step. **Read, verify, summarize, wait. Do not code** — a "small fix" still needs confirmation.

If the invocation carried arguments, treat them as this session's focus: surface the watch-list
items, decisions and roadmap entries that bear on it even if they'd fall outside the default
window, and sharpen the proposed next step accordingly. Verification still runs in full.

## Steps

**1. Confirm** `AGENTS.md` and `STATE.md` exist. Missing → stop and say to run `/relay-scaffold`,
or to paste the starter prompt directly.

**2. Read `AGENTS.md`.** Skip the read if the harness already injected it. Note the locked
decisions, the what-NOT-to-do list, and the always-on rules. If it contains current-state content —
a commit SHA, a "last updated" line — that's drift; flag it.

**3. Read `STATE.md`** top-to-bottom. If it's past ~400 lines, read everything except the decisions
log in full, then `grep -n '^### ' STATE.md` and read only the top 3–5 dated blocks. Don't
compensate for a bloated file by reading all of it — flag it in step 5 instead. Older history lives
in `STATE_archive/*.md` if present.

**4. Verify against reality.**

```bash
git log -1 --format='%H %s'
git status --short
git log --oneline -10
```

- **SHA mismatch** with Current state → commits landed after the last relay-end. List them, ask
  whether they're trusted.
- **Dirty tree** when STATE claims clean → **stop and ask.** It may be another live session's work;
  don't touch it.
- **Tests:** trust the count in STATE. Run them only if the SHA check failed, the new commits touch
  test files, or the user asks.

**5. Summarize in 5–8 lines.** The user reads this to confirm you read correctly, so cite
specifics — a date, a symbol, a name. Vague references don't prove anything.

- SHA, test count, working-tree status
- the last milestone landed
- the one or two decisions or watch-list items that bear on what's next, **cited**
- any drift from step 4
- any non-`none` Pending verification items — **ask about them**; nothing else ever closes them
- the next task, and any suggested skills listed with it

Then check size objectively: `wc -l STATE.md`. Past ~350 lines, or a decisions log past ~20
entries, name the number and suggest a compaction pass. A nudge, never a blocker.

**6. Propose a next step.** Read the `Next` line and the `Suggested skills` line. Judge a suggested
skill by what it does, not its name: one that runs *before* code — scoping, planning, test-first —
gets proposed first, not skipped. One that runs alongside or after gets mentioned as available.

If the line is `none` or empty: a creative or ambiguous task still gets scoped before
implementation; a plainly mechanical one can be proposed directly. Unsure → ask.

**7. End with an availability cue** — one short line inviting direction.

## Do not

- Paraphrase `STATE.md` back at the user. They wrote it. The value is the verification and the
  cited specifics.
- Skip the SHA and working-tree check because the file claims a clean tree.
- Read every decision or session entry from scratch. Top few, then targeted lookups on demand.
- Propose skipping a suggested skill that runs before coding.

If nothing relevant is installed, the `Suggested skills` line still reads as a plain directive:
apply that discipline inline. The relay convention depends on no other skill.
