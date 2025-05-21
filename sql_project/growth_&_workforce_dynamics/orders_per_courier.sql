with pay_user as (
    select 
        time::date as date,
        count(distinct user_id) as paying_users
    from user_actions
    where order_id not in (select order_id from user_actions where action = 'cancel_order')
    group by date
),
act_courier as (
    select 
        time::date as date,
        count(distinct courier_id) as active_couriers
    from courier_actions
    where order_id not in (select order_id from user_actions where action = 'cancel_order')
    group by date
),
orders_t as (
    select 
        creation_time::date as date,
        count(distinct order_id) as total_orders
    from orders
    where order_id not in (select order_id from user_actions where action = 'cancel_order')
    group by date
)

select
    date,
    round(paying_users::decimal / ac.active_couriers, 2) as users_per_courier,
    round(ot.total_orders::decimal / ac.active_couriers, 2) as orders_per_courier
from pay_user
left join act_courier ac using(date)
left join orders_t ot using(date)
order by date;