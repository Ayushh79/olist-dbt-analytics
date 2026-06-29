-- Singular test: no order should have a negative total value.
-- A singular test is just a SELECT. It PASSES when it returns zero rows,
-- and FAILS if it returns any (those rows are the offenders).
select
    order_id,
    total_order_value
from {{ ref('fct_orders') }}
where total_order_value < 0
