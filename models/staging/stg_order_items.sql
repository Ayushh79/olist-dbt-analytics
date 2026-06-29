with source as (
    select * from {{ source('olist', 'order_items') }}
)

select
    order_id,
    order_item_id,
    product_id,
    seller_id,
    try_to_timestamp(shipping_limit_date) as shipping_limit_at,
    price::number(10,2)                    as price,
    freight_value::number(10,2)            as freight_value
from source
