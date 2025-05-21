with rev_tax_tr as (
    select 
        date,
        sum(price) as revenue,
        sum(sum(price)) over(order by date) as total_revenue,
        sum(tax) as tax
    from (SELECT
            date,
            p.price as price,
            CASE
                WHEN p.name IN (
                    'сахар', 'сухарики', 'сушки', 'семечки', 
                    'масло льняное', 'виноград', 'масло оливковое', 
                    'арбуз', 'батон', 'йогурт', 'сливки', 'гречка', 
                    'овсянка', 'макароны', 'баранина', 'апельсины', 
                    'бублики', 'хлеб', 'горох', 'сметана', 'рыба копченая', 
                    'мука', 'шпроты', 'сосиски', 'свинина', 'рис', 
                    'масло кунжутное', 'сгущенка', 'ананас', 'говядина', 
                    'соль', 'рыба вяленая', 'масло подсолнечное', 'яблоки', 
                    'груши', 'лепешка', 'молоко', 'курица', 'лаваш', 'вафли', 'мандарины'
                ) THEN ROUND(p.price * 10 / 110, 2)
                ELSE ROUND(p.price * 20 / 120, 2)
            END AS tax
          from (SELECT creation_time::date as date, 
            unnest(product_ids) as product_id
            from orders
            where order_id not in (select order_id from user_actions where action = 'cancel_order')) pd
        left join products p using (product_id)) t1
    group by date
    order by date
),
fixed_cost as(
select 
    date,
    CASE
        when date < '2022-09-01' then 120000
        else 150000
    end as fixed_costs
from (select
        count(order_id) as orders_count,
        creation_time::date as date
    from orders
    where order_id not in (select order_id from user_actions where action = 'cancel_order')
    group by date) t1
group by date
order by date
),
zbir_cost as (
    select
        date,
        CASE
            when date < '2022-09-01' then sum(orders_count)*140
            else sum(orders_count)*115
        end as zbir_cost
    from (select creation_time::date as date,
            count(distinct order_id) as orders_count
        from orders
        where order_id not in (select order_id from user_actions where action = 'cancel_order')
        group by date) t1
    group by date
    order by date
),
delivery_cost as(
    select 
        date,
        sum(orders_count)*150 as delivery_cost
 from (select courier_id,
        count(distinct order_id) as orders_count,
            time::date as date
        from courier_actions
        where action = 'deliver_order'
        group by date, courier_id
        ) t1
    group by date
),
bonus as (
select
    date,
    SUM(
        CASE 
            WHEN orders_count >= 5 THEN
                CASE 
                    WHEN date < '2022-09-01' THEN 400
                    ELSE 500
                END
            ELSE 0
        END
    ) AS total_bonus
 from (select courier_id,
        count(distinct order_id) as orders_count,
            time::date as date
        from courier_actions
        where action = 'deliver_order'
        group by date, courier_id
        ) t1
    group by date
),
order_costs as (
    select
        fc.date as date,
        fc.fixed_costs + zc.zbir_cost + dc.delivery_cost + b.total_bonus as costs
    from fixed_cost fc
    left join zbir_cost zc using(date)
    left join delivery_cost dc using(date)
    left join bonus b using(date)
)

select
    date,
    revenue,
    costs,
    tax,
    gross_profit,
    total_revenue,
    sum(costs) over(order by date) as total_costs,
    total_tax,
    total_gross_profit,
    gross_profit_ratio,
    round(100*total_gross_profit::decimal / total_revenue, 2) as total_gross_profit_ratio
from (select
        date,
            revenue,
            costs,
            tax,
            gross_profit,
            total_revenue,
            total_tax,
            round(sum(gross_profit) over(order by date), 2) as total_gross_profit,
            round(100*gross_profit::decimal / revenue, 2) as gross_profit_ratio
    from (select
            date,
            revenue,
            oc.costs as costs,
            tax, 
            sum(revenue - oc.costs - tax) over(partition by date) as gross_profit,
            total_revenue,
            sum(tax) over(order by date) as total_tax
        from rev_tax_tr
        left join order_costs oc using(date)) t1 ) t2;