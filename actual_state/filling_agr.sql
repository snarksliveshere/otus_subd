INSERT INTO product(title, slug, product_category_id, product_status_id, vendor_id, is_sku, price)
WITH RECURSIVE cte (n) AS (
    SELECT 1                                    AS inc
         , (SELECT 'first_record_title')        AS title
         , (SELECT 'first_record_slug')         AS slug
         , (WITH rand_range AS (select id,
                                       (row_number() OVER ()) AS num
                                FROM product_category)
            SELECT id
            FROM rand_range
            WHERE num =
                  (SELECT trunc(random() * MAX(num) + 1) FROM rand_range)
    )                                           AS product_category_id
         , (SELECT MIN(id) FROM product_status) AS product_status_id
         , (SELECT MIN(id) FROM vendor)         AS vendor_id
         , TRUE                                 AS is_sku
         , (SELECT 1) :: integer                AS price
    UNION ALL
    SELECT n + 1
         , (SELECT (
                       SELECT string_agg(x
                                  , '')
                       FROM (
                                SELECT chr(ascii('a') + floor(random() * 26)::integer +
                                           (n ::integer - (n :: integer + 1)))
                                FROM generate_series(1
                                         , 20 + b * 0)
                            ) AS y (x)
                   )
            FROM generate_series(1
                     , 1) as a(b)) AS title
         , (SELECT (
                       SELECT string_agg(x
                                  , '')
                       FROM (
                                SELECT chr(ascii('a') + floor(random() * 26)::integer +
                                           (n ::integer - (n :: integer + 1)))
                                FROM generate_series(1
                                         , 20 + b * 0)
                            ) AS y (x)
                   )
            FROM generate_series(1
                     , 1) as a(b)) AS slug
         , (WITH rand_range AS (select id
                                        ,
                                       (row_number() OVER ()) AS num
                                FROM product_category)
            SELECT id
            FROM rand_range
            WHERE num =
                  (SELECT trunc(random() * MAX(num) + 1 + (n :: integer - n ::integer)) FROM rand_range)
    )                              AS product_category_id
         , (WITH rand_range AS (select id
                                        ,
                                       (row_number() OVER ()) AS num
                                FROM product_status)
            SELECT id
            FROM rand_range
            WHERE num =
                  (SELECT trunc(random() * MAX(num) + 1 + (n :: integer - n ::integer)) FROM rand_range)
    )                              AS product_status_id
         , (WITH rand_range AS (select id
                                        ,
                                       (row_number() OVER ()) AS num
                                FROM vendor)
            SELECT id
            FROM rand_range
            WHERE num =
                  (SELECT trunc(random() * MAX(num) + 1 + (n :: integer - n ::integer)) FROM rand_range)
    )                              AS vendor_id
         , CASE WHEN (SELECT trunc(random() * 2 + (n :: integer - n ::integer))) = 0 THEN FALSE ELSE TRUE END
         , (SELECT trunc(random() * 5000 + (n :: integer + 1 - n ::integer))) :: integer
    FROM cte
    WHERE n < 400
)
SELECT title, slug, product_category_id, product_status_id, vendor_id, is_sku, price
FROM cte;

-- sku
INSERT INTO sku(sku, name, price, product_id)
WITH RECURSIVE cte (n) AS (
    SELECT 1                                                 AS inc
         , (SELECT 'first_record_sku1')                      AS sku
         , (SELECT 'first_record_sku_name1')                 AS name
         , (SELECT MIN(id) FROM product WHERE is_sku = TRUE) AS product_id
         , (SELECT 1) :: integer                             AS price
    UNION ALL
    SELECT n + 1
         , (SELECT (
                       SELECT string_agg(x
                                  , '')
                       FROM (
                                SELECT chr(ascii('a') + floor(random() * 26)::integer +
                                           (n ::integer - (n :: integer + 1)))
                                FROM generate_series(1
                                         , 20 + b * 0)
                            ) AS y (x)
                   )
            FROM generate_series(1
                     , 1) as a(b)) AS title
         , (SELECT (
                       SELECT string_agg(x
                                  , '')
                       FROM (
                                SELECT chr(ascii('a') + floor(random() * 26)::integer +
                                           (n ::integer - (n :: integer)))
                                FROM generate_series(1
                                         , 20 + b * 0)
                            ) AS y (x)
                   )
            FROM generate_series(1
                     , 1) as a(b)) AS slug
         , (WITH rand_range AS (select id
                                        ,
                                       (row_number() OVER ()) AS num
                                FROM product
                                WHERE product.is_sku = TRUE)
            SELECT id
            FROM rand_range
            WHERE num =
                  (SELECT trunc(random() * MAX(num) + 1 + (n :: integer - n ::integer)) FROM rand_range)
    )
         , (SELECT trunc(random() * 5000 + (n :: integer + 1 - n ::integer))) :: integer
    FROM cte
    WHERE n < 400
)
SELECT sku, name, price, product_id
FROM cte;


ALTER TABLE customer
    DROP COLUMN type;
DROP TYPE customer_type;

CREATE TABLE public.customer_type
(
    id   SMALLSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    CONSTRAINT public_customer_type_name_ui UNIQUE (name)
);

INSERT INTO public.customer_type (name)
VALUES ('person'),
       ('legal');

ALTER TABLE public.customer
    ADD COLUMN customer_type_id SMALLINT NOT NULL DEFAULT 1;

INSERT INTO public.payment (name, is_active)
VALUES ('наличный расчет', TRUE),
       ('безналичный расчет', TRUE);
INSERT INTO public.delivery (name, is_active)
VALUES ('самовывоз', TRUE),
       ('курьер', TRUE);
INSERT INTO public.customer_address
    (phone, country, zip, region, street, building, room)
VALUES ('123456', 'Canada', '25825', 'SouthWest', 'prince Albert', '12/4', '202A')

INSERT INTO customer ( name
                     , surname
                     , patronymic
                     , login
                     , email
                     , password
                     , customer_address_id)
VALUES ( 'Doe'
       , 'J'
       , 'John'
       , 'jdoe'
       , 'jdoe@email.com'
       , 'hashpass'
       , 1)
;

-- filling shop order


INSERT INTO shop_order(weight, distance, cart_cost, cost, customer_id, delivery_id, created_at)
WITH RECURSIVE cte (n) AS (
    SELECT 1                                     AS inc
         , (SELECT 5) :: integer                 AS weight
         , (SELECT 5) :: integer                 AS distance
         , (SELECT 1) :: integer                 AS cart_cost
         , (SELECT 12) :: integer                AS cost
         , (SELECT MIN(id) FROM public.customer) AS customer_id
         , (SELECT MIN(id) FROM public.delivery) AS delivery_id
         , (SELECT NOW() + INTERVAL '1 second')  AS created_at

    UNION ALL
    SELECT n + 1
         , (SELECT trunc(random() * 15000 + (n :: integer + 1 - n ::integer))) :: integer
         , (SELECT trunc(random() * 85000 + (n :: integer + 1 - n ::integer))) :: integer
         , (SELECT 1) :: integer
         , (SELECT trunc(random() * 99999 + (n :: integer + 1 - n ::integer))) :: integer
         , (WITH rand_range AS (select id,
                                       (row_number() OVER ()) AS num
                                FROM customer)
            SELECT id
            FROM rand_range
            WHERE num =
                  (SELECT trunc(random() * MAX(num) + 1 + (n :: integer - n ::integer)) FROM rand_range)
    )
         , (WITH rand_range AS (select id,
                                       (row_number() OVER ()) AS num
                                FROM delivery)
            SELECT id
            FROM rand_range
            WHERE num =
                  (SELECT trunc(random() * MAX(num) + 1 + (n :: integer - n ::integer)) FROM rand_range)
    )
         , (SELECT CASE WHEN n :: integer - n ::integer = 0 THEN clock_timestamp() END)

    FROM cte
    WHERE n < 1000
)
SELECT weight, distance, cart_cost, cost, customer_id, delivery_id, created_at
FROM cte;


INSERT INTO product2order(product_id, shop_order_id, quantity)
WITH RECURSIVE cte (n) AS (
    SELECT 1                                       AS inc
         , (SELECT MIN(id) FROM public.product)    AS product_id
         , (SELECT MIN(id) FROM public.shop_order) AS shop_order_id
         , (SELECT 1) :: integer                   AS quantity
    UNION ALL
    SELECT n + 1
         , (WITH rand_range AS (select id,
                                       (row_number() OVER ()) AS num
                                FROM product)
            SELECT id
            FROM rand_range
            WHERE num =
                  (SELECT trunc(random() * MAX(num) + 1 + (n :: integer - n ::integer)) FROM rand_range)
    )
         , (WITH rand_range AS (select id,
                                       (row_number() OVER ()) AS num
                                FROM shop_order)
            SELECT id
            FROM rand_range
            WHERE num =
                  (SELECT trunc(random() * MAX(num) + 1 + (n :: integer - n ::integer)) FROM rand_range)
    )
         , (SELECT trunc(random() * 15000 + (n :: integer + 1 - n ::integer))) :: integer

    FROM cte
    WHERE n < 1000
)
SELECT product_id, shop_order_id, quantity
FROM cte;

INSERT INTO sku2order(sku_id, shop_order_id, quantity)
WITH RECURSIVE cte (n) AS (
    SELECT 1                                       AS inc
         , (SELECT MIN(id) FROM public.sku)        AS sku_id
         , (SELECT MIN(id) FROM public.shop_order) AS shop_order_id
         , (SELECT 1) :: integer                   AS quantity
    UNION ALL
    SELECT n + 1
         , (WITH rand_range AS (select id,
                                       (row_number() OVER ()) AS num
                                FROM sku)
            SELECT id
            FROM rand_range
            WHERE num =
                  (SELECT trunc(random() * MAX(num) + 1 + (n :: integer - n ::integer)) FROM rand_range)
    )
         , (WITH rand_range AS (select id,
                                       (row_number() OVER ()) AS num
                                FROM shop_order)
            SELECT id
            FROM rand_range
            WHERE num =
                  (SELECT trunc(random() * MAX(num) + 1 + (n :: integer - n ::integer)) FROM rand_range)
    )
         , (SELECT trunc(random() * 15000 + (n :: integer + 1 - n ::integer))) :: integer

    FROM cte
    WHERE n < 1000
)
SELECT sku_id, shop_order_id, quantity
FROM cte;