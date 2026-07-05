-- ════════════════════════════════════════════════════════════════════
-- InvestorLens India — schema.sql  (Phase 2)
-- The five drawers of the filing cabinet. Paste this into the Supabase
-- SQL editor and Run it ONCE. Then run seed.sql to fill the drawers.
--
-- Safe to re-run: it drops and recreates the five tables cleanly.
-- (Dropping wipes data — you reload it with seed.sql right after.)
-- ════════════════════════════════════════════════════════════════════

drop table if exists mgmt      cascade;
drop table if exists chains    cascade;
drop table if exists factors   cascade;
drop table if exists metrics   cascade;
drop table if exists companies cascade;

-- ── companies ──────────────────────────────────────────────────────
-- One row = one company. The "index card" every other table points at.
create table companies (
  ticker               text primary key,
  name                 text not null,
  exchange             text,
  sector               text,
  sub_sector           text,
  compare_group        text,          -- peer bucket used by Compare mode
  as_of                text,          -- e.g. "Q3 FY26 (quarter ended 31 Dec 2025)"
  fetched_at           date,          -- the day we recorded this card
  source_note          text,          -- where the numbers came from
  business_core        text,          -- plain-English "what this company does"
  value_chain_position text,          -- §2 upstream/downstream position write-up
  value_chain_note     text,          -- the honesty caveat under it
  moat_note            text,          -- §6 durable-advantage note
  bull                 jsonb not null default '[]'::jsonb,  -- array of strings
  bear                 jsonb not null default '[]'::jsonb,  -- array of strings
  metric_order         jsonb not null default '[]'::jsonb,  -- ordered metric_keys
  market_cap_cr        bigint,        -- ₹ crore; the robot refreshes this nightly (Phase 3)
  updated_at           timestamptz not null default now()
);

-- ── metrics ────────────────────────────────────────────────────────
-- One row = one metric value for one company ON ONE DATE.
-- snapshot_date is the quiet superpower: keep every reading forever,
-- and trend charts become free later with zero redesign.
create table metrics (
  id               bigint generated always as identity primary key,
  ticker           text not null references companies(ticker) on delete cascade,
  metric_key       text not null,          -- e.g. "nim", "revenue_growth_pct"
  label            text,                   -- human label, e.g. "Net Interest Margin"
  value            numeric,                -- NULL is allowed (e.g. a distorted ratio we won't fake)
  unit             text,                   -- "%", "₹", "x", "" ...
  note             text,                   -- the one-line caveat under the number
  higher_is_better boolean,                -- true / false / NULL (NULL = display-only, never ranked)
  snapshot_date    date not null,
  unique (ticker, metric_key, snapshot_date)
);

-- ── factors ────────────────────────────────────────────────────────
-- One row = one real-time factor tag (the §3 Factor Tracker).
create table factors (
  id        bigint generated always as identity primary key,
  ticker    text not null references companies(ticker) on delete cascade,
  type      text not null check (type in ('risk','tailwind','neutral')),
  label     text not null,
  tagged_on date,
  position  int                             -- preserves display order
);

-- ── chains ─────────────────────────────────────────────────────────
-- Two kinds of row live here, told apart by `kind`:
--   kind='node' → one value-chain node for ONE company (§2 diagram)
--   kind='map'  → one inter-company map GROUP, stored whole as JSONB
-- (The map groups are shape-shifty — flow / input / ownership — so we
--  keep each one intact as JSONB instead of forcing it into columns.)
create table chains (
  id        bigint generated always as identity primary key,
  kind      text not null default 'node' check (kind in ('node','map')),
  -- kind='node' fields:
  ticker    text references companies(ticker) on delete cascade,
  side      text check (side in ('up','down')),
  position  int,
  label     text,
  tag       text check (tag in ('risk','tailwind','neutral')),  -- NULL = untagged link
  note      text,
  -- kind='map' fields:
  map_id    text,
  map_group jsonb,
  constraint chains_shape check (
    (kind = 'node' and ticker is not null and side is not null) or
    (kind = 'map'  and map_id is not null and map_group is not null)
  )
);

-- ── mgmt ───────────────────────────────────────────────────────────
-- One row = one verified §5 management / capital-allocation record.
create table mgmt (
  ticker       text primary key references companies(ticker) on delete cascade,
  promoter_pct numeric,
  who          text,
  pledge       text,      -- kept as verified TEXT, never forced into a number
  capital      text,
  as_of        text,      -- e.g. "Mar 2026" / "Q4 FY26"
  sources      text
);

-- ── indexes (tiny data today, good hygiene for tomorrow) ───────────
create index metrics_ticker_idx on metrics (ticker);
create index metrics_snap_idx   on metrics (snapshot_date);
create index factors_ticker_idx on factors (ticker);
create index chains_node_idx    on chains  (ticker, side) where kind = 'node';
create index chains_map_idx     on chains  (map_id)       where kind = 'map';

-- ── Row Level Security: anyone may READ, nobody may WRITE via anon ──
-- Writing only ever happens through the master (service_role) key — the
-- nightly robot — or you + Claude in the Supabase dashboard.
alter table companies enable row level security;
alter table metrics   enable row level security;
alter table factors   enable row level security;
alter table chains    enable row level security;
alter table mgmt      enable row level security;

create policy "public read" on companies for select using (true);
create policy "public read" on metrics   for select using (true);
create policy "public read" on factors   for select using (true);
create policy "public read" on chains    for select using (true);
create policy "public read" on mgmt      for select using (true);

-- Make the read grant explicit for the front-door (anon) + logged-in roles.
grant select on companies, metrics, factors, chains, mgmt to anon, authenticated;
