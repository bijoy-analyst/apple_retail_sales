# Sales & Warranty Analytics — SQL Collection

This repository contains a curated set of SQL scripts to solve common business questions for a retail dataset (tables: `sales`, `stores`, `products`, `category`, `warranty`).  
Files included:

- `create_indexes.sql` — Index creation and an `EXPLAIN ANALYZE` example to improve query performance.
- `queries.sql` — Corrected, annotated SQL queries answering 14 business questions (counts, aggregations, window functions, temporal filters).

## Assumptions
- `sales.sale_id` is the primary key on sales and is linked by `warranty.sale_id`.
- `sales.store_id` matches `stores."Store_ID"`.
- Dates are stored in date/timestamp formats or as castable strings (queries cast to date where needed).
- Product and category columns use the quoted names seen in your examples (e.g. `"Product_ID"`, `"Category_ID"`). Adjust names if your schema differs.

## How to use
1. Review `create_indexes.sql` and run it first to create helpful indexes (only if appropriate for your workload).
2. Run `queries.sql` in your SQL client (psql, PgAdmin, DBeaver, etc.).  
   - Some queries use `CURRENT_DATE` to compute "last 1 year" or "last 3 years".
   - If performance is a concern, use `EXPLAIN ANALYZE` on the heavy queries to inspect query plans and add indexes accordingly.

## Notes & Improvements
- Consider partitioning `sales` by `sale_date` (monthly or yearly) if table grows large.
- For analytical workloads, create aggregated summary tables (daily/monthly totals) refreshed nightly.
- Use `NULLIF(...,0)` when computing percentages to avoid division-by-zero.
- Text fields used for dates should be normalized to `DATE` or `TIMESTAMP` for better performance.

## Troubleshooting common errors
- `GROUP BY` must include all non-aggregated columns.
- When using window functions like `RANK()` in grouped results, ensure partition keys match grouping keys.
- For queries using quoted identifiers (e.g. `"Store_ID"`), maintain exact case sensitivity.

## License
Feel free to use and adapt these scripts. No license attached — treat as public domain for your convenience.

