-- Roll item-level measures up to one row per order.
with items as (
    select * from {{ ref('int_order_items_enriched') }}
)

select
    order_id,
    count(*)                   as item_count,
    count(distinct product_id) as distinct_product_count,
    count(distinct seller_id)  as distinct_seller_count,
    sum(price)                 as total_item_price,
    sum(freight_value)         as total_freight_value,
    sum(item_total)            as total_order_value
from items
group by order_id
