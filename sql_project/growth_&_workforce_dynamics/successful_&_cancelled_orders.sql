with suc_ord as (
    SELECT
        extract(hour from creation_time) ::integer as hour,
        count(distinct order_id) as successful_orders
    from
        orders
    where order_id not in (select order_id from user_actions where action = 'cancel_order')
    group by extract(hour from creation_time)
    order by hour
),
canc_ord as (
    SELECT
        extract(hour from creation_time)::integer as hour,
        count(distinct order_id) as canceled_orders
    from orders
    where order_id in (select order_id from user_actions where action = 'cancel_order')
    group by extract(hour from creation_time)
    order by hour
)
    
select
    hour,
    successful_orders,
    co.canceled_orders,
    round(co.canceled_orders::decimal / (successful_orders + co.canceled_orders), 3) as cancel_rate
from suc_ord
left join canc_ord co using(hour);