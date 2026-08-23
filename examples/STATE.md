# STATE.md — Living state

> **Edit cadence:** every relay-end. Single source of truth for current state, decisions log, watch-list, milestones, roadmap. Stable rules live in `AGENTS.md`. **Size budget:** ~250-350 lines steady-state — every fresh session reads this file in full.

---

## Starter prompt (paste to fresh sessions)

```
Continue work on acme-notes at /home/user/code/acme-notes.

Read in this order:
  1. AGENTS.md  — stable rules, conventions, locked decisions, always-on rules
  2. STATE.md   — current state, decisions log, watch-list, milestones, roadmap (top-to-bottom)
  3. docs/DESIGN.md
  4. docs/IMPLEMENTATION_PLAN.md (only the relevant phase)

Verify with:
  git log -1 --format='%H %s'
  git status --short
  cargo test 2>&1 | tail -5   # only if SHA mismatch or test-file changes detected

Summarize in 5-8 lines: SHA, what's done, what's next, drift if any.
Wait for direction before coding.

Default mode: auto OFF — discuss / propose before acting.
```

---

## Current state

- **Commit:** `a3f9c12` (Phase 4 close — tag filtering + bulk operations)
- **Tests:** 187/187 passing
- **Last landed:** Phase 4 — tag CRUD + bulk tag operations (`add-tag` / `remove-tag` / `rename-tag` subcommands). Tag completion in shell installer.
- **Next:** Phase 5 — search ranking improvements.
- **Suggested skills:** `brainstorming (recency-boost vs pure-relevance UX unresolved)`
- **Pending verification:** none.
- **Working tree:** clean.

---

## Watch-list

> Active items only. Symbols: 🚧 in-progress / deferred, ⚠️ known risk with mitigation, 🟡 low-priority observation.

- 🚧 **Sync server deferred to v1.5.** Don't add `tokio` / `reqwest` to v1 paths. v1.5 plan: HTTP/3 + CRDT sync; spec drafted but not started.
- ⚠️ **FTS5 tokenizer doesn't handle CJK well.** `unicode61` does character-by-character on Chinese/Japanese — search for `日本` returns notes containing `日` OR `本`. Mitigation: documented limitation in README. v1.5: evaluate `ICU` tokenizer (adds 2MB).
- ⚠️ **SQLite WAL mode requires careful close ordering.** If the binary panics mid-write, WAL file can leak. Mitigated by `Drop` impl on the connection wrapper, but `process::exit` from `main.rs` would bypass it.
- ⚠️ **Tag table allows duplicates if rename collides.** `rename-tag work → ops` doesn't check if `ops` already exists; silently merges. Documented as feature, but should add `--no-merge` flag for safety.
- 🟡 **Migration system uses ad-hoc SQL files; no rollback support.** v1 acceptable (forward-only), but a future schema change requiring rollback would force a workaround.

---

## Decisions log (newest first)

### 2026-03-12 — Phase 4: tag CRUD + bulk operations

- Bulk tag ops take a `--query` flag ("apply to all notes matching X"), over positional note-ID lists, because query reuse matches the search-first workflow (`a3f9c12`)
- `rename-tag` silently merges on target collision — reviewer flagged it; accepted as v1 behavior, `--no-merge` flag deferred (watch-list)

### 2026-03-08 — Phase 3: full-text search via FTS5

- Trigger-based FTS content sync, over app-level index writes, because triggers can't drift from the source tables (`9e4a118`..`b7c2d33`)
- Tantivy re-evaluated at reviewer's suggestion; rejected again — 3MB binary bloat + build-time index step not worth the 2x speedup at 10k notes
- CJK tokenization gap surfaced (unicode61 splits per-character) → documented limitation, ⚠️ watch-list

### 2026-03-04 — Phase 2: SQLite schema + migrations

- Forward-only migrations locked, over rollback support, because v1 schema churn is low and rollback machinery isn't worth it — a rollback-requiring change forces a workaround (🟡 watch-list) (`4a8b201`..`d12c9e0`)

### 2026-03-01 — Phase 1: clap CLI scaffolding + binary skeleton

- Stable exit-code mapping locked: 1 = user error, 2 = data error, 3 = internal (`7c19f44`)

### 2026-02-27 — Phase 0: design consultation + locked decisions

- Key locks (full rationale in `docs/DESIGN.md`): local-first single-binary v1, SQLite+FTS5 over Tantivy, flat tag namespace, no async; sync server deferred to v1.5

---

## Milestones shipped

- ✅ **Phase 0** (2026-02-27) — Design consultation; DESIGN.md + IMPLEMENTATION_PLAN.md.
- ✅ **Phase 1** (2026-03-01, commit `7c19f44`) — CLI skeleton + clap structure.
- ✅ **Phase 2** (2026-03-04, commits `4a8b201`..`d12c9e0`) — SQLite schema + migration runner.
- ✅ **Phase 3** (2026-03-08, commits `9e4a118`..`b7c2d33`) — FTS5 search + closing-reviewer fix-pass.
- ✅ **Phase 4** (2026-03-12, commit `a3f9c12`) — Tag CRUD + bulk operations + shell completion.

---

## Roadmap (what's not yet done)

- **Phase 5** — Search ranking improvements (recency-boost vs pure-relevance). Needs brainstorming.
- **Phase 6** — Export formats (markdown bundle, JSON, sqlite dump).
- **Phase 7** — Import from Apple Notes / Bear / Obsidian vault.
- **v1 release prep** — `cargo dist` config, signed binaries for macOS/Linux/Windows, install.sh script.
- **v1.5 (deferred)** — Sync server. Spec lives in `docs/DESIGN.md` §8.

---

## Open questions

- 🟡 **Recency-boost weight calibration?** Phase 5 hinges on this. Initial proposal: 0.3 × log(days_since_modified) penalty on relevance. User wants to A/B against pure-relevance for 2 weeks before locking.

---

## Useful commands

```bash
# Run tests
cargo test

# Specific test
cargo test --test integration -- search::cjk_tokenization

# Build release binary
cargo build --release

# Lint + format
cargo clippy -- -D warnings && cargo fmt

# Reset local DB (testing only)
rm -rf ~/.local/share/acme-notes/*.db*

# Inspect FTS index
sqlite3 ~/.local/share/acme-notes/notes.db "SELECT * FROM fts_index LIMIT 10"
```
