with source as (
    select * from {{ source('olist', 'order_reviews') }}
)

select
    review_id,
    order_id,
    review_score,
    review_comment_title                           as comment_title,
    review_comment_message                         as comment_message,
    try_cast(review_creation_date   as timestamp)  as created_at,
    try_cast(review_answer_timestamp as timestamp) as answered_at
from source