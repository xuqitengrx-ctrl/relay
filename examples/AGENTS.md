# AGENTS.md — Stable rules for agents working on this project

> **Edit cadence:** rare. This file holds non-negotiables, locked decisions, and conventions that don't change session-to-session. Living state (current SHA, decisions log, watch-list, what's next) lives in `STATE.md` and is updated every relay-end.
>
> **Read order for fresh sessions:** this file (rules), then `STATE.md` (state), then `DESIGN.md` (spec), then `IMPLEMENTATION_PLAN.md` (build plan, relevant phase only).

---

## What this project is

`acme-notes` is a local-first markdown note-taking CLI with full-text search and tag-based organization. Built on top of SQLite with FTS5; designed to handle ~10k notes with sub-100ms search. v1 ships as a single binary; v1.5 adds a sync server for cross-device access.

---

## Tools, framework, idioms

Rust 1.75+, SQLite 3.45+ (bundled), `clap` for CLI parsing, `rusqlite` for DB access, `tantivy` was considered for search but FTS5 chosen for zero-dep simplicity. No async runtime — operations are short and synchronous. Tests use `cargo test` + a custom `tests/fixtures/` helper module.

---

## Core conventions / locked decisions

> Non-negotiables. Future maintenance depends on these. When a decision is locked (user says "don't revisit"), record it here so future sessions don't relitigate.

- **Local-first; v1 is single-binary.** No external services for v1. Sync deferred to v1.5 explicitly because solo-dev validation comes first. Don't add `tokio` / `reqwest` / network code in v1 paths.
- **SQLite with FTS5, not Tantivy.** Evaluated at design-consultation (Session 3) — Tantivy is faster but adds 3MB and a build-time index step. FTS5 is "good enough" up to ~10k notes; re-evaluate at v2 if user has >50k notes.
- **All DB writes go through `db::tx::with_transaction`.** Never call `conn.execute` directly outside that helper — it ensures rollback on panic + uniform error mapping. Adding a new direct callsite is the kind of thing that breaks the integrity invariant.
- **Tag namespace is flat, not hierarchical.** v1 decision per UX feedback: nested tags are powerful but overwhelming for note-taking. If a user wants `work/projects/alpha`, they tag with `work` + `projects` + `alpha` separately.

---

## What NOT to do

- **Don't add async to v1 paths.** We evaluated and rejected at Session 5; sync code is simpler to debug and `cargo test` runs faster.
- **Don't reach for ORMs.** We tried Diesel at Session 2; the macro overhead + schema migration friction outweighed the type-safety win for a 4-table schema.

---

## Always-on rules

1. **3-strike protocol.** After 3 failed attempts at the same root cause, stop. Document each attempt. Re-read STATE.md watch-list — there may be a prior note. Then surface to the user.

2. **2-action findings save.** After 2 substantial discoveries, pause and ask: *does what I just learned belong in STATE.md watch-list, or as a comment in the affected source file?* Discoveries lost to context are unrecoverable.

3. **Plan-first for ≥3-step work.** Before any task crossing ≥3 files or ≥3 logical steps, re-read STATE.md decisions log + watch-list + the relevant phase in `IMPLEMENTATION_PLAN.md`. Plan before coding.

4. **Per-milestone reviewer discipline.** After every major milestone, dispatch an independent reviewer agent (fresh context, no implementation bias) before starting the next. Pass: commit range, relevant spec sections. Ask: spec compliance, cross-milestone consistency, invariants, test coverage, severity matrix. Don't skip — this catches what unit tests miss.

---

## Project-specific debugging entries

1. **Don't know how the FTS index gets rebuilt?** Look at `src/db/migrations/0003_fts_rebuild.sql` — the trigger is in there, not in Rust code.
2. **Search returns unexpected results?** Check FTS5 tokenization rules (`src/db/fts.rs`); we use `porter unicode61 remove_diacritics 2` which strips accents but keeps stems. Don't change without re-indexing.

---

## Repository layout

```
acme-notes/
├── src/
│   ├── cli/         # clap argument parsing per subcommand
│   ├── db/          # rusqlite wrappers + migrations
│   ├── notes/       # note CRUD + tag management
│   ├── search/      # FTS5 queries + result ranking
│   └── main.rs
├── tests/
│   ├── fixtures/    # shared test data + helpers
│   └── integration/ # end-to-end tests via subprocess invocation
├── docs/
│   ├── DESIGN.md
│   └── IMPLEMENTATION_PLAN.md
├── AGENTS.md
└── STATE.md
```

---

## Personal context (the user)

Solo developer; comfortable in Rust, learning SQL deeply for this project. Prefers terse recommendations over option trees. Cost-conscious — no SaaS dependencies for v1.

---

## When you ship a meaningful change

1. Update `STATE.md` decisions log + watch-list if relevant.
2. Update `DESIGN.md` if the spec changes; call out what changed in the commit.
3. Update `IMPLEMENTATION_PLAN.md` if the build sequence shifts.
4. Run `cargo test` before committing.
5. Bump version in `Cargo.toml` (if versioned release).
