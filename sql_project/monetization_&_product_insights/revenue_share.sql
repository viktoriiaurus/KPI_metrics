with rev as (
    SELECT 
        date,
        sum(p.price) as revenue
    FROM   (SELECT order_id,
                    creation_time::date as date,
                    unnest(product_ids) as product_id
            FROM   orders
            WHERE  order_id not in (SELECT order_id
                                        FROM   user_actions
                                        WHERE  action = 'cancel_order')) pr_id
    LEFT JOIN products as p using(product_id)
    GROUP BY date
    ORDER BY date
), 
new_us as (
    SELECT user_id,
            min(time::date) as date
    FROM   user_actions
    GROUP BY user_id
), 
orders_price as (
    SELECT
        order_id,
        date,
        ua.user_id as user_id,
        sum(p.price) as order_price
    FROM (SELECT order_id,
            creation_time::date as date,
            unnest(product_ids) as product_id
        FROM   orders
        WHERE  order_id not in (SELECT order_id
                                FROM   user_actions
                                WHERE  action = 'cancel_order')) pr
    LEFT JOIN products as p using(product_id)
    LEFT JOIN user_actions ua using(order_id)
    GROUP BY order_id, date, ua.user_id
    ORDER BY date
),
users_rev as (
    select 
        op.date as date,
        sum(op.order_price) as new_users_revenue
    from orders_price op
    left join new_us nu using(user_id)
    where op.date = nu.date
    group by op.date
)

SELECT 
    date,
    r.revenue as revenue,
    new_users_revenue,
    round((100*new_users_revenue::decimal / r.revenue), 2) as new_users_revenue_share,
    round((100*(r.revenue - new_users_revenue)::decimal / r.revenue), 2) as old_users_revenue_share
FROM   users_rev
    LEFT JOIN rev r using(date)
ORDER BY date;