-- Geolocation has ~1M rows but only ~19k distinct zip prefixes.
-- Deduplicate to one row per prefix so it can be used as a clean lookup.
with source as (
    select * from {{ source('olist', 'geolocation') }}
),

deduped as (
    select
        geolocation_zip_code_prefix as zip_code_prefix,
        geolocation_lat             as latitude,
        geolocation_lng             as longitude,
        geolocation_city            as city,
        geolocation_state           as state,
        row_number() over (
            partition by geolocation_zip_code_prefix
            order by geolocation_lat
        ) as row_num
    from source
)

select
    zip_code_prefix,
    latitude,
    longitude,
    city,
    state
from deduped
where row_num = 1
