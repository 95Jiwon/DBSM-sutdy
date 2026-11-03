SELECT
    o.order_id,
    o.status,
    r.name AS restaurant_name
FROM
    orders o
    JOIN restaurants r
    ON o.restaurant_id = r.restaurant_id
order by o.order_id;

SELECT * FROM restaurants;
SELECT * FROM orders;

SELECT
    *
FROM
    orders, restaurants
WHERE
    orders.restaurant_id = restaurants.restaurant_id
ORDER BY
    orders.order_id;

SELECT
    *
FROM
    orders o inner join restaurants r ON r.restaurant_id = o.restaurant_id
ORDER BY
    o.order_id;

SELECT
    *
FROM
    orders o
    left join order_items oi on oi.order_id = o.order_id
    left join menus mn on mn.menu_id = oi.menu_id
    left join reviews rv on rv.order_id = o.order_id
    left join customers ct on ct.customer_id = o.customer_id
    left join restaurants rt on rt.restaurant_id = o.restaurant_id
    left join riders rd on rd.rider_id = o.rider_id
WHERE
    ct.name ='윤지아';

SELECT
    COUNT(*)
FROM
    orders o
    LEFT outer join reviews rv on rv.order_id = o.order_id
WHERE
    rv.review_id is null;

SELECT
    o.order_id,
    o.status,
    rd.name AS rider_name
FROM orders o
    LEFT JOIN riders rd
    ON rd.rider_id = o.rider_id
WHERE o.ordered_at >= '2026-06-30'
ORDER BY o.order_id;

SELECT
    o.restaurant_id,
    rt.name,
    count(distinct o.order_id),
    sum(oi.quantity * oi.unit_price)
FROM
    orders o
    INNER JOIN restaurants rt on rt.restaurant_id = o.restaurant_id
    INNER JOIN order_items oi on oi.order_id = o.order_id
GROUP BY
    o.restaurant_id,
    rt.name;

SELECT DATE_FORMAT(o.ordered_at, '%Y-%m') AS order_month,
       COUNT(DISTINCT o.order_id) AS deliverd_orders,
       SUM(oi.quantity * oi.unit_price) AS food_sales,
       ROUND(SUM(oi.quantity * oi.unit_price)
            / COUNT(DISTINCT o.order_id)) AS avg_food_per_order
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = '배달완료'
GROUP BY order_month
ORDER BY order_month;

SELECT
    r.name AS restaurant_name,
    mn.name AS menu_name,
    mn.price
FROM
    restaurants r
    LEFT JOIN menus mn on r.restaurant_id = mn.restaurant_id
WHERE
    r.category like '%치킨%'
ORDER BY
    r.restaurant_id,
    mn.price DESC;

SELECT
    rd.name AS rider_name,
    rd.vehicle,
    COUNT(od.order_id) AS deliveries
FROM
    riders rd
    JOIN orders od on rd.rider_id = od.rider_id
WHERE
    od.status like '%완료'
GROUP BY
    rd.rider_id,
    rd.name,
    rd.vehicle
ORDER BY
    deliveries DESC;

SELECT
    rv.review_id,
    rv.rating,
    rt.name AS restaurant_name,
    cm.name AS customer_name,
    rv.content
FROM
    reviews rv
    LEFT JOIN orders od ON od.order_id = rv.order_id
    LEFT JOIN restaurants rt ON rt.restaurant_id = od.restaurant_id
    LEFT JOIN customers cm ON cm.customer_id = od.customer_id
WHERE
    rv.rating <=2
ORDER BY
    rv.created_at DESC
LIMIT 10;

SELECT
    od.order_id,
    od.status,
    cm.name AS customer_name,
    rt.name AS restaurant_name,
    rd.name AS rider_name,
    od.ordered_at
FROM
    orders od
    LEFT JOIN customers cm ON cm.customer_id = od.customer_id
    LEFT JOIN restaurants rt ON rt.restaurant_id = od.restaurant_id
    LEFT JOIN riders rd ON rd.rider_id = od.rider_id
WHERE
    od.ordered_at < '2026-06-30 19%'
    AND od.status IN ('접수', '조리중', '배달중')

SELECT
    rt.name AS restaurant_name,
    ROUND(avg(rv.rating), 2) AS avg_rating,
    COUNT(rv.review_id) AS review_count
FROM
    restaurants rt
    LEFT JOIN orders od ON od.restaurant_id = rt.restaurant_id
    LEFT JOIN reviews rv ON rv.order_id = od.order_id
GROUP BY
    rt.restaurant_id,
    rt.name
HAVING
    COUNT(rv.review_id) >= 10
ORDER BY
    avg_rating DESC;

SELECT
    rt.name AS restaurant_name,
    mn.name AS menu_name,
    SUM(oi.quantity) AS sold_quantity
FROM
    order_items oi
    JOIN orders od ON od.order_id = oi.order_id
    JOIN menus mn ON mn.menu_id = oi.menu_id
    JOIN restaurants rt ON rt.restaurant_id = mn.restaurant_id
WHERE
    od.ordered_at BETWEEN '2026-01-01' AND '2026-06-30'
GROUP BY
    rt.name,
    mn.name,
    mn.menu_id
ORDER BY
    sold_quantity DESC,
    mn.menu_id ASC
LIMIT 5;

SELECT
    *
FROM
    order_items;

SELECT
    *
FROM
    menus;

SELECT
    mn.name AS menu_name,
    unit_price,
    current_price,
    sold_quantity
FROM
    order_items oi
    LEFT OUTER JOIN menus mn ON mn.menu_id = oi.menu_id
    LEFT OUTER JOIN orders od ON od.order_id = oi.order_id;


SELECT
    mn.name AS menu_name,
    oi.unit_price,
    mn.price AS current_price,
    SUM(oi.quantity) AS sold_quantity
FROM
    order_items oi
        INNER JOIN menus mn ON mn.menu_id = oi.menu_id AND mn.price != oi.unit_price
        INNER JOIN orders od ON od.order_id = oi.order_id
        AND od.status = '배달완료'
GROUP BY
    oi.menu_id,
    mn.name,
    oi.unit_price,
    mn.price
ORDER BY
    oi.menu_id;

SELECT
    rt.name AS restaurant_name,
    COUNT(od.order_id) AS delivered_orders,
    COUNT(rv.review_id) AS reviewed,
    ROUND((COUNT(rv.order_id) / COUNT(od.order_id) * 100 ), 1)AS review_rate
FROM
    restaurants rt
    LEFT OUTER JOIN orders od ON od.restaurant_id = rt.restaurant_id
    AND od.status ='배달완료'
    LEFT OUTER JOIN reviews rv ON rv.order_id = od.order_id
GROUP BY
    rt.restaurant_id,
    rt.name
ORDER BY
    review_rate DESC;


SELECT
    date_FORMAT(ordered_at, '%Y-%m') AS order_month,
    SUM(if(rt.category='한식', oi.quantity * oi.unit_price, 0)) AS korean,
    SUM(if(rt.category='중식', oi.quantity * oi.unit_price, 0)) AS chinese,
    SUM(if(rt.category='치킨', oi.quantity * oi.unit_price, 0)) AS chicken,
    SUM(if(rt.category='피자', oi.quantity * oi.unit_price, 0)) AS pizza,
    SUM(oi.quantity * oi.unit_price) as all_categories
FROM
    orders od
    INNER JOIN order_items oi ON oi.order_id = od.order_id
    AND od.status = '배달완료'
    LEFT OUTER JOIN restaurants rt ON rt.restaurant_id = od.restaurant_id
GROUP BY
    DATE_FORMAT(ordered_at, '%Y-%m')