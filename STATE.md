# STATE.md — the briefing (read me first, every chat)

*Start every new chat with: "Read STATE.md and CONTRACT.md. Today's single concern: ___. Files involved: ___. Proceed."*

---

## Where we are

- **Phases 1–4: DONE.** The site is live on the eight-table schema with
  **107 companies** (flip completed in the early hours of 8 Jul 2026 IST).
- **Robots v2: DONE (Session C, 8 Jul 2026).** Both GitHub Actions robots now
  speak the eight-table schema — details below.
- **New UI: DONE (Session D, 9 Jul 2026).** Bull/bear debate re-housed into
  §9 (per CONTRACT) with the centre "vs" spine; §2 strategic-position card;
  honest §10 placeholder; §5 queued copy now count-driven. Shipped
  byte-verified against `main`; chip text unchanged.
- **Mgmt gaps, Batch 1: DONE (Session E, 9 Jul 2026).** The 8
  government-promoter tickers (BANKBARODA, CANBK, PNB, COALINDIA, NTPC,
  ONGC, POWERGRID, BEL): machine-researched with named sources,
  founder-verified against screener + exchange SHP filings, inserted via
  SQL Editor. Chip confirmed: **72 verified promoter records** (was 64).
  35 of the original 43 gaps remain.
- **Flag 5 closed: DONE (Session F, 9 Jul 2026).** §5's "Verified <date>" is
  now data-driven: `mgmt_profiles.verified_on` (date, nullable) added and
  backfilled (64 × 02 Jul 2026, 8 × 09 Jul 2026, 0 NULLs), the waiter carries
  it (+1 mapping line in `data.js`), and `company.js` prints each row's own
  date — "—" when NULL, never a borrowed date. Migration saved as
  `sql/2026-07-09_flag5_verified_on.sql`; CONTRACT's MGMT shape, translation
  rules and parachute updated. Chip text unchanged. Batch 2 is unblocked.
- The Phase-2 five-table world is retired: the flip emptied its dependent
  tables (rows preserved in `investorlens-backups`, including a fresh manual
  run taken minutes before the flip). `sql/schema.sql` + `sql/seed.sql` in the
  repo are now historical.
- **CONTRACT.md v1** describes the new shapes. It is the menu again.

## Session B — how flip day actually went (verified, not narrated)

- The branch hold didn't take: `data.js` (+ STATE v3.2) landed **straight on
  `main`** (~19:26–19:56 UTC, 7 Jul) → GitHub Pages published immediately →
  early blackout while live Supabase still held the old tables.
- Decision: verify forward, fast. Same-day re-proofs before any live click:
  both SQL files re-run clean on a fresh PostgreSQL 16 UTF-8 (idempotency +
  all-or-nothing + full audit green); then the round-trip harness against the
  **actual bytes on `main`** — order clauses asserted correct, and precisely
  the 19 predicted peer-group failures appeared, nothing else.
- Founder ran: fresh backup → `1_SCHEMA_complete.sql` → `2_DATA_complete.sql`
  on live. Site returned on the new schema.
- `compare.js` took two attempts: the first commit **silently never landed**
  — caught by direct repo verification (commit feed + byte-diff), not by eye.
  The fix file was built from `main`'s exact bytes +9 lines (the 8 groups,
  house style), harness-proven, committed (`8139799`), then verified
  byte-identical end to end. Full-tree diff: nothing else changed.
- Harness on the exact live bytes: **all checks passed — 107 companies,
  492 metric bindings, 14 forces, 139 exposure links, 4 value-chain maps
  (17 links), 64 verified management records.** Home chip text:
  `● data checks: 107 companies · 492 metric bindings · 14 forces · 64
  verified promoter records`.

## Session C — robots v2 (done, harness-proven)

- **`etl/refresh.py` v2 (nightly, 20:30 UTC = 02:00 IST).** Each night it
  writes **one dated `metric_snapshots` row per ticker**
  (`metric_key='market_cap_cr'`, `status='verified'` direct — market cap is
  price × shares inside sane fences, so no human review needed), then stamps
  `companies.fetched_at` for the tickers that succeeded. It no longer touches
  the vestigial `companies.market_cap_cr` / `updated_at` leftovers and speaks
  **only Phase-4 columns**, so it also works on a database rebuilt from
  `1_SCHEMA_complete.sql`.
- **Idempotent-per-day:** the schema has no "one row per company per day"
  rule, so the robot brings its own — before inserting it deletes **today's**
  market-cap rows for **exactly the tickers it is re-inserting** (never
  yesterday, never another metric, never a ticker it has no fresh number
  for). Run it five times in a day: one row per ticker remains. On a **total
  source outage it writes NOTHING** and exits non-zero (GitHub emails);
  same-day earlier rows survive. The keep-alive ping is unchanged.
- Dates are the runner's UTC date (at 02:00 IST that is the previous IST
  calendar day) — consistent night to night; newest-date-wins unaffected.
- **`etl/backup.py` v2 (weekly, Sun 21:30 UTC).** Dumps **all eight tables**
  + manifest (`"schema": "phase4-eight-tables"`), pages past 1,000 rows,
  sorts companies/mgmt_profiles by `ticker` and the rest by `id`, and refuses
  to write a backup with 0 companies **or 0 metric snapshots** (an empty
  `staged_metric_snapshots` is healthy and saved as `[]`).
- **Both workflow files unchanged** — verified zero functional need
  (`git add -A` picks up the new filenames). A stale "five tables" comment
  remains in `backup.yml`; deliberately left, cosmetic only.
- **Verification:** 28/28 harness checks against a fake PostgREST (fresh
  night; same-day re-run replaces without duplicates; total-outage writes
  nothing; 3-page backup pagination; empty-backup refusal; `M&M` /
  `BAJAJ-AUTO` travel quoted through every `in.()` filter) + 5/5 round-trip
  through the **exact live `data.js` bytes** (tonight's rows win by newest
  date; market cap stays out of `metric_order` and `HIGHER_IS_BETTER`).

## Live counts

107 companies · 599 metric snapshots **at flip** (107 market-cap rows + 492
business metrics; 21 honest NULLs) · 518 chain nodes · 321 factor tags ·
642 bull/bear · **72 mgmt profiles** (64 at flip + 8 in Session E) ·
4 narratives · staging 0. Current chip: `● data checks: 107 companies ·
492 metric bindings · 14 forces · 72 verified promoter records`.
`metric_snapshots` now grows by ~107 rows per successful night (599 + one row
per fetched company per night; ≈706 after the first v2 run).

## ⚠️ Flags carried (accepted, not blockers)

1. **Map page lists stories alphabetically** (banca → holding → metals-auto →
   power). Cosmetic; permanent fix = tiny `display_order` column, Session E.
   Do NOT edit the verified SQL files for this.
2. **LTIM sits alone in "IT Services"** while TCS/INFY/WIPRO/HCLTECH/TECHM are
   in "IT" — LTIM shows no compare chip. Founder to decide; the fix is a
   one-word row edit in Supabase Table Editor, no code ship.
3. **Four stale husk files** (`metrics.json`, `factors.json`, `chains.json`,
   `mgmt.json`) sit in `investorlens-backups` at pre-flip content. Optional
   tidy-up: delete them via the web UI after the first v2 backup — their
   history stays in git forever.
4. **Snapshot growth:** ~3.2k rows/month. `data.js` paginates (verified), so
   the site keeps working, but every +1,000 rows adds one request to page
   load. Before it matters (several months), plan a prune/view session:
   keep the last N days + first-of-month rows.

## Session G+

1. **The 35 remaining mgmt gaps**, in the Session-E batch order — every
   batch INSERT now carries its real `verified_on` date, and every batch
   paste ends with the judge `WHERE verified_on IS NULL` (expect 0):
   - Batch 2 — private banks (5): AUBANK, AXISBANK, BANDHANBNK,
     FEDERALBNK, IDFCFIRSTB
   - Batch 3 — NBFC/insurance (5): CHOLAFIN, SHRIRAMFIN, JIOFIN,
     HDFCLIFE, SBILIFE
   - Batch 4 — IT + auto (7): HCLTECH, TECHM, WIPRO, BAJAJ-AUTO,
     EICHERMOT, M&M, TMPV
   - Batch 5 — pharma/health (5): CIPLA, DRREDDY, SUNPHARMA, APOLLOHOSP,
     MAXHEALTH
   - Batch 6 — metals/cement/infra (6): HINDALCO, JSWSTEEL, TATASTEEL,
     ULTRACEMCO, GRASIM, ADANIPORTS
   - Batch 7 — consumer/new-age (7): ASIANPAINT, NESTLEIND, TATACONSUM,
     TITAN, TRENT, INDIGO, ETERNAL
- Optional carried: `display_order` on `cross_company_narratives` (flag 1);
  LTIM group decision (flag 2); husk-file tidy-up (flag 3); replace the
  retired `/sql` files with the Phase-4 pair; snapshot prune/view strategy
  (flag 4).

## Lessons Session B added

- The iPad GitHub web editor can **silently drop a commit** (and the "create a
  new branch" option can fail to take). Rule: after every commit, confirm it
  landed — the file page must show the new content, or the commits list the
  new entry — before doing anything that depends on it.
- **"The site renders" ≠ "the tests pass."** Acid tests read the chip
  word-for-word.
- Direct repo verification (commit feed, sha-pinned file fetches, full-tree
  diffs) caught both misses on flip day; eyeballs caught neither.

## Lessons Session C added

- When the schema has no uniqueness rule for a job, **the robot brings its
  own discipline** (delete today's rows only for the tickers being
  re-inserted) — proven by the same-day re-run test, not assumed.
- On a total source outage the robot must **write nothing at all** — a
  half-write would destroy same-day rows it cannot replace.
- Robot code should speak **only the current schema's columns**, never
  leftovers that happen to exist on the live table — otherwise a parachute
  rebuild breaks the robot.

## Lessons Session D added

- When a design fork appears, **the founder's own CONTRACT is the arbiter**:
  its "§9 bull case / §7 red flags" annotations settled where the debate
  lives. No doctrine (titles, nav, section count) was edited — only bodies.
- The commit-landed check that works on iPad: open **Raw** view → Safari
  **Find on Page** → search a string only the NEW bytes contain (expect 1)
  and one only the OLD bytes contained (expect 0). Content is the
  fingerprint, not "the page looks right."

## Lessons Session E added

- The mission-lock division works as a *pipeline*: machine researches and
  drafts WITH named sources; human verifies every number and sentence
  against screener + the exchange SHP filing before anything is pasted.
  Aggregator discrepancies (one-decimal promoter figures; Coal India's
  ₹26.5-vs-₹26.75 FY26 total) are exactly what the human pass exists to
  catch.
- A draft SQL file should carry its own judges: pre-flight SELECT (expect
  zero rows), post-flight COUNT (expect the exact number), and the chip
  acid test — the paste becomes self-verifying on iPad, no extra tooling.
- Inserting rows made flag 5 louder, not quieter: a cosmetic
  lie-in-waiting became a live falsehood the moment real verified-dates
  diverged from the hardcoded one. Sequencing debt compounds.

## Lessons Session F added

- `select=*` delivers a new column to the browser, but the waiter's mapping
  is an explicit list — so every new column is, by design, a one-line
  `data.js` edit. Nothing reaches the UI unnamed.
- `verified_on` stays NULLABLE on purpose: NOT NULL would make the verified,
  re-runnable `1_SCHEMA`/`2_DATA` pair fail on a re-run (its mgmt INSERTs
  don't know the column). Honesty is enforced where it is seen — a missing
  date renders "—" — plus each batch's own post-flight judges.
- Harness-proven surgical: for the 64 at-flip records the new §5 output is
  byte-identical to the old hardcode; only the 8 Batch-1 pages change on
  screen. "Fixed" and "nothing else moved" were both proven, not eyeballed.

## Mission lock (unchanged)

Business UNDERSTANDING first — value chains, business cores, moats, live
factors, management quality. Valuation secondary; stock-picking out of scope.
Machines refresh NUMBERS; only humans write/verify SENTENCES.

## Changelog

- **v3.7 / Phase 4 Session F:** Flag 5 closed. `mgmt_profiles.verified_on`
  (date, nullable) added + backfilled via self-judging SQL (Judge 1: 64 →
  02 Jul, 8 → 09 Jul; Judge 2: 0 NULLs); `data.js` mgmt mapping +1 line;
  `company.js` gained `fmtVerifiedOn()` and prints the row's date ("—" when
  NULL). vm-harness on exact bytes: six globals identical old-vs-new;
  02-Jul pages byte-identical; COALINDIA differs only at the date; queued
  box untouched; formatter immune to Date() timezone shift. CONTRACT MGMT
  shape + parachute updated; migration committed as
  `sql/2026-07-09_flag5_verified_on.sql`. Chip text unchanged.
- **v3.6 / Phase 4 Session E:** Mgmt gaps Batch 1 shipped. 8
  government-promoter records (BANKBARODA, CANBK, PNB, COALINDIA, NTPC,
  ONGC, POWERGRID, BEL) machine-researched — including three FY26 SEBI
  SAST nil-encumbrance disclosures found at source — founder-verified
  against exchange SHP filings, then inserted via SQL Editor. Chip acid
  test passed: 72 verified promoter records. 35 gaps remain, pre-grouped
  into batches 2–7. Flag 5 escalated: the hardcoded "Verified 02 Jul 2026"
  is now false for the 8 new rows — Session F top priority before Batch 2.

- **v3.5 / Phase 4 Session D:** New UI shipped. Bull/bear debate re-housed
  from §10 into §9 Price & Valuation (per CONTRACT: bull=§9, bear=§7/§9) with
  intro line, count badges and a centre "vs" spine; §2 gained the
  strategic-position card; §10 is now an honest news placeholder; §5 queued
  copy is count-driven (auto-reads "64 of 107", never stale). Framework
  untouched — 10 sections, titles/nav byte-identical. 22/22 vm-harness checks
  on the exact new bytes incl. §7 regression; chip text unchanged; both
  commits content-verified via raw-view find. NEW FLAG: §5 verified-date is
  hardcoded "02 Jul 2026" in company.js — needs a data-driven date (Session E).

- **v3.4 / Phase 4 Session C (this pass):** Robots v2 shipped. `refresh.py`
  writes one dated, idempotent-per-day market-cap row per ticker into
  `metric_snapshots` (`status='verified'`) + stamps `companies.fetched_at`;
  `backup.py` dumps all eight tables with pagination + manifest; both
  workflows verified unchanged. 28/28 fake-PostgREST harness checks + 5/5
  round-trip through live `data.js` bytes. New flags: backup-repo husk files
  (optional delete), snapshot growth / future prune session.
- **v3.3 / Phase 4 Session B (this pass):** DB flipped live (fresh backup →
  1_SCHEMA → 2_DATA); `compare.js` +8 peer groups on `main` (commit `8139799`,
  byte-verified); harness green on the exact live bytes
  (107/492/14/139/4/64). Incidents documented above: early blackout (commits
  landed on `main`, no branch) and a silently-dropped commit — both caught by
  direct repo verification and resolved forward. Robots v2 promoted to
  Session C with the backup gap flagged.
- **v3.2 / Phase 4 Session A:** New 8-table `data.js` written; `compare.js`
  +8 peer groups (9 lines). Round-trip harness: NEW selftest PASS
  (107/492/14/139/4/64); OLD baseline PASS (58/295/14/85/4/15); 58-overlap
  zero structural + zero value diffs; order-by-id proven == curated
  metric_order for all 58. Flags: CHAINMAP alphabetical order (cosmetic),
  LTIM solo in "IT Services".
- **v3.1 / Phase 4 dry run:** Both founder SQL files executed cleanly on local
  PostgreSQL 16 UTF-8; full audit green. Discovered the companies-name
  collision → locked the frontend-first, fast-flip order.
- **v3.0 / Phase 4 kickoff:** 107-company SQL revealed; pre-load backup rule.
- **v3.0 / Phase 3a+3b:** nightly mcap robot; weekly backup (6 files landed).
- **v3.0 / Phase 2:** five tables seeded; acid test passed.
- **v3.0 / Phase 1:** monolith split; self-tests identical.
