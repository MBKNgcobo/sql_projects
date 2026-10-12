# Supply Chain Analysis

Exploratory analysis of a 100-row / 24-column supply-chain dataset
(product pricing, stock, lead times, suppliers, shipping, defect rates)
on PostgreSQL.

## Contents

| File | Purpose |
|---|---|
| `0_import.sql` | **Start here** — creates the `supply_chain` table and loads the CSV |
| `1_data_cleaning.sql` | Schema + data-quality profiling (despite the name, it does not mutate data) |
| `2_stock.sql` | Stock levels, stockouts, inventory-to-sales ratio |
| `3_lead_time.sql` | Lead times by risk level |
| `4_supplier_analysis.sql` | Supplier cost/defect/lead-time comparisons |
| `5_exploratory_business_analysis.sql` | Revenue by demographics, shipping, risk |
| `6_operation_cost.sql` | Profit, margin, manufacturing/shipping cost burden |
| `archive/supply_chain_data.csv` | Source dataset (100 rows, UTF-8 with BOM) |

## How to run (PostgreSQL + psql)

```bash
# open a terminal IN THIS FOLDER, then:
psql -U postgres -d postgres -f 0_import.sql
psql -U postgres -d postgres -f 1_data_cleaning.sql
psql -U postgres -d postgres -f 2_stock.sql
# ... then 3_ through 6_
```

`0_import.sql` uses **relative** `\copy` paths, so it works from any checkout
location as long as the terminal starts in this folder — no path editing.

## Dataset notes (verified against the CSV)

- Exactly 100 rows, no NULL cells, no duplicate SKUs, no zero/negative
  prices or sold quantities.
- `Number of products sold` has a minimum of 8 — no zero divisors — but all
  divisions still use `NULLIF(..., 0)` so a refreshed dataset cannot raise
  division-by-zero errors.
- The profit margin in `6_operation_cost.sql` is a *ratio of sums*
  (`(Σrevenue − Σmfg − Σshipping) / Σrevenue`). Manufacturing and shipping
  costs appear to be per-unit while revenue is a total, so margins sit near
  100% by construction — read them as a relative ranking between product
  types, not an accounting margin.
- Currency is not defined in the dataset (comments use "R", possibly ZAR).

Re-check these expectations with `python tests/python/validate_datasets.py`
from the repository root. Audit history: `docs/SQA_BASELINE.md` and
`docs/SQA_REPORT.md`.
