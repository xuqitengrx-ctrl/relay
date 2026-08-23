---
name: relay-end
description: End-of-session handoff for the 2-file relay convention (AGENTS.md + STATE.md). Updates STATE.md — Current state, Decisions log (dated, no numbering), Watch-list, Milestones, Roadmap. Verifies state with fresh git + test evidence before drafting. Pauses for user review before committing.
allowed-tools: Read, Edit, Write, Bash, Grep, Glob
---

# relay-end — end-of-session handoff

Leave `STATE.md` so a fresh agent — new session, no history — can resume. `AGENTS.md` changes only
when a new always-on rule lands.

**Docs only. Do not code.** If the user wants a fix plus a relay, do the fix, commit, then relay.

If the invocation carried arguments, treat them as what the *next* session will do, and bias `Next`
and the surfaced watch-list items toward it.

## Two rules that govern everything below

**Write from the diff, not from memory.** At the end of a long session your context holds every
intermediate product — abandoned approaches, superseded plans, three drafts of one decision. They
feel important because you just lived them. Source each entry from `git log` / `git show` and the
code as it stands. If the session's work isn't in a commit, that is what you record about it, not
the deliberation that produced it.

**Net-zero by default.** Do not leave `STATE.md` longer than you found it. Adding a line means
finding one to delete. A file that only grows makes every future `relay-start` pay for the whole
project's history. If the session genuinely earned net growth, say so and why.

## What belongs

For each commit, decision or thread, ask in order:

1. **Is it recoverable?** If `git log`, `git show`, or reading the code answers it, leave it out.
   This kills most candidates. STATE holds the *why* and the constraint, never a changelog.
2. **Did it touch project source, lock a decision, or surface a risk?** If no — tooling talk, skill
   setup, off-topic asides — it's out regardless of how much of the session it consumed.
3. **Would a fresh agent re-derive it or repeat the mistake without it?** If no, out.

A session that was mostly off-project earns a Current-state bump and nothing else. Don't pad.

## Steps

**1. Confirm** `AGENTS.md` and `STATE.md` exist at the project root. If not, stop and say to run
`/relay-scaffold`.

**2. Check the tree.** `git status --short`. Clean → proceed. Uncommitted work from this session →
ask whether to bundle it into the relay commit. Uncommitted work from elsewhere → stop, say so.

If other sessions or worktrees are live on this repo, flag that their relay-ends will conflict at
the top of the decisions log — mechanical to merge, but merge deliberately.

**3. Find the range.** `git log --oneline -30`, back to the last `docs:.*relay-end`. No prior one →
ask where the session started; don't guess.

**4. Get fresh evidence.** `git log -1 --format='%H %s'` and the project's test command. **Never
draft a passing-test claim on a red tree** — surface the failures and ask.

**5. Read `STATE.md`** in full. Read `AGENTS.md` only if a new always-on rule landed.

**6. Edit `STATE.md`.** One home per item — a deferred task lives in the roadmap or the watch-list,
never both.

- **Current state** — overwrite in place: commit SHA, test count, what landed (1–2 sentences), next
  task (one line), suggested skills (0–3 actually installed, or `none`), pending verification
  (close out the previous block's items explicitly before adding new ones), working tree.
- **Watch-list** — add what surfaced, delete what resolved, update what moved. An item carried
  unchanged for many sessions is re-confirmed or deleted. **Don't delete an item you don't
  understand** — find out why it's there first. Symbols: 🚧 deferred, ⚠️ risk, 🟡 minor.
- **Decisions** — one dated block per session, newest first, prepended:

  ```
  ### YYYY-MM-DD — <a few words>

  - <decision> (`abc123`)
  ```

  **One line each.** Expand only when the entry would otherwise be unusable — a real trade-off, a
  constraint that isn't in the code. **Record a rejected alternative only if a future agent would
  plausibly propose it again, and then as one line without the supporting data.** Everything else
  about what you didn't do is noise: it never shipped, so it has no claim on the record.

  **Supersede in place.** A reversed decision gets deleted, or the new entry says it supersedes the
  old and the old is cut to whatever still holds. Never leave two live entries giving opposite
  advice, and never rewrite an old entry so past reasoning reads like present knowledge.

  Past ~20 entries, archive the oldest down to ~12 into `STATE_archive/decisions-YYYY-QN.md` as
  part of this edit.

- **Milestones** — one bullet if the session closed one, else skip. Past ~15, collapse the oldest
  into a single grouped line; git history keeps the detail.
- **Roadmap** — strip what shipped, append what surfaced, re-confirm or delete the stale. An entry
  with no trigger and no owner is litter.
- **Open questions** — add only what will shape a near-term task; delete what resolved.
- **Session log** — skip. Only for prose that genuinely won't fit a decision bullet.

**7. `AGENTS.md`** — only for a rule that binds every future session in any state. The bar is high.
When you do open it, propose cutting any rule now enforced by a test, lint or type.

**8. Self-check.** `wc -l STATE.md && git diff --stat AGENTS.md STATE.md`. Report the line count
against where it started. Over ~350 → cut your own additions first.

**9. Pause.** Show the diff stat and ask whether to commit or inspect.

**10. Commit** on confirmation:

```
docs: relay-end <topic> → <next milestone>

<what landed>

Working tree clean for next session.
```

## Compaction mode — on request only

When the user asks to compact `STATE.md`: apply the recoverability test and the one-line rule to
every existing entry, including ones you didn't write. Classify each as keep / compact / cut. Move
cuts to `STATE_archive/pre-compact-YYYY-MM-DD.md` so the pass stays reversible. Report entry counts
before and after, pause for review, then commit as `docs: compact STATE.md (<before> → <after>)`.

## Do not

- Paraphrase commit subjects — copy them exactly, so STATE and `git log` stay greppable.
- Number decisions. Dated headings are already ordered.
- Write one dated block per commit. One per session.
- Auto-pick the relay boundary, auto-bump versions, or add always-on rules unprompted.
