#!/usr/bin/env python3
# ============================================================================
# InvestorLens India — etl/refresh.py   (robot v2 — Phase 4, Session C)
# ----------------------------------------------------------------------------
# WHAT THIS SCRIPT DOES, in one breath:
#   1. Ask the database for the list of companies.
#        (This one call also PINGS Supabase, so the free project never falls
#         asleep — Supabase pauses a project only after 7 quiet days.)
#   2. For each company, ask a free public source "how big are you today?"
#        (its market capitalisation — the current ₹-value of the whole company).
#   3. Write ONE dated row per company into metric_snapshots
#        (metric_key = 'market_cap_cr', status = 'verified'), then stamp
#        companies.fetched_at = today for the companies that succeeded.
#
# WHAT CHANGED FROM v1 (the Phase-3a robot), and WHY:
#   v1 wrote onto a WHITEBOARD: it PATCHed companies.market_cap_cr, wiping
#   yesterday's number every night. Phase 4 moved market cap into a DIARY:
#   metric_snapshots keeps one dated line per night, forever, so future trend
#   charts are possible. The website (js/data.js) now reads ONLY the diary —
#   it shows the newest dated line per company. The old whiteboard column
#   still physically exists on the live table, but nothing reads it and this
#   robot no longer writes it. v2 speaks ONLY Phase-4 columns, so it would
#   also work unchanged on a database rebuilt from scratch with
#   1_SCHEMA_complete.sql (the parachute scenario).
#
# IDEMPOTENT-PER-DAY (safe to run twice, or five times, in one day):
#   metric_snapshots has no "one row per company per day" rule in the schema,
#   so before inserting, the robot DELETES today's market-cap rows for exactly
#   the tickers it is about to (re)insert — never yesterday's rows, never any
#   other metric, never a ticker it has no fresh number for. However often it
#   runs today, you end with ONE market-cap row per company for today,
#   carrying the latest fetch. History before today is never touched.
#
# WHAT THIS SCRIPT NEVER DOES  (the mission lock, Plan v3 §6/§7):
#   It never touches business_core, value_chain, moat_note, factors, or mgmt.
#   Those are the *understanding* of the business and are human-verified in
#   Claude sessions. A machine may refresh a NUMBER; only a human may change a
#   SENTENCE. Market cap here is "how big is this business," not a buy/sell call.
#   (Market cap = live price × share count: pure arithmetic inside sane fences,
#   which is why it may go in as status='verified' without a human look.)
#
# THE ONE SECRET IT NEEDS:
#   the service_role master key, read from the environment variable
#   SUPABASE_SERVICE_KEY. That variable is filled by GitHub from
#   Settings > Secrets > Actions. The key is NEVER written in this file.
# ============================================================================

import os
import sys
import time
import datetime as dt

import requests
import yfinance as yf

# ---- Fixed, PUBLIC settings ------------------------------------------------
# Safe to hardcode: this is the very same project URL already shipped inside
# the public website (js/config.js). It is not a secret. (The env override
# exists only so the test harness can point the robot at a fake database;
# GitHub Actions sets no SUPABASE_URL, so production always uses the default.)
SUPABASE_URL = os.environ.get("SUPABASE_URL",
                              "https://uhqyhsniwlgivdlxbpoj.supabase.co")
COMPANIES_ENDPOINT = SUPABASE_URL + "/rest/v1/companies"
SNAPSHOTS_ENDPOINT = SUPABASE_URL + "/rest/v1/metric_snapshots"

# ---- What a nightly market-cap row looks like -------------------------------
# The website ignores label/unit/note on market-cap rows (js/data.js reads only
# metric_value + snapshot_date for this key) — these three exist purely so the
# rows read nicely in the Supabase Table Editor. higher_is_better is left NULL:
# size is shown, never ranked.
MCAP_KEY = "market_cap_cr"
MCAP_LABEL = "Market Cap"
MCAP_UNIT = "₹ cr"
MCAP_NOTE = "auto-refreshed nightly by robot v2 (Yahoo Finance)"

# ---- Safety fences ---------------------------------------------------------
# A real Indian listed company sits comfortably inside this range (in ₹ crore).
# Anything outside is almost certainly a bad/garbled fetch, so we REFUSE it
# rather than let one junk number sit next to good, verified ones.
MIN_CR = 100                 # ₹100 crore floor
MAX_CR = 50_000_000          # ₹50 lakh crore ceiling (above the biggest Indian co)

PAUSE_SECONDS = 1.5          # be polite to the data source between requests
MAX_RETRIES = 3              # per company, on a transient hiccup / rate-limit
EARLY_ABORT_AFTER = 8        # if the FIRST 8 companies all fail in a row, assume
                             # the source is blocking us tonight and stop early.


def get_service_key():
    """Read the master key from the environment. Refuse to run without it."""
    key = os.environ.get("SUPABASE_SERVICE_KEY", "").strip()
    if not key:
        sys.exit("FATAL: SUPABASE_SERVICE_KEY is not set. In GitHub it is "
                 "supplied from Settings > Secrets > Actions.")
    return key


def auth_headers(service_key):
    # The service_role key is BOTH the apikey and the Bearer token. It bypasses
    # Row-Level-Security on purpose — which is exactly why it lives only inside
    # GitHub Secrets and never in the website or in any committed file.
    return {"apikey": service_key, "Authorization": "Bearer " + service_key}


def fetch_company_list(service_key):
    """Read every ticker + its exchange from the database.
       IMPORTANT: this request is also the nightly keep-alive PING.
       (v1 also selected the old market_cap_cr column; v2 does not, so this
        works even on a fresh database that never had that column.)"""
    resp = requests.get(
        COMPANIES_ENDPOINT,
        headers=auth_headers(service_key),
        params={"select": "ticker,exchange"},
        timeout=30,
    )
    resp.raise_for_status()          # DB unreachable => fail LOUD (GitHub emails you)
    rows = resp.json()
    print("Ping OK — database returned %d companies." % len(rows))
    return rows


def yahoo_symbol(ticker, exchange):
    """Our tickers are bare NSE symbols (e.g. 'HDFCBANK'). Yahoo wants a suffix:
       NSE -> '.NS', BSE -> '.BO'. Default to NSE when unknown."""
    suffix = ".BO" if (exchange or "").upper() == "BSE" else ".NS"
    return ticker + suffix


def fetch_market_cap_cr(symbol):
    """Return today's market cap in ₹ crore, or None if we could not get a
       number we trust. Prefers fast_info (the LIGHT endpoint), falls back to
       the heavier .info, and retries a few times on a hiccup."""
    for attempt in range(1, MAX_RETRIES + 1):
        try:
            t = yf.Ticker(symbol)
            raw = None

            # 1) fast_info: light + reliable (last_price x shares under the hood)
            fi = getattr(t, "fast_info", None)
            if fi is not None:
                try:
                    raw = fi.get("market_cap")
                except Exception:
                    raw = getattr(fi, "market_cap", None)

            # 2) fall back to the heavier .info only if needed
            if not raw:
                info = {}
                try:
                    info = t.info or {}
                except Exception:
                    info = {}
                raw = info.get("marketCap")

            if raw:
                cr = round(float(raw) / 1e7)      # INR (absolute) -> ₹ crore
                if MIN_CR <= cr <= MAX_CR:
                    return cr
                print("  %s: value %d cr is outside the sane fence, rejecting." % (symbol, cr))
                return None

        except Exception as e:
            wait = attempt * 5
            print("  %s: attempt %d failed (%s); retrying in %ds."
                  % (symbol, attempt, str(e)[:80], wait))
            time.sleep(wait)

    return None


def in_filter(tickers):
    """PostgREST's 'is the value in this list?' filter. Each ticker is wrapped
       in double quotes so names with special characters (M&M, BAJAJ-AUTO)
       travel safely inside the comma-separated list."""
    return "in.(" + ",".join('"%s"' % t for t in tickers) + ")"


def write_snapshots(service_key, caps, today):
    """Two bulk calls that make the night's diary entry.
       caps = { ticker: market cap in cr } — successes only.

       Call 1 (DELETE): remove TODAY's market-cap rows for exactly these
         tickers. On the normal 2 AM run this deletes nothing (today is a
         fresh page); on a same-day re-run it clears the rows we are about to
         replace, so the day never holds duplicates. Yesterday and earlier are
         never touched — that history is the whole point of the diary.
       Call 2 (POST): insert one fresh row per ticker. Row ids are assigned by
         the database; market-cap rows never enter metric display order
         (js/data.js keeps this key out of metric_order by design)."""
    tickers = sorted(caps)

    resp = requests.delete(
        SNAPSHOTS_ENDPOINT,
        headers=auth_headers(service_key),
        params={"metric_key": "eq." + MCAP_KEY,
                "snapshot_date": "eq." + today,
                "ticker": in_filter(tickers)},
        timeout=60,
    )
    resp.raise_for_status()

    rows = [{"ticker": t,
             "snapshot_date": today,
             "metric_key": MCAP_KEY,
             "metric_value": caps[t],
             "metric_unit": MCAP_UNIT,
             "metric_label": MCAP_LABEL,
             "metric_note": MCAP_NOTE,
             "status": "verified"} for t in tickers]
    resp = requests.post(
        SNAPSHOTS_ENDPOINT,
        headers={**auth_headers(service_key),
                 "Content-Type": "application/json",
                 "Prefer": "return=minimal"},
        json=rows,
        timeout=60,
    )
    resp.raise_for_status()


def stamp_fetched_at(service_key, tickers, today):
    """One bulk PATCH: companies.fetched_at = today, for the tickers whose
       number we just refreshed. 'Last machine touch', exactly as CONTRACT.md
       defines it. (v1 also wrote market_cap_cr and updated_at here — both are
       old-schema leftovers that nothing reads, so v2 has stopped.)"""
    resp = requests.patch(
        COMPANIES_ENDPOINT,
        headers={**auth_headers(service_key),
                 "Content-Type": "application/json",
                 "Prefer": "return=minimal"},
        params={"ticker": in_filter(sorted(tickers))},
        json={"fetched_at": today},
        timeout=60,
    )
    resp.raise_for_status()


def main():
    service_key = get_service_key()
    # GitHub runners live on UTC, so at the 02:00 IST run this is "yesterday's"
    # calendar date in India. That is fine: the label only needs to be
    # consistent night to night, and newest-date-wins keeps working.
    today = dt.date.today().isoformat()

    companies = fetch_company_list(service_key)      # <-- the keep-alive ping
    total = len(companies)
    caps = {}                                        # ticker -> fresh ₹ cr
    failed = []
    streak = 0                                       # consecutive failures

    for i, c in enumerate(companies, 1):
        ticker = c["ticker"]
        symbol = yahoo_symbol(ticker, c.get("exchange"))
        cr = fetch_market_cap_cr(symbol)

        if cr is None:
            failed.append(ticker)
            streak += 1
            print("[%d/%d] %s: no fresh number (site keeps its newest older row)."
                  % (i, total, ticker))
            if not caps and streak >= EARLY_ABORT_AFTER:
                print("Early abort: first %d companies all failed — source is "
                      "blocking us tonight." % EARLY_ABORT_AFTER)
                break
        else:
            caps[ticker] = cr
            streak = 0
            print("[%d/%d] %s: market cap today -> %s cr" % (i, total, ticker, format(cr, ",")))

        time.sleep(PAUSE_SECONDS)

    print("-" * 60)
    print("Fetched %d/%d. Failed: %d %s"
          % (len(caps), total, len(failed), failed if failed else ""))

    # The loud-vs-quiet rule (Plan v3 §9 "degrade gracefully, fail loudly"):
    #   * A FEW failures are normal (a source hiccups): those companies simply
    #     show their newest OLDER row, the site never breaks, and we exit 0.
    #   * ZERO successes means the whole source is down: write NOTHING (so any
    #     rows already written today survive untouched) and exit non-zero so
    #     GitHub EMAILS you. The ping already happened, so the DB stays awake.
    if not caps:
        sys.exit("FATAL: 0 companies fetched — the data source likely blocked "
                 "this run. Nothing was written or deleted; the site still "
                 "serves its newest stored numbers, and the database was "
                 "pinged — but tonight's refresh did not happen.")

    write_snapshots(service_key, caps, today)
    stamp_fetched_at(service_key, sorted(caps), today)
    print("Wrote %d dated market-cap rows into metric_snapshots for %s and "
          "stamped fetched_at." % (len(caps), today))
    print("Done. The website will show these fresh numbers on the next visit.")


if __name__ == "__main__":
    main()
