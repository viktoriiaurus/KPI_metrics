WITH product_price AS (
    SELECT 
        p.name AS product_name,
        SUM(p.price) AS revenue
    FROM (
        SELECT 
            order_id,
            creation_time::date AS date,
            unnest(product_ids) AS product_id
        FROM orders
        WHERE order_id NOT IN (
            SELECT order_id FROM user_actions WHERE action = 'cancel_order'
        )
    ) pr_id
    LEFT JOIN products AS p USING(product_id)
    GROUP BY p.name
),
rev AS (
    SELECT 
        SUM(p.price) AS total_revenue
    FROM (
        SELECT unnest(product_ids) AS product_id 
        FROM orders
        WHERE order_id NOT IN (
            SELECT order_id FROM user_actions WHERE action = 'cancel_order'
        )
    ) pd 
    LEFT JOIN products AS p USING(product_id)
),
final AS (
    SELECT 
        pp.product_name,
        pp.revenue,
        ROUND(100 * pp.revenue::decimal / r.total_revenue, 2) AS share_in_revenue
    FROM product_price pp
    CROSS JOIN rev r
)

SELECT 
    CASE 
        WHEN share_in_revenue < 0.5 THEN 'ДРУГОЕ'
        ELSE product_name
    END AS product_name,
    SUM(revenue) AS revenue,
    SUM(share_in_revenue) AS share_in_revenue
FROM final
GROUP BY 
    CASE 
        WHEN share_in_revenue < 0.5 THEN 'ДРУГОЕ'
        ELSE product_name
    END
ORDER BY share_in_revenue DESC;

SELECT product_name,
       sum(revenue) as revenue,
       sum(share_in_revenue) as share_in_revenue
FROM   (SELECT case when round(100 * revenue / sum(revenue) OVER (), 2) >= 0.5 then name
                    else 'ДРУГОЕ' end as product_name,
               revenue,
               round(100 * revenue / sum(revenue) OVER (), 2) as share_in_revenue
        FROM   (SELECT name,
                       sum(price) as revenue
                FROM   (SELECT order_id,
                               unnest(product_ids) as product_id
                        FROM   orders
                        WHERE  order_id not in (SELECT order_id
                                                FROM   user_actions
                                                WHERE  action = 'cancel_order')) t1
                    LEFT JOIN products using(product_id)
                GROUP BY name) t2) t3
GROUP BY product_name
ORDER BY share_in_revenue desc;
