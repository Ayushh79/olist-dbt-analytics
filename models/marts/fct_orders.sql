-- Order fact table: one row per order, with delivery, payment, and review measures.
with orders as (
    select * from {{ ref('stg_orders') }}
),

items as (
    select * from {{ ref('int_order_items_by_order') }}
),

payments as (
    select * from {{ ref('int_payments_by_order') }}
),

reviews as (
    select * from {{ ref('int_reviews_by_order') }}
)

select
    orders.order_id,
    orders.customer_id,
    orders.status as order_status,

    -- timestamps
    orders.purchased_at,
    orders.approved_at,
    orders.delivered_to_customer_at,
    orders.estimated_delivery_at,

    -- delivery performance (days)
    datediff('day', orders.purchased_at, orders.delivered_to_customer_at)          as delivery_days,
    datediff('day', orders.estimated_delivery_at, orders.delivered_to_customer_at) as days_vs_estimate,

    -- item measures
    coalesce(items.item_count, 0)             as item_count,
    coalesce(items.distinct_product_count, 0) as distinct_product_count,
    coalesce(items.distinct_seller_count, 0)  as distinct_seller_count,
    coalesce(items.total_item_price, 0)       as total_item_price,
    coalesce(items.total_freight_value, 0)    as total_freight_value,
    coalesce(items.total_order_value, 0)      as total_order_value,

    -- payment measures
    payments.total_payment_value,
    payments.payment_count,
    payments.max_installments,
    payments.payment_types,

    -- review measures
    reviews.avg_review_score,
    reviews.review_count
from orders
left join items    on orders.order_id = items.order_id
left join payments on orders.order_id = payments.order_id
left join reviews  on orders.order_id = reviews.order_id
