-- ============================================================================
-- InvestorLens — sql/2026-07-11_mgmt_batch7_consumer_newage.sql
-- Session L · Mgmt gaps, Batch 7 — THE LAST BATCH:
--   ASIANPAINT · NESTLEIND · TATACONSUM · TITAN · TRENT · INDIGO · ETERNAL
-- After this file, all 107 companies carry a verified promoter record.
--
-- ⚠ CHAINED FILE: paste order is Batch 5 → 6 → 7. This file's pre-flight
-- expects Batches 5 and 6 to have already run (100 rows). If Judge 0a shows
-- 89 or 94, STOP and paste the earlier batches first.
--
-- Machine-researched with named sources; founder-verifies every line before
-- pasting.
--
-- IDEMPOTENT — WHERE NOT EXISTS inserts; safe to run twice.
-- Pre-flight: expect 100 / 0 / 7. Post-flight: expect 107 / 7 / 0.
--
-- TWO ROWS NEED YOUR EYES BEFORE PASTING:
--   INDIGO      promoter_pct 40.48 is DERIVED (IGE ~35.7% + residual RG Group
--               ~4.78% after the Aug-2025 block sale), not read off a single
--               Mar-2026 SHP. It is the softest headline number in all seven
--               batches. Open the Mar-2026 SHP and replace with the exact
--               figure before pasting. The [VERIFY] marker will not let you
--               forget.
--   ASIANPAINT  the pledge is real, live, and moving (creations AND releases
--               through H1-2026). The share counts below are from individual
--               Reg 31 event filings; confirm against the Jun-2026 SHP
--               encumbrance table.
--   And one first: ETERNAL has promoter_pct = 0. No promoter exists. That is
--   an answer, not a blank (Flag-5 family of lessons).
--
-- verified_on is written ONCE (Part B).
-- ============================================================================

-- ── PART A · pre-flight (read-only) ─────────────────────────────────────────
-- Judge 0a — expect exactly 100. If 89 or 94, STOP: paste Batches 5/6 first.
SELECT COUNT(*) AS mgmt_rows_before FROM mgmt_profiles;

-- Judge 0b — expect ZERO rows.
SELECT ticker FROM mgmt_profiles
 WHERE ticker IN ('ASIANPAINT','NESTLEIND','TATACONSUM','TITAN','TRENT','INDIGO','ETERNAL');

-- Judge 0c — expect exactly 7.
SELECT COUNT(*) AS companies_present FROM companies
 WHERE ticker IN ('ASIANPAINT','NESTLEIND','TATACONSUM','TITAN','TRENT','INDIGO','ETERNAL');

-- ── PART B · the seven records ──────────────────────────────────────────────
INSERT INTO mgmt_profiles
       (ticker, promoter_pct, promoter_who, pledge_note, capital_note,
        as_of, source_note, verified_on)
SELECT v.ticker, v.promoter_pct, v.promoter_who, v.pledge_note, v.capital_note,
       v.as_of, v.source_note, DATE '2026-07-11'
  FROM (VALUES

  -- 1 ── ASIANPAINT · three families, eighty years, and a live pledge ─────────
  ('ASIANPAINT', 52.63,
   'The founding families — Choksi, Dani and Vakil — into the fourth generation, mostly through unlisted holding companies rather than personal names: bodies corporate hold 42.07% of the company (Smiti Holding, Sattva Holding and peers), individuals and HUFs 10.48%, trusts 0.08%. Total block 50,47,85,198 shares. No single family controls it; the three-family concert does.',
   'A live, working pledge — created and released in real time through 2026. Smiti Holding & Trading Co had 3,53,15,000 shares (3.68% of the company) in the pledged category per its own Reg 31 filings; Sattva Holding pledged a further 5,00,000 shares to Bajaj Finance on 2 Mar 2026 as loan collateral; a 15-Jun-2026 Smiti filing discloses further pledge-and-release activity. The Vakil branch separately filed an FY26 Reg 31(4) confirming no NEW encumbrances on its side. So: part of the concert borrows against the stock as routine treasury, part does not. Confirm the aggregate against the Jun-2026 SHP encumbrance table — this cell moves.',
   'The uncomfortable fact is outside the register: GRASIM (another row on this platform) is spending ₹10,000 cr building Birla Opus to attack exactly this company, and Asian Paints'' own commentary has turned cautious — mixed analyst verdicts, price hikes against demand risk, new products at ~17% of revenue as the defensive play. The promoter block itself did not move: 52.63% at Mar-2026, equity capital unchanged at 95,91,97,790 shares. Final FY26 dividend approved at the 9-Jul-2026 AGM, payment from 13 Jul 2026.',
   'Mar 2026',
   'Asian Paints Integrated Annual Report FY26 SHP (promoter 52.63% / 50,47,85,198 shares; bodies corporate 42.07%, individuals 10.48%) + Smiti Holding Reg 31 filings (3,53,15,000 shares pledged; 15-Jun-2026 pledge/release) + Sattva Reg 31 (5,00,000 shares to Bajaj Finance, 2-Mar-2026) + Vakil-branch FY26 Reg 31(4) + AGM notices'),

  -- 2 ── NESTLEIND · the promoter is a Swiss multinational ────────────────────
  ('NESTLEIND', 62.76,
   'Nestlé S.A. of Vevey, Switzerland — the global parent, through its holding entities. This is the platform''s cleanest example of an MNC-parent promoter: one owner, no family tree, no holding-company lattice, and the "promoter" cannot die, divorce, or divide an estate. Succession risk is a board decision in Switzerland, not a family event in India.',
   'None. An MNC parent pledging its subsidiary''s shares is essentially unheard of, and the trackers show nil, every quarter.',
   'A royalty-and-dividend machine by design: the parent takes a licence fee on sales and the company pays out most of what remains — a ₹2 special dividend was declared 3 Jul 2026 (record 10 Jul, payment from 30 Jul). Growth capex continues in absolute terms (₹225 cr for a new Munch line at Sanand), but the structural fact is that the majority owner''s economics flow partly OUTSIDE the dividend, via royalty — minority shareholders should always read the royalty rate alongside the payout ratio. FY26 revenue ₹23,155 cr, profit ₹3,545 cr.',
   'Mar 2026',
   'Kotak Neo / Screener Mar-2026 (promoter 62.8%; report 62.76%) + special-dividend disclosure 3-Jul-2026 + Sanand capex announcement + FY26 results (Apr-2026)'),

  -- 3 ── TATACONSUM · the Tata pattern, consumer edition ──────────────────────
  ('TATACONSUM', 33.84,
   'Tata Sons Pvt Ltd (~29%) with Tata Investment Corporation and other group entities to 33.84% — the standard Tata architecture: one-third promoter, philanthropies behind Tata Sons, and the operating company left to professional management. Compare the TATASTEEL, TITAN and TRENT rows: same fingerprint, four industries.',
   'None flagged. Nil promoter pledge on trackers — the Tata Sons practice, consistent across the group.',
   'The register is still; the portfolio is not. Tata Consumer has spent the decade assembling brands (Tata Tea + Salt legacy, Soulfull, Capital Foods, Organic India, NourishCo) and pruning structure — the wholly-owned Tata Tea Holdings was struck off effective 29 Jun 2026, one more shell removed. Five-year sales growth of ~12% is the number critics point at; the bet is that distribution scale eventually compounds faster than the FMCG incumbents can defend. Promoter percentage has barely moved through all of it.',
   'Mar 2026',
   'Screener Mar-2026 (promoter 33.8%) + tracker consensus 33.84% + Tata Tea Holdings strike-off disclosure, 30-Jun-2026 + acquisition history from company filings'),

  -- 4 ── TITAN · the biggest promoter is a state government body ──────────────
  ('TITAN', 52.90,
   'Two promoters, and the LARGER one is not the Tatas: the Tamil Nadu Industrial Development Corporation (TIDCO), a state government undertaking, holds ~27.88%, while the Tata Group holds ~25.02% (Tata Sons ~21%). The 1984 joint venture never unwound — TIDCO put in ~₹10 cr and land in Hosur during the Licence Raj, simply never sold, and now sits on a stake worth on the order of ₹1 lakh cr. A state corporation quietly owning the largest slice of India''s premier lifestyle company is one of the strangest facts on this platform.',
   'None flagged. Nil promoter pledge on trackers — neither a state corporation nor Tata Sons borrows against this stake.',
   'Neither promoter has meaningfully moved in decades, which is itself the story: a frozen two-party register above a business that reinvests everything into store rollout (Tanishq, CaratLane, watches, eyewear). Governance nuance worth recording: Tata runs the company with the SMALLER stake — management control and brand sit with Tata, patience and the larger claim on value sit with the state. When TIDCO ever decides to monetise, it will be one of the largest single-shareholder events in Indian market history; there is no sign of it yet.',
   'Mar 2026',
   'Screener FY26 company notes (TIDCO ~28%, Tata Group ~25% incl. Tata Sons ~21%) + Business Today, Jun-2026 (TIDCO history, 27.88%) + tracker consensus ~52.9% combined promoter block'),

  -- 5 ── TRENT · the compounder the market fell out of love with ──────────────
  ('TRENT', 37.01,
   'Tata Sons Pvt Ltd at 32.5% plus Tata Investment Corporation at 4.3% — 37.01% in the familiar Tata shape. Founded as Lakmé''s successor by Simone Tata; her son Noel Tata (now also chairman of Tata Trusts) chairs Trent, which gives this particular Tata company an unusually direct family link back to the top of the group.',
   'None flagged. Nil promoter pledge on trackers.',
   'Ownership did nothing; the stock did a lot: down ~19% over the year even as revenue crossed ₹20,000 cr and profit ₹1,721 cr — the market repricing the growth rate of Zudio, not doubting the owner. The company keeps paying people in equity rather than the promoter''s shares: 11,13,500 fresh ESOPs granted 19 Jun 2026 at ₹2,652 exercise price. A flat promoter line through a violent derating is what long ownership looks like; the row to reread in a year.',
   'Mar 2026',
   'Screener Mar-2026 (promoter 37.0%; Tata Sons 32.5% + Tata Investment 4.3%) + ESOP grant disclosure 19-Jun-2026 + AGM outcome 23-Jun-2026'),

  -- 6 ── INDIGO · a promoter walking out the door, on schedule, in public ─────
  ('INDIGO', 40.48,
   'Two co-founding groups moving in opposite directions. Rahul Bhatia''s InterGlobe Enterprises (IGE Group) holds steady at ~35.7% and runs the airline. Rakesh Gangwal''s RG Group (Rakesh and Shobha Gangwal, Dr Asha Mukherjee, the Chinkerpoo Family Trust) is EXITING on a stated five-year plan since his Feb-2022 board resignation: ~3.4% sold May-2025, ~3.1% in an Aug-2025 block at ₹5,808, roughly ₹45,000+ cr raised across sales, residual ~4.78% and falling. [VERIFY: this 40.48% total is DERIVED (35.7 + 4.78), not read from the Mar-2026 SHP — replace with the exact filed figure before pasting.]',
   'None created in FY26 beyond prior disclosures: Rakesh Gangwal and the RG Group filed the Reg 31(4) confirmation on 4 Apr 2026 (same careful "other than those already disclosed" construction as ADANIPORTS — check the SHP table for any legacy line). IGE side: nil flagged on trackers.',
   'A promoter selling ~₹45,000 cr of stock over four years, announced in advance, executed in blocks, with the stock broadly absorbing it — this is what an orderly promoter exit looks like, and it is the reference case for the platform. Each RG sale mechanically shrinks the promoter block without any change of control, since Bhatia''s side holds still. Business context for the same year: FY26 net loss narrowed, ~900-aircraft order book, international mix targeted at 40% by FY30. The promoter_pct on this row has a built-in downward drift; re-verify it every quarter until RG reaches zero.',
   'Mar 2026',
   'RG Group Reg 31(4) filing, 4-Apr-2026 + NDTV Profit / Elite Wealth block-deal coverage (Aug-2025: 1.21 cr shares at ₹5,808, ~₹7,028 cr; residual 4.78%) + IGE ~35.7% tracker consensus + FY26 results commentary — HEADLINE % DERIVED, VERIFY AGAINST MAR-2026 SHP'),

  -- 7 ── ETERNAL · the first row on this platform with no promoter at all ─────
  ('ETERNAL', 0,
   'NOBODY — and that is the record, not a gap. Eternal Ltd (renamed from Zomato Ltd; same listed entity) is professionally managed with NO promoter: founder and CEO Deepinder Goyal is classified as a public shareholder, and no person or entity is designated promoter in the SHP. The register is entirely institutions and public. On this platform every governance question that the promoter_pct column usually answers — alignment, succession, pledge risk — has to be answered differently here: through the board, ESOP policy, and founder-CEO incentives instead.',
   'Not applicable — there is no promoter to pledge. (Recorded explicitly so the nil is never misread as an unresearched blank.)',
   'Capital allocation without a promoter means the founder answers to the register every quarter with no controlling cushion: Zomato''s food-delivery cash engine funds Blinkit''s land-grab losses, and the market judges the trade in real time. The Mar-2025 rename to Eternal marks the diversification (food delivery, Blinkit quick-commerce, Hyperpure, District) — read pre-rename comparisons as the same entity, unlike the TMPV case where the rename crossed a demerger. The absence in the promoter column IS this company''s governance model.',
   'Mar 2026',
   'Eternal Ltd SHP via IIFL (no promoter category; renamed from Zomato with MoA/AoA amendment) + exchange filings on the rename + quarterly results disclosures')

  ) AS v(ticker, promoter_pct, promoter_who, pledge_note, capital_note,
         as_of, source_note)
 WHERE NOT EXISTS (SELECT 1 FROM mgmt_profiles m WHERE m.ticker = v.ticker);

-- ── PART C · the judges ─────────────────────────────────────────────────────
-- Judge 1 — expect exactly 107. FULL COVERAGE: every company has a record.
SELECT COUNT(*) AS mgmt_rows_after FROM mgmt_profiles;

-- Judge 2 — expect 7 rows, all 2026-07-11, all 'Mar 2026':
-- 52.63 / 0 / 40.48 / 62.76 / 33.84 / 52.90 / 37.01. ETERNAL's 0 is correct.
SELECT ticker, promoter_pct, as_of, verified_on
  FROM mgmt_profiles
 WHERE ticker IN ('ASIANPAINT','NESTLEIND','TATACONSUM','TITAN','TRENT','INDIGO','ETERNAL')
 ORDER BY ticker;

-- Judge 3 — expect 0.
SELECT COUNT(*) AS still_null FROM mgmt_profiles WHERE verified_on IS NULL;

-- Judge 4 — expect 3 rows: 2026-07-02 → 64 · 2026-07-09 → 8 · 2026-07-11 → 35.
SELECT verified_on, COUNT(*) AS records
  FROM mgmt_profiles GROUP BY verified_on ORDER BY verified_on;

-- Judge 5 — expect 0. (promoter_pct = 0 passes: the check is NULL/range, and
-- zero is a legitimate recorded answer for ETERNAL.)
SELECT COUNT(*) AS malformed FROM mgmt_profiles
 WHERE promoter_who IS NULL OR promoter_who = ''
    OR pledge_note  IS NULL OR pledge_note  = ''
    OR capital_note IS NULL OR capital_note = ''
    OR as_of        IS NULL OR as_of        = ''
    OR source_note  IS NULL OR source_note  = ''
    OR promoter_pct IS NULL
    OR promoter_pct < 0 OR promoter_pct > 100;

-- Judge 6 — THE BACKLOG-CLOSURE JUDGE. Expect 0: every ticker in companies
-- now has a mgmt_profiles row.
SELECT COUNT(*) AS companies_still_missing_mgmt
  FROM companies c
 WHERE NOT EXISTS (SELECT 1 FROM mgmt_profiles m WHERE m.ticker = c.ticker);
