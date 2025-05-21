with rev as (
 select
            date,
            sum(p.price)  as revenue
        from (select 
                order_id,
                creation_time::date as date,
                unnest(product_ids) as product_id
              from orders
              where order_id not in (select order_id from user_actions where action = 'cancel_order')) pr_id
        left join products as p using(product_id)
        group by date
        order by date
),
users_count as (
    select 
    time::date as date,
    count(DISTINCT user_id) as user_count
    from user_actions
    group by date
),
paying_us as (
    select
        time::date as date,
        count(DISTINCT user_id) as paying_user
    from user_actions
    where order_id not in (select order_id from user_actions where action = 'cancel_order')
    group by date
),
orders_count as(
    select
        creation_time::date as date,
        count(distinct order_id) as order_count
    from orders
    where order_id not in (select order_id from user_actions where action = 'cancel_order')
    group by date
)

select 
    date,
    round(revenue::decimal / uc.user_count, 2) as arpu,
    round(revenue::decimal / pu.paying_user, 2) as arppu,
    round(revenue::decimal / oc.order_count, 2) as aov
from rev
left join users_count uc using(date)
left join paying_us pu using(date)
left join orders_count oc using(date)
order by date;