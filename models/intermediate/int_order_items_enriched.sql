-- Item grain: each order item joined to its product, category, and seller.
with order_items as (
    select * from {{ ref('stg_order_items') }}
),

products as (
    select * from {{ ref('stg_products') }}
),

categories as (
    select * from {{ ref('stg_product_category_translation') }}
),

sellers as (
    select * from {{ ref('stg_sellers') }}
)

select
    order_items.order_id,
    order_items.order_item_id,
    order_items.product_id,
    order_items.seller_id,
    order_items.price,
    order_items.freight_value,
    order_items.price + order_items.freight_value as item_total,
    order_items.shipping_limit_at,
    products.product_category_name,
    coalesce(categories.category_name_english, products.product_category_name, 'unknown') as product_category,
    products.product_weight_g,
    sellers.state as seller_state,
    sellers.city  as seller_city
from order_items
left join products   on order_items.product_id = products.product_id
left join categories on products.product_category_name = categories.product_category_name
left join sellers    on order_items.seller_id = sellers.seller_id
