with pr_id as(
select 
    order_id,
    creation_time::date as date,
    unnest(product_ids) as product_id
from orders
where order_id not in (select order_id from user_actions where action = 'cancel_order')
)
select
    date,
    revenue,
    total_revenue,
    round((revenue - lag(revenue) OVER(ORDER BY date))*100 / lag(revenue) OVER(ORDER BY date)::decimal, 2) as revenue_change
from (select
        date,
        revenue,
        sum(revenue) OVER(ORDER BY date) as total_revenue
    from (select
            date,
            sum(p.price)  as revenue
        from pr_id
        left join products as p using(product_id)
        group by date
        order by date) t1
) t2;

