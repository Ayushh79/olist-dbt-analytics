-- An order can have more than one review; aggregate to one row per order.
with reviews as (
    select * from {{ ref('stg_order_reviews') }}
)

select
    order_id,
    avg(review_score) as avg_review_score,
    count(*)          as review_count,
    max(created_at)   as latest_review_at
from reviews
group by order_id
