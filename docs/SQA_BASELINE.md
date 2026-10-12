# SQA Baseline Assessment — SQL Portfolio

**Audit date:** 2026-11-10
**Repository root:** `C:\Users\mcngc\Downloads\SQL` (remote: `https://github.com/MBKNgcobo/SQL_Projects.git`)
**Baseline commit:** `7574d1b` (`main`) — "Clean up commit"
**Scope:** Car Part Sales Analysis Project, SQL_Project_Data_Job_analysis, Supply Chain analysis

This document records findings **before** any fix was applied. Post-fix status, severity
totals, and verification evidence live in `docs/SQA_REPORT.md`.

---

## 1. Repository state at baseline

| Item | Observation |
|---|---|
| Tracked files | 37 (one `.gitignore`, 3 projects, root `README.md`, one `.xlsx`) |
| Root `README.md` | Placeholder: contains only `Update this later` |
| Project READMEs | None exist for any of the three projects |
| `.gitignore` | Ignores `/.vscode`, `/pagila-master` and 4 job CSVs — but 3 of those 4 CSVs are tracked anyway (ignore has no effect on tracked files) |
| Untracked user files | `Online_retail/`, `Synthetic_Financial_datasets_log.csv`, `token.txt` — **not touched by this audit** |
| Uncommitted changes to tracked files | None at baseline |
| Tests / lint / CI | None exist |
| Tracked junk | `SQL_Project_Data_Job_analysis/__MACOSX/**` (2 files), `csv_files/.DS_Store` |
| Stray/empty files | `project_sql/4_top_paying_skills` (0 bytes, no extension), `car_part_sales.session.sql` (0 bytes), `sql_course.session.sql` (auto-generated placeholder `INSERT` with `job_id:integer` literals — not executable SQL) |
| Possible secret | Root `token.txt` (114 bytes, begins `hugging face...`) — untracked; risk noted, no content stored in any doc |
| Database engine | All three projects are PostgreSQL (verified: `DATE_TRUNC`, `\copy`, `CREATE TABLE ... AS`, `::numeric`, `public.` schema). No dialect mixing found |

## 2. Environment discovered (baseline)

| Component | Status |
|---|---|
| PostgreSQL 17 service | Running (`postgresql-x64-17`); PostgreSQL 18 installed but stopped |
| `psql` | Present at `C:\Program Files\PostgreSQL\17\bin\psql.exe` (not on `PATH`) |
| Authentication | `scram-sha-256` for all local connections; **no** pgpass file → agent cannot execute DB-backed tests in this audit round |
| Python | 3.14.7 available (used for static dataset profiling) |
| SQLFluff | Not installed at baseline |
| Databases referenced | Job project → `sql_course`; Car Part & Supply Chain → default `postgres` DB (no dedicated database or `CREATE DATABASE` script) |

## 3. Dataset inventory (verified by direct file inspection)

### Car Part Sales (`Car Part Sales Analysis Project/archive/`) — all files valid UTF-8
| File | Rows (excl. header) | Notes |
|---|---|---|
| `applications.csv` | 95,588 | 11 columns; matches `1_Create_Tables.sql` order; 0 dup `app_id` |
| `compatibility.csv` | 30,927 | 292 duplicate `(app_id, vehicles_id)` pairs; 8 rows `bottom_year > top_year` |
| `product_category.csv` | 665 | 0 orphan parents |
| `seller.csv` | 2,554 | UTF-8 BOM on header (skipped by `HEADER TRUE`) |
| `vehicles.csv` | 1,614 | 0 orphan `vehicle_type_id` |
| `vehicle_type.csv` | 3 | Header is `id,type_name` (positional load OK with `HEADER TRUE`) |
| `application_status.csv` | 4 | Values are listing tiers: standard / VIP / VIP+ / S VIP — **not** active/inactive |

Referential integrity (computed from CSVs): **0 orphans** app→category, app→seller,
app→vehicle_type, category→parent, vehicle→vehicle_type, compatibility→app,
compatibility→vehicle.

Data-quality facts:
- `price_usd = 0` for 13,323 rows (13.94%); 12,938 of those also have `price_gel = 0`.
  No negative prices; max 999.
- `status_id` distribution: 1=standard 95,228 · 2=VIP 227 · 3=VIP+ 88 · 4=S VIP 45.
- Only 15,311 of 95,588 applications have any compatibility rows.
- Date range `app_register_date`: 2021-06-09 → 2024-10-07; no blank dates.
- `item_condition`: New 57,762 / Old 37,826 (no blanks).

### Job Analysis (`SQL_Project_Data_Job_analysis/csv_files/`)
| File | Rows | Tracked in git? | Notes |
|---|---|---|---|
| `job_postings_fact.csv` | 787,686 | **No** (gitignored, never in history; 129 MB > GitHub 100 MB limit) | valid UTF-8 |
| `company_dim.csv` | 140,033 | Yes | valid UTF-8 |
| `company_dim_utf8.csv` | 140,033 | Yes | same content + BOM/line-ending differences only |
| `skills_dim.csv` / `_utf8` | 259 / 259 | Yes | same pattern |
| `skills_job_dim.csv` / `_utf8` | 3,669,604 / 3,669,604 | Yes | same pattern |
| `__MACOSX/**`, `.DS_Store` | — | Yes | junk metadata |

Job data facts: 22,034 postings (2.8%) carry `salary_year_avg`; 196,593 Data Analyst
postings; 69,606 `Anywhere` locations; 52 null `job_country`; `salary_rate` values
year 22,035 / hour 10,665 / month 379 / week 11 / empty 754,586.

### Supply Chain (`Supply Chain analysis/archive/`)
| File | Rows | Notes |
|---|---|---|
| `supply_chain_data.csv` | 100 | 24 columns, UTF-8 BOM; no NULLs, no dup SKUs, no zero/negative values in price, revenue, costs, defect rates, sold quantities; `Stock levels` min 0 (1 row: SKU68); `Number of products sold` min 8 (no zero-divisor rows) |
| `archive.zip` | 9,340 B | duplicate archive of the same CSV |

## 4. Baseline defect register

Severity: Critical > High > Medium > Low. Baseline status for all: **Open** (resolution in `docs/SQA_REPORT.md`).

### Critical

**CAR-001 — Wrong join key in manufacturer/model pricing**
- Project/file: `Car Part Sales Analysis Project/4_pricing_and_market_demand.sql` (queries 3–4, lines 28–47)
- Evidence: `JOIN vehicles v ON vt.id = v.id` equates `vehicle_type.id` with `vehicles.id`
  (unrelated tables). Python reproduction: vehicle_type 1 (Car, 95,261 listings) pairs only
  with vehicles row id=1 (SUZUKI) → "SUZUKI" average = 163.55 over 95,581 rows; only one
  other manufacturer (FORD, 327 rows) ever appears. Model query equally invalid.
- Impact: Every manufacturer/model average price reported by these queries is wrong.

**CAR-002 — Row-multiplying join in manufacturer average price**
- Project/file: `Car Part Sales Analysis Project/6_vehicle_manufacturer_analysis.sql` (lines 31–43)
- Evidence: `JOIN vehicles v ON vt.id = v.vehicle_type_id` expands 95,588 applications to
  ~4.3M (application × vehicle) pairs; manufacturers of the same type all report identical
  type-level averages (IVECO/JCB/KAMAZ = 182.26 exactly).
- Impact: Misleading ranking of manufacturers by price; expensive intermediate result.

**JOB-001 — Primary dataset missing from repository**
- Project/file: `SQL_Project_Data_Job_analysis/csv_files/job_postings_fact.csv`
- Evidence: gitignored (`.gitignore:4`), never committed, no git history, no documented
  download source anywhere in the repo.
- Impact: A fresh clone cannot create or analyse the `sql_course` database — the flagship
  project is not reproducible for recruiters/reviewers.

### High

**CAR-003 — Zero prices dilute all average-price metrics**
- Files: `4_pricing_and_market_demand.sql`, `6_vehicle_manufacturer_analysis.sql`
- Evidence: 13,323 / 95,588 `price_usd = 0` (13.94%). Effect measured: Car 163.55 → 189.94
  excluding zeros; Heavy Machinery 182.26 → 251.77 (27.6% of its rows are zero).
- Impact: Understated average prices; category comparisons biased by differing zero rates.

**SUP-001 — Profit-margin formula incorrect**
- File: `Supply Chain analysis/6_operation_cost.sql` (line 28)
- Evidence: `SUM((revenue - (manufacturing - shipping)) / revenue)` has (a) a sign error —
  it *adds* shipping instead of subtracting it, and (b) sums per-row ratios instead of
  computing a ratio of sums. Recomputed: buggy sum-of-ratios 98.90, corrected per-row sum
  98.62, correct aggregate `(Σrev−Σmfg−Σship)/Σrev` = 99.09.
- Impact: Wrong margin values and an uninterpretable aggregate.

**SUP-002 — Missing semicolons break end-to-end execution**
- Files: `2_stock.sql` (after `ORDER BY number_of_products_sold DESC`) and
  `6_operation_cost.sql` (after `ORDER BY shipping_cost`).
- Evidence: statement before the next `WITH`/`SELECT` is never terminated → syntax error
  when the file is run as a script.
- Impact: Scripts fail in psql/CI script mode.

**SUP-003 — No import path for the supply-chain dataset**
- File: `Supply Chain analysis/1_data_cleaning.sql` creates `supply_chain` but no script
  anywhere loads `archive/supply_chain_data.csv`; no README; runs inside default `postgres`.
- Impact: Project cannot be reproduced from a clean checkout without guessing column order
  and load commands.

**REPO-001 — Documentation absent / inaccurate**
- Root `README.md` = "Update this later"; no project READMEs; database names, script order,
  dataset locations, engine version, and Windows import pitfalls all undocumented.

**JOB-003 — Server-side `COPY` with machine-specific path as executable path**
- File: `sql_load/3_modify_tables.sql`. Executable statements use server-side `COPY FROM
  'C:\Users\mcngc\...'` while the portable `\copy` alternative is only inside a comment.
- Impact: Fails for any other machine/user and confuses server vs client file access —
  the classic Windows permission-denied trap the file's own comment warns about.

### Medium

| ID | Project / file | Evidence | Impact |
|---|---|---|---|
| CAR-004 | Car Part data + questions file | 292 duplicate compatibility pairs; 8 `bottom_year > top_year`; questions file asks for "active/inactive" statuses but `application_status` holds listing tiers (99.2% `standard`); questions sections E/F/G have no scripts | Business questions unanswerable as written; DQ issues undiscovered |
| CAR-005 | `2_import.sql` | Absolute hard-coded Windows paths; no database creation step | Import fails on any other machine |
| CAR-006 | `6_vehicle_manufacturer_analysis.sql` | Comment says "models" but query groups vehicle types; final stub query never implemented | Misleading docs; incomplete file |
| JOB-002 | `csv_files/*_utf8.csv` | Byte-level comparison: identical rows, differ only by BOM + line endings; load scripts use non-`_utf8` copies | ~110 MB avoidable repo weight; reviewer confusion |
| JOB-004 | `project_sql/4_top_paying_skills.sql` | Top-25 AVG(salary) with no sample-size guard; only 2.8% of postings have yearly salaries; skills with 1 posting can rank #1 | Salary rankings can be noise-driven |
| JOB-005 | stray files | Empty `4_top_paying_skills` (no extension), `sql_course.session.sql` junk INSERT, tracked `.DS_Store`/`__MACOSX` | Clutter; reviewer confusion |
| SUP-004 | `5_exploratory_business_analysis.sql` L68–80 | "Which customer demographic generates the most revenue?" query never references `customer_demographics` (copy of the revenue-per-unit query) | Question silently unanswered |
| SUP-005 | `1_data_cleaning.sql` | Stray `COMMIT;` without `BEGIN`; file performs profiling, not cleaning; no stated currency for revenue ("R241.6k") | Confusing naming/semantics; ambiguous units |
| SUP-006 | `2_stock.sql`, `3_lead_time.sql`, `4_supplier_analysis.sql` | Division by `number_of_products_sold` without `NULLIF` (safe on current data — verified min sold = 8 — but inconsistent with files 5–6) | Fragile if data refreshes |
| TOOL-001 | repository | No tests, lint, CI, no expected-results artifacts | Regressions invisible; no trust signal for reviewers |

### Low

| ID | Location | Evidence |
|---|---|---|
| LOW-001 | multiple SQL files | Typos in aliases/comments: `avarage_price`, `assiciated`, `transportaion_cost`, `GROUP bY`, "discrepency", "inconsistant" |
| LOW-002 | `4_pricing_and_market_demand.sql` L5–26 | Redundant `vehicle_type` join in the category query; commented-out columns left in place |
| LOW-003 | `advanced_sql/4_cte.sql` | Redundant `GROUP BY` on a query with no aggregate functions |
| LOW-004 | `.gitignore` | Ignores 3 files that are already tracked; no entries for `.DS_Store`, `__MACOSX`, `token.txt` |
| LOW-005 | root | `token.txt` (Hugging Face token, untracked) in repo root — one `git add .` away from being published |

## 5. Analytical claims already present in comments (spot-check results)

All numeric claims embedded in the Supply Chain SQL comments were recomputed from
`supply_chain_data.csv` and **verified accurate**: 45% Critical+High risk, skincare 52.5%,
haircare 44.12%, cosmetics 34.62%, skincare revenue ≈ 241.6k, supplier defect/lead/cost
figures, risk-level average lead times (7.14 / 19.03 / 16.73), Carrier B cost 5.51 & time
5.30, SKU2/SKU51/SKU68 observations. Currency is undefined in the dataset (comment uses
"R" — rand?). Recorded as an open documentation issue, not a data defect.

## 6. Baseline test position

| Test category | Baseline |
|---|---|
| DB-backed data-quality tests | **Not executable** in this audit round — scram-sha-256 password required, no stored credentials. Scripts prepared in `tests/sql/`, marked *Not Executed*. |
| Static dataset validation (Python) | Executable — implemented in `tests/python/validate_datasets.py` |
| SQL lint | Not present at baseline; SQLFluff added with postgres dialect |
| CI | None at baseline; GitHub Actions workflow added |

---
*This baseline was produced before any corrective edit. See `docs/SQA_REPORT.md` for the
post-fix state, executed test results, and the full finding-by-finding status.*


