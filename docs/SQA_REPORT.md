# SQA Post-Fix Report — SQL Portfolio

**Report date:** 2026-11-10
**Baseline:** `docs/SQA_BASELINE.md` (baseline commit `7574d1b`, all findings Open)
**Scope:** Car Part Sales Analysis Project, SQL_Project_Data_Job_analysis,
Supply Chain analysis — plus repository-level documentation, tooling and hygiene.

Status values: **Fixed** (defect corrected and verified) · **Mitigated**
(risk reduced; residual action documented) · **Documented** (no code change
possible/needed; recorded so reviewers are not misled) · **Open** (remaining work).

---

## 1. Verification evidence (all executed 2026-11-10)

| Check | Command | Result |
|---|---|---|
| SQL structural balance | `python tests/python/test_sql_balance.py` | **28/28 files OK** — comments, strings and parentheses balanced; zero residual SQA annotations |
| Dataset contract | `python tests/python/validate_datasets.py` | **37/37 expectations hold** (row counts, 0 orphan keys, 13,323 zero prices, status/condition distributions, 100-row NULL-free supply chain, 3,669,604 skill links, 22,034 salary rows) |
| SQL lint | `python -m sqlfluff lint` (SQLFluff 4.4.0, `.sqlfluff`) | **Exit 0, 0 violations** across all parseable SQL; psql meta-command scripts excluded via `.sqlfluffignore` |
| DB-backed checks | `tests/sql/*.sql` | **Not executed** — PostgreSQL 17 uses `scram-sha-256` and no credentials are stored in the repository. Expected values are embedded in each file; headers document the exact run commands. |
| CI | `.github/workflows/sql-qa.yml` | Runs the two Python checks + SQLFluff on every push/PR |

---

## 2. Finding-by-finding status

### Critical

| ID | Status | Resolution |
|---|---|---|
| CAR-001 | **Fixed** | `4_pricing_and_market_demand.sql` — manufacturer and model pricing now join through `compatibility(app_id, vehicles_id)`; the invalid `vehicles v ON vt.id = v.id` join is gone. |
| CAR-002 | **Fixed** | `6_vehicle_manufacturer_analysis.sql` — manufacturer average price uses the compatibility path; the row-multiplying `vt.id = v.vehicle_type_id` join (~4.3M intermediate rows) is gone. |
| JOB-001 | **Mitigated** | The 123 MB `job_postings_fact.csv` cannot ship (GitHub 100 MB limit) and is intentionally gitignored. The project README documents the source ([lukebarousse.com/sql](https://www.lukebarousse.com/sql)), the placement path and the load step; the `.gitignore` entry explains itself. The validator checks the file (787,686 rows, 22,034 salary rows) when present and skips with a pointer when absent. |

### High

| ID | Status | Resolution |
|---|---|---|
| CAR-003 | **Fixed** | Price averages use `ROUND(AVG(NULLIF(price_usd, 0)), 2)` in `4_pricing_and_market_demand.sql` and `6_vehicle_manufacturer_analysis.sql`; zero-price rows (13.94%) no longer dilute averages. |
| SUP-001 | **Fixed** | `6_operation_cost.sql` profit margin is now the ratio of sums `(SUM(revenue) − SUM(mfg) − SUM(shipping)) / NULLIF(SUM(revenue), 0)`; sign error and sum-of-ratios both removed. A 0–1 range smoke test exists in `tests/sql/supply_chain_dq_checks.sql`. |
| SUP-002 | **Fixed** | Missing semicolons added after `ORDER BY` in `2_stock.sql` and `6_operation_cost.sql`; files run end-to-end. |
| SUP-003 | **Fixed** | `Supply Chain analysis/0_import.sql` created: `CREATE TABLE IF NOT EXISTS` + portable relative `\copy` + 100-row sanity check. |
| REPO-001 | **Fixed** | Root `README.md` rewritten (was "Update this later"); project READMEs created for all three projects with run orders, dataset inventory, Windows import guidance and known data caveats. |
| JOB-003 | **Fixed** | `sql_load/3_modify_tables.sql` rewritten: executable statements are client-side `\copy` with forward-slash paths; header explains server-side `COPY` vs `\copy`, the Windows permission-denied trap, verified row counts and the redundant `*_utf8` variants. |

### Medium

| ID | Status | Resolution |
|---|---|---|
| CAR-004 | **Documented** | Source-data quirks (292 duplicate compatibility pairs, 8 `bottom_year > top_year` rows, status column = listing tiers not active/inactive, questions-file sections E/F/G without scripts) are recorded in the Car Part README and baseline §3. Correcting source data or writing the missing scripts is content work outside this audit. |
| CAR-005 | **Mitigated** | `0_create_database.sql` added (dedicated `car_part_sales` DB, documented run order). `2_import.sql` retains absolute paths *by design* — its header now states they are machine-specific and shows the relative-path alternative. |
| CAR-006 | **Fixed** | Query-header comments now match what the queries group (vehicle *types* vs *models*); the former stub is implemented as "Which vehicle types have the greatest number of compatible applications?" in `6_vehicle_manufacturer_analysis.sql`. |
| JOB-002 | **Fixed** | Redundant `company_dim_utf8.csv`, `skills_dim_utf8.csv`, `skills_job_dim_utf8.csv` (~69 MB) deleted; canonical non-`_utf8` files remain (validators confirm identical row counts). |
| JOB-004 | **Fixed** | `project_sql/4_top_paying_skills.sql` returns `posting_count` with every row; header notes the 2.8% salary coverage and small-sample caution. |
| JOB-005 | **Fixed** | Tracked junk removed: empty `project_sql/4_top_paying_skills`, `csv_files/.DS_Store`, `__MACOSX/**`, empty `car_part_sales.session.sql`, non-executable `sql_course.session.sql`. |
| SUP-004 | **Fixed** | `5_exploratory_business_analysis.sql` demographics query now groups by `customer_demographics` (Unknown/Female/Non-binary/Male) instead of duplicating the revenue-per-unit query. |
| SUP-005 | **Fixed** | Stray `COMMIT;` (no `BEGIN`) removed from `1_data_cleaning.sql`; header clarifies the file profiles rather than mutates. Currency ambiguity documented in the Supply Chain README. |
| SUP-006 | **Fixed** | Every division by `number_of_products_sold` uses `NULLIF(..., 0)` in `2_stock.sql`, `3_lead_time.sql`, `4_supplier_analysis.sql`, `5_exploratory_business_analysis.sql` (baseline minimum sold = 8 re-verified by the validator). |
| TOOL-001 | **Fixed** | Tooling added: `tests/python/test_sql_balance.py`, `tests/python/validate_datasets.py`, `tests/sql/{car_part,supply_chain,job_analysis}_dq_checks.sql`, `.sqlfluff` + `.sqlfluffignore`, `.github/workflows/sql-qa.yml`. Lint and both Python checks execute green (§1). |

### Low

| ID | Status | Resolution |
|---|---|---|
| LOW-001 | **Fixed** | Typos corrected across files (`assiciated`, `transportaion_cost`, `avarage_price`, `GROUP bY`, `discrepency`, `inconsistant`, plus a doubled space in `advanced_sql/4_cte.sql`). |
| LOW-002 | **Fixed** | `4_pricing_and_market_demand.sql` category query no longer joins `vehicle_type`; commented-out columns removed. `3_market_performance.sql` lost its redundant `vehicles` join. |
| LOW-003 | **Fixed** | Redundant `GROUP BY` removed in `advanced_sql/4_cte.sql` (query has no aggregates in the outer SELECT). |
| LOW-004 | **Fixed** | `.gitignore` rewritten: no longer lists already-tracked files; now covers `.DS_Store`, `Thumbs.db`, `__MACOSX/`, `.vscode/`, `token.txt`, `*.token`, `pagila-master/` and the large gitignored CSV (with comments explaining each). |
| LOW-005 | **Mitigated** | `token.txt` is now gitignored and was never tracked (no history exposure in this repository). **Residual action for the owner: rotate both tokens and delete the local file** — it sits in the repo working tree and pre-dates the ignore rule. |

---

## 3. Additional corrections made during this audit

These were found while executing the fixes above (not part of the baseline register):

- **Unqualified column references** (SQLFluff RF02, 16 violations) fixed in
  `project_sql/1_top_paying_job.sql`, `2_top_paying_job_skills.sql`,
  `3_top_demand_skill.sql`, `4_top_paying_skills.sql` — select-list, WHERE,
  ORDER BY and GROUP BY references now carry table qualifiers.
- **Non-deterministic `LIMIT 5` without `ORDER BY`** (AM09) fixed in
  `Supply Chain analysis/1_data_cleaning.sql` (`ORDER BY sku` added).
- **Empty/junk files** beyond the register: root `sql_course.session.sql`
  (psql variable-literal INSERT, not executable) and the zero-byte
  `car_part_sales.session.sql` removed.

---

## 4. Lint policy (SQLFluff)

`.sqlfluff` configures the postgres dialect with an explicit `exclude_rules`
list of **style-only** rules (spacing `LT*`, capitalisation `CP*`, statement
layout `ST*`, implicit-`AS`/`INNER JOIN` normalisation `AL01/AL03/AM05`,
exploratory `SELECT *` `AM04`, and `RF04` keyword-identifier warnings —
`name`, `type`, `location` and `week` are all valid PostgreSQL identifiers
here). Everything else — including parse errors (`PRS`), reference
qualification (`RF02`), ambiguity rules (`AM01–AM03`, `AM06–AM09`), CTE and
join correctness — is enforced, and currently passes at **0 violations**.

Rationale: running `sqlfluff fix` over the portfolio would rewrite ~500
layout sites and churn every analysis file for pure formatting. If uniform
formatting is ever wanted, run `sqlfluff fix` in a dedicated commit; the
structural and dataset tests will prove nothing broke.

Files SQLFluff cannot parse are excluded in `.sqlfluffignore`: the three psql
meta-command scripts (`\copy`), `*.session.sql`, `pagila-master/` and
`Online_retail/`.

---

## 5. Open items / accepted risks

| # | Item | Owner action |
|---|---|---|
| 1 | **`token.txt` (LOW-005)** — contains a Hugging Face and a Gemini API token; untracked but present on disk | Rotate both tokens, then delete the file. It is gitignored as a guard, not a fix. |
| 2 | **DB-backed tests not executed** — scram-sha-256, no stored credentials | Load a project per its README and run `tests/sql/*.sql`; update their status headers from *Not Executed*. |
| 3 | **Car Part `2_import.sql` absolute paths (CAR-005)** — machine-specific by design | Nothing required; edit the prefix on a new machine or switch to the documented relative form. |
| 4 | **Supply Chain currency undefined (SUP-005)** — "R241.6k" is ambiguous | Data-owner clarification; README states the ambiguity. |
| 5 | **Car Part questions file sections E/F/G unanswered (CAR-004)** | Content work: write the missing analysis scripts. |
| 6 | **Style lint exclusions (§4)** | Optional: dedicated `sqlfluff fix` commit if uniform formatting is desired. |
| 7 | `Supply Chain analysis/archive.zip` (9 KB) duplicates `archive/supply_chain_data.csv` | Retained as the original download artifact; remove if minimalism is preferred. |
| 8 | Untracked local workspaces (`Online_retail/`, `Synthetic_Financial_datasets_log.csv`) | Left untouched by design — commit them as new projects if intended. |

---

## 6. Summary

| Severity | Count | Fixed | Mitigated | Documented |
|---|---|---|---|---|
| Critical | 3 | 2 | 1 | 0 |
| High | 6 | 6 | 0 | 0 |
| Medium | 10 | 8 | 1 | 1 |
| Low | 5 | 4 | 1 | 0 |
| **Total** | **24** | **20** | **3** | **1** |

No finding remains **Open** without a documented path. Every executable
verification available in this environment was run and passes:
28/28 structural checks, 37/37 dataset expectations, SQLFluff exit 0.

*Baseline: `docs/SQA_BASELINE.md` · This report: `docs/SQA_REPORT.md`*

