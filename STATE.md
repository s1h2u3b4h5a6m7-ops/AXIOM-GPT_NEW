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
- **Mgmt gaps, Batch 2: DONE (Session G, 11 Jul 2026).** The 5 private banks
  (AUBANK, AXISBANK, BANDHANBNK, FEDERALBNK, IDFCFIRSTB): machine-researched
  with named sources — including AU's own 31-Mar-2026 exchange SHP read at
  source and BFHL's SEBI Reg 29(2) sell-down filing — founder-verified, then
  inserted via SQL Editor. Two of the five have **no promoter at all**
  (FEDERALBNK, IDFCFIRSTB): a fact, recorded as 0%, not a gap left blank.
  Chip confirmed: **77 verified promoter records** (was 72). 30 gaps remain.
- **Mgmt gaps, Batch 3: DONE (Session H, 11 Jul 2026).** The 5 NBFC/insurance
  names (CHOLAFIN, SHRIRAMFIN, JIOFIN, HDFCLIFE, SBILIFE): machine-researched
  with named sources — including HDFC Bank's own Q4 FY26 deck and its FY26
  Reg 31(4) nil-encumbrance filing, HDFC Life's FY26 call transcript, and the
  post-event shareholding patterns of 08-Apr-2026 (SHRIRAMFIN) and 21-Apr-2026
  (JIOFIN) — founder-verified, then inserted via SQL Editor. In **none of the
  five did a promoter sell a share**; four saw a capital event inside 90 days.
  Chip confirmed: **82 verified promoter records** (was 77). 25 gaps remain.
- **Mgmt gaps, Batch 4: DONE (Session I, 11 Jul 2026).** The 7 IT + auto names
  (HCLTECH, TECHM, WIPRO, BAJAJ-AUTO, EICHERMOT, M&M, TMPV): machine-researched
  with named sources — Tech Mahindra's and Eicher's own 31-Mar-2026 exchange
  SHPs read at source, Wipro's and Eicher's FY26 Reg 31(4) nil-encumbrance
  filings, and Wipro's 30-Jun-2026 buyback-extinguishment filing — then
  founder-verified and inserted via SQL Editor. **First non-zero pledges on the
  platform:** M&M 0.02% (40,000 shares, one named individual) and BAJAJ-AUTO
  ~0.01%. Chip confirmed: **89 verified promoter records** (was 82). 18 gaps
  remain.
- **Mgmt gaps, Batch 5: DONE (Session J, 11 Jul 2026).** The 5 pharma + health
  names (CIPLA, DRREDDY, SUNPHARMA, APOLLOHOSP, MAXHEALTH): machine-researched
  with named sources — Dr Reddy's and Max Healthcare's FY26 Reg 31(4)
  nil-encumbrance declarations, Apollo's NCLT scheme filings, and the Mar-2026
  shareholding tables read entity by entity — then founder-verified and
  inserted via SQL Editor. **The pledge batch:** SUNPHARMA 1.42% and RISING
  (two named individuals; the founder's own shares unpledged), APOLLOHOSP 2.49%
  and FALLING (16.30% → 2.49% in three years). Chip confirmed: **94 verified
  promoter records** (was 89). 13 gaps remain.
- **Mgmt gaps, Batches 6 + 7: DONE (Sessions K + L, 11 Jul 2026) — BACKLOG
  COMPLETE.** Batch 6, metals/cement/infra (HINDALCO, JSWSTEEL, TATASTEEL,
  ULTRACEMCO, GRASIM, ADANIPORTS) and Batch 7, consumer/new-age (ASIANPAINT,
  NESTLEIND, TATACONSUM, TITAN, TRENT, INDIGO, ETERNAL). Headlines: JSWSTEEL
  carries the platform's largest pledge (11.81% of the block, six named
  entities, falling from 15.24%); ASIANPAINT has a live multi-entity pledge;
  ETERNAL is the first no-promoter row (promoter_pct = 0 recorded as an
  answer); INDIGO's headline % is derived pending SHP confirmation. Files are
  count-chained: 5 → 6 → 7 pre-flights expect 89 / 94 / 100. Chip after all
  three: **107 verified promoter records — every company covered.** 0 gaps
  remain.
- **Flag 5 closed: DONE (Session F, 9 Jul 2026).** §5's "Verified <date>" is
  now data-driven: `mgmt_profiles.verified_on` (date, nullable) added and
  backfilled (64 × 02 Jul 2026, 8 × 09 Jul 2026, 0 NULLs), the waiter carries
  it (+1 mapping line in `data.js`), and `company.js` prints each row's own
  date — "—" when NULL, never a borrowed date. Migration saved as
  `sql/2026-07-09_flag5_verified_on.sql`; CONTRACT's MGMT shape, translation
  rules and parachute updated. Chip text unchanged. Batch 2 is unblocked.
- **Narratives `display_order`: DONE (Session N, 14 Jul 2026).** Flag 1 closed.
  `cross_company_narratives.display_order` (integer, nullable, spaced by 10s,
  not unique) added and backfilled in the order the site was already showing;
  the waiter now orders by `display_order.asc.nullslast,id.asc` (`data.js:198`,
  1 line changed). Map order is a data decision now — editable in the Table
  Editor, no deploy. Migration saved as
  `sql/2026-07-14_narratives_display_order.sql`. Chip text unchanged.
  **Part C (the curated renumber) was run same day:** map order is now
  power → metals-auto → holding → banca.
- **LTIM peer group: DONE (Session O, 14 Jul 2026).** Flag 2 closed. One
  guarded UPDATE moved LTIM's `compare_group` from the solo "IT Services"
  bucket into "IT" (now 6 members). Pre-flight confirmed "IT Services" held
  ONLY LTIM before the move; post-flight judge: it_services_left = 0. Root
  cause understood, not just patched: `groupsForCompare()` (compare.js:46)
  only surfaces groups with ≥ 2 members, so a solo group renders NO chip and
  company.js:33 hides the compare button — LTIM was un-comparable, not
  mislabelled. No code shipped; the empty "IT Services" label stays in
  GROUP_LABELS on purpose (see Lessons Session O). Migration saved as
  `sql/2026-07-14_ltim_peer_group.sql`. Chip text unchanged.
- **INDIGO exact figure: DONE (Session P, 15 Jul 2026). The Session N+ queue
  is now EMPTY of one-off items.** The derived 40.48 is replaced by the filed
  Mar-2026 SHP total: **41.57%** (160,732,247 shares — IGE 35.69 + Bhatia
  individuals 0.03 + Rakesh Gangwal 4.53 + Chinkerpoo Family Trust 1.32),
  founder-verified against the exchange filing. The old derivation's error is
  now explained, not just replaced: it missed the Chinkerpoo Trust's 1.32%
  (filed RG side 5.85, not 4.78). Four value-guarded UPDATEs in
  `sql/2026-07-15_indigo_shp_exact.sql` — the number lived in FOUR places
  (headline + two prose sentences + source_note), so Part D of the repair file
  alone would have left the page contradicting itself. Part D is hereby
  superseded and stays commented-out forever. Chip text unchanged.
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
642 bull/bear · **107 mgmt profiles** (64 at flip + 8 E + 5 G + 5 H + 7 I +
5 J + 6 K + 7 L) · 4 narratives · staging 0. Current chip: `● data checks: 107
companies · 492 metric bindings · 14 forces · 107 verified promoter records`.
**The mgmt_profiles backlog is closed: full coverage.**
`metric_snapshots` now grows by ~107 rows per successful night (599 + one row
per fetched company per night; ≈706 after the first v2 run).

## ⚠️ Flags carried (accepted, not blockers)

1. ~~**Map page lists stories alphabetically.**~~ **CLOSED (Session N,
   14 Jul 2026).** `cross_company_narratives.display_order` (integer, nullable,
   spaced by 10s) now drives the map page; `data.js` orders by
   `display_order.asc.nullslast,id.asc`. A NULL means *not placed yet* and
   renders last, never mid-list. Order is now a Table-Editor edit, not a code
   ship.
2. ~~**LTIM sits alone in "IT Services".**~~ **CLOSED (Session O,
   14 Jul 2026).** LTIM moved to "IT" via a guarded one-row UPDATE
   (`sql/2026-07-14_ltim_peer_group.sql`); compare page now shows IT · 6 and
   LTIM's page gained its "compare with peers" button. The empty "IT Services"
   label deliberately remains in GROUP_LABELS — deleting it while any company
   points at it turns the chip red (selftest.js:30), and empty it costs
   nothing (the ≥ 2 filter never surfaces it).
3. **Four stale husk files** (`metrics.json`, `factors.json`, `chains.json`,
   `mgmt.json`) sit in `investorlens-backups` at pre-flip content. Optional
   tidy-up: delete them via the web UI after the first v2 backup — their
   history stays in git forever.
4. **Snapshot growth:** ~3.2k rows/month. `data.js` paginates (verified), so
   the site keeps working, but every +1,000 rows adds one request to page
   load. Before it matters (several months), plan a prune/view session:
   keep the last N days + first-of-month rows.

## Session N+

1. ~~**INDIGO exact figure owed.**~~ **DONE — Session P, 15 Jul 2026.** Filed
   figure 41.57% verified and pasted; Part D superseded by
   `2026-07-15_indigo_shp_exact.sql` (four guarded UPDATEs, not one — the
   number lived in four places). The queue's only remaining item is the
   standing quarterly sweep (item 4).
2. ~~**Narratives `display_order`.**~~ **DONE — Session N, 14 Jul 2026.**
   Column added + backfilled order-preservingly; `data.js:198` reorders. The
   curated renumber (Part C of the migration: power → metals-auto → holding →
   banca) is optional and is the founder's call — run it in the SQL Editor or
   just edit the four numbers in the Table Editor whenever.
3. ~~**LTIM compare_group.**~~ **DONE — Session O, 14 Jul 2026.** Pre-flight
   proved the bucket held only LTIM; the guarded UPDATE moved it; IT is now a
   6-member group. Re-run returns UPDATE 0 by construction.
4. **Mgmt maintenance** — quarterly re-verification
   sweep after each SHP season, prioritising the flagged rows: INDIGO (derived
   %, RG Group exit drifts it down every quarter), BAJAJ-AUTO (post-buyback
   SHP), ASIANPAINT (live pledge moves), SUNPHARMA (rising pledge + Organon
   clause), ADANIPORTS (encumbrance-table check), HDFCLIFE (post-16-Jun event
   SHP), TMPV (demerger-era comparisons).
   - Batch 6 — metals/cement/infra (6): HINDALCO, JSWSTEEL, TATASTEEL,
     ULTRACEMCO, GRASIM, ADANIPORTS
   - Batch 7 — consumer/new-age (7): ASIANPAINT, NESTLEIND, TATACONSUM,
     TITAN, TRENT, INDIGO, ETERNAL
- Optional carried: husk-file tidy-up (flag 3); replace the retired `/sql`
  files with the Phase-4 pair; snapshot prune/view strategy (flag 4).
  *(Flags 1 and 2 are closed — Sessions N and O.)*

## Lessons Session P added

- **A number is not a cell; it is every sentence that mentions it.** Part D
  assumed the fix was one UPDATE. The bytes showed 40.48/4.78 living in four
  places — headline, two prose sentences, source_note. Fixing only the
  headline would have shipped a page that disagreed with itself. Before
  replacing any figure, grep for it everywhere it could have been narrated.
- **A wrong number you can explain beats a right number you can't.** The
  derived 40.48 wasn't sloppy arithmetic — it undercounted the RG side by
  exactly the Chinkerpoo Trust's 1.32%. Finding the mechanism of the error is
  what makes the correction trustworthy, and it sharpened the platform's
  understanding of the promoter structure at the same time.
- **Aggregators disagree by QUARTER more often than by value.** 41.58 vs 41.57
  vs 43.5 were all "true" — for Dec-2025, Mar-2026, and Jun-2025 respectively.
  The verification instruction must decode the noise in advance, or the
  verifier drowns in numbers that are each correct about a different date.
- **"Founder-verified" is a claim the database makes; it must be earned before
  it is pasted.** The migration carried a written hard gate: PASTE 2 does not
  run until the exchange filing has been seen with human eyes. Source one is
  never enough, even when three aggregators agree.

## Lessons Session O added

- **A solo peer group is invisible, not broken.** `groupsForCompare()` filters
  to ≥ 2 members, so a one-member group renders NO chip at all, and the
  company page then hides its compare button too. The symptom ("LTIM shows no
  compare chip") looked like a rendering bug; the bytes showed it was a
  membership fact. Diagnose from the code path, then verify from the data.
- **An empty label is free; a dangling pointer is not.** The tempting cleanup —
  delete the now-unused "IT Services" from GROUP_LABELS — has a live tripwire:
  selftest.js:30 asserts every company's compare_group exists in GROUP_LABELS,
  so deleting the label before every row has moved turns the home chip red.
  Empty, the label costs nothing and is ready for a future IT-services name
  without a deploy. Sequencing debt again, in miniature.
- **The code names the buckets; only the database knows the members.** The repo
  could prove two IT buckets exist, but "is LTIM alone in there?" was
  answerable only by the pre-flight grid. That is why the migration's Paste 1
  carries a written STOP condition: more-than-LTIM would have been a business
  decision (two real tiers of IT?) — not a typo fix.

## Lessons Session N added

- **A migration and a decision are different statements.** Adding the column and
  *choosing the order* were separable, so they were separated: Part B is
  order-preserving and provable ("nothing moved"); Part C is the founder's call
  and is the only line in the file that changes a pixel. A migration that also
  reorders the page cannot be verified as surgical — it has already moved the
  thing it would be checked against.
- **NULL is a position, not a hole.** `nullslast` parks an unnumbered story at
  the END of the map page instead of letting it barge into the middle
  alphabetically. Same reasoning as `verified_on`: nullable keeps the parachute
  re-runnable, and the honest render is a *defined* one, not an accident.
- **Gaps of 10 are cheap; renumbering is not.** A fifth story slots in as 25.
  Consecutive integers would have forced an UPDATE on every row beneath it.
- **The backfill must not be able to clobber the decision.** Part B counts up
  from the current MAX and only ever touches NULLs — proven by re-running it
  after Part C and getting the renumbered order back untouched. A re-runnable
  file that quietly resets your choices is worse than one that errors.

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

## Lessons Session G added

- **"No promoter" is an answer, not an absence.** Two of the five banks have
  zero promoter — and the *reason* differs: FEDERALBNK never had one;
  IDFCFIRSTB stopped having one when IDFC Ltd reverse-merged into it
  (1 Oct 2024). Writing 0% with the story attached is more honest — and more
  useful — than leaving the row queued. §5 already renders 0% correctly
  (HDFCBANK, ICICIBANK, ITC, LT set that precedent at the flip).
- **Promoter % is not always a sentiment signal.** BANDHANBNK's promoter sold
  ~2% because RBI's licensing terms *force* dilution — its own filing calls it
  "disposal of excess shareholding." A tracker showing "promoter selling" would
  have read as a red flag; the filing says it is a staircase agreed to in
  advance. This is exactly what the human verification pass is for.
- **Trackers round; filings do not.** AUBANK came out of the exchange SHP at
  22.76% with a machine-readable "encumbered: 0" — no aggregator needed. Where
  a primary filing exists, read the filing.
- **The `WHERE NOT EXISTS` insert makes a batch re-runnable without assuming a
  unique constraint** — the paste can be repeated after a dropped connection
  and cannot double-insert. Proven on PostgreSQL 16.2: run twice → 77 rows,
  second run inserts 0.

## Lessons Session H added

- **Read the event SHP, not just the quarterly one.** A capital-structure
  change forces a company to re-file its shareholding pattern. Three of this
  batch had done so since 31 Mar 2026 — SHRIRAMFIN on 08 Apr, JIOFIN on
  21 Apr. Recording the March figure for those two would have shipped a number
  the company itself had already superseded. `as_of` earns its keep here: the
  batch honestly carries a mix of "Mar 2026" and "Apr 2026".
- **The percentage lies; the share count does not.** In four of these five the
  promoter's share COUNT was unchanged quarter-on-quarter — SHRIRAMFIN held
  47,76,30,880 shares before and after falling from 25.38% to 20.30%; SBI has
  held the same 55,50,00,000 shares in SBILIFE for years; CHOLAFIN's promoter
  crossed below 50% without selling. A tracker that reports only "% down"
  reports a decision that nobody made. Always read the share count next to it.
- **Lock-in is not pledge.** JIOFIN shows 25 crore promoter shares "locked" —
  the statutory lock-in on a preferential allotment, a rule the promoter agreed
  to, not collateral a lender can seize. Same column on a tracker, opposite
  meaning. §5's pledge sentence says so explicitly.
- **A batch can carry a comparison the single pages cannot.** HDFCLIFE and
  SBILIFE are both bank-owned life insurers; one closed FY26 at 177% solvency
  and took ₹1,000 cr from its parent, the other at 190% and took nothing. Two
  rows researched in the same pass make that visible; two rows researched six
  months apart would not have.

## Lessons Session M added

- **A delivered filename is part of the delivered bytes.** The batch files
  landed with spaces instead of underscores — the download UI displays names
  without underscores, and the display name got typed into the GitHub filename
  box. The parachute replays migrations in filename order, so a space (0x20 <
  0x5F) silently reorders the chain. Commit-verification now includes the
  FILENAME, not just the content: the Ctrl+F step must be run against the
  sql/ directory listing too.
- **A [VERIFY] marker is a tripwire, not a decoration.** Both markers walked
  straight into production because the paste step didn't include the
  documented zero-hits Ctrl+F. Future flagged files put the tripwire IN THE
  JUDGES: a pre-flight `SELECT ... LIKE '%VERIFY%'` with "expect 0 in your
  edited paste" would have shown 2 in the results grid before the insert ran.
- **Stale memory loses to live bytes, in both directions.** The backlog said
  the robots weren't live; the repo says they are. Fetch-first isn't just for
  catching missing work — it also stops you redoing finished work.

## Lessons Sessions K + L added

- **The biggest pledge is a financing model, not a distress flare.** JSWSTEEL:
  11.81% of the block pledged across six named entities (two offshore vehicles
  at 100%), yet falling for two years while the promoter BUYS and the rating
  agencies UPGRADE (CARE AA+, Fitch BB+ positive, the same week). Size alone
  reads as alarm; trajectory + who-pledged + ratings read as treasury.
- **Two nils are not the same nil.** Wipro's Reg 31(4) says nothing was
  encumbered, full stop. ADANIPORTS' and INDIGO-RG's FY26 filings say no NEW
  encumbrance was created "excluding those already disclosed" — a narrower
  sentence. The pledge_note must quote the construction, or the platform
  flattens a real distinction.
- **promoter_pct = 0 is a governance model, not missing data.** ETERNAL has no
  promoter; the founder is a public shareholder. Every question the column
  usually answers gets answered elsewhere (board, ESOPs, register pressure).
  First row of its kind here; there will be more as new-age listings age in.
- **A derived number must confess.** INDIGO's 40.48% is arithmetic (IGE ~35.7 +
  RG residual ~4.78), not a filed figure — the row says so in three places.
  Better an honest derivation flagged loudly than a false precision quietly.
- **The state can be the biggest promoter.** TITAN: TIDCO (Tamil Nadu govt)
  holds ~27.88% — more than the Tatas who run it. Control and the largest
  claim on value can live at different addresses.
- **Cross-links are now load-bearing.** GRASIM promotes ULTRACEMCO (both
  rows); GRASIM's Birla Opus attacks ASIANPAINT (both rows); M&M promotes
  TECHM; JSW Energy holds JSW Steel. The mgmt layer is becoming a graph, not
  a table — a future UI candidate.

## Lessons Session J added

- **A pledge has a direction, and the direction is the story.** Two non-zero
  pledges, pointing opposite ways. SUNPHARMA's went 0.97% → 1.42% in one
  quarter — a fresh pledge, created now. APOLLOHOSP's went 16.30% → 2.49% over
  three years — a family unwinding leverage in public. Identical-looking cells;
  opposite meanings. A static percentage cannot carry that, so the §5 sentence
  carries the trajectory.
- **Ask WHO pledged, not HOW MUCH.** Sun Pharma's 1.42% is not Dilip Shanghvi —
  his 23 crore shares are unencumbered, as is all of Shanghvi Finance. The
  pledge belongs to Raksha Sudhir Valia (63.96% of everything she owns) and
  Kumud Shantilal Shanghvi (100% of hers). Apollo's 2.49% is K Vishweshwar
  Reddy (42.16% of his) and Suneeta Reddy (11.58%). Block-level pledge numbers
  hide personal balance sheets; the entity table shows them.
- **A founder can be reclassified out of his own company.** Analjit Singh built
  Max Healthcare; Abhay Soi reverse-merged Radiant Life Care into it in 2020,
  and the Singh family was moved from promoter to PUBLIC. The `who` field
  records who promotes it today, not who founded it — and for MAXHEALTH those
  are different people.
- **A depositary bank is not a shareholder.** DRREDDY's biggest non-promoter
  name is J P Morgan Chase Bank NA at 11.94% — that is the ADR custodian for
  the New York listing, not a conviction holder. Reading it as an institutional
  vote of confidence would be a category error.
- **Selling and then stopping is itself a signal.** Cipla's Hamieds dropped
  four points across 2024, then held exactly 23,52,87,003 shares for five
  straight quarters. The flat line after the sell-down says as much as the
  sell-down did.

## Lessons Session I added

- **A pledge cell is finally not blank — twice.** Eight batches of nil made nil
  feel like the default. M&M carries 40,000 pledged shares (0.02% of the block)
  and they belong to one named promoter-group individual, Sanjay Mohan Labroo —
  a personal arrangement, not company leverage. BAJAJ-AUTO shows ~0.01% on the
  trackers. The §5 sentences say so plainly. A tracker that rounds these to
  "0%" is not being kind; it is deleting the only information in the cell.
- **A buyback can make a promoter sell AND rise.** Wipro's promoters tendered
  42,80,45,126 shares into the ₹15,000 cr buyback — real cash out — and their
  stake still went 72.52% → 72.59%, because 60 crore shares were cancelled
  faster than the family sold. "Promoter stake up" and "promoter sold" were
  both true in the same fortnight. Only the share count untangles it.
- **A rename is not a continuity.** TMPV *is* the old Tata Motors Limited (same
  BSE code 500570), renamed 13 Oct 2025 after the CV demerger. Every pre-Oct-25
  comparison for that ticker is comparing two different companies, and its FY26
  profit carries demerger accounting. The row says so, out loud, rather than
  letting the number imply a trend that does not exist.
- **"Promoter" can be mostly not-the-promoter.** A third of TECHM's promoter
  block is the TML Benefit Trust, not M&M; nearly all of HCLTECH's is two
  holding companies, with the founder's own name against 736 shares. The `who`
  field earns its place — the percentage alone would mislead in both.
- **When Trendlyne is stale, go to the company.** Its TECHM page still showed
  Dec-2025 while the company's own Q4 SHP for 31-Mar-2026 was sitting on
  techmahindra.com. Aggregator lag is silent; it does not announce itself.

## Mission lock (unchanged)

Business UNDERSTANDING first — value chains, business cores, moats, live
factors, management quality. Valuation secondary; stock-picking out of scope.
Machines refresh NUMBERS; only humans write/verify SENTENCES.

## Changelog

- **v4.6 / Phase 4 Session P: INDIGO's filed figure lands — the Session N/O/P
  queue is complete.** promoter_pct 40.48 (derived) → **41.57** (filed Mar-2026
  SHP, founder-verified against the exchange filing 15-Jul-2026). Research
  trail: Trendlyne entity-level table (self-reconciling to the share:
  35.69 IGE + 0.03 Bhatia individuals + 4.53 Rakesh Gangwal + 1.32 Chinkerpoo
  Trust = 41.57 / 160,732,247 shares), corroborated by IIFL (41.57) and Kotak
  (41.6 rounded); discrepancy log resolved 41.58 = Dec-2025 and 43.5 = Jun-2025
  before verification began. Error mechanism identified: the old derivation
  missed the Chinkerpoo Trust's 1.32%. Executed as FOUR value-guarded UPDATEs
  (`2026-07-15_indigo_shp_exact.sql`), not Part D's one — the number lived in
  four places (promoter_pct, two promoter_who sentences, source_note); Part D
  verbatim would have left "41.57" above prose still calling it "a derived
  40.48". Dry-run on a production-identical fixture (batch7 text + repair
  B3/B4 applied): pre-flight t/t/t → four UPDATE 1 → judge green → re-run four
  UPDATE 0. Prose now reads "the filed Mar-2026 SHP figure… will drift lower
  each quarter until the RG Group reaches zero" — the drift warning survives,
  the caveat retires. CONTRACT parachute +1 (file replays last by filename;
  batch7's 40.48 judge remains true at its point in the replay and is
  superseded by this file's judge). Chip text unchanged. With this, every
  one-off item queued at Session N's opening is closed; what remains is the
  standing quarterly SHP re-verification sweep — INDIGO explicitly flagged as
  drift-prone until the RG Group reaches zero.
- **v4.5 / Phase 4 Session O: LTIM joins its peers (flag 2 closed).** One
  guarded UPDATE (`WHERE ticker = 'LTIM' AND compare_group = 'IT Services'`)
  moved LTIM into "IT" — the guard means it can only ever touch LTIM and
  re-running returns UPDATE 0, proven twice on PostgreSQL 16.14. Pre-flight
  judge confirmed the solo bucket held only LTIM (STOP condition written into
  the file for the other case). vm harness on the exact live compare.js bytes,
  before vs after: BEFORE — no "IT Services" chip (< 2 members), LTIM compare
  button HIDDEN; AFTER — IT · 6, button SHOWN; metric keys union cleanly (a
  metric only LTIM discloses renders "—" for the other five, already captioned
  honestly). No code shipped; "IT Services" stays in GROUP_LABELS empty (the
  selftest.js:30 tripwire makes deleting it strictly worse than keeping it).
  Only other pixel moved: LTIM's home-card chip now reads "IT" (home.js:148
  prints compare_group). CONTRACT parachute +1 dated migration
  (`2026-07-14_ltim_peer_group.sql` — note it sorts BEFORE the narratives file
  in filename-order replay; the two touch different tables and are
  order-independent), and the stale "repair file runs last" sentence — left
  behind by Session N's own edit — corrected in the same pass. Chip text
  unchanged. Session N+ queue now holds a single item: INDIGO's filed
  Mar-2026 SHP figure.
- **v4.4 / Phase 4 Session N: narratives get a sort key (flag 1 closed).**
  `cross_company_narratives.display_order` (integer, NULLABLE, spaced by 10s, no
  unique constraint) added and backfilled **in the order the site was already
  showing** — so the migration itself moves nothing on screen; the curated order
  (power → metals-auto → holding → banca) is a separate, optional Part C the
  founder runs when he wants it. `data.js` 1 line changed (`:198`): `id.asc` →
  `display_order.asc.nullslast,id.asc`. SQL-before-JS enforced (JS first would
  400 on an unknown order column and blank the map page). Dry-run on PostgreSQL
  16.14: pre-flight reproduces the alphabetical bug; Part B run twice →
  identical (idempotent); Part C run twice → identical (re-runnable); Part B
  re-run AFTER Part C does **not** clobber the renumber; a 5th story inserted
  with no number lands **last** and gets 50 on the next Part B. vm round-trip
  harness against the exact live bytes: 5/5 — order param changes, every
  CHAINMAP story object byte-identical, no `display_order` key leaks into the UI
  shape, the other six tables' order clauses untouched. CONTRACT updated
  (Narratives translation rule + parachute now names
  `2026-07-14_narratives_display_order.sql`, which must run before a rebuilt
  database serves `data.js`). Chip text unchanged.
- **v4.3 / Phase 4 Session M: post-paste repair + record corrections.**
  (1) Verified from live bytes that BOTH robots are already v2 on main —
  refresh.py writes dated `metric_snapshots` rows with the delete-then-insert
  guard (cron 02:00 IST nightly), backup.py photocopies all 8 tables with
  empty-backup refusal (cron Sun 03:00 IST) — the "robots v2 need to land"
  backlog line was stale; what remains is a green-run check in the Actions
  tab. (2) Batches 5-7 landed on main byte-identical to the drafts, which
  means the two [VERIFY] flags entered production unresolved; shipped
  `2026-07-12_session_m_flag_repair.sql` (4 guarded UPDATEs, idempotent,
  proven twice on the 107-row end-state fixture: flags 2→0, count 107
  unchanged). SUNPHARMA's Organon clause is now CONFIRMED — definitive
  agreement 26-Apr-2026, US$14.00/share all-cash, EV US$11.75 bn, 103%
  premium, close expected early 2027 (joint release + Organon SEC 8-K) — the
  Forbes clause was true and now carries the filing. INDIGO's bracket became
  an honest house-style caveat; the exact SHP figure is still owed (Session
  N+ item 1). (3) The three batch files were committed with SPACES in their
  filenames ("2026-07-11 mgmt batch5 pharma health.sql"), which breaks the
  parachute's filename-order replay (space sorts before underscore) and
  orphans CONTRACT's references — rename runsheet issued; CONTRACT text is
  correct once the renames land. New lesson below.
- **v4.2 / Phase 4 Sessions K + L: MGMT BACKLOG COMPLETE.** Batches 6 and 7
  shipped as count-chained files (pre-flights 94 and 100; paste order 5→6→7
  enforced by Judge 0a). Batch 6 (HINDALCO 34.64, JSWSTEEL 45.32, TATASTEEL
  33.19, ULTRACEMCO 59.33, GRASIM 43.74, ADANIPORTS 68.02): JSWSTEEL's 11.81%
  pledge is the platform's largest — six named entities, offshore vehicles at
  100%, falling from 15.24% — recorded alongside the same-week CARE/Fitch
  upgrades; ADANIPORTS' nil carries its 17.31%-in-2023 history and the
  "excluding already-disclosed" Reg 31(4) wording verbatim. Batch 7
  (ASIANPAINT 52.63 with a live Smiti/Sattva pledge incl. 5,00,000 shares to
  Bajaj Finance 2-Mar-2026; NESTLEIND 62.76; TATACONSUM 33.84; TITAN 52.90
  with TIDCO 27.88% as the larger promoter; TRENT 37.01; INDIGO 40.48 DERIVED
  and marked [VERIFY]; ETERNAL 0 — first no-promoter row). Batch 7 adds Judge
  6: zero companies without a mgmt row. Chained dry-run on PostgreSQL 16.14:
  89→94→100→107, all judges as predicted, second pass INSERT 0 0 on all three
  files. Chip acid test: 107 verified promoter records. Backlog: 0.
- **v4.1 / Phase 4 Session J:** Mgmt gaps Batch 5 shipped. 5 pharma/health
  records (CIPLA 29.21%, DRREDDY 26.63%, SUNPHARMA 54.48%, APOLLOHOSP 28.02%,
  MAXHEALTH 23.74%) machine-researched — Dr Reddy's FY26 Reg 31(4)&(5)
  nil-encumbrance declaration (signed by K Satish Reddy and G V Prasad), Max
  Healthcare's FY26 Reg 31(4) filing (6-Apr-2026, Abhay Soi + Aditya Soi),
  Apollo's NCLT-approved composite scheme (24-Jun-2026) demerging pharmacy and
  digital health, and the Mar-2026 shareholding tables read entity by entity —
  founder-verified, inserted via SQL Editor as
  `sql/2026-07-11_mgmt_batch5_pharma_health.sql`. Idempotent `WHERE NOT EXISTS`
  insert + 6 self-judges; dry-run on PostgreSQL 16.14 passed twice (94 rows,
  0 dupes, 0 NULL verified_on, date buckets 64/8/22). **Two substantive
  pledges, moving in opposite directions:** SUNPHARMA 1.42% and rising (Raksha
  Sudhir Valia 63.96% of her holding; Kumud Shantilal Shanghvi 100% of hers;
  Dilip Shanghvi himself 0.00%), APOLLOHOSP 2.49% and falling from 16.30% at
  Jun-2023 (K Vishweshwar Reddy 42.16% of his; Suneeta Reddy 11.58%). CONTRACT
  parachute list updated (+1 dated migration). Chip acid test: 94 verified
  promoter records. 13 gaps remain (batches 6-7).
- **v4.0 / Phase 4 Session I:** Mgmt gaps Batch 4 shipped. 7 IT/auto records
  (HCLTECH 60.86%, TECHM 34.97%, WIPRO 72.59% *as of Jun-26, post-buyback*,
  BAJAJ-AUTO 55.01%, EICHERMOT 49.07%, M&M 18.45%, TMPV 42.56%)
  machine-researched — Tech Mahindra's and Eicher's own 31-Mar-2026 exchange
  SHPs read at source (TECHM's encumbrance rows all "No"), Wipro's FY26
  Reg 31(4) nil-encumbrance filing (6-Apr-2026), Eicher's promoter-group
  Reg 31(4)&(5) filings (8-Apr-2026), and Wipro's 30-Jun-2026 extinguishment
  filing (60 cr shares cancelled; promoter 72.52% → 72.59% *while selling*
  42,80,45,126 shares) — founder-verified, inserted via SQL Editor as
  `sql/2026-07-11_mgmt_batch4_it_auto.sql`. Idempotent `WHERE NOT EXISTS`
  insert + 6 self-judges; dry-run on PostgreSQL 16.14 passed twice (89 rows,
  0 dupes, 0 NULL verified_on, date buckets 64/8/17; `M&M` and `BAJAJ-AUTO`
  round-tripped intact). First two non-zero pledge cells on the platform.
  CONTRACT parachute list updated (+1 dated migration). Chip acid test: 89
  verified promoter records. 18 gaps remain (batches 5-7).
- **v3.9 / Phase 4 Session H:** Mgmt gaps Batch 3 shipped. 5 NBFC/insurance
  records (CHOLAFIN 49.25% Mar-26, SHRIRAMFIN 20.30% Apr-26, JIOFIN 49.13%
  Apr-26, HDFCLIFE 50.21% Mar-26, SBILIFE 55.33% Mar-26) machine-researched —
  SHRIRAMFIN's 08-Apr-2026 and JIOFIN's 21-Apr-2026 event shareholding patterns
  read at source, plus HDFC Bank's Q4 FY26 deck (50.21%, solvency 177%), its
  FY26 Reg 31(4) nil-encumbrance filing (3 Apr 2026) and HDFC Life's own FY26
  call transcript (₹1,000 cr preferential issue, ~900 bps of solvency) —
  founder-verified, inserted via SQL Editor as
  `sql/2026-07-11_mgmt_batch3_nbfc_insurance.sql`. Idempotent `WHERE NOT
  EXISTS` insert + 6 self-judges; dry-run on PostgreSQL 16.14 passed twice
  (82 rows, 0 dupes, 0 NULL verified_on, date buckets 64/8/10). CONTRACT
  parachute list updated (+1 dated migration). Chip acid test: 82 verified
  promoter records. 25 gaps remain (batches 4-7). Zero pledges across all five.
- **v3.8 / Phase 4 Session G:** Mgmt gaps Batch 2 shipped. 5 private-bank
  records (AUBANK 22.76%, AXISBANK 8.15%, BANDHANBNK 39.0%, FEDERALBNK 0%,
  IDFCFIRSTB 0%) machine-researched — AU's 31-Mar-2026 exchange SHP and FY26
  Reg 31(4) nil-encumbrance read at source; BFHL's Reg 29(2) filing (40.00% →
  37.93%, Sep-25 → 12-May-26) read at source — founder-verified, inserted via
  SQL Editor as `sql/2026-07-11_mgmt_batch2_private_banks.sql`. Idempotent
  `WHERE NOT EXISTS` insert + 6 self-judges; dry-run on PostgreSQL 16.2 passed
  twice (77 rows, 0 dupes, 0 NULL verified_on, date buckets 64/8/5). Chip acid
  test: 77 verified promoter records. 30 gaps remain (batches 3–7).
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
