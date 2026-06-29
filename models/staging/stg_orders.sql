with source as (
    select * from {{ source('olist', 'orders') }}
)

select
    order_id,
    customer_id,
    order_status                                     as status,
    try_to_timestamp(order_purchase_timestamp)       as purchased_at,
    try_to_timestamp(order_approved_at)              as approved_at,
    try_to_timestamp(order_delivered_carrier_date)   as delivered_to_carrier_at,
    try_to_timestamp(order_delivered_customer_date)  as delivered_to_customer_at,
    try_to_timestamp(order_estimated_delivery_date)  as estimated_delivery_at
from source
