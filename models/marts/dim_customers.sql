with customers as (
    select * from {{ ref('stg_customers') }}
),

geo as (
    select * from {{ ref('stg_geolocation') }}
)

select
    customers.customer_id,
    customers.customer_unique_id,
    customers.zip_code_prefix,
    customers.city,
    customers.state,
    geo.latitude,
    geo.longitude
from customers
left join geo on customers.zip_code_prefix = geo.zip_code_prefix
