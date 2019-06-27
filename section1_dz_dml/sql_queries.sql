-- 1. Запросы на встравку данных INSERT VALUES
INSERT INTO public.product_category (title, slug, parent_id)
VALUES ('title1', 'slug1', 0)
     , ('title2', 'slug2', 0)
     , ('title3', 'slug3', 0);
INSERT INTO public.product_status (status)
VALUES ('ready');
INSERT INTO public.product_status (status)
VALUES ('available');

-- 2. Запросы на insert с использованием Select
INSERT INTO public.product (title, slug, product_category_id, product_status_id)
VALUES ('title1',
        'slug1',
        (SELECT id FROM public.product_category WHERE title = 'title1'),
        (SELECT id FROM public.product_status WHERE status = 'available'));

INSERT INTO public.product (title, slug, product_category_id, product_status_id)
VALUES ('title2',
        'slug2',
        (SELECT id FROM public.product_category WHERE title = 'title1'),
        (SELECT id FROM public.product_status WHERE status = 'ready'));

-- 3. Изменение данных UPDATE, UPDATE с использованием JOIN
-- Несколько надуманный пример
-- select *
-- from product_category;

UPDATE public.product_category
SET title = p.title || '_' || s.created_at :: text
FROM public.product p
         JOIN public.product_status s ON p.product_status_id = s.id AND s.status = 'ready'
WHERE product_category.slug = 'slug1';

-- 4. Delete
DELETE
FROM public.product_category
WHERE id = 9;

-- 5. Процедура со вставкой и обновлением блока
Не совсем понял, какого блока?
-- 6. Merge – потренироваться и прочувствовать
-- Merge в postgres, к сожалению, нет, поэтому ON CONFLICT на уникальный ключ
INSERT INTO public.product_category(title, slug, parent_id, description)
VALUES ('title', 'some_slug', 0 , 'some_description1')
ON CONFLICT (title, slug, parent_id) DO UPDATE SET description = EXCLUDED.description;


select *
from product_category;


select *
from product_category