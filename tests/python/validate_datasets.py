"""Static dataset validation for the SQL portfolio repositories.

Re-runs the profiling checks that the SQA baseline recorded, directly against
the CSV files, so data drift is caught without a live PostgreSQL instance.

  * Car Part Sales  - row counts, key uniqueness, zero-price rate, status and
                      condition distributions, referential integrity.
  * Supply Chain    - row/column count, NULL and duplicate-SKU scans, the
                      minimum-sold value that guards the division queries.
  * Job Analysis    - row counts of the tracked CSVs; the gitignored
                      job_postings_fact.csv is validated only when present.

Run from anywhere:  python tests/python/validate_datasets.py
Exit code 0 = all expectations hold.
"""

import csv
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
CAR = REPO_ROOT / "Car Part Sales Analysis Project" / "archive"
SUPPLY = REPO_ROOT / "Supply Chain analysis" / "archive"
JOB = REPO_ROOT / "SQL_Project_Data_Job_analysis" / "csv_files"

failures: list[str] = []


def expect(label: str, actual, expected) -> None:
    if actual == expected:
        print(f"OK   {label}: {actual}")
    else:
        print(f"FAIL {label}: expected {expected!r}, got {actual!r}")
        failures.append(label)


def read_rows(path: Path):
    # utf-8-sig strips the BOM carried by several source exports.
    with open(path, encoding="utf-8-sig", newline="") as fh:
        yield from csv.DictReader(fh)


def validate_car_part() -> None:
    print("\n== Car Part Sales ==")

    app_ids: set[str] = set()
    dup_app_ids = 0
    zero_price = 0
    status_counts: dict[str, int] = {}
    condition_counts: dict[str, int] = {}
    dates: list[str] = []
    for row in read_rows(CAR / "applications.csv"):
        if row["app_id"] in app_ids:
            dup_app_ids += 1
        app_ids.add(row["app_id"])
        if float(row["price_usd"] or 0) == 0:
            zero_price += 1
        status_counts[row["status_id"]] = status_counts.get(row["status_id"], 0) + 1
        condition_counts[row["item_condition"]] = (
            condition_counts.get(row["item_condition"], 0) + 1
        )
        dates.append(row["app_register_date"])
    expect("applications rows", len(app_ids) + dup_app_ids, 95_588)
    expect("applications duplicate app_id", dup_app_ids, 0)
    expect("applications price_usd = 0", zero_price, 13_323)
    expect("status_id 1 (standard)", status_counts.get("1"), 95_228)
    expect("status_id 2 (VIP)", status_counts.get("2"), 227)
    expect("status_id 3 (VIP+)", status_counts.get("3"), 88)
    expect("status_id 4 (S VIP)", status_counts.get("4"), 45)
    expect("item_condition New", condition_counts.get("New"), 57_762)
    expect("item_condition Old", condition_counts.get("Old"), 37_826)
    expect("app_register_date min", min(dates)[:10], "2021-06-09")
    expect("app_register_date max", max(dates)[:10], "2024-10-07")

    category_ids = {r["id"] for r in read_rows(CAR / "product_category.csv")}
    seller_ids = {r["id"] for r in read_rows(CAR / "seller.csv")}
    vehicle_type_ids = {r["id"] for r in read_rows(CAR / "vehicle_type.csv")}
    vehicle_rows = list(read_rows(CAR / "vehicles.csv"))
    vehicle_ids = {r["id"] for r in vehicle_rows}
    expect("product_category rows", len(category_ids), 665)
    expect("seller rows", len(seller_ids), 2_554)
    expect("vehicle_type rows", len(vehicle_type_ids), 3)
    expect("vehicles rows", len(vehicle_ids), 1_614)
    expect(
        "application_status rows",
        len(list(read_rows(CAR / "application_status.csv"))),
        4,
    )

    orphan_cat = orphan_seller = orphan_vt = 0
    for row in read_rows(CAR / "applications.csv"):
        orphan_cat += row["category_id"] not in category_ids
        orphan_seller += row["seller_id"] not in seller_ids
        orphan_vt += row["vehicle_type_id"] not in vehicle_type_ids
    expect("applications -> product_category orphans", orphan_cat, 0)
    expect("applications -> seller orphans", orphan_seller, 0)
    expect("applications -> vehicle_type orphans", orphan_vt, 0)
    expect(
        "vehicles -> vehicle_type orphans",
        sum(r["vehicle_type_id"] not in vehicle_type_ids for r in vehicle_rows),
        0,
    )

    compat_pairs: set[tuple[str, str]] = set()
    compat_dups = bad_years = orphan_app = orphan_vehicle = 0
    apps_with_compat: set[str] = set()
    for row in read_rows(CAR / "compatibility.csv"):
        pair = (row["app_id"], row["vehicles_id"])
        if pair in compat_pairs:
            compat_dups += 1
        compat_pairs.add(pair)
        if float(row["bottom_year"]) > float(row["top_year"]):
            bad_years += 1
        orphan_app += row["app_id"] not in app_ids
        orphan_vehicle += row["vehicles_id"] not in vehicle_ids
        apps_with_compat.add(row["app_id"])
    expect("compatibility rows", len(compat_pairs) + compat_dups, 30_927)
    expect("compatibility duplicate pairs", compat_dups, 292)
    expect("compatibility bottom_year > top_year", bad_years, 8)
    expect("compatibility -> applications orphans", orphan_app, 0)

def validate_supply_chain() -> None:
    print("\n== Supply Chain ==")
    rows = list(read_rows(SUPPLY / "supply_chain_data.csv"))
    expect("supply_chain rows", len(rows), 100)
    expect("supply_chain columns", len(rows[0]), 24)
    expect(
        "supply_chain empty cells (NULLs)",
        sum(1 for r in rows for v in r.values() if v in ("", None)),
        0,
    )
    skus = [r["SKU"] for r in rows]
    expect("supply_chain duplicate SKUs", len(skus) - len(set(skus)), 0)
    expect(
        "min number_of_products_sold (guards divisions)",
        min(int(r["Number of products sold"]) for r in rows),
        8,
    )
    expect("min stock_levels", min(int(r["Stock levels"]) for r in rows), 0)
    expect("non-positive prices", sum(float(r["Price"]) <= 0 for r in rows), 0)


def validate_job_analysis() -> None:
    print("\n== Job Analysis ==")

    def count_rows(path: Path) -> int:
        with open(path, encoding="utf-8-sig", errors="strict") as fh:
            return sum(1 for _ in fh) - 1

    expect("company_dim rows", count_rows(JOB / "company_dim.csv"), 140_033)
    expect("skills_dim rows", count_rows(JOB / "skills_dim.csv"), 259)
    expect("skills_job_dim rows", count_rows(JOB / "skills_job_dim.csv"), 3_669_604)

    postings = JOB / "job_postings_fact.csv"
    if postings.exists():
        expect("job_postings_fact rows", count_rows(postings), 787_686)
        with_year = data_analysts = 0
        for row in read_rows(postings):
            if row["salary_year_avg"] not in ("", None):
                with_year += 1
            if row["job_title_short"] == "Data Analyst":
                data_analysts += 1
        expect("postings with salary_year_avg", with_year, 22_034)
        expect("Data Analyst postings", data_analysts, 196_593)
    else:
        print(
            "SKIP job_postings_fact.csv not present (gitignored, 123 MB). "
            "See SQL_Project_Data_Job_analysis/README.md for the download source."
        )


def main() -> int:
    validate_car_part()
    validate_supply_chain()
    validate_job_analysis()
    print()
    if failures:
        print(f"{len(failures)} expectation(s) FAILED")
        return 1
    print("All dataset expectations hold.")
    return 0


if __name__ == "__main__":
    sys.exit(main())

    expect("compatibility -> vehicles orphans", orphan_vehicle, 0)
    expect("applications with any compatibility row", len(apps_with_compat), 15_311)
