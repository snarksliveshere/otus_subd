--DROP SCHEMA public CASCADE;
--CREATE SCHEMA public;


CREATE OR REPLACE FUNCTION public.upd_updated_at() RETURNS TRIGGER
    LANGUAGE plpgsql
AS
$$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


CREATE OR REPLACE FUNCTION public.add_timestamps_to_table() RETURNS event_trigger
    LANGUAGE plpgsql
AS
$BODY$
DECLARE
    table_name text;
BEGIN
    SELECT object_identity INTO STRICT table_name FROM pg_event_trigger_ddl_commands() WHERE object_type = 'table';
    EXECUTE 'ALTER TABLE ' || table_name || ' ADD COLUMN created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL;';
    EXECUTE 'ALTER TABLE ' || table_name || ' ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL;';
    EXECUTE 'CREATE TRIGGER t_' || REPLACE(table_name, '.', '_') || '
                 BEFORE UPDATE
                ON ' || table_name || '
                FOR EACH ROW
          EXECUTE PROCEDURE  public.upd_updated_at();';
END;
$BODY$;

CREATE EVENT TRIGGER trg_create_table ON ddl_command_end
    WHEN TAG IN ('CREATE TABLE')
EXECUTE PROCEDURE add_timestamps_to_table();

--------------------------------------------------------------------------------

-- ARTICLE SECTION
CREATE TABLE public.article_category
(
    id            BIGSERIAL PRIMARY KEY,
    title         VARCHAR(128)           NOT NULL,
    longtitle     VARCHAR(128),
    image_intro   VARCHAR(255),
    image         VARCHAR(255),
    slug          VARCHAR(128)           NOT NULL,
    intro         VARCHAR(255),
    description   VARCHAR(512),
    content       TEXT,
    is_deleted    BOOLEAN  DEFAULT FALSE NOT NULL,
    is_publish    BOOLEAN  DEFAULT FALSE NOT NULL,
    filter_member BOOLEAN  DEFAULT TRUE  NOT NULL,
    search_member BOOLEAN  DEFAULT TRUE  NOT NULL,
    parent_id     SMALLINT DEFAULT 0     NOT NULL,
    CONSTRAINT public_article_category_title_parent_id_ui UNIQUE (title, parent_id, slug)
);
-- ALTER TABLE public.article_category
--     ADD CONSTRAINT public_article_category_article_category_fk FOREIGN KEY (parent_id) REFERENCES public.article_category (id);
CREATE INDEX public_article_category_parent_id_index ON public.article_category (parent_id);

COMMENT ON TABLE public.article_category IS 'Таблица для категорий статей';
COMMENT ON COLUMN public.article_category.title IS 'Заголовок. Вообще, достаточно 80, но если тематика это электротехника, то там может быть длинная строка';
COMMENT ON COLUMN public.article_category.longtitle IS 'Расширенный заголовок. Он используется как заголовок H1. По правилам, он не должен превышать 60 символов, но слишком часто бывают исключения';
COMMENT ON COLUMN public.article_category.image_intro IS 'Путь к картинке для представления в виде списка';
COMMENT ON COLUMN public.article_category.image IS 'Путь к подробной картинке';
COMMENT ON COLUMN public.article_category.slug IS 'ЧПУ';
COMMENT ON COLUMN public.article_category.intro IS 'Небольшое текстовое превью (в списке, обычно)';
COMMENT ON COLUMN public.article_category.description IS 'Описание';
COMMENT ON COLUMN public.article_category.content IS 'Всякий возможный контент. Не уверен, что на него надо ставить ограничения';
COMMENT ON COLUMN public.article_category.is_deleted IS 'Флаг для soft delete';
COMMENT ON COLUMN public.article_category.is_publish IS 'Флаг опубликован или нет';
COMMENT ON COLUMN public.article_category.parent_id IS 'Внешний ключ на родительскую категорию. Может быть null у таблиц 1 уровня';

COMMENT ON CONSTRAINT public_article_category_title_parent_id_ui ON public.article_category IS 'Уникальный ключ для категории';
COMMENT ON CONSTRAINT public_article_category_article_category_fk ON public.article_category IS 'Внешний ключ на родителя - на id этой же таблицы';
COMMENT ON INDEX public_article_category_parent_id_index IS 'Индекс на внешний ключ - родительская категория';

CREATE TABLE public.article
(
    id                  BIGSERIAL PRIMARY KEY,
    title               VARCHAR(128)          NOT NULL,
    longtitle           VARCHAR(128),
    image_intro         VARCHAR(255),
    image               VARCHAR(255),
    slug                VARCHAR(128)          NOT NULL,
    intro               VARCHAR(255),
    description         VARCHAR(512),
    content             TEXT,
    is_deleted          BOOLEAN DEFAULT FALSE NOT NULL,
    is_publish          BOOLEAN DEFAULT FALSE NOT NULL,
    filter_member       BOOLEAN DEFAULT TRUE  NOT NULL,
    search_member       BOOLEAN DEFAULT TRUE  NOT NULL,
    article_category_id BIGINT                NOT NULL,
    CONSTRAINT public_article_title_article_category_id_ui UNIQUE (title, article_category_id, slug)

);
ALTER TABLE public.article
    ADD CONSTRAINT public_article_article_category_fk FOREIGN KEY (article_category_id) REFERENCES public.article_category (id);
CREATE INDEX public_article_article_category_id_index ON public.article (article_category_id);

COMMENT ON TABLE public.article IS 'Таблица для статей';
COMMENT ON COLUMN public.article.title IS 'Заголовок. Вообще, достаточно 80, но если тематика это электротехника, то там может быть длинная строка';
COMMENT ON COLUMN public.article.longtitle IS 'Расширенный заголовок. Он используется как заголовок H1. По правилам, он не должен превышать 60 символов, но слишком часто бывают исключения';
COMMENT ON COLUMN public.article.image_intro IS 'Путь к картинке для представления в виде списка';
COMMENT ON COLUMN public.article.image IS 'Путь к подробной картинке';
COMMENT ON COLUMN public.article.slug IS 'ЧПУ';
COMMENT ON COLUMN public.article.intro IS 'Небольшое текстовое превью (в списке, обычно)';
COMMENT ON COLUMN public.article.description IS 'Описание';
COMMENT ON COLUMN public.article.content IS 'Всякий возможный контент. Не уверен, что на него надо ставить ограничения';
COMMENT ON COLUMN public.article.is_deleted IS 'Флаг для soft delete';
COMMENT ON COLUMN public.article.is_publish IS 'Флаг опублиован или нет';
COMMENT ON COLUMN public.article.article_category_id IS 'Внешний ключ на родительскую категорию.';

COMMENT ON CONSTRAINT public_article_title_article_category_id_ui ON public.article IS 'Уникальный ключ для статьи';
COMMENT ON CONSTRAINT public_article_article_category_fk ON public.article IS 'Внешний ключ на родительскую категорию';
COMMENT ON INDEX public_article_article_category_id_index IS 'Индекс на внешний ключ - родительская категория';


-- PRODUCT SECTION

CREATE TABLE public.shop_settings
(
    id              SMALLSERIAL PRIMARY KEY,
    title           VARCHAR(128)          NOT NULL,
    logo            VARCHAR(255),
    image           VARCHAR(255),
    intro           VARCHAR(255),
    description     VARCHAR(512),
    content         TEXT,
    country         VARCHAR(70),
    page            VARCHAR(128),
    email           VARCHAR(70)           NOT NULL,
    phone           VARCHAR(50),
    currency        VARCHAR(3)            NOT NULL,
    is_nds_included BOOLEAN DEFAULT TRUE  NOT NULL,
    is_active       BOOLEAN DEFAULT FALSE NOT NULL
);
-- сюда потом надо будет триггером навесить условие, что is_active - только 1 запись
COMMENT ON TABLE public.shop_settings IS 'Таблица настроек магазина';

COMMENT ON COLUMN public.shop_settings.title IS 'Заголовок. Тут может быть что угодно, в принципе';
COMMENT ON COLUMN public.shop_settings.logo IS 'Путь к логотипу';
COMMENT ON COLUMN public.shop_settings.image IS 'Путь к подробной картинке';
COMMENT ON COLUMN public.shop_settings.intro IS 'Небольшое текстовое превью';
COMMENT ON COLUMN public.shop_settings.description IS 'Описание';
COMMENT ON COLUMN public.shop_settings.content IS 'Всякий возможный контент';
COMMENT ON COLUMN public.shop_settings.country IS 'Страна';
COMMENT ON COLUMN public.shop_settings.page IS 'Интернет-ресурс';
COMMENT ON COLUMN public.shop_settings.email IS 'Email';
COMMENT ON COLUMN public.shop_settings.phone IS 'Контактный телефон';
COMMENT ON COLUMN public.shop_settings.currency IS 'Валюта магазина';
COMMENT ON COLUMN public.shop_settings.is_nds_included IS 'Включен ли НДС в стоимость товара';
COMMENT ON COLUMN public.shop_settings.is_active IS 'Активна ли данная настройка';


CREATE TABLE public.product_category
(
    id            BIGSERIAL PRIMARY KEY,
    title         VARCHAR(128)          NOT NULL,
    longtitle     VARCHAR(128),
    image_intro   VARCHAR(255),
    image         VARCHAR(255),
    slug          VARCHAR(128)          NOT NULL,
    intro         VARCHAR(255),
    description   VARCHAR(512),
    content       TEXT,
    is_deleted    BOOLEAN DEFAULT FALSE NOT NULL,
    is_publish    BOOLEAN DEFAULT FALSE NOT NULL,
    filter_member BOOLEAN DEFAULT TRUE  NOT NULL,
    search_member BOOLEAN DEFAULT TRUE  NOT NULL,
    parent_id     BIGINT  DEFAULT 0     NOT NULL,
    CONSTRAINT public_product_title_parent_id_ui UNIQUE (title, parent_id, slug)
);
-- ALTER TABLE public.product_category
--     ADD CONSTRAINT public_product_category_product_category_fk FOREIGN KEY (parent_id) REFERENCES public.product_category (id);
CREATE INDEX public_product_category_parent_id_index ON public.product_category (parent_id);

COMMENT ON TABLE product_category IS 'Таблица категорий продуктов';
COMMENT ON COLUMN public.product_category.title IS 'Заголовок. Вообще, достаточно 80, но если тематика это электротехника, то там может быть длинная строка';
COMMENT ON COLUMN public.product_category.longtitle IS 'Расширенный заголовок. Он используется как заголовок H1. По правилам, он не должен превышать 60 символов, но слишком часто бывают исключения';
COMMENT ON COLUMN public.product_category.image_intro IS 'Путь к картинке для представления в виде списка';
COMMENT ON COLUMN public.product_category.image IS 'Путь к подробной картинке';
COMMENT ON COLUMN public.product_category.slug IS 'ЧПУ';
COMMENT ON COLUMN public.product_category.intro IS 'Небольшое текстовое превью (в списке, обычно)';
COMMENT ON COLUMN public.product_category.description IS 'Описание';
COMMENT ON COLUMN public.product_category.content IS 'Всякий возможный контент. Не уверен, что на него надо ставить ограничения';
COMMENT ON COLUMN public.product_category.is_deleted IS 'Флаг для soft delete';
COMMENT ON COLUMN public.product_category.is_publish IS 'Флаг опублиован или нет';
COMMENT ON COLUMN public.product_category.parent_id IS 'Внешний ключ на родительскую категорию. Может быть null у таблиц 1 уровня';

COMMENT ON CONSTRAINT public_product_title_parent_id_ui ON public.product_category IS 'Уникальный ключ для категории';
COMMENT ON CONSTRAINT public_product_category_product_category_fk ON public.product_category IS 'Внешний ключ на родительскую категорию';
COMMENT ON INDEX public_product_category_parent_id_index IS 'Индекс на внешний ключ - родительская категория';


CREATE TABLE public.product_status
(
    id     SMALLSERIAL PRIMARY KEY,
    status VARCHAR(128) NOT NULL,
    CONSTRAINT public_product_status_ui UNIQUE (status)
);

COMMENT ON TABLE public.product_status IS 'Таблица для отображения статусов продукта';
COMMENT ON COLUMN public.product_status.status IS 'На данный момент, Может быть вида: в наличии, ожидается, отсутствует';

COMMENT ON CONSTRAINT public_product_status_ui ON public.product_status IS 'Статус уникален и не может дублироваться';

CREATE TABLE public.vendor
(
    id      SMALLSERIAL PRIMARY KEY,
    name    VARCHAR(128) NOT NULL,
    country VARCHAR(70),
    page    VARCHAR(128),
    email   VARCHAR(70)  NOT NULL,
    phone   VARCHAR(50),
    logo    VARCHAR(255),
    CONSTRAINT public_vendor_name_ui UNIQUE (name)
);
COMMENT ON TABLE public.vendor IS 'Таблица для отображения производителей товаров';
COMMENT ON COLUMN public.vendor.name IS 'Название фирмы производителя';
COMMENT ON COLUMN public.vendor.country IS 'Страна';
COMMENT ON COLUMN public.vendor.page IS 'Интернет-ресурс';
COMMENT ON COLUMN public.vendor.email IS 'Email';
COMMENT ON COLUMN public.vendor.phone IS 'Контактный телефон';
COMMENT ON COLUMN public.vendor.logo IS 'Путь на лого производителя';

COMMENT ON CONSTRAINT public_vendor_name_ui ON public.vendor IS 'Имя должно быть уникально. Все остальное, как это бывает, вполне может дублироваться';


CREATE TABLE public.product
(
    id                  BIGSERIAL PRIMARY KEY,
    title               VARCHAR(128)          NOT NULL,
    longtitle           VARCHAR(128),
    image_intro         VARCHAR(255),
    image               VARCHAR(255),
    slug                VARCHAR(128)          NOT NULL,
    intro               VARCHAR(255),
    description         VARCHAR(512),
    content             TEXT,
    price               NUMERIC(19, 6)        NOT NULL DEFAULT 0,
    old_price           NUMERIC(19, 6)        NOT NULL DEFAULT 0,
    is_deleted          BOOLEAN DEFAULT FALSE NOT NULL,
    is_publish          BOOLEAN DEFAULT FALSE NOT NULL,
    special             BOOLEAN DEFAULT FALSE NOT NULL,
    novelty             BOOLEAN DEFAULT FALSE NOT NULL,
    popular             BOOLEAN DEFAULT FALSE NOT NULL,
    is_sku              BOOLEAN DEFAULT FALSE NOT NULL,
    filter_member       BOOLEAN DEFAULT TRUE  NOT NULL,
    search_member       BOOLEAN DEFAULT TRUE  NOT NULL,
    product_category_id BIGINT                NOT NULL,
    product_status_id   SMALLINT              NOT NULL,
    vendor_id           SMALLINT,
    CONSTRAINT public_product_title_product_category_slug_ui UNIQUE (title, product_category_id, slug)
);
ALTER TABLE public.product
    ADD
        CONSTRAINT public_product_product_category FOREIGN KEY (product_category_id) REFERENCES public.product_category (id);
ALTER TABLE public.product
    ADD CONSTRAINT public_product_product_status_fk FOREIGN KEY (product_status_id) REFERENCES public.product_status (id);
ALTER TABLE public.product
    ADD CONSTRAINT public_product_vendor_fk FOREIGN KEY (vendor_id) REFERENCES public.vendor (id);

ALTER TABLE product
    ADD CONSTRAINT public_product_price_check CHECK (
        CASE WHEN price >= 0 THEN TRUE ELSE FALSE END);
ALTER TABLE product
    ADD CONSTRAINT public_product_old_price_check CHECK (
        CASE
            WHEN old_price >= 0 THEN TRUE
            ELSE FALSE END
        );

CREATE INDEX public_product_product_category_index ON public.product (product_category_id);
CREATE INDEX public_product_vendor_index_ ON public.product (vendor_id);
CREATE INDEX public_product_product_status_index ON public.product (product_status_id);

COMMENT ON TABLE public.product IS 'Таблица для отображения товаров';
COMMENT ON COLUMN public.product.title IS 'Заголовок. Вообще, достаточно 80, но если тематика это электротехника, то там может быть длинная строка';
COMMENT ON COLUMN public.product.longtitle IS 'Расширенный заголовок. Он используется как заголовок H1. По правилам, он не должен превышать 60 символов, но слишком часто бывают исключения';
COMMENT ON COLUMN public.product.image_intro IS 'Путь к картинке для представления в виде списка';
COMMENT ON COLUMN public.product.image IS 'Путь к подробной картинке';
COMMENT ON COLUMN public.product.slug IS 'ЧПУ';
COMMENT ON COLUMN public.product.intro IS 'Небольшое текстовое превью (в списке, обычно)';
COMMENT ON COLUMN public.product.description IS 'Описание';
COMMENT ON COLUMN public.product.content IS 'Всякий возможный контент. Не уверен, что на него надо ставить ограничения';
COMMENT ON COLUMN public.product.is_deleted IS 'Флаг для soft delete';
COMMENT ON COLUMN public.product.is_publish IS 'Флаг опублиован или нет';
COMMENT ON COLUMN public.product.popular IS 'Флаг популярный. Может использоваться для Хит продаж';
COMMENT ON COLUMN public.product.novelty IS 'Флаг новинка. Может использоваться для новинка';
COMMENT ON COLUMN public.product.special IS 'Флаг особый, специальный. Кастомное использование';
COMMENT ON COLUMN public.product.price IS 'Цена. По умолчанию 0';
COMMENT ON COLUMN public.product.old_price IS 'Поле Старая(прошлая цена). Очень часто используется в маркетинговых целях, часто поставляется по умолчанию';
COMMENT ON COLUMN public.product.is_sku IS 'Поле, которое определяет, если ли у товара торговые предложения';
COMMENT ON COLUMN public.product.product_category_id IS 'Внешний ключ на родитеский каталог';
COMMENT ON COLUMN public.product.product_status_id IS 'Внешний ключ на статус';
COMMENT ON COLUMN public.product.vendor_id IS 'Внешний ключ на производителя';

COMMENT ON CONSTRAINT public_product_title_product_category_slug_ui ON public.product IS 'Уникальный ключ для товара';
COMMENT ON CONSTRAINT public_product_product_category ON public.product IS 'Внешний ключ на родительскую категорию';
COMMENT ON CONSTRAINT public_product_product_status_fk ON public.product IS 'Внешний ключ на статус продукта';
COMMENT ON CONSTRAINT public_product_vendor_fk ON public.product IS 'Внешний ключ на производителя';

COMMENT ON CONSTRAINT public_product_price_check ON public.product IS 'Ограничение - цена не может быть меньше ноля';
COMMENT ON CONSTRAINT public_product_old_price_check ON public.product IS 'Ограничение - прошлая цена не может быть меньше ноля';

COMMENT ON INDEX public_product_product_category_index IS 'Индекс на внешний ключ - родительская категория';
COMMENT ON INDEX public_product_vendor_index_ IS 'Индекс на внешний ключ - производитель';
COMMENT ON INDEX public_product_product_status_index IS 'Индекс на внешний ключ - статус';


-- АРТИКУЛЫ

CREATE TABLE public.sku
(
    id          BIGSERIAL PRIMARY KEY,
    sku         VARCHAR(128)                 NOT NULL,
    name        VARCHAR(128),
    price       NUMERIC(19, 6) DEFAULT 0     NOT NULL,
    old_price   NUMERIC(19, 6) DEFAULT 0     NOT NULL,
    image       VARCHAR(255),
    description VARCHAR(255),
    content     TEXT,
    is_deleted  BOOLEAN        DEFAULT FALSE NOT NULL,
    is_publish  BOOLEAN        DEFAULT FALSE NOT NULL,
    product_id  BIGINT                       NOT NULL,
    CONSTRAINT public_sku_product_sku_ui UNIQUE (sku, product_id),
    CONSTRAINT public_sku_price_check CHECK (
        CASE WHEN price >= 0 THEN TRUE ELSE FALSE END),
    CONSTRAINT public_sku_old_price_check CHECK (
        CASE WHEN old_price >= 0 THEN TRUE ELSE FALSE END)
);
ALTER TABLE public.sku
    ADD CONSTRAINT public_sku_product_fk FOREIGN KEY (product_id) REFERENCES public.product (id);

CREATE INDEX public_sku_product_index ON public.sku (product_id);

COMMENT ON TABLE public.sku IS 'Таблица для отображения артикулов товара (товаров с Торговыми предложениями)';
COMMENT ON COLUMN public.sku.name IS 'Название для ТП, nullable';
COMMENT ON COLUMN public.sku.old_price IS 'Прошлая цена. По умолчанию 0';
COMMENT ON COLUMN public.sku.price IS 'Цена. По умолчанию 0';
COMMENT ON COLUMN public.sku.image IS 'Путь к подробной картинке';
COMMENT ON COLUMN public.sku.description IS 'Описание';
COMMENT ON COLUMN public.sku.content IS 'Всякий возможный контент';
COMMENT ON COLUMN public.sku.is_deleted IS 'Флаг для soft delete';
COMMENT ON COLUMN public.sku.is_publish IS 'Флаг опублиован или нет';
COMMENT ON COLUMN public.sku.product_id IS 'Внешний ключ на продукт';

COMMENT ON CONSTRAINT public_sku_product_sku_ui ON public.sku IS 'Уникальный ключ для торгового предложения';
COMMENT ON CONSTRAINT public_sku_price_check ON public.sku IS 'Ограничение - цена не может быть меньше ноля';
COMMENT ON CONSTRAINT public_sku_old_price_check ON public.sku IS 'Ограничение - прошлая цена не может быть меньше ноля';
COMMENT ON CONSTRAINT public_sku_product_fk ON public.sku IS 'Внешний ключ на id товара';

COMMENT ON INDEX public_sku_product_index IS 'Индекс на внешний ключ - на товар';

-- ХАРАКТЕРИСТИКИ

CREATE TABLE public.product_chars
(
    id   BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    CONSTRAINT public_product_chars_ui UNIQUE (name)
);
COMMENT ON TABLE public.product_chars IS 'Таблица для отображения названий характеристик продукта';
COMMENT ON COLUMN public.product_chars.name IS 'Поле, в котором содержатся названия характеристик';

COMMENT ON CONSTRAINT public_product_chars_ui ON public.product_chars IS 'Уникальный ключ названия характеристик';

CREATE TABLE public.chars_value
(
    id               BIGSERIAL PRIMARY KEY,
    value            VARCHAR(255) NOT NULL,
    product_chars_id BIGINT       NOT NULL,
    CONSTRAINT public_value_product_chars_fk_ui UNIQUE (value, product_chars_id)
);
ALTER TABLE public.chars_value
    ADD CONSTRAINT public_chars_value_product_chars_fk FOREIGN KEY (product_chars_id) REFERENCES public.product_chars (id);
CREATE INDEX public_chars_value_index ON public.chars_value (product_chars_id);

COMMENT ON TABLE public.chars_value IS 'Таблица для отображения соответствия названий характеристик продукта их значениям';
COMMENT ON COLUMN public.chars_value.value IS 'Поле для записи значения характеристики';
COMMENT ON COLUMN public.chars_value.product_chars_id IS 'Поле для внешнего ключа на названия характеристик';

COMMENT ON CONSTRAINT public_value_product_chars_fk_ui ON public.chars_value IS 'Уникальный ключ для соответствия названия характеристики и значения';
COMMENT ON CONSTRAINT public_chars_value_product_chars_fk ON public.chars_value IS 'Внешний ключ на название характеристики';
COMMENT ON INDEX public_chars_value_index IS 'Индекс на внешний ключ - название характеристики';

-- СВЯЗИ ХАРАКТЕРИСТИК, ПРОДУКТОВ, АРТИКУЛОВ И ТАБЛИЦЫ ДЛЯ ХАРАКТЕРИСТИК КАТЕГОРИЙ (ДЛЯ УДОБСТВА КОНТЕНТ-МЕНЕДЖЕРОВ)

-- Sku/Product 2 chars_value (CROSS TABLE)
CREATE TABLE public.sku2chars_value
(
    id             BIGSERIAL PRIMARY KEY,
    sku_id         BIGINT NOT NULL,
    chars_value_id BIGINT NOT NULL,
    CONSTRAINT public_sku2chars_value_chars_value_sku_ui UNIQUE (sku_id, chars_value_id)
);
ALTER TABLE public.sku2chars_value
    ADD CONSTRAINT public_sku2chars_value_sku_fk FOREIGN KEY (sku_id) REFERENCES public.sku (id);
ALTER TABLE public.sku2chars_value
    ADD CONSTRAINT public_sku2chars_value_chars_value_fk FOREIGN KEY (chars_value_id) REFERENCES public.chars_value (id);
CREATE INDEX public_sku2chars_value_sku_index ON public.sku2chars_value (sku_id);
CREATE INDEX public_sku2chars_value_chars_value_index ON public.sku2chars_value (chars_value_id);

COMMENT ON TABLE public.sku2chars_value IS 'Кросс Таблица для соответствия значения характеристик и артикула - реализация торгового предложения';
COMMENT ON COLUMN public.sku2chars_value.sku_id IS 'Поле внешнего ключа на ТП';
COMMENT ON COLUMN public.sku2chars_value.chars_value_id IS 'Поле для внешнего ключа на характеристики';

COMMENT ON CONSTRAINT public_sku2chars_value_chars_value_sku_ui ON public.sku2chars_value IS 'Уникальный ключ для соответствия названия характеристик, значений и торговых предложений';
COMMENT ON CONSTRAINT public_sku2chars_value_sku_fk ON public.sku2chars_value IS 'Внешний ключ на ТП';
COMMENT ON CONSTRAINT public_sku2chars_value_chars_value_fk ON public.sku2chars_value IS 'Внешний ключ на характеристики';
COMMENT ON INDEX public_sku2chars_value_sku_index IS 'Индекс на внешний ключ - ТП';
COMMENT ON INDEX public_sku2chars_value_chars_value_index IS 'Индекс на внешний ключ - на характеристики';


CREATE TABLE public.product2chars_value
(
    id             BIGSERIAL PRIMARY KEY,
    product_id     BIGINT NOT NULL,
    chars_value_id BIGINT NOT NULL,
    CONSTRAINT public_product2chars_value_chars_value_sku_ui UNIQUE (product_id, chars_value_id)
);
ALTER TABLE public.product2chars_value
    ADD CONSTRAINT public_product2chars_value_product_fk FOREIGN KEY (product_id) REFERENCES public.product (id);
ALTER TABLE public.product2chars_value
    ADD CONSTRAINT public_product2chars_value_chars_value_fk FOREIGN KEY (chars_value_id) REFERENCES public.chars_value (id);
CREATE INDEX public_product2chars_value_product_index ON public.product2chars_value (product_id);
CREATE INDEX public_product2chars_value_chars_value_index ON public.product2chars_value (chars_value_id);

COMMENT ON TABLE public.product2chars_value IS 'Кросс Таблица для соответствия значения характеристик и товара';
COMMENT ON COLUMN public.product2chars_value.product_id IS 'Поле внешнего ключа на товар';
COMMENT ON COLUMN public.product2chars_value.chars_value_id IS 'Поле для внешнего ключа на характеристики';

COMMENT ON CONSTRAINT public_product2chars_value_chars_value_sku_ui ON public.product2chars_value IS 'Уникальный ключ для соответствия названия характеристик, значений и товара';
COMMENT ON CONSTRAINT public_product2chars_value_product_fk ON public.product2chars_value IS 'Внешний ключ на товар';
COMMENT ON CONSTRAINT public_product2chars_value_chars_value_fk ON public.product2chars_value IS 'Внешний ключ на характеристики';
COMMENT ON INDEX public_product2chars_value_product_index IS 'Индекс на внешний ключ - товар';
COMMENT ON INDEX public_product2chars_value_chars_value_index IS 'Индекс на внешний ключ - на характеристики';


-- Следующие 2 таблицы исключительно для админки - для удобства заполнения
CREATE TABLE public.sku2product_category
(
    id                  BIGSERIAL PRIMARY KEY,
    sku_id              BIGINT NOT NULL,
    product_category_id BIGINT NOT NULL,
    CONSTRAINT public_sku2product_category_product_category_sku_ui UNIQUE (sku_id, product_category_id)
);
ALTER TABLE public.sku2product_category
    ADD CONSTRAINT public_sku2product_category_sku_fk FOREIGN KEY (sku_id) REFERENCES public.sku (id);
ALTER TABLE public.sku2product_category
    ADD CONSTRAINT public_sku2product_category_product_category_fk FOREIGN KEY (product_category_id) REFERENCES public.product_category (id);
CREATE INDEX public_sku2product_category_sku_index ON public.sku2product_category (sku_id);
CREATE INDEX public_sku2product_category_product_category_index ON public.sku2product_category (product_category_id);

COMMENT ON TABLE public.sku2product_category IS 'Кросс Таблица для соответствия ТП и категорий продукта. Больше для удобства пользования редакторам';
COMMENT ON COLUMN public.sku2product_category.sku_id IS 'Поле внешнего ключа на ТП';
COMMENT ON COLUMN public.sku2product_category.product_category_id IS 'Поле для внешнего ключа на категорию товара';

COMMENT ON CONSTRAINT public_sku2product_category_product_category_sku_ui ON public.sku2product_category IS 'Уникальный ключ для соответствия ТП и категории продукта';
COMMENT ON CONSTRAINT public_sku2product_category_sku_fk ON public.sku2product_category IS 'Внешний ключ на ТП';
COMMENT ON CONSTRAINT public_sku2product_category_product_category_fk ON public.sku2product_category IS 'Внешний ключ на категорию продукта';
COMMENT ON INDEX public_sku2product_category_sku_index IS 'Индекс на внешний ключ - ТП';
COMMENT ON INDEX public_sku2product_category_product_category_index IS 'Индекс на внешний ключ - на категорию продукта';


CREATE TABLE public.product_category2chars_value
(
    id                  BIGSERIAL PRIMARY KEY,
    product_category_id BIGINT NOT NULL,
    chars_value_id      BIGINT NOT NULL,
    CONSTRAINT public_product_category2chars_value_chars_value_product_category_ui UNIQUE (product_category_id, chars_value_id)
);
ALTER TABLE public.product_category2chars_value
    ADD CONSTRAINT public_product_category2chars_value_chars_value_fk FOREIGN KEY (product_category_id) REFERENCES public.product_category (id);
ALTER TABLE public.product_category2chars_value
    ADD CONSTRAINT public_product_category2chars_value_product_category_fk FOREIGN KEY (chars_value_id) REFERENCES public.chars_value (id);
CREATE INDEX public_product_category2chars_value_product_category_index ON public.product_category2chars_value (product_category_id);
CREATE INDEX public_product_category2chars_value_chars_value_index ON public.product_category2chars_value (chars_value_id);

COMMENT ON TABLE public.product_category2chars_value IS 'Кросс Таблица для соответствия категорий продукта и характеристик. Больше для удобства пользования редакторам. Можно накидать шаблон характеристик для категории';
COMMENT ON COLUMN public.product_category2chars_value.product_category_id IS 'Поле для внешнего ключа на категорию товара';
COMMENT ON COLUMN public.product_category2chars_value.chars_value_id IS 'Поле внешнего ключа на характеристики';

COMMENT ON CONSTRAINT public_product_category2chars_value_chars_value_product_category_ui ON public.product_category2chars_value IS 'Уникальный ключ для соответствия характеристик и категории продукта';
COMMENT ON CONSTRAINT public_product_category2chars_value_chars_value_fk ON public.product_category2chars_value IS 'Внешний ключ на характеристики';
COMMENT ON CONSTRAINT public_product_category2chars_value_product_category_fk ON public.product_category2chars_value IS 'Внешний ключ на категорию продукта';
COMMENT ON INDEX public_product_category2chars_value_product_category_index IS 'Индекс на внешний ключ - категорию продукта';
COMMENT ON INDEX public_product_category2chars_value_chars_value_index IS 'Индекс на внешний ключ - на характеристики';

-- ДОСТАВКА
CREATE TABLE public.delivery
(
    id             BIGSERIAL PRIMARY KEY,
    name           VARCHAR(128)          NOT NULL,
    description    TEXT,
    weight_price   MONEY,
    distance_price MONEY,
    is_active      BOOLEAN DEFAULT FALSE NOT NULL,
    CONSTRAINT public_delivery_name_ui UNIQUE (name)
);
COMMENT ON TABLE public.delivery IS 'Таблица способов доставки довара';
COMMENT ON COLUMN public.delivery.name IS 'Название типа доставки';
COMMENT ON COLUMN public.delivery.description IS 'Описание';
COMMENT ON COLUMN public.delivery.weight_price IS 'Цена за кг';
COMMENT ON COLUMN public.delivery.distance_price IS 'Цена 1кг / 1 км';
COMMENT ON COLUMN public.delivery.is_active IS 'Статус - активна ли';

COMMENT ON CONSTRAINT public_delivery_name_ui ON public.delivery IS 'Название типа доставки должно быть уникальным';


-- СКЛАДЫ

CREATE TABLE public.storehouse
(
    id              BIGSERIAL PRIMARY KEY,
    name            VARCHAR(128)          NOT NULL,
    phone           VARCHAR(50)           NOT NULL,
    email           VARCHAR(70),
    country         VARCHAR(70),
    zip             VARCHAR(10),
    region          VARCHAR(70),
    metro           VARCHAR(70),
    street          VARCHAR(70),
    building        VARCHAR(15),
    room            VARCHAR(5),
    currency        VARCHAR(3)            NOT NULL,
    legal_person_id BIGINT                NOT NULL,
    is_active       BOOLEAN DEFAULT FALSE NOT NULL,
    CONSTRAINT public_storehouse_name_ui UNIQUE (name)
);
ALTER TABLE storehouse
    ADD CONSTRAINT public_storehouse_legal_person_fk FOREIGN KEY (legal_person_id) REFERENCES legal_person (id);

COMMENT ON TABLE public.storehouse IS 'Таблица складов. Контакты';
COMMENT ON COLUMN public.storehouse.name IS 'Название';
COMMENT ON COLUMN public.storehouse.phone IS 'Контактный телефон';
COMMENT ON COLUMN public.storehouse.email IS 'Email';
COMMENT ON COLUMN public.storehouse.zip IS 'Zip code, индекс';
COMMENT ON COLUMN public.storehouse.region IS 'Регион';
COMMENT ON COLUMN public.storehouse.metro IS 'Метро';
COMMENT ON COLUMN public.storehouse.street IS 'Улица';
COMMENT ON COLUMN public.storehouse.building IS 'Здание, строение, корпус';
COMMENT ON COLUMN public.storehouse.room IS 'Офис, помещение';
COMMENT ON COLUMN public.storehouse.currency IS 'Валюта, по которой идет расчет';
COMMENT ON COLUMN public.storehouse.is_active IS 'Статус, активен ли';

COMMENT ON CONSTRAINT public_storehouse_name_ui ON public.storehouse IS 'Название склада должно быть уникальным';


CREATE TABLE public.storehouse_available
(
    id            BIGSERIAL PRIMARY KEY,
    storehouse_id BIGINT NOT NULL,
    sku_id        BIGINT,
    product_id    BIGINT,
    available     INT,
    reserve       INT,
    CONSTRAINT public_storeshouse_available_reserve_less_available CHECK ( reserve <= available )
);
ALTER TABLE public.storehouse_available
    ADD CONSTRAINT storehouse_available_storehouse_fk FOREIGN KEY (storehouse_id) REFERENCES public.storehouse (id);
ALTER TABLE public.storehouse_available
    ADD CONSTRAINT storehouse_available_sku_fk FOREIGN KEY (sku_id) REFERENCES public.sku (id);
ALTER TABLE public.storehouse_available
    ADD CONSTRAINT storehouse_available_storehouse_product_fk FOREIGN KEY (product_id) REFERENCES public.product (id);
CREATE INDEX public_storehouse_available_storehouse_index ON public.storehouse_available (storehouse_id);
CREATE INDEX public_storehouse_available_product_index ON public.storehouse_available (product_id);
CREATE INDEX public_storehouse_available_sku_index ON public.storehouse_available (sku_id);

ALTER TABLE public.storehouse_available
    ADD CONSTRAINT public_storehouse_available_relationship_check CHECK (
        CASE
            WHEN sku_id ISNULL AND product_id ISNULL THEN FALSE
            WHEN sku_id NOTNULL AND product_id NOTNULL THEN FALSE
            ELSE TRUE
            END
        );

COMMENT ON TABLE public.storehouse_available IS 'Наличие товара на складе';
COMMENT ON COLUMN public.storehouse_available.storehouse_id IS 'Ссылка на склад';
COMMENT ON COLUMN public.storehouse_available.sku_id IS 'Ссылка на ТП';
COMMENT ON COLUMN public.storehouse_available.product_id IS 'Ссылка на товар';
COMMENT ON COLUMN public.storehouse_available.available IS 'Товара в наличии';
COMMENT ON COLUMN public.storehouse_available.reserve IS 'Зарезервировано товара';

COMMENT ON CONSTRAINT public_storeshouse_available_reserve_less_available ON public.storehouse_available IS 'Количество зарезервированного товара не может првышать количество товара в наличии. Зарезервированный товар - заказанный через интеренет-магазин';
COMMENT ON CONSTRAINT storehouse_available_storehouse_fk ON public.storehouse_available IS 'Внешний ключ на склад';
COMMENT ON CONSTRAINT storehouse_available_storehouse_product_fk ON public.storehouse_available IS 'Внешний ключ на товар';
COMMENT ON CONSTRAINT storehouse_available_sku_fk ON public.storehouse_available IS 'Внешний ключ на ТП';
COMMENT ON CONSTRAINT public_storehouse_available_relationship_check ON public.storehouse_available IS 'Может быть ссылка на товар или на ТП, но не сразу на то и другое';

COMMENT ON INDEX public_storehouse_available_storehouse_index IS 'Индекс на внешний ключ - на склад';
COMMENT ON INDEX public_storehouse_available_product_index IS 'Индекс на внешний ключ - на товар';
COMMENT ON INDEX public_storehouse_available_sku_index IS 'Индекс на внешний ключ - на ТП';


-- Дополнительные поля

CREATE TABLE public.field_type
(
    id   SMALLSERIAL PRIMARY KEY,
    name VARCHAR(128) NOT NULL,
    CONSTRAINT public_field_type_name_ui UNIQUE (name)
);
COMMENT ON TABLE public.field_type IS 'Таблица типов дополнительных полей';
COMMENT ON COLUMN public.field_type.name IS 'Название типа дополнительного поля';
COMMENT ON CONSTRAINT public_field_type_name_ui ON public.field_type IS 'Тип дополнительного поля';

CREATE TABLE public.field
(
    id            BIGSERIAL PRIMARY KEY,
    name          VARCHAR(128) NOT NULL,
    field_type_id SMALLINT     NOT NULL,
    product_id    BIGINT       NOT NULL,
    CONSTRAINT public_field_name_product_ui UNIQUE (product_id, name)
);
ALTER TABLE public.field
    ADD CONSTRAINT public_field_field_type_fk FOREIGN KEY (field_type_id) REFERENCES public.field_type (id);
ALTER TABLE public.field
    ADD CONSTRAINT public_field_product_fk FOREIGN KEY (product_id) REFERENCES public.product (id);
CREATE INDEX public_field_field_type_index ON public.field (field_type_id);
CREATE INDEX public_field_product_index ON public.field (product_id);

COMMENT ON TABLE public.field IS 'Дополнительные поля';
COMMENT ON COLUMN public.field.name IS 'Название дополнительных полей';
COMMENT ON COLUMN public.field.field_type_id IS 'Тип дополнительного поля. Декларативный характер, просто чтобы в админке было понятно, какой тип поля';
COMMENT ON COLUMN public.field.product_id IS 'Ссылка на товар. В моей реализации, дополнительные поля могут быть только у товара, но не у ТП';

COMMENT ON CONSTRAINT public_field_name_product_ui ON public.field IS 'Уникальный ключ на имя поля и на ссылку на товар';
COMMENT ON CONSTRAINT public_field_field_type_fk ON public.field IS 'Внешний ключ на тип доп поля';
COMMENT ON CONSTRAINT public_field_product_fk ON public.field IS 'Внешний ключ на продукт';

COMMENT ON INDEX public_field_field_type_index IS 'Индекс на внешний ключ - на тип доп.поля';
COMMENT ON INDEX public_field_product_index IS 'Индекс на внешний ключ - на продукт';


CREATE TABLE public.field_type_jsonb
(
    id       BIGSERIAL PRIMARY KEY,
    data     jsonb  NOT NULL,
    field_id BIGINT NOT NULL,
    CONSTRAINT public_field_type_jsonb_data_field_ui UNIQUE (data, field_id)
);
ALTER TABLE public.field_type_jsonb
    ADD CONSTRAINT public_field_type_jsonb_field_fk FOREIGN KEY (field_id) REFERENCES public.field (id);
CREATE INDEX public_field_type_jsonb_field_index ON public.field_type_jsonb (field_id);

COMMENT ON TABLE public.field_type_jsonb IS 'Дополнительные поля';
COMMENT ON COLUMN public.field_type_jsonb.data IS 'Данные, например, удобно хранить meta для сайта';
COMMENT ON COLUMN public.field_type_jsonb.field_id IS 'Ссылка на id доп.поля - а по нему я привяжу поле к товару';

COMMENT ON CONSTRAINT public_field_type_jsonb_data_field_ui ON public.field_type_jsonb IS 'Уникальный ключ по данным и id доп. поля';
COMMENT ON CONSTRAINT public_field_type_jsonb_field_fk ON public.field_type_jsonb IS 'Внешний ключ на доп. поле';

COMMENT ON INDEX public_field_type_jsonb_field_index IS 'Индекс на внешний ключ - на тип доп.поля';

CREATE TABLE public.field_type_int
(
    id       BIGSERIAL PRIMARY KEY,
    data     INT    NOT NULL,
    field_id BIGINT NOT NULL,
    CONSTRAINT public_field_type_int_data_field_ui UNIQUE (data, field_id)
);
ALTER TABLE public.field_type_int
    ADD CONSTRAINT public_field_type_int_field_fk FOREIGN KEY (field_id) REFERENCES public.field (id);
CREATE INDEX public_field_type_int_field_index ON public.field_type_int (field_id);

COMMENT ON TABLE public.field_type_int IS 'Таблица типа дополнительного поля: целое число';
COMMENT ON COLUMN public.field_type_int.data IS 'Данные, например, удобно хранить рейтинг товара';
COMMENT ON COLUMN public.field_type_int.field_id IS 'Ссылка на id доп.поля - а по нему я привяжу поле к товару';

COMMENT ON CONSTRAINT public_field_type_int_data_field_ui ON public.field_type_int IS 'Уникальный ключ по данным и id доп. поля';
COMMENT ON CONSTRAINT public_field_type_int_field_fk ON public.field_type_int IS 'Внешний ключ на доп. поле';

COMMENT ON INDEX public_field_type_int_field_index IS 'Индекс на внешний ключ - на тип доп.поля';

-- ПОЛЬЗОВАТЕЛИ

CREATE TABLE public.customer_address
(
    id       BIGSERIAL PRIMARY KEY,
    phone    VARCHAR(50) NOT NULL,
    country  VARCHAR(70),
    zip      VARCHAR(10),
    region   VARCHAR(70),
    metro    VARCHAR(70),
    street   VARCHAR(70),
    building VARCHAR(15),
    room     VARCHAR(5),
    CONSTRAINT public_customer_address_phone_ui UNIQUE (phone)
);
COMMENT ON TABLE public.customer_address IS 'Таблица адресов клиентов';
COMMENT ON COLUMN public.customer_address.phone IS 'Контактный телефон';
COMMENT ON COLUMN public.customer_address.zip IS 'Zip code, индекс';
COMMENT ON COLUMN public.customer_address.region IS 'Регион';
COMMENT ON COLUMN public.customer_address.metro IS 'Метро';
COMMENT ON COLUMN public.customer_address.street IS 'Улица';
COMMENT ON COLUMN public.customer_address.building IS 'Здание, строение, корпус';
COMMENT ON COLUMN public.customer_address.room IS 'Офис, помещение';

COMMENT ON CONSTRAINT public_customer_address_phone_ui ON public.customer_address IS 'Пусть будет привязка по телефону, все остальное - не факт, что клиент согласится давать реальные данные, если у меня, к примеру, интим интернет-магазин';


CREATE TABLE public.legal_address
(
    id       BIGSERIAL PRIMARY KEY,
    phone    VARCHAR(50) NOT NULL,
    country  VARCHAR(70) NOT NULL,
    zip      VARCHAR(10) NOT NULL,
    region   VARCHAR(70) NOT NULL,
    street   VARCHAR(70) NOT NULL,
    building VARCHAR(15) NOT NULL,
    room     VARCHAR(5)  NOT NULL
);
COMMENT ON TABLE public.legal_address IS 'Таблица адресов юрлиц. Уникального ключа нет. Юр адрес может совпадать с фактическим, но я не хочу в таблице legal_person накидывать одинаковые внешние ключи на юр адрес и фактический адрес';
COMMENT ON COLUMN public.legal_address.phone IS 'Контактный телефон';
COMMENT ON COLUMN public.legal_address.zip IS 'Zip code, индекс';
COMMENT ON COLUMN public.legal_address.region IS 'Регион';
COMMENT ON COLUMN public.legal_address.street IS 'Улица';
COMMENT ON COLUMN public.legal_address.building IS 'Здание, строение, корпус';
COMMENT ON COLUMN public.legal_address.room IS 'Офис, помещение';

---------------------------
-- LEGAL
-- тут наверное, много тонкостей, поэтому пока так
CREATE TABLE public.legal_person
(
    id                 BIGSERIAL PRIMARY KEY,
    inn                VARCHAR(12)  NOT NULL,
    kpp                VARCHAR(9)   NOT NULL,
    ogrn               VARCHAR(18)  NOT NULL,
    rs                 VARCHAR(20)  NOT NULL,
    ks                 VARCHAR(20)  NOT NULL,
    bik                VARCHAR(9)   NOT NULL,
    bank               VARCHAR(255) NOT NULL,
    city               VARCHAR(70)  NOT NULL,
    building           VARCHAR(12)  NOT NULL,
    room               VARCHAR(5),
    legal_address_id   BIGINT       NOT NULL,
    defacto_address_id BIGINT       NOT NULL,
    CONSTRAINT public_legal_person_all_ui UNIQUE (inn, kpp, ogrn, rs, ks, bik, bank, city, building,
                                                  legal_address_id, defacto_address_id)
);
ALTER TABLE public.legal_person
    ADD CONSTRAINT public_legal_address_customer_address_fk FOREIGN KEY (legal_address_id) REFERENCES public.legal_address (id);
ALTER TABLE public.legal_person
    ADD CONSTRAINT public_defacto_address_customer_address_fk FOREIGN KEY (defacto_address_id) REFERENCES public.legal_address (id);
CREATE INDEX public_legal_person_legal_address_index ON public.legal_person (legal_address_id);
CREATE INDEX public_legal_person_defacto_address_index ON public.legal_person (defacto_address_id);

COMMENT ON TABLE public.legal_person IS 'Таблица для счетов юрлиц.';
COMMENT ON COLUMN public.legal_person.inn IS 'ИНН';
COMMENT ON COLUMN public.legal_person.kpp IS 'КПП';
COMMENT ON COLUMN public.legal_person.ogrn IS 'ОГРН';
COMMENT ON COLUMN public.legal_person.rs IS 'Расчетный счет. не понятно, сколько в нем символов';
COMMENT ON COLUMN public.legal_person.ks IS 'Корсчет. Тоже надо уточнять относительно количества символов';
COMMENT ON COLUMN public.legal_person.bik IS 'БИК';
COMMENT ON COLUMN public.legal_person.bank IS 'Имя банка. Может быть очень длинным';
COMMENT ON COLUMN public.legal_person.city IS 'Город банка';
COMMENT ON COLUMN public.legal_person.building IS 'Здание, строение банка';
COMMENT ON COLUMN public.legal_person.room IS 'офис помещение банка';
COMMENT ON COLUMN public.legal_person.legal_address_id IS 'Ссылка на Юридический адрес';
COMMENT ON COLUMN public.legal_person.defacto_address_id IS 'Ссылка на Фактический адрес';

COMMENT ON CONSTRAINT public_legal_person_all_ui ON public.legal_person IS 'Уникальность юрлица. Пока уникальны все поля';
COMMENT ON CONSTRAINT public_legal_address_customer_address_fk ON public.legal_person IS 'Внешний ключ на юрадрес';
COMMENT ON CONSTRAINT public_defacto_address_customer_address_fk ON public.legal_person IS 'Внешний ключ на фактический адрес';

COMMENT ON INDEX public_legal_person_legal_address_index IS 'Индекс на внешний ключ - на юрадрес';
COMMENT ON INDEX public_legal_person_defacto_address_index IS 'Индекс на внешний ключ - на фактический адрес';


CREATE TYPE customer_type AS ENUM ('individual', 'legal');

CREATE TABLE public.customer
(
    id                  BIGSERIAL PRIMARY KEY,
    name                VARCHAR(35)   NOT NULL,
    surname             VARCHAR(35),
    patronymic          VARCHAR(35),
    login               VARCHAR(35)   NOT NULL,
    email               VARCHAR(70)   NOT NULL,
    password            VARCHAR(50)   NOT NULL,
    type                customer_type NOT NULL,
    legal_person_id     BIGINT,
    customer_address_id BIGINT,
    CONSTRAINT public_customer_email_ui UNIQUE (email),
    CONSTRAINT public_customer_login_ui UNIQUE (login)
);
ALTER TABLE public.customer
    ADD CONSTRAINT public_customer_customer_address_fk FOREIGN KEY (customer_address_id) REFERENCES public.customer_address (id);
ALTER TABLE public.customer
    ADD CONSTRAINT public_customer_legal_person_fk FOREIGN KEY (legal_person_id) REFERENCES legal_person (id);
CREATE INDEX public_customer_customer_address_index ON public.customer (customer_address_id);
CREATE INDEX public_customer_legal_person_index ON public.customer (legal_person_id);

ALTER TABLE public.customer
    ADD CONSTRAINT public_customer_relationship_check CHECK (
        CASE
            WHEN type = 'individual' AND customer_address_id NOTNULL THEN TRUE
            WHEN type = 'legal' AND legal_person_id NOTNULL THEN TRUE
            ELSE FALSE
            END
        );

COMMENT ON TABLE public.customer IS 'Таблица клиентов';
COMMENT ON COLUMN public.customer.name IS 'Имя';
COMMENT ON COLUMN public.customer.surname IS 'Фамилия';
COMMENT ON COLUMN public.customer.patronymic IS 'Отчество';
COMMENT ON COLUMN public.customer.login IS 'Логин';
COMMENT ON COLUMN public.customer.password IS 'Пароль';
COMMENT ON COLUMN public.customer.type IS 'Тип перечисления. Физическое или Юрлицо';
COMMENT ON COLUMN public.customer.legal_person_id IS 'Ссылка на юрлицо';
COMMENT ON COLUMN public.customer.customer_address_id IS 'Адрес физлица';

COMMENT ON CONSTRAINT public_customer_email_ui ON public.customer IS 'Email дожен быть уникальным';
COMMENT ON CONSTRAINT public_customer_login_ui ON public.customer IS 'Login дожен быть уникальным в принципе, а не только в связке с email';
COMMENT ON CONSTRAINT public_customer_customer_address_fk ON public.customer IS 'Внешний ключ на адрес физлица';
COMMENT ON CONSTRAINT public_customer_legal_person_fk ON public.customer IS 'Внешний ключ на юрлицо';
COMMENT ON CONSTRAINT public_customer_relationship_check ON public.customer IS 'Условие, что если клиент - физлицо, то должна быть ссылка на адрес, если юрлицо - на таблиц юрлиц';

COMMENT ON INDEX public_customer_customer_address_index IS 'Индекс на внешний ключ - на физический адрес';
COMMENT ON INDEX public_customer_legal_person_index IS 'Индекс на внешний ключ - на юрлицо';


-- Специалисты сайта

CREATE TABLE public.user_address
(
    id       BIGSERIAL PRIMARY KEY,
    phone    VARCHAR(50) NOT NULL,
    country  VARCHAR(70),
    zip      VARCHAR(10),
    region   VARCHAR(70),
    metro    VARCHAR(70),
    street   VARCHAR(70),
    building VARCHAR(15),
    room     VARCHAR(5),
    CONSTRAINT public_user_address_phone_ui UNIQUE (phone)
);
COMMENT ON TABLE public.user_address IS 'Таблица адресов специалистов, работающих с сайтом';
COMMENT ON COLUMN public.user_address.phone IS 'Контактный телефон';
COMMENT ON COLUMN public.user_address.zip IS 'Zip code, индекс';
COMMENT ON COLUMN public.user_address.region IS 'Регион';
COMMENT ON COLUMN public.user_address.metro IS 'Метро';
COMMENT ON COLUMN public.user_address.street IS 'Улица';
COMMENT ON COLUMN public.user_address.building IS 'Здание, строение, корпус';
COMMENT ON COLUMN public.user_address.room IS 'Офис, помещение';

COMMENT ON CONSTRAINT public_user_address_phone_ui ON public.user_address IS 'Уникальный только телефон, т.к. могут быть фрилансеры';


-- user я его назвать не могу - зарезервированное имя
CREATE TABLE public.site_user
(
    id              BIGSERIAL PRIMARY KEY,
    name            VARCHAR(35)   NOT NULL,
    surname         VARCHAR(35),
    patronymic      VARCHAR(35),
    login           VARCHAR(35)   NOT NULL,
    email           VARCHAR(70)   NOT NULL,
    password        VARCHAR(50)   NOT NULL,
    roles           VARCHAR(1024) NOT NULL,
    user_address_id BIGINT        NOT NULL,
    CONSTRAINT public_user_email_ui UNIQUE (email),
    CONSTRAINT public_user_login_ui UNIQUE (login)
);
ALTER TABLE public.site_user
    ADD CONSTRAINT public_user_user_address_fk FOREIGN KEY (user_address_id) REFERENCES public.user_address (id);
CREATE INDEX public_site_user_user_address_index ON public.site_user (user_address_id);

COMMENT ON TABLE public.site_user IS 'Таблица специалистов, работающих с сайтом';
COMMENT ON COLUMN public.site_user.roles IS 'Роли пользователей. Роли могут быть сериализованы, так что непонятно, сколько они занимают места';
COMMENT ON COLUMN public.site_user.name IS 'Имя';
COMMENT ON COLUMN public.site_user.surname IS 'Фамилия';
COMMENT ON COLUMN public.site_user.patronymic IS 'Отчество';
COMMENT ON COLUMN public.site_user.login IS 'Логин';
COMMENT ON COLUMN public.site_user.password IS 'Пароль';
COMMENT ON COLUMN public.site_user.user_address_id IS 'Ссылка на адрес';

COMMENT ON CONSTRAINT public_user_email_ui ON public.site_user IS 'Email дожен быть уникальным';
COMMENT ON CONSTRAINT public_user_login_ui ON public.site_user IS 'Login дожен быть уникальным в принципе, а не только в связке с email';
COMMENT ON CONSTRAINT public_user_user_address_fk ON public.site_user IS 'Внешний ключ на адрес';

COMMENT ON INDEX public_site_user_user_address_index IS 'Индекс на внешний ключ - на адрес';


-- ЗАКАЗЫ

CREATE TABLE public.order_address
(
    id       BIGSERIAL PRIMARY KEY,
    phone    VARCHAR(50) NOT NULL,
    country  VARCHAR(70),
    zip      VARCHAR(10),
    region   VARCHAR(70),
    metro    VARCHAR(70),
    street   VARCHAR(70),
    building VARCHAR(15),
    room     VARCHAR(5),
    CONSTRAINT public_order_address_phone_ui UNIQUE (phone)
);
COMMENT ON TABLE public.order_address IS 'Таблица адресов заказа';
COMMENT ON COLUMN public.order_address.phone IS 'Контактный телефон';
COMMENT ON COLUMN public.order_address.zip IS 'Zip code, индекс';
COMMENT ON COLUMN public.order_address.region IS 'Регион';
COMMENT ON COLUMN public.order_address.metro IS 'Метро';
COMMENT ON COLUMN public.order_address.street IS 'Улица';
COMMENT ON COLUMN public.order_address.building IS 'Здание, строение, корпус';
COMMENT ON COLUMN public.order_address.room IS 'Офис, помещение';

COMMENT ON CONSTRAINT public_order_address_phone_ui ON public.order_address IS 'Уникальный только телефон, т.к. тип доставки может быть курьер, и адрес - в поле комментарий к заказу';


CREATE TABLE public.payment
(
    id          BIGSERIAL PRIMARY KEY,
    name        VARCHAR(128)                NOT NULL,
    description VARCHAR(255),
    currency    VARCHAR(3),
    is_active   BOOLEAN       DEFAULT FALSE NOT NULL,
    options     JSONB,
    fee         DECIMAL(6, 4) DEFAULT 0     NOT NULL,
    inn         VARCHAR(12),
    comment     VARCHAR(512),
    CONSTRAINT public_payment_name_ui UNIQUE (name)
);
COMMENT ON TABLE public.payment IS 'Таблица доступных платежных систем';
COMMENT ON COLUMN public.payment.name IS 'Название платежной системы';
COMMENT ON COLUMN public.payment.description IS 'Описание платежной системы';
COMMENT ON COLUMN public.payment.currency IS 'Валюта платежной системы';
COMMENT ON COLUMN public.payment.is_active IS 'Активна ли платежная система';
COMMENT ON COLUMN public.payment.inn IS 'ИНН платежной системы';
COMMENT ON COLUMN public.payment.options IS 'Дополнительные опции платежных систем';
COMMENT ON COLUMN public.payment.fee IS 'Комиссия';
COMMENT ON COLUMN public.payment.comment IS 'Комментарий к платежной системе';

COMMENT ON CONSTRAINT public_payment_name_ui ON public.payment IS 'Уникальность определяется по имени';

-- order тоже зарезервированное слово
CREATE TABLE public.shop_order
(
    id               BIGSERIAL PRIMARY KEY,
    weight           DECIMAL(10, 4) DEFAULT 0 NOT NULL,
    distance         INT            DEFAULT 0 NOT NULL,
    cart_cost        NUMERIC(19, 6)           NOT NULL,
    delivery_cost    NUMERIC(19, 6) DEFAULT 0 NOT NULL,
    cost             NUMERIC(19, 6)           NOT NULL,
    comment          VARCHAR(512),
    order_address_id BIGINT,
    customer_id      BIGINT                   NOT NULL,
    delivery_id      BIGINT                   NOT NULL
);
ALTER TABLE public.shop_order
    ADD CONSTRAINT public_order_customer_created_ui UNIQUE (customer_id, created_at);

ALTER TABLE public.shop_order
    ADD CONSTRAINT public_order_order_address_fk FOREIGN KEY (order_address_id) REFERENCES public.order_address (id);
ALTER TABLE public.shop_order
    ADD CONSTRAINT public_order_delivery_fk FOREIGN KEY (delivery_id) REFERENCES public.delivery (id);
ALTER TABLE public.shop_order
    ADD CONSTRAINT public_order_customer_fk FOREIGN KEY (customer_id) REFERENCES public.customer (id);

ALTER TABLE shop_order
    ADD CONSTRAINT public_shop_order_cart_cost_check CHECK (
        CASE WHEN cart_cost > 0 THEN TRUE ELSE FALSE END);
ALTER TABLE shop_order
    ADD CONSTRAINT public_shop_order_delivery_cost_check CHECK (
        CASE WHEN delivery_cost >= 0 THEN TRUE ELSE FALSE END);
ALTER TABLE shop_order
    ADD CONSTRAINT public_shop_order_cost_check CHECK (
        CASE WHEN cost > 0 THEN TRUE ELSE FALSE END);

CREATE INDEX public_shop_order_order_address_index ON public.shop_order (order_address_id);
CREATE INDEX public_shop_order_customer_index ON public.shop_order (customer_id);
CREATE INDEX public_shop_order_delivery_index ON public.shop_order (delivery_id);
CREATE INDEX public_shop_order_payment_index ON public.shop_order (payment_id);

COMMENT ON TABLE public.shop_order IS 'Таблица заказов';
COMMENT ON COLUMN public.shop_order.distance IS 'Поле расстояние - для доставки';
COMMENT ON COLUMN public.shop_order.weight IS 'Поле вес - для доставки';
COMMENT ON COLUMN public.shop_order.cart_cost IS 'Цена по корзине';
COMMENT ON COLUMN public.shop_order.delivery_cost IS 'Цена доставки. Может быть 0';
COMMENT ON COLUMN public.shop_order.cost IS 'Общая цена - получается из обычного сложения cart_cost + delivery_cost';
COMMENT ON COLUMN public.shop_order.comment IS 'Комментарий клиента к заказу';
COMMENT ON COLUMN public.shop_order.order_address_id IS 'Клиент может указать другой адрес, или не указывать вовсе - тогда на тот, что указан при регистрации';
COMMENT ON COLUMN public.shop_order.customer_id IS 'Ссылка на клиента';
COMMENT ON COLUMN public.shop_order.payment_id IS 'Ссылка на платежную систему';
COMMENT ON COLUMN public.shop_order.delivery_id IS 'Ссылка на способ доставки';

COMMENT ON CONSTRAINT public_order_customer_created_ui ON public.shop_order IS 'Уникальность определяется id клиента и временем, когда поступил заказ';
COMMENT ON CONSTRAINT public_order_order_address_fk ON public.shop_order IS 'Внешний ключ - если указан доп адрес для заказа';
COMMENT ON CONSTRAINT public_order_delivery_fk ON public.shop_order IS 'Внешний ключ - на способ доставки';
COMMENT ON CONSTRAINT public_order_customer_fk ON public.shop_order IS 'Внешний ключ - на клиента';
COMMENT ON CONSTRAINT public_order_customer_fk ON public.shop_order IS 'Внешний ключ - на клиента';
COMMENT ON CONSTRAINT public_order_payment_fk ON public.shop_order IS 'Внешний ключ - на платежную систему';

COMMENT ON CONSTRAINT public_shop_order_cart_cost_check ON public.shop_order IS 'Ограничение, цена по корзине больше ноля';
COMMENT ON CONSTRAINT public_shop_order_delivery_cost_check ON public.shop_order IS 'Ограничение, цена доставки больше либо равно нолю';
COMMENT ON CONSTRAINT public_shop_order_cost_check ON public.shop_order IS 'Ограничение, общая цена доставки больше ноля';

COMMENT ON INDEX public_shop_order_order_address_index IS 'Индекс на внешний ключ - на адрес заказа';
COMMENT ON INDEX public_shop_order_customer_index IS 'Индекс на внешний ключ - на клиента';
COMMENT ON INDEX public_shop_order_delivery_index IS 'Индекс на внешний ключ - на доставку';
COMMENT ON INDEX public_shop_order_payment_index IS 'Индекс на внешний ключ - на платежную систему';



CREATE TABLE public.order_status
(
    id   SMALLSERIAL PRIMARY KEY,
    name VARCHAR(128) NOT NULL,
    CONSTRAINT public_order_status_name_ui UNIQUE (name)
);
COMMENT ON TABLE public.order_status IS 'Таблица статусов заказов';
COMMENT ON COLUMN public.order_status.name IS 'Поле статусов заказа, к примеру, новый, согласован, оплачен, возврат и так далее';
COMMENT ON CONSTRAINT public_order_status_name_ui ON public.order_status IS 'Название статуса не должно дублироваться';

CREATE TABLE public.transaction
(
    id          BIGSERIAL PRIMARY KEY,
    payment_id  BIGINT NOT NULL,
    transaction TEXT,
    CONSTRAINT public_transaction_payment_transaction_ui UNIQUE (payment_id, transaction)
);
ALTER TABLE public.transaction
    ADD CONSTRAINT public_transaction_payment_fk FOREIGN KEY (payment_id) REFERENCES payment (id);
CREATE INDEX public_transaction_payment_index ON public.transaction (payment_id);
COMMENT ON INDEX public_transaction_payment_index IS 'Для поиска по транзакции';


ALTER TABLE order_processing
    ADD COLUMN transaction_id BIGINT;


CREATE TABLE public.order_processing
(
    id              BIGSERIAL PRIMARY KEY,
    site_user_id    BIGINT,
    shop_order_id   BIGINT       NOT NULL,
    order_status_id SMALLINT     NOT NULL,
    transaction_id  BIGINT,
    cash_voucher    VARCHAR(128) NOT NULL,
    comment         VARCHAR(512),
    CONSTRAINT public_order_processing_shop_order_ui UNIQUE (shop_order_id)
);
ALTER TABLE order_processing
    ADD CONSTRAINT public_order_processing_transaction_fk FOREIGN KEY (transaction_id) REFERENCES public.transaction (id);

ALTER TABLE public.order_processing
    ADD CONSTRAINT public_order_processing_user_fk FOREIGN KEY (site_user_id) REFERENCES public.site_user (id);
ALTER TABLE public.order_processing
    ADD CONSTRAINT public_order_processing_order_fk FOREIGN KEY (shop_order_id) REFERENCES public.shop_order (id);
ALTER TABLE public.order_processing
    ADD CONSTRAINT public_order_processing_status_fk FOREIGN KEY (order_status_id) REFERENCES public.order_status (id);
CREATE INDEX public_order_processing_site_user_index ON public.order_processing (site_user_id);
CREATE INDEX public_order_processing_shop_order_index ON public.order_processing (shop_order_id);
CREATE INDEX public_order_processing_order_status_index ON public.order_processing (order_status_id);

COMMENT ON TABLE public.order_processing IS 'Таблица сопровождения заказа';
COMMENT ON COLUMN public.order_processing.site_user_id IS 'Менеджер сопровождающий заказ';
COMMENT ON COLUMN public.order_processing.shop_order_id IS 'Ссылка на заказ';
COMMENT ON COLUMN public.order_processing.cash_voucher IS 'Чек';
COMMENT ON COLUMN public.order_processing.comment IS 'Комментарий менеджера';

COMMENT ON CONSTRAINT public_order_processing_shop_order_ui ON public.order_processing IS 'Уникальность по id заказа';
COMMENT ON CONSTRAINT public_order_processing_user_fk ON public.order_processing IS 'Внешний ключ на менеджера';
COMMENT ON CONSTRAINT public_order_processing_order_fk ON public.order_processing IS 'Внешний ключ на id заказа';
COMMENT ON CONSTRAINT public_order_processing_status_fk ON public.order_processing IS 'Внешний ключ на статус заказ';

COMMENT ON INDEX public_order_processing_site_user_index IS 'Индекс на внешний ключ - на менеджера';
COMMENT ON INDEX public_order_processing_shop_order_index IS 'Индекс на внешний ключ - на заказ';
COMMENT ON INDEX public_order_processing_order_status_index IS 'Индекс на внешний ключ - на статус заказа';

-- PRODUCT - order

CREATE TABLE public.product2order
(
    id            BIGSERIAL PRIMARY KEY,
    product_id    BIGINT NOT NULL,
    shop_order_id BIGINT NOT NULL,
    quantity      INT    NOT NULL,
    CONSTRAINT public_product2order_order_ui UNIQUE (shop_order_id, product_id)
);
ALTER TABLE public.product2order
    ADD CONSTRAINT public_product2order_product_fk FOREIGN KEY (product_id) REFERENCES public.product (id);
ALTER TABLE public.product2order
    ADD CONSTRAINT public_product2order_order_fk FOREIGN KEY (shop_order_id) REFERENCES public.shop_order (id);

CREATE INDEX public_product2order_product_index ON public.product2order (product_id);
CREATE INDEX public_product2order_shop_order_index ON public.product2order (shop_order_id);

COMMENT ON TABLE public.product2order IS 'Кросс таблица заказ-артикул-товар и количество на каждый артикул-товар';
COMMENT ON COLUMN public.product2order.product_id IS 'Ссылка на товар';
COMMENT ON COLUMN public.product2order.shop_order_id IS 'Ссылка id заказа';
COMMENT ON COLUMN public.product2order.quantity IS 'Поле количество на каждый артикул-товар';

COMMENT ON CONSTRAINT public_product2order_order_ui ON public.product2order IS 'Уникальность определятся по заказу, ТП, товару';
COMMENT ON CONSTRAINT public_product2order_product_fk ON public.product2order IS 'Внешний ключ на товар';
COMMENT ON CONSTRAINT public_product2order_order_fk ON public.product2order IS 'Внешний ключ на заказ';

COMMENT ON INDEX public_product2order_product_index IS 'Индекс на внешний ключ - на товар';
COMMENT ON INDEX public_product2order_shop_order_index IS 'Индекс на внешний ключ - на заказ';


-- SKU-order
CREATE TABLE public.sku2order
(
    id            BIGSERIAL PRIMARY KEY,
    sku_id        BIGINT NOT NULL,
    shop_order_id BIGINT NOT NULL,
    quantity      INT    NOT NULL,
    CONSTRAINT public_sku2order_sku_order_ui UNIQUE (shop_order_id, sku_id)
);
ALTER TABLE public.sku2order
    ADD CONSTRAINT public_sku2order_sku_fk FOREIGN KEY (sku_id) REFERENCES public.sku (id);

ALTER TABLE public.sku2order
    ADD CONSTRAINT public_sku2order_order_fk FOREIGN KEY (shop_order_id) REFERENCES public.shop_order (id);

CREATE INDEX public_sku2order_sku_index ON public.sku2order (sku_id);
CREATE INDEX public_sku2order_shop_order_index ON public.sku2order (shop_order_id);

COMMENT ON TABLE public.sku2order IS 'Кросс таблица заказ-артикул-товар и количество на каждый артикул-товар';
COMMENT ON COLUMN public.sku2order.sku_id IS 'Ссылка на ТП';
COMMENT ON COLUMN public.sku2order.shop_order_id IS 'Ссылка id заказа';
COMMENT ON COLUMN public.sku2order.quantity IS 'Поле количество на каждый артикул-товар';

COMMENT ON CONSTRAINT public_sku2order_sku_order_ui ON public.sku2order IS 'Уникальность определятся по заказу, ТП, товару';
COMMENT ON CONSTRAINT public_sku2order_sku_fk ON public.sku2order IS 'Внешний ключ на ТП';
COMMENT ON CONSTRAINT public_sku2order_order_fk ON public.sku2order IS 'Внешний ключ на заказ';

COMMENT ON INDEX public_sku2order_sku_index IS 'Индекс на внешний ключ - на ТП';
COMMENT ON INDEX public_sku2order_shop_order_index IS 'Индекс на внешний ключ - на заказ';

-- АНАЛИТИКА


CREATE TABLE public.product_price_history
(
    id         BIGSERIAL PRIMARY KEY,
    product_id BIGINT         NOT NULL,
    price      NUMERIC(19, 6) NOT NULL
);
ALTER TABLE public.product_price_history
    ADD CONSTRAINT public_product_price_history_product_fk FOREIGN KEY (product_id) REFERENCES public.product (id);
CREATE INDEX public_product_price_history_product_index ON public.product_price_history (product_id);

COMMENT ON TABLE public.product_price_history IS 'Аналитическая таблица предыдущих цен для продукта.';
COMMENT ON COLUMN public.product_price_history.product_id IS 'Ссылка на товар';
COMMENT ON COLUMN public.product_price_history.price IS 'Поле для исторических цен';

COMMENT ON CONSTRAINT public_product_price_history_product_fk ON public.product_price_history IS 'Внешний ключ на товар';

COMMENT ON INDEX public_product_price_history_product_index IS 'Индекс на внешний ключ - на товар';


CREATE TABLE public.sku_price_history
(
    id     BIGSERIAL PRIMARY KEY,
    sku_id BIGINT         NOT NULL,
    price  NUMERIC(19, 6) NOT NULL
);
ALTER TABLE public.sku_price_history
    ADD CONSTRAINT public_sku_price_history_product_fk FOREIGN KEY (sku_id) REFERENCES public.sku (id);
CREATE INDEX public_sku_price_history_sku_index ON public.sku_price_history (sku_id);

COMMENT ON TABLE public.sku_price_history IS 'Аналитическая таблица предыдущих цен для торговых предложений';
COMMENT ON COLUMN public.sku_price_history.sku_id IS 'Ссылка на ТП';
COMMENT ON COLUMN public.sku_price_history.price IS 'Поле для исторических цен';

COMMENT ON CONSTRAINT public_sku_price_history_product_fk ON public.sku_price_history IS 'Внешний ключ на ТП';

COMMENT ON INDEX public_sku_price_history_sku_index IS 'Индекс на внешний ключ - на товар';



CREATE OR REPLACE FUNCTION public.get_product_price() RETURNS TRIGGER
    LANGUAGE plpgsql
AS
$$
BEGIN
    INSERT INTO public.product_price_history (price, product_id) VALUES (NEW.price, NEW.id);
    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.get_sku_price() RETURNS TRIGGER
    LANGUAGE plpgsql
AS
$$
BEGIN
    INSERT INTO public.sku_price_history (price, sku_id) VALUES (NEW.price, NEW.id);
    RETURN NEW;
END;
$$;

CREATE TRIGGER trigger_public_sku_price
    AFTER INSERT OR UPDATE
    ON public.sku
    FOR EACH ROW
EXECUTE PROCEDURE public.get_sku_price();

CREATE TRIGGER trigger_public_product_price
    AFTER INSERT OR UPDATE
    ON public.product
    FOR EACH ROW
EXECUTE PROCEDURE public.get_product_price();


COMMENT ON COLUMN public.article_category.slug IS 'Человекопонятный URL на категорию статей';
CREATE INDEX public_article_category_slug_index ON public.article_category (slug);
COMMENT ON INDEX public_article_category_slug_index IS 'Для поиска по человекопонятному URL в категориях статей';


COMMENT ON COLUMN public.article.slug IS 'Человекопонятный URL на статью';
CREATE INDEX public_article_slug_index ON public.article (slug);
COMMENT ON INDEX public_article_slug_index IS 'Для поиска по человекопонятному URL в статьях';


COMMENT ON COLUMN public.product_category.slug IS 'Человекопонятный URL на категорию продукта';
CREATE INDEX public_product_category_slug_index ON public.product_category (slug);
COMMENT ON INDEX public_product_category_slug_index IS 'Для поиска по человекопонятному URL в категориях продукта';


COMMENT ON COLUMN public.product.slug IS 'Человекопонятный URL на продукт';
CREATE INDEX public_product_slug_index ON public.product_category (slug);
COMMENT ON INDEX public_product_slug_index IS 'Для поиска по человекопонятному URL в продуктах';

CREATE INDEX public_discount_name_index ON public.discount (name);
COMMENT ON INDEX public_discount_name_index IS 'Для поиска по на названию скидки';

CREATE INDEX public_vendor_name_index ON public.vendor (name);
COMMENT ON INDEX public_vendor_name_index IS 'Для поиска по названию производителя';

CREATE INDEX public_sku_name_index ON public.sku (name);
COMMENT ON INDEX public_sku_name_index IS 'Для поиска по названию Торгового предложения / артикула';

CREATE INDEX public_article_category_title_index ON public.article_category (title);
COMMENT ON INDEX public_article_category_title_index IS 'Для поиска по названию категории статей';

CREATE INDEX public_article_title_index ON public.article (title);
COMMENT ON INDEX public_article_title_index IS 'Для поиска по названию статьи';

CREATE INDEX public_product_category_title_index ON public.product_category (title);
COMMENT ON INDEX public_product_category_title_index IS 'Для поиска по названию категории товара';

CREATE INDEX public_product_title_index ON public.product (title);
COMMENT ON INDEX public_product_title_index IS 'Для поиска по названию товара';

CREATE INDEX public_customer_login_index ON public.customer (login);
COMMENT ON INDEX public_customer_login_index IS 'Для поиска по логину клиента';

CREATE INDEX public_customer_password_index ON public.customer (password);
COMMENT ON INDEX public_customer_password_index IS 'Для поиска по паролю клиента';


CREATE TABLE public.currency_rate
(
    id            BIGSERIAL PRIMARY KEY,
    date          DATE           NOT NULL,
    currency_from VARCHAR(3)     NOT NULL,
    currency_to   VARCHAR(3)     NOT NULL,
    value         NUMERIC(19, 8) NOT NULL,
    CONSTRAINT public_currency_rate_date_currencies_ui UNIQUE (date, currency_to, currency_from)
);

COMMENT ON TABLE public.currency_rate IS 'Таблица валют. Значения подтягиваются ежедневно';
COMMENT ON COLUMN public.currency_rate.currency_from IS 'Преобразовать из какой валюты';
COMMENT ON COLUMN public.currency_rate.currency_to IS 'Преобразовать в какую валюту';
COMMENT ON COLUMN public.currency_rate.value IS 'Кросс-курс валют currency_from/currency_to';

COMMENT ON CONSTRAINT public_currency_rate_date_currencies_ui ON public.currency_rate IS 'Уникальный ключ по дате и кросс-курсу';

CREATE TABLE public.customer_session
(
    id          BIGSERIAL PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    session     TEXT   NOT NULL,
    actions     JSONB,
    CONSTRAINT public_customer_customer_session_ui UNIQUE (customer_id, session)
);
ALTER TABLE public.customer_session
    ADD CONSTRAINT public_customer_session_customer_fk FOREIGN KEY (customer_id) REFERENCES customer (id);

CREATE TABLE public.cart
(
    id          BIGSERIAL PRIMARY KEY,
    cart        JSONB                 NOT NULL,
    customer_id BIGINT                NOT NULL,
    session     TEXT                  NOT NULL,
    is_approved BOOLEAN DEFAULT FALSE NOT NULL,
    CONSTRAINT public_cart_cart_customer_session_ui UNIQUE (cart, customer_id, session)
);
ALTER TABLE public.cart ADD CONSTRAINT public_cart_customer_fk FOREIGN KEY (customer_id) REFERENCES public.customer (id);
CREATE INDEX ON public.cart (customer_id);





