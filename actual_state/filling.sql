INSERT INTO public.product_category (title, slug, description, parent_id)
VALUES ('Галактики', 'galaxies',
        'Галактикой называется большая система из звезд, межзвездного газа, пыли, темной материи и темной энергии, связанная силами гравитационного взаимодействия. Количество звезд и размеры галактик могут быть различными. Как правило, галактики содержат от нескольких миллионов до нескольких триллионов (1 000 000 000 000) звезд. ',
        0),
       ('Звезды', 'stars',
        'Находясь на различных стадиях своего эволюционного развития, звезды подразделяются на нормальные звезды, звезды карлики, звезды гиганты',
        0),
       ('Планеты', 'planets',
        'небесное тело, вращающееся по орбите вокруг звезды или её остатков, достаточно массивное, чтобы стать округлым под действием собственной гравитации, но недостаточно массивное для начала термоядерной реакции, и сумевшее очистить окрестности своей орбиты от планетезималей',
        0),
       ('Астероиды', 'asteroids',
        'относительно небольшое небесное тело Солнечной системы, движущееся по орбите вокруг Солнца. Астероиды значительно уступают по массе и размерам планетам, имеют неправильную форму и не имеют атмосферы, хотя при этом и у них могут быть спутники.',
        0)
;



INSERT INTO public.product_category (title, slug, description, parent_id)
VALUES ('Эллиптические F', 'elliptical',
        'класс галактик с четко выраженной сферической структурой и уменьшающейся к краям яркостью. Они сравнительно медленно вращаются, заметное вращение наблюдается только у галактик со значительным сжатием. В таких галактиках нет пылевой материи, которая в тех галактиках, в которых она имеется, видна как тёмные полосы на непрерывном фоне звёзд галактики. Поэтому внешне эллиптические галактики отличаются друг от друга в основном одной чертой — большим или меньшим сжатием.',
        1),
       ('линзообразные SO', 'lenticular',
        'Линзообразные галактики — это промежуточный тип между спиральными и эллиптическими. У них есть балдж, гало и диск, но нет спиральных рукавов. Их примерно 20% среди всех звездных систем. В этих галактиках яркое основное тело – линза, окружено слабым ореолом. Иногда линза имеет вокруг себя кольцо.',
        1),
       ('обычные спиральные S', 'spiral',
        'Спиральные галактики названы так, потому что имеют внутри диска яркие рукава звёздного происхождения, которые почти логарифмически простираются из балджа (почти сферического утолщения в центре галактики). Спиральные галактики имеют центральное сгущение и несколько спиральных ветвей, или рукавов, которые имеют голубоватый цвет, так как в них присутствует много молодых гигантских звезд',
        1),
       ('пересеченные спиральные SB', 'spiral-b',
        'спиральные галактики с перемычкой («баром») из ярких звёзд, выходящей из центра и пересекающей галактику посередине. Спиральные ветви в таких галактиках начинаются на концах перемычек, тогда как в обычных спиральных галактиках они выходят непосредственно из ядра.',
        1),
       ('неправильные Ir', 'irr',
        'Неправильные галактики — это галактики, которые не обнаруживают ни спиральной, ни эллиптической структуры. Чаще всего такие галактики имеют хаотичную форму без ярко выраженного ядра и спиральных ветвей. В процентном отношении составляют одну четверть от всех галактик. Большинство неправильных галактик в прошлом являлись спиральными или эллиптическими, но были деформированы гравитационными силами',
        1)
;

INSERT INTO public.product_category (title, slug, description, parent_id)
VALUES ('Коричневые карлики', 'brown dwarf',
        'Коричневые карлики — это тип звёзд, в которых ядерные реакции никогда не могли компенсировать потери энергии на излучение.',
        2),
       ('Желтые карлики', 'yellow dwarf',
        'Жёлтый карлик – тип небольших звёзд главной последовательности, имеющих массу от 0,8 до 1,2 массы Солнца и температуру поверхности 5000–6000 K',
        2),
       ('Белые карлики', 'white dwarf',
        'Вскоре после гелиевой вспышки «загораются» углерод и кислород; каждое из этих событий вызывает сильную перестройку звезды и её быстрое перемещение по диаграмме Герцшпрунга — Рассела.',
        2),
       ('Красные гиганты', 'red giants',
        'Красные гиганты и сверхгиганты — это звёзды с довольно низкой эффективной температурой (3000—5000 К), однако с огромной светимостью.',
        2),
       ('Переменные звёзды', '',
        'Переменная звезда — это звезда, у которой за всю историю наблюдения хоть один раз менялся блеск.', 2),
       ('Новые', 'nova', 'Новая звезда — тип катаклизмических переменных.', 2),
       ('Сверхновые', 'supernova',
        'Сверхно́вые звёзды — звёзды, заканчивающие свою эволюцию в катастрофическом взрывном процессе.', 2)
;


INSERT INTO public.product_category (title, slug, description, parent_id)
VALUES ('горячий юпитер', 'hot-jupiter',
        'пылающий багровым светом с темными полосами облаков из силикатной или графитовой пыли, температура поверхности 1000-1500К ',
        3),
       ('очень теплый юпитер', 'warm-jupiter',
        'тускло-серый диск из-за толстого слоя органического смога, вращение слишком медленное для появления полос, температура поверхности 500-900К',
        3),
       ('серный гигант', 'sulfur-giant',
        'окутан желтоватыми облаками из серной кислоты, орбита соответствует орбите Венеры или чуть ближе ', 3),
       ('водный гигант', 'water-giant',
        'окутан белыми облаками из водяного льда, полосатый от быстрого вращения, расположен примерно на уровне эффективной орбиты Земли ',
        3),
       ('двойник Юпитера', 'jupiter-twin',
        'окутан желтовато-бежевыми облаками замерзшего аммиака, полосатый от быстрого вращения, температура поверхности примерно 80-180К (-200 -100С)',
        3),
       ('горячий нептун', 'hot-neptune', 'мощная гелиевая атмосфера, толстый слой органического смога ', 3),
       ('суперземля', 'super-earth',
        'массивный аналог Венеры, развитая вулканическая и тектоническая активность, лавовые моря, плотная раскаленная атмосфера ',
        3),
       ('ледяной гигант', 'ice-giant',
        'аналог Урана и Нептуна в Солнечной системе. Атмосфера из водорода и гелия с примесью метана, температура поверхности 40-70К (-240 -210С). Синий или бирюзовый диск с редкими белыми пятнами облаков из замерзшего метана',
        3)
;


INSERT INTO public.product_category (title, slug, description, parent_id)
VALUES ('Класс A', 'class-a',
        'характеризуются достаточно высоким альбедо (между 0,17 и 0,35) и красноватым цветом в видимой части спектра.',
        4),
       ('Класс B', 'class-b',
        'в целом относятся к астероидам класса C, но почти не поглощают волны ниже 0,5 мкм, а их спектр слегка голубоватый',
        4),
       ('Класс D', 'class-d',
        'характеризуются очень низким альбедо (0,02−0,05) и ровным красноватым спектром без чётких линий поглощения.',
        4),
       ('Класс E', 'class-e',
        'поверхность этих астероидов содержит в своём составе такой минерал, как энстатит и может иметь сходство с ахондритами.',
        4),
       ('Класс F', 'class-f', 'в целом схожи с астероидами класса B, но без следов «воды»', 4)
;

INSERT INTO public.vendor (name, country, page, email, phone)
VALUES ('BigBangInc', 'Canada', 'www.bigbang.inc', 'clients@bigbang.inc', '11121232132'),
       ('FirstGenerationStars', 'Australia', 'www.firstgenerationstars.com', 'clients@firstgenerationstars.com',
        '456897213'),
       ('SpaceEngineeringGroup', 'Norway', 'www.seg.com', 'clients@seg.com', '78999999999')
;


INSERT INTO public.product_status (status)
VALUES ('В наличии'),
       ('В производстве'),
       ('На складе'),
       ('Скоро в продаже!')
;

-- заполняю продукты. Не руками, понятное дело

INSERT INTO product(title, slug, product_category_id, product_status_id, vendor_id)
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
    UNION ALL
    SELECT n + 1
         , (SELECT (
                       SELECT string_agg(x, '')
                       FROM (
                                SELECT chr(ascii('a') + floor(random() * 26)::integer +
                                           (n ::integer - (n :: integer + 1)))
                                FROM generate_series(1, 20 + b * 0)
                            ) AS y(x)
                   )
            FROM generate_series(1, 1) as a(b)) AS title
         , (SELECT (
                       SELECT string_agg(x, '')
                       FROM (
                                SELECT chr(ascii('a') + floor(random() * 26)::integer +
                                           (n ::integer - (n :: integer + 1)))
                                FROM generate_series(1, 20 + b * 0)
                            ) AS y(x)
                   )
            FROM generate_series(1, 1) as a(b)) AS slug
         , (WITH rand_range AS (select id,
                                       (row_number() OVER ()) AS num
                                FROM product_category)
            SELECT id
            FROM rand_range
            WHERE num =
                  (SELECT trunc(random() * MAX(num) + 1 + (n :: integer - n ::integer)) FROM rand_range)
    )                                           AS product_category_id
         , (WITH rand_range AS (select id,
                                       (row_number() OVER ()) AS num
                                FROM product_status)
            SELECT id
            FROM rand_range
            WHERE num =
                  (SELECT trunc(random() * MAX(num) + 1 + (n :: integer - n ::integer)) FROM rand_range)
    )                                           AS product_status_id
         , (WITH rand_range AS (select id,
                                       (row_number() OVER ()) AS num
                                FROM vendor)
            SELECT id
            FROM rand_range
            WHERE num =
                  (SELECT trunc(random() * MAX(num) + 1 + (n :: integer - n ::integer)) FROM rand_range)
    )                                           AS vendor_id
    FROM cte
    WHERE n < 500
)
SELECT title, slug, product_category_id, product_status_id, vendor_id
FROM cte;

-- названия характеристики

INSERT INTO public.product_chars (name)
WITH RECURSIVE cte (n) AS (
    SELECT 1                             AS inc
         , (SELECT 'first_record_chars') AS title
    UNION ALL
    SELECT n + 1                                As inc
         , (SELECT (
                       SELECT string_agg(x, '')
                       FROM (
                                SELECT chr(ascii('a') + floor(random() * 26)::integer +
                                           (n ::integer - (n :: integer + 1)))
                                FROM generate_series(1, 10 + b * 0)
                            ) AS y(x)
                   )
            FROM generate_series(1, 1) as a(b)) AS title
    FROM cte
    WHERE n < 100
)
SELECT title
FROM cte;

-- значения характеристик
INSERT INTO public.chars_value (product_chars_id, value)
WITH RECURSIVE cte (n) AS (
    SELECT 1                                   AS inc
         , (SELECT 'first_record_chars_value') AS title
         , (SELECT MIN(id) FROM product_chars) AS product_chars_id
    UNION ALL
    SELECT n + 1                                As inc

         , (SELECT (
                       SELECT string_agg(x, '')
                       FROM (
                                SELECT chr(ascii('a') + floor(random() * 26)::integer +
                                           (n ::integer - (n :: integer + 1)))
                                FROM generate_series(1, 10 + b * 0)
                            ) AS y(x)
                   )
            FROM generate_series(1, 1) as a(b)) AS title
         , (WITH rand_range AS (select id,
                                       (row_number() OVER ()) AS num
                                FROM product_chars)
            SELECT id
            FROM rand_range
            WHERE num =
                  (SELECT trunc(random() * MAX(num) + 1 + (n :: integer - n ::integer)) FROM rand_range)
    )                                           AS product_chars_id
    FROM cte
    WHERE n < 300
)
SELECT product_chars_id, title
FROM cte;


-- кросс таблица соответствие характеристик продуктами
INSERT INTO public.product2chars_value (product_id, chars_value_id)
WITH RECURSIVE cte (n) AS (
    SELECT 1                                 AS inc
         , (SELECT MIN(id) FROM product)     AS product_id
         , (SELECT MIN(id) FROM chars_value) AS chars_value_id
    UNION ALL
    SELECT n + 1 As inc
         , (WITH rand_range AS (select id,
                                       (row_number() OVER ()) AS num
                                FROM product)
            SELECT id
            FROM rand_range
            WHERE num =
                  (SELECT trunc(random() * MAX(num) + 1 + (n :: integer - n ::integer)) FROM rand_range)
    )            AS product_id
         , (WITH rand_range AS (select id,
                                       (row_number() OVER ()) AS num
                                FROM chars_value)
            SELECT id
            FROM rand_range
            WHERE num =
                  (SELECT trunc(random() * MAX(num) + 1 + (n :: integer - n ::integer)) FROM rand_range)
    )            AS chars_value_id
    FROM cte
    WHERE n < 300
)
SELECT product_id, chars_value_id
FROM cte;