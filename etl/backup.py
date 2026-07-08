#!/usr/bin/env python3
# ============================================================================
# InvestorLens India — etl/backup.py   (photocopier v2 — Phase 4, Session C)
# ----------------------------------------------------------------------------
# WHAT THIS DOES, in one breath:
#   Read every row of all EIGHT Phase-4 tables from Supabase and save them as
#   eight JSON files (plus a little manifest), into a folder the workflow then
#   commits into a PRIVATE backup repo.
#
# WHAT CHANGED FROM v1, and WHY:
#   v1 photocopied the retired five-drawer cabinet (companies, metrics,
#   factors, chains, mgmt). The Phase-4 flip emptied four of those drawers and
#   moved everything into eight new ones — so v1 was faithfully photocopying
#   husks. v2 photocopies the eight real drawers. Nothing else changed: same
#   paging, same stable sort, same diff-friendly files, same loud failure.
#
# WHY IT EXISTS:
#   Supabase's free tier keeps NO backups of its own. If the project were ever
#   lost, these JSON files are the photocopy we rebuild from. The MOST precious
#   rows are the human-verified UNDERSTANDING — business_core, value_chain*,
#   moat_note, mgmt, factors, bull/bear, narratives. A machine can re-fetch a
#   market cap tomorrow; it can never re-derive a hand-written moat note. This
#   protects the mission.
#
# THE ONE SECRET IT NEEDS:
#   SUPABASE_SERVICE_KEY (from GitHub Secrets). Reads work with any key, but the
#   robot already carries the master key, so we reuse it. Never written in code.
# ============================================================================

import os
import sys
import json
import datetime as dt

import requests

# Public project URL — the same one shipped inside the website; not a secret.
# (The env override exists only so the test harness can point this script at a
#  fake database; GitHub Actions sets no SUPABASE_URL, so production always
#  uses the default.)
SUPABASE_URL = os.environ.get("SUPABASE_URL",
                              "https://uhqyhsniwlgivdlxbpoj.supabase.co")

# The eight drawers of the Phase-4 filing cabinet, and the column we sort each
# by. Sorting gives STABLE output, so next week's git diff shows only what
# truly changed. mgmt_profiles and companies have no id column (ticker is
# their primary key); cross_company_narratives' id is its text slug.
TABLES = {
    "companies":                "ticker",
    "metric_snapshots":         "id",
    "chain_nodes":              "id",
    "tech_geo_tags":            "id",
    "bull_bear_cases":          "id",
    "mgmt_profiles":            "ticker",
    "cross_company_narratives": "id",
    "staged_metric_snapshots":  "id",   # the robot's inbox — usually empty, still photocopied
}

PAGE = 1000                                   # PostgREST returns <= 1000 rows/call
OUT_DIR = os.environ.get("OUT_DIR", "backups-repo")


def service_key():
    k = os.environ.get("SUPABASE_SERVICE_KEY", "").strip()
    if not k:
        sys.exit("FATAL: SUPABASE_SERVICE_KEY is not set. In GitHub it comes "
                 "from Settings > Secrets > Actions.")
    return k


def headers(k):
    return {"apikey": k, "Authorization": "Bearer " + k}


def dump_table(table, order_col, k):
    """Read EVERY row, 1,000 at a time. We MUST page because metric_snapshots
       now grows nightly (one dated market-cap row per company per night) and
       passes 1,000 rows within days of robot v2 going live."""
    rows = []
    start = 0
    while True:
        r = requests.get(
            SUPABASE_URL + "/rest/v1/" + table,
            headers={**headers(k), "Range": "%d-%d" % (start, start + PAGE - 1)},
            params={"select": "*", "order": order_col + ".asc"},
            timeout=60,
        )
        if r.status_code not in (200, 206):
            r.raise_for_status()               # a real read error => fail LOUD
        batch = r.json()
        rows.extend(batch)
        if len(batch) < PAGE:                  # short page => that was the last one
            break
        start += PAGE
    return rows


def main():
    k = service_key()
    os.makedirs(OUT_DIR, exist_ok=True)

    manifest = {
        "backed_up_at": dt.datetime.now(dt.timezone.utc).isoformat(),
        "source": SUPABASE_URL,
        "schema": "phase4-eight-tables",
        "counts": {},
    }

    for table, order_col in TABLES.items():
        rows = dump_table(table, order_col, k)
        path = os.path.join(OUT_DIR, table + ".json")
        with open(path, "w", encoding="utf-8") as f:
            # ensure_ascii=False keeps ₹ and — readable; sort_keys + indent make
            # the file diff-friendly week to week.
            json.dump(rows, f, ensure_ascii=False, indent=2, sort_keys=True)
        manifest["counts"][table] = len(rows)
        print("  %-26s %6d rows -> %s" % (table, len(rows), path))

    with open(os.path.join(OUT_DIR, "backup_manifest.json"), "w", encoding="utf-8") as f:
        json.dump(manifest, f, ensure_ascii=False, indent=2, sort_keys=True)

    # Safety: never let a broken read save an EMPTY backup over a good one.
    # (Git history would still hold the old copy, but failing loud is clearer.)
    # companies and metric_snapshots are the two structural pillars; an empty
    # staged_metric_snapshots, by contrast, is the normal, healthy state.
    if manifest["counts"].get("companies", 0) == 0:
        sys.exit("FATAL: 0 companies dumped — refusing to write an empty backup.")
    if manifest["counts"].get("metric_snapshots", 0) == 0:
        sys.exit("FATAL: 0 metric snapshots dumped — refusing to write an empty backup.")

    print("-" * 60)
    print("Backup complete:", manifest["counts"])


if __name__ == "__main__":
    main()
