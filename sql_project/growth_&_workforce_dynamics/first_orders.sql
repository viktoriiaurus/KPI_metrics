with order_count as ( 
    SELECT
        time::date as date,
        count(order_id) as orders
    from user_actions
    where order_id not in (select order_id from user_actions where action = 'cancel_order')
    group by date
    order by date
), 
first_order as (  
    select
        date,
        count(distinct user_id) as first_orders
    from (select 
            user_id,
            min(time::date) as date
        from user_actions
        where order_id not in (select order_id from user_actions where action = 'cancel_order')
        group by user_id 
        order by date) t1
    group by date
),
new_users as (  
    select
        t2.date as date,
        count(order_id) as new_users_orders
    from (select 
            min(time::date) as date,
            user_id
        from user_actions
        group by user_id) t2
    join user_actions ua ON t2.user_id = ua.user_id and t2.date = ua.time::date
    where order_id not in (select order_id from user_actions where action = 'cancel_order')
    group by t2.date
)

select 
    date,
    orders,
    fo.first_orders as first_orders,
    nu.new_users_orders as new_users_orders,
    round(100*fo.first_orders::decimal / orders, 2) as first_orders_share, 
    round(100*nu.new_users_orders::decimal / orders, 2) as new_users_orders_share 
from order_count
left join first_order fo using(date)
left join new_users nu using(date)
order by date;