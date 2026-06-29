# Olist Analytics — dbt + Snowflake

An analytics-engineering project that transforms the [Olist Brazilian E-Commerce](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
dataset (~100k orders, 2016–2018) into a tested, documented **star schema** using **dbt** on **Snowflake**.

Raw CSVs land in a `RAW` schema, then dbt models them through three layers —
**staging → intermediate → marts** — producing fact and dimension tables ready for BI and analysis.

## Architecture

```
RAW (Snowflake)            staging (views)         intermediate (views)        marts (tables)
─────────────────          ─────────────────       ──────────────────────      ────────────────
customers          ──────▶ stg_customers       ─┐
orders             ──────▶ stg_orders           │
order_items        ──────▶ stg_order_items     ─┼─▶ int_order_items_enriched ─▶ fct_order_items
order_payments     ──────▶ stg_order_payments   │   int_order_items_by_order ─┐
order_reviews      ──────▶ stg_order_reviews    │   int_payments_by_order    ─┼▶ fct_orders
products           ──────▶ stg_products         │   int_reviews_by_order     ─┘
sellers            ──────▶ stg_sellers          │                              dim_customers
geolocation        ──────▶ stg_geolocation     ─┘                              dim_products
category_translation ────▶ stg_product_category_translation                    dim_sellers
```

- **Staging (`stg_`)** — one model per raw table. Light cleaning only: rename, cast types,
  fix the dataset's two misspelled product columns, dedupe geolocation to one row per zip.
  Materialized as **views**.
- **Intermediate (`int_`)** — joins and aggregations. Order items are enriched with product/seller
  attributes, then items, payments, and reviews are each rolled up to one row per order.
  Materialized as **views**.
- **Marts (`fct_`/`dim_`)** — the star schema. `fct_orders` (one row per order) and
  `fct_order_items` (one row per line item) hold the measures; `dim_customers`, `dim_products`,
  and `dim_sellers` hold descriptive attributes. Materialized as **tables**.

## Data quality

Tested with dbt generic tests (`unique`, `not_null`, `accepted_values`, `relationships`) declared
in YAML, plus one singular test (`tests/assert_fct_orders_total_value_non_negative.sql`) asserting
that no order has a negative total value. Primary keys and key foreign-key relationships are
enforced across every layer.

## Stack

- **dbt-snowflake** (Python 3.12)
- **Snowflake** (XS warehouse)
- Raw load via `snowflake-connector-python` + pandas (`load_raw.py`, not committed)

## Running it

```bash
# from the project root, with the virtual environment active
dbt debug      # validate the Snowflake connection
dbt run        # build all models
dbt test       # run all tests
dbt build      # run + test together, in dependency order
```

Generate and view the documentation and lineage graph:

```bash
dbt docs generate
dbt docs serve
```

## Project layout

```
olist_analytics/
├── dbt_project.yml
├── models/
│   ├── staging/        # stg_*.sql + _sources.yml + _staging.yml
│   ├── intermediate/   # int_*.sql + _intermediate.yml
│   └── marts/          # fct_*/dim_*.sql + _marts.yml
├── tests/              # singular tests
└── README.md
```

## Possible extensions

- Convert `fct_orders` to an **incremental** model keyed on `purchased_at` for large daily loads.
- Add `dbt source freshness` once a reliable load-timestamp column is available.
- Split layers into separate schemas (`DEV_staging`, `DEV_marts`) via `+schema` configs.
- Add the `dbt_utils` package for surrogate-key generation and extra generic tests.
