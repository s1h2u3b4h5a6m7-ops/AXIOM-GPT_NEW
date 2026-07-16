-- ===========================================================================
-- InvestorLens India -- 2026-07-16_snapshot_prune.sql
-- ===========================================================================
-- CONCERN (one breath): metric_snapshots gains ~3,200 'market_cap_cr' rows per
-- month forever (one dated row per company per night, written by refresh.py).
-- This prune caps that growth WITHOUT losing signal and WITHOUT changing one
-- pixel the site shows.
--
-- KEEPS, for metric_key = 'market_cap_cr' ONLY:
--   * every row from the last 90 days               -> full recent daily detail
--   * the FIRST recorded row of each calendar month  -> permanent monthly
--     per company, kept FOREVER                         trend, never lost
-- DELETES, for metric_key = 'market_cap_cr' ONLY:
--   * rows older than 90 days that are NOT a company's first-of-month row
-- NEVER TOUCHES:
--   * any row where metric_key <> 'market_cap_cr' (all 492 hand-verified
--     understanding bindings are untouched)
--   * the NEWEST market_cap_cr row per company (always < 90 days old) -> the
--     market cap every visitor sees is unchanged
--
-- CHIP INVARIANT BY DESIGN: market_cap_cr is not part of metric_order, so the
-- 492 cannot move; companies/forces/promoter counts live in other tables.
--
-- IDEMPOTENT: re-running immediately deletes 0 further rows. This is the
-- standing maintenance prune -- safe to re-run any time.
--
-- Generated: 2026-07-16
-- ===========================================================================

-- Capture BEFORE counts (read) so one final grid can show before/after/deleted.
DROP TABLE IF EXISTS _prune_before;
CREATE TEMP TABLE _prune_before AS
SELECT
  COUNT(*) FILTER (WHERE metric_key =  'market_cap_cr')  AS mcap_rows,
  COUNT(*) FILTER (WHERE metric_key <> 'market_cap_cr')  AS other_rows,
  COUNT(*)                                               AS total_rows
FROM metric_snapshots;

-- The prune.
WITH keep_first_of_month AS (
  SELECT DISTINCT ON (ticker, date_trunc('month', snapshot_date)) id
  FROM   metric_snapshots
  WHERE  metric_key = 'market_cap_cr'
  ORDER  BY ticker, date_trunc('month', snapshot_date), snapshot_date ASC, id ASC
)
DELETE FROM metric_snapshots ms
WHERE  ms.metric_key = 'market_cap_cr'
  AND  ms.snapshot_date < CURRENT_DATE - INTERVAL '90 days'
  AND  NOT EXISTS (SELECT 1 FROM keep_first_of_month k WHERE k.id = ms.id);

-- Final judge: one row, before vs after, with the safety proof column.
SELECT
  b.mcap_rows                       AS mcap_before,
  a.mcap_rows                       AS mcap_after,
  b.mcap_rows - a.mcap_rows         AS mcap_deleted,
  b.other_rows                      AS other_before,
  a.other_rows                      AS other_after,
  (b.other_rows = a.other_rows)     AS other_rows_unchanged,
  b.total_rows                      AS total_before,
  a.total_rows                      AS total_after
FROM _prune_before b
CROSS JOIN (
  SELECT
    COUNT(*) FILTER (WHERE metric_key =  'market_cap_cr')  AS mcap_rows,
    COUNT(*) FILTER (WHERE metric_key <> 'market_cap_cr')  AS other_rows,
    COUNT(*)                                               AS total_rows
  FROM metric_snapshots
) a;
