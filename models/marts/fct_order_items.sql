-- Order-item fact table: one row per item within an order.
with items as (
    select * from {{ ref('int_order_items_enriched') }}
)

select
    md5(order_id || '-' || cast(order_item_id as varchar)) as order_item_key,  -- surrogate key
    order_id,
    order_item_id,
    product_id,
    seller_id,
    product_category,
    seller_state,
    price,
    freight_value,
    item_total,
    shipping_limit_at
from items
