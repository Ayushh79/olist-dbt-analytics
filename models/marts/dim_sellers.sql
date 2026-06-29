with sellers as (
    select * from {{ ref('stg_sellers') }}
),

geo as (
    select * from {{ ref('stg_geolocation') }}
)

select
    sellers.seller_id,
    sellers.zip_code_prefix,
    sellers.city,
    sellers.state,
    geo.latitude,
    geo.longitude
from sellers
left join geo on sellers.zip_code_prefix = geo.zip_code_prefix
