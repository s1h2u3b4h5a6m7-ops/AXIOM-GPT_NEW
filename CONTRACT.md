# CONTRACT.md — the menu (data shapes)

*The one document the kitchen (data) and the dining room (UI) both agree on.*
**Status: v1 — Phase 4.** The kitchen is now eight Supabase tables; the dining
room still eats the exact same six globals it has eaten since Phase 1. That is
the whole point of the split: the kitchen was rebuilt and the menu never changed.

> **Rule:** UI code and data both read *this file*, never each other. If a shape
> needs to change, it changes here first, then in the tables (service_role SQL),
> then in `js/data.js`'s translation, and only then — if at all — in the UI.

---

## Where the data lives (Phase 4)

Eight tables in Supabase (Mumbai / ap-south-1). `js/data.js` — the waiter — reads
seven of them over PostgREST with the public anon key and rebuilds the same app
globals: `SEED`, `CHAINS`, `CHAINMAP`, `MGMT`, `MARKET_CAP_CR`,
`HIGHER_IS_BETTER`. No other file knows the data moved. The eighth table is the
robot's inbox; the site never reads it.

| Table | Feeds | One row = |
| --- | --- | --- |
| `companies` | `SEED` (skeleton) | one company's identity + verified sentences |
| `metric_snapshots` | `SEED[t].metrics` + `metric_order`, `MARKET_CAP_CR`, `HIGHER_IS_BETTER` | one number for one company on one date |
| `chain_nodes` | `CHAINS` | one upstream or downstream link |
| `tech_geo_tags` | `SEED[t].tech_geo_tags` | one live §3 factor |
| `bull_bear_cases` | `SEED[t].bull` / `.bear` | one bull or bear sentence |
| `mgmt_profiles` | `MGMT` | one verified management record |
| `cross_company_narratives` | `CHAINMAP` | one multi-company story |
| `staged_metric_snapshots` | *(nothing — robot inbox, human review)* | one unverified scraped number |

## The app globals (unchanged since Phase 1)

`SEED` — object keyed by ticker:

```jsonc
{
  "ticker": "RELIANCE",            // must equal the key
  "name": "Reliance Industries",
  "exchange": "NSE",
  "sector": "Conglomerate",
  "sub_sector": "…",               // optional
  "compare_group": "Conglomerate", // must exist in GROUP_LABELS (compare.js — 27 groups)
  "as_of": "Q4 FY26",
  "fetched_at": "2026-03-31",      // last machine touch (may be null)
  "source_note": "…",              // where the numbers came from
  "business_core": "…",            // §1 what the business actually does
  "moat_note": "…",                // §6 moat
  "value_chain": { "position": "…", "note": "…" },   // §2 (position required)
  "tech_geo_tags": [ { "label": "…", "type": "risk|tailwind|neutral" } ], // ≥1
  "metric_order": ["nim", "gnpa_pct"],   // display order (≥1) — see row-order rule
  "metrics": { "nim": { "label": "…", "value": 3.5, "unit": "%", "note": "…" } },
  "bull": ["…", "…", "…"],         // 3 in practice (data guarantees 3+3)
  "bear": ["…", "…", "…"]
}
```

`CHAINS` — `{ TICKER: { up: [{l, t?, n?}], down: [{l, t?, n?}] } }`, ≥1 each side.
`MGMT` — `{ TICKER: { promoter_pct, who, pledge, capital, as_of, src,
verified_on } }` — a subset; a missing ticker honestly means "queued — no
guesses", never a guess. `as_of` is the period the numbers describe (the SHP
quarter); `verified_on` is the ISO date the founder verified the record.
`MARKET_CAP_CR` — `{ TICKER: number > 0 }` for every SEED ticker.
`HIGHER_IS_BETTER` — `{ metric_key: true|false|null }` for every metric used
(110 keys today). `true` = higher better, `false` = lower better, `null` = show
but don't rank.
`CHAINMAP` — array of story objects
`{ id, kind, title, blurb?, stages?, flows?, pairs?, evidence? }`.

## How rows become globals (the waiter's translation rules)

- **Newest wins.** Per `(ticker, metric_key)`, the row with the latest
  `snapshot_date` supplies value/unit/label/note. Older rows are history — kept
  for future trend views, never overwritten, never deleted.
- **Row order is display order.** `metric_order` is the first-seen `id` order of
  a ticker's snapshot rows; chain nodes and factor tags also render in `id`
  order. Operational rule: INSERT in the order you want to see; to change
  wording, UPDATE the row in place — delete-and-reinsert changes ids and
  therefore order.
- **Market cap is a snapshot like any other**, except
  `metric_key = 'market_cap_cr'` feeds `MARKET_CAP_CR` (newest per ticker) and
  is excluded from `metrics` / `metric_order`.
- **`higher_is_better` rides on snapshot rows**; newest wins per metric key.
- **Directions translate.** DB `'upstream'/'downstream'` → app `up`/`down`;
  columns `node_name / tag / note` → `l / t / n`.
- **Bull/bear.** The newest `snapshot_date` *set* per ticker wins, rendered
  `case_order` 1→3. To refresh a company's cases, insert a complete new 3+3 set
  under a new date.
- **Narratives.** JSONB `stages/flows/pairs` pass through as-is; null columns
  are omitted; stories currently sort alphabetically by `id` (no display_order
  column yet — Session D option).
- **`verified_on` passes through untouched.** `mgmt_profiles.verified_on` (a
  date column) becomes `MGMT[t].verified_on` as an ISO string; the UI formats
  it for display ("2026-07-09" → "09 Jul 2026").
- **Honest gaps stay honest.** `metric_value` NULL renders "—"; a ticker absent
  from `mgmt_profiles` renders the queued box; a NULL `verified_on` renders
  "—", never a borrowed date.

## Who may read and write what (RLS)

- The browser's **anon key** can only SELECT, and only: `metric_snapshots`
  where `status='verified'`; `tech_geo_tags` where `is_active=true`; the other
  five read-tables in full. `staged_metric_snapshots` has **no** public read.
- All writes use the **service_role key**: GitHub Actions for numbers, the
  founder in the SQL Editor for sentences. **Machines refresh NUMBERS; only
  humans write or verify SENTENCES.**

## What the self-tests enforce (`js/selftest.js`)

Ticker equals key; `name`, `sector`, `compare_group`, `as_of`, `business_core`,
`source_note`, `moat_note`, `value_chain.position` present; ≥1 factor with a
valid type; `bull` and `bear` non-empty; every `metric_order` key exists in
`metrics` AND in `HIGHER_IS_BETTER`; `compare_group` exists in `GROUP_LABELS`;
a positive market cap per ticker; ≥1 up and ≥1 down chain node, labelled, tags
valid; no orphan tickers in caps/chains/MGMT; every force matches ≥1 company;
every story well-formed (pairs for ownership; otherwise ≥2 stages and
flows = stages−1, every ticker real); MGMT rows complete, `promoter_pct` 0–100.

## What is **not** data (stays as code)

- **`FORCES`** (`js/forces.js`) — 14 macro forces; holds RegExp, so it is code.
- **`GROUP_LABELS`** (`js/compare.js`) — 27 peer groups; holds functions.
- **`CHAINMAP` moved OUT of code in Phase 4:** new stories are database rows in
  `cross_company_narratives` — adding one needs no deploy.

## The parachute

There is no local-JSON fallback anymore. To rebuild the entire database from a
blank project: run `1_SCHEMA_complete.sql` then `2_DATA_complete.sql`
(idempotent + all-or-nothing), then the dated migrations in `/sql` **in
filename order** — currently `2026-07-09_flag5_verified_on.sql` (adds +
backfills `verified_on`), `2026-07-11_mgmt_batch2_private_banks.sql`
(Session G's 5 private-bank mgmt records) and
`2026-07-11_mgmt_batch3_nbfc_insurance.sql` (Session H's 5 NBFC/insurance mgmt
records) and `2026-07-11_mgmt_batch4_it_auto.sql` (Session I's 7 IT/auto mgmt
records). The order is not cosmetic: the Batch-2, Batch-3 and Batch-4 files
write `verified_on`, so the flag-5 file must have created the column first. (Rows inserted after the flip and *not* carried by a dated
migration — e.g. Session E's 8 mgmt records — come back from
`investorlens-backups`.) To resurrect the pre-Phase-4 world: revert the flip
commits on `main` and restore the old five tables from `investorlens-backups`.

## Counts as of the flip (8 Jul 2026) — the checkable state

107 companies · 599 metric snapshots (107 market-cap + 492 business; 21 honest
NULLs) · 518 chain nodes · 321 factor tags · 642 bull/bear (3+3 × 107) ·
64 mgmt profiles · 4 narratives · staging empty.
