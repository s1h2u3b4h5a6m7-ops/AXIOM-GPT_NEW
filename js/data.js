/* ============================================================================
   InvestorLens India — data.js  (THE WAITER)
   The ONE file that knows where the data comes from. Every other file just uses
   SEED / CHAINS / MGMT / MARKET_CAP_CR / HIGHER_IS_BETTER and never asks where
   they came from.

   Phase 1 (now):  fetch the local JSON seed files in /data.
   Phase 2 (next): swap the body of loadData() to read from Supabase instead —
                   and NOTHING else in the app has to change. That clean seam is
                   the reason the whole project was split into files.
   Carved for Plan v3 §4.
   ============================================================================ */

// These become the app's global data once loadData() finishes. They start empty
// and are filled in before init() runs, so every render function sees real data.
var SEED = {};
var CHAINS = {};
var MGMT = {};
var MARKET_CAP_CR = {};
var HIGHER_IS_BETTER = {};

// Fetch one JSON file and hand back its parsed contents. Throws loudly (with the
// file name) if the file is missing or malformed, so a broken seed can't fail
// silently — it shows up in the console and the boot error banner.
function fetchJson(name) {
  var url = CONFIG.dataDir + '/' + name;
  return fetch(url).then(function (res) {
    if (!res.ok) throw new Error('could not load ' + url + ' (HTTP ' + res.status + ')');
    return res.json();
  });
}

// Load every seed file (in parallel) and publish the results as the app globals.
// Returns a promise; the bootstrap in index.html waits for it, then calls init().
function loadData() {
  if (CONFIG.dataSource === 'local-json') {
    return Promise.all([
      fetchJson('companies.json'),
      fetchJson('chains.json'),
      fetchJson('mgmt.json'),
      fetchJson('market_caps.json'),
      fetchJson('metric_meta.json')
    ]).then(function (r) {
      SEED = r[0];
      CHAINS = r[1];
      MGMT = r[2];
      MARKET_CAP_CR = r[3];
      HIGHER_IS_BETTER = r[4];
      // expose on window too, so bare references resolve no matter the load order
      window.SEED = SEED; window.CHAINS = CHAINS; window.MGMT = MGMT;
      window.MARKET_CAP_CR = MARKET_CAP_CR; window.HIGHER_IS_BETTER = HIGHER_IS_BETTER;
      return { source: 'local-json', companies: Object.keys(SEED).length };
    });
  }

  // Phase 2 will add: if (CONFIG.dataSource === 'supabase') { ...read the 5 tables... }
  return Promise.reject(new Error('unknown dataSource: ' + CONFIG.dataSource));
}
