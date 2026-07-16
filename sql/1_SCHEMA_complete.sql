-- ============================================================================
-- InvestorLens India -- 1_SCHEMA_complete.sql
-- ============================================================================
-- THE ONE structure file. Creates every table, column, index and security
-- policy the project uses -- the original Phase 1 schema AND the Phase 1b
-- additions, merged into a single place.
--
-- SAFE TO RUN ON ANY DATABASE STATE:
--   * Fresh, empty Supabase project        -> creates everything
--   * Existing project with old schema     -> adds only what's missing
--   * Already fully up to date             -> changes nothing, no errors
-- (Every statement uses IF NOT EXISTS, or drop-and-recreate for policies,
--  so running it twice is harmless.)
--
-- Run this FIRST, before 2_DATA_complete.sql.
-- Generated: 2026-07-03
-- ============================================================================

-- ============================================================================
-- TABLE 1: COMPANIES -- one row per ticker; the identity card
-- ============================================================================
CREATE TABLE IF NOT EXISTS companies (
  ticker TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  exchange TEXT NOT NULL,
  sector TEXT NOT NULL,
  sub_sector TEXT,
  compare_group TEXT,
  business_core TEXT,
  source_note TEXT,
  moat_note TEXT,
  value_chain_position TEXT,
  value_chain_note TEXT,
  as_of TEXT,
  fetched_at DATE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Defensive: if this database was created from the ORIGINAL Phase 1 schema
-- (which lacked these four columns), add them now. On a fresh database these
-- four lines do nothing, harmlessly.
ALTER TABLE companies ADD COLUMN IF NOT EXISTS value_chain_position TEXT;
ALTER TABLE companies ADD COLUMN IF NOT EXISTS value_chain_note TEXT;
ALTER TABLE companies ADD COLUMN IF NOT EXISTS as_of TEXT;
ALTER TABLE companies ADD COLUMN IF NOT EXISTS fetched_at DATE;

-- ============================================================================
-- TABLE 2: METRIC_SNAPSHOTS -- history-friendly numbers, one row per
-- company per metric per snapshot date. Never overwritten, only appended.
-- ============================================================================
CREATE TABLE IF NOT EXISTS metric_snapshots (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  ticker TEXT NOT NULL REFERENCES companies(ticker),
  snapshot_date DATE NOT NULL,
  metric_key TEXT NOT NULL,
  metric_value NUMERIC,
  metric_unit TEXT,
  metric_label TEXT,
  metric_note TEXT,
  higher_is_better BOOLEAN,
  fetched_at TIMESTAMPTZ DEFAULT NOW(),
  status TEXT DEFAULT 'verified',
  CONSTRAINT valid_status CHECK (status IN ('verified', 'staged', 'flagged'))
);

CREATE INDEX IF NOT EXISTS idx_metric_snapshots_ticker_date
  ON metric_snapshots(ticker, snapshot_date DESC);

-- ============================================================================
-- TABLE 3: CHAIN_NODES -- upstream/downstream value-chain links per company
-- ============================================================================
CREATE TABLE IF NOT EXISTS chain_nodes (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  ticker TEXT NOT NULL REFERENCES companies(ticker),
  direction TEXT NOT NULL,
  node_name TEXT NOT NULL,
  tag TEXT,
  note TEXT,
  CONSTRAINT valid_direction CHECK (direction IN ('upstream', 'downstream')),
  CONSTRAINT valid_tag CHECK (tag IN ('risk', 'tailwind', 'neutral'))
);

-- ============================================================================
-- TABLE 4: TECH_GEO_TAGS -- the Real-Time Factor Tracker
-- ============================================================================
CREATE TABLE IF NOT EXISTS tech_geo_tags (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  ticker TEXT NOT NULL REFERENCES companies(ticker),
  label TEXT NOT NULL,
  tag_type TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  is_active BOOLEAN DEFAULT TRUE,
  CONSTRAINT valid_tag_type CHECK (tag_type IN ('risk', 'tailwind', 'neutral'))
);

-- ============================================================================
-- TABLE 5: BULL_BEAR_CASES -- exactly 3 bull + 3 bear per company
-- ============================================================================
CREATE TABLE IF NOT EXISTS bull_bear_cases (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  ticker TEXT NOT NULL REFERENCES companies(ticker),
  snapshot_date DATE NOT NULL,
  case_type TEXT NOT NULL,
  case_text TEXT NOT NULL,
  case_order INT,
  source_note TEXT,
  CONSTRAINT valid_case_type CHECK (case_type IN ('bull', 'bear')),
  CONSTRAINT valid_order CHECK (case_order IN (1, 2, 3))
);

-- ============================================================================
-- TABLE 6: STAGED_METRIC_SNAPSHOTS -- Phase 3 robot's staging area.
-- Deliberately no FK and no index: untrusted data awaiting human review.
-- ============================================================================
CREATE TABLE IF NOT EXISTS staged_metric_snapshots (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  ticker TEXT,
  snapshot_date DATE,
  metric_key TEXT,
  metric_value NUMERIC,
  metric_unit TEXT,
  metric_label TEXT,
  source_url TEXT,
  scraped_at TIMESTAMPTZ DEFAULT NOW(),
  flag_reason TEXT
);

-- ============================================================================
-- TABLE 7 (Phase 1b): MGMT_PROFILES -- promoter/ownership/capital allocation
-- A missing row honestly means "not yet researched", never a guess.
-- ============================================================================
CREATE TABLE IF NOT EXISTS mgmt_profiles (
  ticker TEXT PRIMARY KEY REFERENCES companies(ticker),
  promoter_pct NUMERIC,
  promoter_who TEXT,
  pledge_note TEXT,
  capital_note TEXT,
  as_of TEXT,
  source_note TEXT
);

-- ============================================================================
-- TABLE 8 (Phase 1b): CROSS_COMPANY_NARRATIVES -- multi-ticker stories
-- (e.g. "How electricity reaches you"). JSONB because story shapes differ.
-- ============================================================================
CREATE TABLE IF NOT EXISTS cross_company_narratives (
  id TEXT PRIMARY KEY,
  kind TEXT NOT NULL,
  title TEXT NOT NULL,
  blurb TEXT,
  stages JSONB,
  flows JSONB,
  pairs JSONB,
  evidence TEXT
);

-- ============================================================================
-- ROW LEVEL SECURITY -- public can READ verified data; nobody can WRITE
-- from the browser. Only the service_role key (backend / GitHub Actions)
-- can insert, update or delete.
-- ENABLE is safe to repeat; policies are drop-and-recreate so re-running
-- this file never errors with "policy already exists".
-- ============================================================================
ALTER TABLE companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE metric_snapshots ENABLE ROW LEVEL SECURITY;
ALTER TABLE chain_nodes ENABLE ROW LEVEL SECURITY;
ALTER TABLE tech_geo_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE bull_bear_cases ENABLE ROW LEVEL SECURITY;
ALTER TABLE mgmt_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE cross_company_narratives ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "public_read_companies" ON companies;
CREATE POLICY "public_read_companies" ON companies
  FOR SELECT USING (TRUE);

DROP POLICY IF EXISTS "public_read_metric_snapshots" ON metric_snapshots;
CREATE POLICY "public_read_metric_snapshots" ON metric_snapshots
  FOR SELECT USING (status = 'verified');

DROP POLICY IF EXISTS "public_read_chain_nodes" ON chain_nodes;
CREATE POLICY "public_read_chain_nodes" ON chain_nodes
  FOR SELECT USING (TRUE);

DROP POLICY IF EXISTS "public_read_tech_geo_tags" ON tech_geo_tags;
CREATE POLICY "public_read_tech_geo_tags" ON tech_geo_tags
  FOR SELECT USING (is_active = TRUE);

DROP POLICY IF EXISTS "public_read_bull_bear_cases" ON bull_bear_cases;
CREATE POLICY "public_read_bull_bear_cases" ON bull_bear_cases
  FOR SELECT USING (TRUE);

DROP POLICY IF EXISTS "public_read_mgmt_profiles" ON mgmt_profiles;
CREATE POLICY "public_read_mgmt_profiles" ON mgmt_profiles
  FOR SELECT USING (TRUE);

DROP POLICY IF EXISTS "public_read_narratives" ON cross_company_narratives;
CREATE POLICY "public_read_narratives" ON cross_company_narratives
  FOR SELECT USING (TRUE);

-- staged_metric_snapshots intentionally has NO public read policy.
-- Only the service_role (the nightly robot / you) can see staging data.
