-- An order can have several payment rows; aggregate to one row per order.
with payments as (
    select * from {{ ref('stg_order_payments') }}
)

select
    order_id,
    sum(payment_value)                    as total_payment_value,
    count(*)                              as payment_count,
    max(payment_installments)             as max_installments,
    listagg(distinct payment_type, ', ')  as payment_types
from payments
group by order_id
