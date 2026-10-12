# SQL Portfolio Projects

A collection of SQL projects focused on using data to answer **real-world business questions** through data exploration, transformation, analysis, and reporting.

These projects demonstrate my ability to work with relational data and use SQL to identify trends, calculate business metrics, investigate relationships between datasets, and turn raw data into actionable insights.

---

## Projects

### 1. Car Part Sales Analysis

**Objective:**
Analyse car-part sales data to understand sales performance, customer behaviour, product performance, and revenue trends.

**Key Areas of Analysis:**

* Sales and revenue performance
* Product and car-part performance
* Customer purchasing behaviour
* Regional and category-level sales
* Top-performing products and customers
* Average order values
* Revenue trends and comparisons

**SQL Concepts Used:**

* `SELECT`, `WHERE`, `ORDER BY`
* `JOIN`
* `GROUP BY`
* Aggregate functions
* `CASE`
* Common Table Expressions (CTEs)
* Subqueries
* Window functions
* `RANK()`
* `DENSE_RANK()`
* `ROW_NUMBER()`
* `HAVING`

**Business Questions:**

* Which products generate the most revenue?
* Which customers contribute the most to sales?
* Which categories perform best?
* What are the average order values?
* How does sales performance differ across regions?

---

### 2. Supply Chain Analysis

**Objective:**
Analyse supply chain data to evaluate operational performance, inventory movement, supplier performance, and potential areas of inefficiency.

**Key Areas of Analysis:**

* Supplier performance
* Inventory levels
* Product movement
* Order performance
* Supply chain costs
* Lead times
* Regional performance
* Operational efficiency

**SQL Concepts Used:**

* Multi-table `JOIN`s
* Aggregations
* CTEs
* Subqueries
* `CASE` statements
* Date-based analysis
* Window functions
* Ranking
* Conditional aggregation
* `HAVING`

**Business Questions:**

* Which suppliers perform best?
* Which products have the highest demand?
* Where are potential supply chain bottlenecks?
* Which suppliers or products contribute the most to costs?
* How does operational performance vary across regions?

---

### 3. Job Data Analysis

**Objective:**
Analyse job-market data to identify trends in job availability, salaries, skills, industries, and job requirements.

**Key Areas of Analysis:**

* Job availability
* Salary analysis
* Job titles and roles
* Required technical skills
* Experience requirements
* Location-based trends
* Industry demand
* Employer/job-market trends

**SQL Concepts Used:**

* Data filtering and transformation
* Multi-table `JOIN`s
* `GROUP BY`
* Aggregations
* CTEs
* Subqueries
* `CASE`
* Window functions
* Ranking
* Conditional aggregation

**Business Questions:**

* Which roles appear most frequently?
* Which skills are most in demand?
* Which roles have the highest salaries?
* How does salary vary by experience level?
* Which locations have the most opportunities?
* What technical skills are associated with higher-paying roles?

---

## SQL Skills Demonstrated

Across these projects, I have worked with SQL techniques including:

```sql
-- Filtering
WHERE

-- Aggregation
GROUP BY
HAVING
COUNT()
SUM()
AVG()
MIN()
MAX()

-- Combining data
INNER JOIN
LEFT JOIN
RIGHT JOIN

-- Conditional logic
CASE

-- Advanced querying
CTEs
Subqueries

-- Window functions
RANK()
DENSE_RANK()
ROW_NUMBER()
LAG()
LEAD()
```

The projects also involve building queries progressively—from basic data exploration to more advanced analytical queries involving **multiple tables, business logic, aggregations, CTEs, and window functions**.

---

## Repository Structure

```text
SQL_Projects/
|-- Car Part Sales Analysis Project/
|   |-- 0_create_database.sql ... 6_*.sql   load + analysis scripts
|   |-- archive/                            7 source CSVs
|   `-- README.md
|-- SQL_Project_Data_Job_analysis/
|   |-- sql_load/                           create DB, tables, \copy load
|   |-- project_sql/                        the four core questions
|   |-- advanced_sql/                       dates, CASE, CTEs
|   |-- csv_files/                          source CSVs (job_postings: see README)
|   `-- README.md
|-- Supply Chain analysis/
|   |-- 0_import.sql ... 6_*.sql            load + analysis scripts
|   |-- archive/                            supply_chain_data.csv
|   `-- README.md
|-- docs/                                  SQA_BASELINE.md, SQA_REPORT.md
|-- tests/                                 python + SQL data-quality checks
|-- .github/workflows/                     SQL QA CI
`-- README.md
```

---

## Approach

For each project, I follow a structured analytical process:

**1. Understand the business problem**
Identify what the organisation wants to understand or improve.

**2. Explore the data**
Examine tables, relationships, data types, missing values, and relevant fields.

**3. Build the analysis**
Start with exploratory queries and progressively develop more complex SQL.

**4. Answer business questions**
Use SQL to calculate relevant metrics and identify trends or patterns.

**5. Extract insights**
Translate query results into meaningful business findings.

---

## Tools

* **SQL** (PostgreSQL dialect — every project targets PostgreSQL)
* **PostgreSQL / psql** for loading and running the scripts
* **Python** for the repository's data-contract tests (standard library only)
* **SQLFluff** for linting
* **VS Code**
* **Git & GitHub**

---

## Getting Started

Each project has its own README with a copy-paste load/run sequence:

* [Car Part Sales Analysis](Car%20Part%20Sales%20Analysis%20Project/README.md)
* [SQL Project — Data Job Analysis](SQL_Project_Data_Job_analysis/README.md)
* [Supply Chain Analysis](Supply%20Chain%20analysis/README.md)

## Quality & Testing

```bash
python tests/python/test_sql_balance.py    # structural checks on every SQL file
python tests/python/validate_datasets.py   # dataset contract (row counts, keys, integrity)
python -m sqlfluff lint                    # correctness-oriented SQL lint
```

`tests/sql/` holds DB-backed checks with expected values inline; run them
manually after loading a project (local PostgreSQL uses `scram-sha-256` and
no credentials are stored in the repo). All three checks also run in CI on
every push via `.github/workflows/sql-qa.yml`.

Audit documentation: [baseline findings](docs/SQA_BASELINE.md) and
[post-fix report](docs/SQA_REPORT.md).

---

## About Me

I am an **IT graduate** interested in software development, data analysis, SQL, automation, and building technology-driven solutions to real-world business problems.

I created these projects to strengthen my ability to move beyond writing individual SQL statements and develop the **query-building and analytical reasoning skills** required to solve practical business problems with data.

---
