with pay_users as (
    SELECT time::date as date,
                      count(distinct user_id) as paying_users
               FROM   user_actions
               WHERE  order_id not in (SELECT order_id
                                       FROM   user_actions
                                       WHERE  action = 'cancel_order')
               GROUP BY date             
),

single_order as(
    select
        date,
        count(user_id) as single_order_users
    from    (select 
            time::date as date,
            user_id,
            count(order_id) as user_orders
        from user_actions
        WHERE  order_id not in (SELECT order_id
                                           FROM   user_actions
                                           WHERE  action = 'cancel_order')
        GROUP BY date, user_id 
        having count(distinct order_id) = 1) t1
    group by date
),

several_orders as (
    select
        date,
        count(user_id) as several_orders_users
    from    (select 
            time::date as date,
            user_id,
            count(order_id) as orders_user
        from user_actions
        WHERE  order_id not in (SELECT order_id
                                           FROM   user_actions
                                           WHERE  action = 'cancel_order')
        GROUP BY date, user_id 
        having count(distinct order_id) > 1) t2
    group by date
)

SELECT
    pu.date,
    round((so.single_order_users::decimal / pu.paying_users)*100, 2) as single_order_users_share,
    round((sv.several_orders_users::decimal / pu.paying_users)*100, 2) as several_orders_users_share
FROM pay_users pu
left join single_order so using(date)
left join several_orders sv using(date)
order by pu.date;