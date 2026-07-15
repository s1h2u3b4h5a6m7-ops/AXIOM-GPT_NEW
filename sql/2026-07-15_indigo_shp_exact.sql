-- ============================================================================
-- InvestorLens India — Session P (15 Jul 2026)
-- Concern: replace INDIGO's DERIVED promoter figure (40.48) with the FILED
--          Mar-2026 SHP figure. This retires the last item owed from the
--          Session M repair (its Part D).
--
-- ⛔ HARD GATE — DO NOT RUN PASTE 2 UNTIL THE FOUNDER HAS VERIFIED 41.57%
--    AGAINST THE PRIMARY EXCHANGE FILING (NSE or BSE SHP, quarter ended
--    31-Mar-2026, row "Total Shareholding of Promoter and Promoter Group").
--    The candidate figure below was researched from aggregators (Trendlyne
--    entity-level table, cross-checked against IIFL; Kotak's rounded 41.6% is
--    consistent). Aggregators are the FIRST source. The exchange filing is
--    the SECOND. Mission lock: nothing enters the database on one source.
--
-- CANDIDATE FIGURE (to be confirmed): 41.57% = 160,732,247 shares
--   Indian side  35.72%:  InterGlobe Enterprises Pvt Ltd 35.69%
--                         + Bhatia-family individuals 0.03%
--                           (Kapil 0.01, Rahul 0.01, Rohini 0.00, Alok Mehta 0.00)
--   Foreign side  5.85%:  Rakesh Gangwal 4.53%
--                         + Chinkerpoo Family Trust 1.32%
--   Sum check: 35.72 + 5.85 = 41.57 ✓  (shares: 137,987,201 + 108,140
--              + 17,530,493 + 5,106,413 = 160,732,247 ✓)
--
-- WHY THIS FILE IS BIGGER THAN PART D SAID IT WOULD BE:
--   Part D of the repair file updated promoter_pct + appended to source_note.
--   But the number 40.48 / 4.78 lives in FOUR places in the production row:
--     1. promoter_pct                    (the headline number)
--     2. promoter_who — "residual ~4.78% and falling"
--     3. promoter_who — the "One honest caveat..." sentence (40.48, 35.7, 4.78)
--     4. source_note  — "(35.7 + 4.78) ... pending founder verification"
--   Running Part D verbatim would set the headline to 41.57 while the prose
--   underneath still called it "a derived 40.48" — the page would contradict
--   itself. This file fixes all four, each with a value-guarded replace, so
--   every statement is idempotent and can never fire twice or fire on the
--   wrong text.
--
-- WHY THE FILED FIGURE DIFFERS FROM THE DERIVED ONE (worth understanding):
--   The old derivation (35.7 + 4.78 = 40.48) undercounted the RG side: the
--   Chinkerpoo Family Trust's 1.32% was missing from the residual. Filed RG
--   side is 4.53 (Rakesh) + 1.32 (trust) = 5.85%.
--
-- Parachute note: on a full rebuild, batch7 re-inserts 40.48 (guarded insert),
-- the Session M repair rewrites the sentences, and THIS file — replaying after
-- both in filename order — lands the filed figure. batch7's judge comment
-- ("expect ... 40.48 ...") is true at its point in the replay and superseded
-- by this file's judge. Two pastes; the editor shows only the last grid.
-- ============================================================================


-- ============================================================================
-- PASTE 1 of 2 — PRE-FLIGHT JUDGE (reads only)
-- Expect exactly 1 row: promoter_pct = 40.48, who_has_caveat = true,
-- note_pending = true. If promoter_pct is already 41.57, this file has
-- already run — stop, nothing to do.
-- ============================================================================

SELECT ticker,
       promoter_pct,
       promoter_who LIKE '%One honest caveat: the 40.48% headline is a derived figure%' AS who_has_caveat,
       promoter_who LIKE '%residual ~4.78%% and falling%'                               AS who_has_stale_residual,
       source_note  LIKE '%pending founder verification%'                               AS note_pending
  FROM mgmt_profiles
 WHERE ticker = 'INDIGO';


-- ============================================================================
-- PASTE 2 of 2 — THE FIX (⛔ only after the founder's primary-source check)
-- If you verify on a date other than 15-Jul-2026, change the date in D4
-- before pasting — a wrong confirmation date is its own small lie.
-- ============================================================================

-- D1 · the headline number, guarded on its current wrong value
UPDATE mgmt_profiles
   SET promoter_pct = 41.57
 WHERE ticker = 'INDIGO'
   AND promoter_pct = 40.48;

-- D2 · promoter_who: stale residual sentence → filed decomposition
UPDATE mgmt_profiles
   SET promoter_who = replace(promoter_who,
     'residual ~4.78% and falling.',
     'residual 5.85% (Rakesh Gangwal 4.53% + the Chinkerpoo Family Trust 1.32%) and falling.')
 WHERE ticker = 'INDIGO'
   AND promoter_who LIKE '%residual ~4.78%% and falling.%';

-- D3 · promoter_who: the caveat sentence has done its honest job — retire it
--      with the confirmation, keeping the forward-looking drift warning.
UPDATE mgmt_profiles
   SET promoter_who = replace(promoter_who,
     'One honest caveat: the 40.48% headline is a derived figure — IGE''s ~35.7% plus the RG residual ~4.78% — pending the exact Mar-2026 SHP number, and it will drift lower each quarter until the RG Group reaches zero.',
     'The 41.57% headline is the filed Mar-2026 SHP figure (Indian promoters 35.72% + foreign promoters 5.85%), and it will drift lower each quarter until the RG Group reaches zero.')
 WHERE ticker = 'INDIGO'
   AND promoter_who LIKE '%One honest caveat: the 40.48%% headline is a derived figure%';

-- D4 · source_note: "pending" clause → confirmed clause. (Part D prescribed an
--      append; a replace is used instead so the note cannot say "pending" and
--      "confirmed" in the same breath.)
UPDATE mgmt_profiles
   SET source_note = replace(source_note,
     '— headline % derived (35.7 + 4.78); exact Mar-2026 SHP figure pending founder verification',
     '— 41.57% read from the Mar-2026 SHP filing (NSE/BSE), founder-verified 15-Jul-2026')
 WHERE ticker = 'INDIGO'
   AND source_note LIKE '%pending founder verification%';

-- Judge — expect exactly 1 row:
--   promoter_pct 41.57 · caveat_gone true · stale_residual_gone true ·
--   note_confirmed true · derived_mentions 0 · rows_107 = 107
SELECT ticker,
       promoter_pct,
       promoter_who NOT LIKE '%One honest caveat%'          AS caveat_gone,
       promoter_who NOT LIKE '%~4.78%'                      AS stale_residual_gone,
       source_note  LIKE '%founder-verified%'               AS note_confirmed,
       (SELECT COUNT(*) FROM mgmt_profiles
         WHERE promoter_who LIKE '%derived figure%'
            OR source_note  LIKE '%pending founder verification%') AS derived_mentions,
       (SELECT COUNT(*) FROM mgmt_profiles)                 AS rows_107
  FROM mgmt_profiles
 WHERE ticker = 'INDIGO';
