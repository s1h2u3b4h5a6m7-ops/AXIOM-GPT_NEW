/* ============================================================================
   InvestorLens India — data.js  (THE WAITER, Phase 4 edition)
   The ONE file that knows where the data comes from. Every other file just uses
   SEED / CHAINS / CHAINMAP / MGMT / MARKET_CAP_CR / HIGHER_IS_BETTER and never
   asks where they came from.

   Phase 4: the kitchen was reorganised into EIGHT tables (companies,
   metric_snapshots, chain_nodes, tech_geo_tags, bull_bear_cases,
   mgmt_profiles, cross_company_narratives, + a staging table the site never
   reads). This file translates those eight tables back into the EXACT same
   in-memory shapes the UI has eaten since Phase 1 — so no other file changes.

   The big translations, in plain words:
   • market cap is no longer a column on the company — it is a dated row in
     metric_snapshots (metric_key = 'market_cap_cr'). We take the NEWEST row
     per company. Older rows stay behind for future trend charts.
   • every other metric also lives as dated snapshot rows; the UI shows the
     newest reading per (company, metric). The DISPLAY ORDER of metrics is
     the order the rows were first written (row id order) — verified equal
     to the old hand-curated metric_order for all 58 original companies.
   • bull/bear points moved out of the company row into bull_bear_cases
     (exactly 3 + 3 per company, case_order 1..3). We take the newest
     snapshot_date per company.
   • chain directions are stored as 'upstream'/'downstream' and translated
     back to the 'up'/'down' the UI expects.
   • the 4 inter-company map stories now live in cross_company_narratives
     (JSONB) and become CHAINMAP — new stories can be added as database
     rows, no code shipped.

   EMERGENCY PARACHUTE: there is no local-JSON fallback any more (the /data
   folder was retired). If this file ever misbehaves after the Phase-4 flip,
   the rollback is: revert the commit that introduced it (GitHub → repo →
   Commits → this commit → Revert), which restores the old 5-table waiter —
   AND the old tables must still hold their rows (i.e. before 2_DATA ran,
   or after restoring them from the weekly backup).
   ============================================================================ */

// These become the app's global data once loadData() finishes. They start empty
// and are filled in before init() runs, so every render function sees real data.
var SEED = {};
var CHAINS = {};
var CHAINMAP = [];
var MGMT = {};
var MARKET_CAP_CR = {};
var HIGHER_IS_BETTER = {};

// The one metric key that is NOT a business-quality metric: it feeds the
// market-cap figure in the header/cards instead of the metrics section.
var MCAP_KEY = 'market_cap_cr';

/* ---------------------------------------------------------------------------
   SUPABASE READER
   Supabase exposes every table over plain HTTPS (PostgREST). We ask politely
   with the read-only anon key; Row Level Security on the server means that
   key can only look, never touch — and it silently hides any snapshot row
   that is not status='verified' and any tag that is not is_active. So the
   site can only ever show human-verified rows, by construction.
--------------------------------------------------------------------------- */

// Pull EVERY row of one table, 1,000 at a time (Supabase's page cap), in a
// stable order. metric_snapshots will grow nightly once robot v2 runs; this
// same loop just keeps paging until the table runs out.
function fetchTable(table, order) {
  var base = CONFIG.supabaseUrl + '/rest/v1/' + table + '?select=*&order=' + order;
  function page(from, acc) {
    return fetch(base, {
      headers: {
        apikey: CONFIG.supabaseAnonKey,
        Authorization: 'Bearer ' + CONFIG.supabaseAnonKey,
        Range: from + '-' + (from + 999)
      }
    }).then(function (res) {
      if (!res.ok) throw new Error('Supabase read failed: ' + table + ' (HTTP ' + res.status + ')');
      return res.json();
    }).then(function (batch) {
      acc = acc.concat(batch);
      return batch.length < 1000 ? acc : page(from + 1000, acc);
    });
  }
  return page(0, []);
}

// Turn the eight tables' rows back into the exact in-memory shapes the UI has
// always eaten (CONTRACT.md). One row at a time into the right pocket.
function buildFromTables(companies, snapshots, chainNodes, tags, cases, mgmt, narratives) {
  var seed = {}, caps = {}, chainsByCo = {}, mg = {}, hib = {};

  // companies → SEED skeleton (identity card + the verified sentences)
  companies.forEach(function (c) {
    seed[c.ticker] = {
      ticker: c.ticker, name: c.name, exchange: c.exchange,
      sector: c.sector, sub_sector: c.sub_sector, compare_group: c.compare_group,
      as_of: c.as_of, fetched_at: c.fetched_at, source_note: c.source_note,
      business_core: c.business_core, moat_note: c.moat_note,
      value_chain: { position: c.value_chain_position, note: c.value_chain_note },
      metric_order: [], bull: [], bear: [],
      metrics: {}, tech_geo_tags: []
    };
  });

  // metric_snapshots → three pockets at once, walking rows in id order
  // (id order = the order rows were written = the curated display order):
  //   • MCAP_KEY rows        → MARKET_CAP_CR (newest snapshot_date wins)
  //   • everything else      → c.metrics (newest wins) + c.metric_order
  //                            (first time a key appears for that company)
  //   • higher_is_better     → HIGHER_IS_BETTER (newest wins)
  // ISO dates ('2026-06-29') compare correctly as plain text.
  var mDate = {}, hDate = {}, cDate = {};
  snapshots.forEach(function (m) {
    if (m.metric_key === MCAP_KEY) {
      if (!(m.ticker in cDate) || m.snapshot_date > cDate[m.ticker]) {
        cDate[m.ticker] = m.snapshot_date;
        caps[m.ticker] = m.metric_value;
      }
      return;
    }
    if (!(m.metric_key in hDate) || m.snapshot_date > hDate[m.metric_key]) {
      hDate[m.metric_key] = m.snapshot_date;
      hib[m.metric_key] = m.higher_is_better; // true / false / null
    }
    var c = seed[m.ticker]; if (!c) return;
    if (!(m.metric_key in c.metrics)) c.metric_order.push(m.metric_key);
    var k = m.ticker + '\u00A7' + m.metric_key;
    if (!(k in mDate) || m.snapshot_date > mDate[k]) {
      mDate[k] = m.snapshot_date;
      c.metrics[m.metric_key] = { value: m.metric_value, unit: m.metric_unit,
                                  label: m.metric_label, note: m.metric_note };
    }
  });

  // tech_geo_tags → §3 real-time factors, in the order they were written.
  // (RLS already filtered out anything with is_active = false.)
  tags.forEach(function (f) {
    var c = seed[f.ticker]; if (c) c.tech_geo_tags.push({ label: f.label, type: f.tag_type });
  });

  // chain_nodes → per-company up/down links. The database speaks
  // 'upstream'/'downstream'; the UI has always spoken 'up'/'down'.
  chainNodes.forEach(function (r) {
    var e = chainsByCo[r.ticker] || (chainsByCo[r.ticker] = { up: [], down: [] });
    var node = { l: r.node_name };
    if (r.tag) node.t = r.tag;
    if (r.note) node.n = r.note;
    e[r.direction === 'upstream' ? 'up' : 'down'].push(node);
  });

  // bull_bear_cases → c.bull / c.bear. Rows arrive ordered by case_order, so
  // pushing preserves 1→2→3. If a company ever gets a re-dated set of cases,
  // only the NEWEST snapshot_date's set is shown.
  var bbDate = {};
  cases.forEach(function (b) {
    if (!(b.ticker in bbDate) || b.snapshot_date > bbDate[b.ticker]) bbDate[b.ticker] = b.snapshot_date;
  });
  cases.forEach(function (b) {
    var c = seed[b.ticker]; if (!c) return;
    if (b.snapshot_date !== bbDate[b.ticker]) return;
    c[b.case_type === 'bull' ? 'bull' : 'bear'].push(b.case_text);
  });

  // mgmt_profiles → MGMT (DB column names → the app's historical names)
  mgmt.forEach(function (m) {
    mg[m.ticker] = { promoter_pct: m.promoter_pct, who: m.promoter_who,
                     pledge: m.pledge_note, capital: m.capital_note,
                     as_of: m.as_of, src: m.source_note };
  });

  // cross_company_narratives → CHAINMAP. Columns that are NULL in the row
  // (e.g. 'pairs' on a flow story) are simply left off the object, exactly
  // like the old curated literal.
  var maps = narratives.map(function (n) {
    var ch = { id: n.id, kind: n.kind, title: n.title, blurb: n.blurb };
    if (n.stages) ch.stages = n.stages;
    if (n.flows) ch.flows = n.flows;
    if (n.pairs) ch.pairs = n.pairs;
    if (n.evidence) ch.evidence = n.evidence;
    return ch;
  });

  // publish — same globals, same shapes, new pantry
  SEED = seed; CHAINS = chainsByCo; MGMT = mg;
  MARKET_CAP_CR = caps; HIGHER_IS_BETTER = hib; CHAINMAP = maps;
  window.SEED = SEED; window.CHAINS = CHAINS; window.MGMT = MGMT;
  window.MARKET_CAP_CR = MARKET_CAP_CR; window.HIGHER_IS_BETTER = HIGHER_IS_BETTER;
  window.CHAINMAP = CHAINMAP;
}

// Load the eight tables' rows (in parallel) and publish the app globals.
// Returns a promise; the bootstrap in index.html waits for it, then calls init().
function loadData() {
  return Promise.all([
    fetchTable('companies',                'ticker.asc'),
    fetchTable('metric_snapshots',         'id.asc'),
    fetchTable('chain_nodes',              'id.asc'),
    fetchTable('tech_geo_tags',            'id.asc'),
    fetchTable('bull_bear_cases',          'ticker.asc,case_order.asc,id.asc'),
    fetchTable('mgmt_profiles',            'ticker.asc'),
    fetchTable('cross_company_narratives', 'id.asc')
  ]).then(function (r) {
    buildFromTables(r[0], r[1], r[2], r[3], r[4], r[5], r[6]);
    return { source: 'supabase', companies: Object.keys(SEED).length };
  });
}
