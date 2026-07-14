-- ============================================================================
-- InvestorLens India — Session N (14 Jul 2026)
-- Concern: cross_company_narratives renders ALPHABETICALLY (banca → holding →
--          metals-auto → power) because js/data.js:198 orders by `id.asc` and
--          `id` is a text slug. Give the table a sort key of its own.
--
-- Shape change, so it walks the CONTRACT lane: menu (this file) → table →
-- waiter (data.js) → UI. SQL FIRST. If data.js ships before this runs, every
-- page load 400s on an unknown order column and the map page goes blank.
--
-- Promise of this file: ZERO visual change. It writes today's live order into
-- the new column (10, 20, 30, 40). The map page looks identical afterwards.
-- The order only changes when YOU renumber the rows — Paste 3, whenever you
-- want it.
--
-- Supabase SQL Editor only shows the LAST statement's result grid, so this is
-- three separate pastes, each ending in its own judge.
-- ============================================================================


-- ============================================================================
-- PASTE 1 of 3 — PRE-FLIGHT JUDGE (reads nothing, writes nothing)
-- Expect: 4 rows, in this order: banca, holding, metals-auto, power.
--         column_exists = false on all 4 rows.
-- If column_exists is already true, PASTE 2 is still safe (it is idempotent) —
-- it will simply leave the existing numbers alone.
-- ============================================================================

SELECT
  n.id,
  n.kind,
  ROW_NUMBER() OVER (ORDER BY n.id ASC) AS position_today,
  EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'cross_company_narratives'
      AND column_name = 'display_order'
  ) AS column_exists
FROM cross_company_narratives n
ORDER BY n.id ASC;


-- ============================================================================
-- PASTE 2 of 3 — THE MIGRATION (add the column + write today's order into it)
--
-- Part A adds a NULLABLE integer. Nullable on purpose, two reasons:
--   1. the 1_SCHEMA/2_DATA parachute pair does not know this column, so NOT
--      NULL would make a rebuild fail on re-run (same reasoning as verified_on);
--   2. a brand-new story inserted with no number is not a lie — it is "not
--      placed yet", and `nullslast` parks it at the END of the map page instead
--      of letting it barge into the middle alphabetically.
--
-- Part B numbers the rows in 10s, in TODAY'S CURRENT ORDER (id.asc). Gaps of
-- 10 mean a fifth story can slot between #2 and #3 as 25 — no renumbering of
-- anything else. It only touches rows where display_order IS NULL, and it
-- starts counting after the current MAX, so re-running it can never clobber
-- your numbers and can never collide with them.
--
-- Expect after Paste 2: 4 rows, display_order 10/20/30/40, nulls_left = 0.
-- ============================================================================

-- Part A — the column
ALTER TABLE cross_company_narratives
  ADD COLUMN IF NOT EXISTS display_order integer;

COMMENT ON COLUMN cross_company_narratives.display_order IS
  'Map-page sort key. Lower renders first. NULL = not placed yet (renders last). Spaced by 10 so rows can be inserted between without renumbering. Deliberately NOT unique: a temporary tie during a renumber must not throw — data.js breaks ties on id.asc.';

-- Part B — backfill by the order the site shows TODAY (zero visual change)
WITH ranked AS (
  SELECT
    id,
    COALESCE((SELECT MAX(display_order) FROM cross_company_narratives), 0)
      + 10 * ROW_NUMBER() OVER (ORDER BY id ASC) AS n
  FROM cross_company_narratives
  WHERE display_order IS NULL
)
UPDATE cross_company_narratives c
   SET display_order = r.n
  FROM ranked r
 WHERE c.id = r.id;

-- Judge — this is EXACTLY the order data.js will ask for after the JS ships
SELECT
  n.display_order,
  n.id,
  n.kind,
  n.title,
  (SELECT COUNT(*) FROM cross_company_narratives WHERE display_order IS NULL) AS nulls_left,
  (SELECT COUNT(*) FROM cross_company_narratives) AS total_rows
FROM cross_company_narratives n
ORDER BY n.display_order ASC NULLS LAST, n.id ASC;


-- ============================================================================
-- PASTE 3 of 3 — OPTIONAL, AND ONLY WHEN YOU WANT THE ORDER TO CHANGE.
--
-- This is the ONLY statement in the whole file that moves anything on screen.
-- The order below restores the curated sequence the map page had before the
-- Phase-4 flip (the order the old hardcoded CHAINMAP literal in js/map.js is
-- still written in): the two flow stories first, the two ownership stories
-- after. Change the numbers to any order you like — that is the whole point of
-- the column.
--
-- Safe to run before OR after the data.js ship. Re-runnable: it sets absolute
-- numbers, so running it twice gives the same result.
--
-- Expect: 4 rows in the order power, metals-auto, holding, banca.
-- ============================================================================

UPDATE cross_company_narratives SET display_order = 10 WHERE id = 'power';
UPDATE cross_company_narratives SET display_order = 20 WHERE id = 'metals-auto';
UPDATE cross_company_narratives SET display_order = 30 WHERE id = 'holding';
UPDATE cross_company_narratives SET display_order = 40 WHERE id = 'banca';

SELECT
  n.display_order,
  n.id,
  n.kind,
  n.title,
  (SELECT COUNT(*) FROM cross_company_narratives WHERE display_order IS NULL) AS nulls_left
FROM cross_company_narratives n
ORDER BY n.display_order ASC NULLS LAST, n.id ASC;
