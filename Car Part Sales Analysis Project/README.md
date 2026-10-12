# Car Part Sales Analysis

Marketplace analysis of **95,588 car-part application listings** (categories,
vehicle types, sellers, manufacturers/models and pricing) on PostgreSQL.

## Contents

| File | Purpose |
|---|---|
| `0_create_database.sql` | Optional — creates a dedicated `car_part_sales` database |
| `1_Create_Tables.sql` | Creates the seven tables |
| `2_import.sql` | Loads the CSVs from `archive/` with psql `\copy` |
| `3_market_performance.sql` | Listings over time, by category and vehicle type |
| `4_pricing_and_market_demand.sql` | Average prices by type, category, manufacturer, model, condition |
| `5_seller_performance.sql` | Seller listing counts and pricing |
| `6_vehicle_manufacturer_analysis.sql` | Manufacturer/model rankings and compatibility coverage |
| `Car Part Sales Analysis Project questions.txt` | The original business-question list |
| `archive/*.csv` | Source dataset (7 files) |

## How to run (PostgreSQL + psql)

```bash
# from this folder
psql -U postgres -f 0_create_database.sql        # optional dedicated DB
psql -U postgres -d car_part_sales -f 1_Create_Tables.sql
psql -U postgres -d car_part_sales -f 2_import.sql
psql -U postgres -d car_part_sales -f 3_market_performance.sql
# ... then 4_, 5_, 6_
```

> **Windows note:** `2_import.sql` uses client-side `\copy`, which reads the
> CSVs from your session and avoids the server-side `COPY` "Permission denied"
> trap. The paths in `2_import.sql` are absolute — edit the directory prefix if
> your checkout lives elsewhere.

## Dataset notes (verified against the CSVs)

- `applications.csv` 95,588 rows · `compatibility.csv` 30,927 ·
  `product_category.csv` 665 · `seller.csv` 2,554 · `vehicles.csv` 1,614 ·
  `vehicle_type.csv` 3 · `application_status.csv` 4.
- **Zero prices:** 13,323 listings (13.94%) have `price_usd = 0` and are
  treated as "price not set"; price averages use
  `AVG(NULLIF(price_usd, 0))` so they are not dragged down.
- **Application → vehicle link:** `applications` has *no* direct vehicle
  column. Manufacturer/model analysis goes through
  `compatibility(app_id, vehicles_id)` — joining `vehicle_type.id` to
  `vehicles.id` produces wrong results (they are unrelated keys).
- Known source-data quirks: 292 duplicate `(app_id, vehicles_id)` pairs,
  8 compatibility rows with `bottom_year > top_year`, and
  `application_status` holds listing *tiers* (standard / VIP / VIP+ / S VIP),
  not active/inactive flags.

Re-run the machine-checked version of these expectations with
`python tests/python/validate_datasets.py` from the repository root.
See `docs/SQA_BASELINE.md` and `docs/SQA_REPORT.md` for the full audit.
