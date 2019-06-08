-- все переписываю, причины - ревизия + я сделал ошибку, когда накидывал TIMESTAMP WITHOUT TIME ZONE

DROP SCHEMA public CASCADE;
CREATE SCHEMA public;


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
    raise notice 'table: %', REPLACE(table_name, '.', '_');
    raise notice 'table: %', SPLIT_PART(table_name, '.', 1);
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


-- ARTICLE SECTION

CREATE TABLE public.article_category
(
    id          SERIAL PRIMARY KEY,
    title       TEXT CHECK ( LENGTH(title) < 255 ) NOT NULL,
    longtitle   TEXT CHECK ( LENGTH(longtitle) < 255 ),
    image_intro TEXT CHECK ( LENGTH(image_intro) < 1024),
    image       TEXT CHECK ( LENGTH(image) < 1024),
    slug        TEXT CHECK ( LENGTH(slug) < 255)   NOT NULL,
    intro       TEXT CHECK ( LENGTH(intro) < 1024),
    description TEXT,
    content     TEXT,
    is_deleted  BOOLEAN,
    is_publish  BOOLEAN,
    parent_id   SMALLINT,
    CONSTRAINT public_article_category_title_parent_id_ui UNIQUE (title, parent_id, slug)
);
ALTER TABLE public.article_category
    ADD CONSTRAINT public_article_category_article_category_fk FOREIGN KEY (parent_id) REFERENCES public.article_category (id);
CREATE INDEX ON public.article_category (parent_id);

COMMENT ON TABLE public.article_category IS 'Таблица для категорий статей';

CREATE TABLE public.article
(
    id                  SERIAL PRIMARY KEY,
    title               TEXT CHECK ( LENGTH(title) < 255 ) NOT NULL,
    longtitle           TEXT CHECK ( LENGTH(longtitle) < 255 ),
    image_intro         TEXT CHECK ( LENGTH(image_intro) < 1024),
    image               TEXT CHECK ( LENGTH(image) < 1024),
    slug                TEXT CHECK ( LENGTH(slug) < 255)   NOT NULL,
    intro               TEXT CHECK ( LENGTH(intro) < 1024),
    description         TEXT,
    content             TEXT,
    is_deleted          BOOLEAN,
    is_publish          BOOLEAN,
    article_category_id SMALLINT                           NOT NULL,
    CONSTRAINT public_article_title_article_category_id_ui UNIQUE (title, article_category_id, slug)

);
ALTER TABLE public.article
    ADD CONSTRAINT public_article_article_category_fk FOREIGN KEY (article_category_id) REFERENCES public.article_category (id);
CREATE INDEX ON public.article (article_category_id);

COMMENT ON TABLE public.article IS 'Таблица для статей';

-- PRODUCT SECTION

CREATE TABLE public.product_category
(
    id          SERIAL PRIMARY KEY,
    title       TEXT CHECK ( LENGTH(title) < 255 ) NOT NULL,
    longtitle   TEXT CHECK ( LENGTH(longtitle) < 255 ),
    image_intro TEXT CHECK ( LENGTH(image_intro) < 1024),
    image       TEXT CHECK ( LENGTH(image) < 1024),
    slug        TEXT CHECK ( LENGTH(slug) < 255)   NOT NULL,
    intro       TEXT CHECK ( LENGTH(intro) < 1024),
    description TEXT,
    content     TEXT,
    is_deleted  BOOLEAN,
    is_publish  BOOLEAN,
    parent_id   INT,
    CONSTRAINT public_product_title_parent_id_ui UNIQUE (title, parent_id, slug)
);
ALTER TABLE public.product_category
    ADD CONSTRAINT public_product_category_product_category_fk FOREIGN KEY (parent_id) REFERENCES public.product_category (id);
CREATE INDEX ON public.product_category (parent_id);

COMMENT ON TABLE product_category IS 'Таблица категорий продуктов';

CREATE TABLE public.product_status
(
    id     SMALLSERIAL PRIMARY KEY,
    status TEXT CHECK ( LENGTH(status) < 255 ) NOT NULL
);

COMMENT ON TABLE public.product_status IS 'Таблица для отображения статусов продукта';
COMMENT ON COLUMN public.product_status.status IS 'На данный момент, Может быть вида: в наличии, ожидается, отсутствует';

CREATE TABLE public.vendor
(
    id      SMALLSERIAL PRIMARY KEY,
    name    TEXT CHECK ( LENGTH(name) < 255 ) NOT NULL,
    country TEXT CHECK ( LENGTH(country) < 128 ),
    page    TEXT CHECK ( LENGTH(page) < 255),
    email   TEXT CHECK ( LENGTH(email) < 255) NOT NULL,
    phone   TEXT CHECK ( LENGTH(phone) < 128),
    logo    TEXT CHECK ( LENGTH(logo) < 1024)
);
COMMENT ON TABLE public.vendor IS 'Таблица для отображения производителей товаров';

CREATE TABLE public.product
(
    id                  BIGSERIAL PRIMARY KEY,
    title               TEXT CHECK ( LENGTH(title) < 255 ) NOT NULL,
    longtitle           TEXT CHECK ( LENGTH(title) < 255 ),
    image_intro         TEXT CHECK ( LENGTH(title) < 1024),
    image               TEXT CHECK ( LENGTH(title) < 1024),
    slug                TEXT CHECK ( LENGTH(title) < 255)  NOT NULL,
    intro               TEXT CHECK ( LENGTH(title) < 1024),
    description         TEXT,
    content             TEXT,
    price               MONEY,
    old_price           MONEY,
    is_deleted          BOOLEAN,
    is_publish          BOOLEAN,
    special             BOOLEAN,
    novelty             BOOLEAN,
    popular             BOOLEAN,
    product_category_id INT                                NOT NULL,
    product_status_id   SMALLINT,
    vendor_id           INT,
    CONSTRAINT public_product_title_product_category_ui UNIQUE (title, product_category_id, slug)
);
ALTER TABLE public.product
    ADD CONSTRAINT public_product_product_status_fk FOREIGN KEY (product_status_id) REFERENCES public.product_status (id);
ALTER TABLE public.product
    ADD CONSTRAINT public_product_vendor_fk FOREIGN KEY (vendor_id) REFERENCES public.vendor (id);

ALTER TABLE product
    ADD CONSTRAINT public_product_price_check CHECK (
        CASE WHEN price NOTNULL AND price >= 0 :: money THEN TRUE ELSE FALSE END);
ALTER TABLE product
    ADD CONSTRAINT public_product_old_price_check CHECK (
        CASE WHEN old_price NOTNULL AND old_price >= 0 :: money THEN TRUE ELSE FALSE END);

ALTER TABLE public.product
    ADD
        CONSTRAINT public_product_product_category FOREIGN KEY (product_category_id) REFERENCES public.product_category (id);
CREATE INDEX ON public.product (product_category_id);
CREATE INDEX ON public.product (vendor_id);
CREATE INDEX ON public.product (product_status_id);

-- Есть ли ТП на продукт
ALTER TABLE public.product
    ADD COLUMN is_sku BOOLEAN DEFAULT FALSE;

COMMENT ON TABLE public.product IS 'Таблица для отображения товаров';
COMMENT ON COLUMN public.product.popular IS 'Флаг популярный. Может использоваться для Хит продаж';
COMMENT ON COLUMN public.product.novelty IS 'Флаг новинка. Может использоваться для новинка';
COMMENT ON COLUMN public.product.special IS 'Флаг особый, специальный. Кастомное использование';
COMMENT ON COLUMN public.product.old_price IS 'Поле Старая(прошлая цена). Очень часто используется в маркетинговых целях, часто поставляется по умолчанию';
COMMENT ON COLUMN public.product.is_sku IS 'Поле, которое определяет, если ли у товара торговые предложения';
-- АРТИКУЛЫ

CREATE TABLE public.sku
(
    id          SERIAL PRIMARY KEY,
    sku         TEXT CHECK ( LENGTH(sku) < 255 ) NOT NULL,
    name        TEXT CHECK ( LENGTH(name) < 255 ),
    price       MONEY,
    old_price   MONEY,
    image       TEXT CHECK ( LENGTH(image) < 1024 ),
    description TEXT,
    content     TEXT,
    is_deleted  BOOLEAN,
    is_publish  BOOLEAN,
    product_id  INT                              NOT NULL,
    CONSTRAINT public_sku_product_sku_ui UNIQUE (sku),
    CONSTRAINT public_sku_price_check CHECK (
        CASE WHEN price NOTNULL AND price >= 0 :: money THEN TRUE ELSE FALSE END),
    CONSTRAINT public_sku_old_price_check CHECK (
        CASE WHEN old_price NOTNULL AND old_price >= 0 :: money THEN TRUE ELSE FALSE END)
);
ALTER TABLE public.sku
    ADD CONSTRAINT public_sku_product_fk FOREIGN KEY (product_id) REFERENCES public.product (id);

COMMENT ON TABLE public.sku IS 'Таблица для отображения артикулов товара (товаров с Торговыми предложениями)';
COMMENT ON COLUMN public.sku.name IS 'Название для ТП, nullable';
COMMENT ON COLUMN public.sku.old_price IS 'Поле Старая(прошлая цена). Очень часто используется в маркетинговых целях, часто поставляется по умолчанию';

-- ХАРАКТЕРИСТИКИ

CREATE TABLE public.product_chars
(
    id   SERIAL PRIMARY KEY,
    name TEXT CHECK ( LENGTH(name) < 255 ) NOT NULL
);
COMMENT ON TABLE public.product_chars IS 'Таблица для отображения названий характеристик продукта';
COMMENT ON COLUMN public.product_chars.name IS 'Поле, в котором содержатся названия характеристик';

CREATE TABLE public.chars_value
(
    id               SERIAL PRIMARY KEY,
    value            TEXT CHECK ( LENGTH(value) < 255 ) NOT NULL,
    product_chars_id INT                                NOT NULL,
    CONSTRAINT public_value_product_chars_fk_ui UNIQUE (value, product_chars_id)
);
ALTER TABLE public.chars_value
    ADD CONSTRAINT public_chars_value_product_chars_fk FOREIGN KEY (product_chars_id) REFERENCES public.product_chars (id);
CREATE INDEX ON public.chars_value (product_chars_id);

COMMENT ON TABLE public.chars_value IS 'Таблица для отображения соответствия названий характеристик продукта их значениям';
COMMENT ON COLUMN public.chars_value.value IS 'Поле для записи значения характеристики';

-- СВЯЗИ ХАРАКТЕРИСТИК, ПРОДУКТОВ, АРТИКУЛОВ И ТАБЛИЦЫ ДЛЯ ХАРАКТЕРИСТИК КАТЕГОРИЙ (ДЛЯ УДОБСТВА КОНТЕНТ-МЕНЕДЖЕРОВ)

-- Sku/Product 2 chars_value (CROSS TABLE)
CREATE TABLE public.sku2chars_value
(
    id             BIGSERIAL PRIMARY KEY,
    sku_id         INT NOT NULL,
    chars_value_id INT NOT NULL,
    CONSTRAINT public_sku2chars_value_chars_value_sku_ui UNIQUE (sku_id, chars_value_id)
);
ALTER TABLE public.sku2chars_value
    ADD CONSTRAINT public_sku2chars_value_sku_fk FOREIGN KEY (sku_id) REFERENCES public.sku (id);
ALTER TABLE public.sku2chars_value
    ADD CONSTRAINT public_sku2chars_value_chars_value_fk FOREIGN KEY (chars_value_id) REFERENCES public.chars_value (id);
CREATE INDEX ON public.sku2chars_value (sku_id);
CREATE INDEX ON public.sku2chars_value (chars_value_id);

COMMENT ON TABLE public.sku2chars_value IS 'Кросс Таблица для соответствия значения характеристик и артикула - реализация торгового предложения';

CREATE TABLE public.product2chars_value
(
    id             BIGSERIAL PRIMARY KEY,
    product_id     INT NOT NULL,
    chars_value_id INT NOT NULL,
    CONSTRAINT public_product2chars_value_chars_value_sku_ui UNIQUE (product_id, chars_value_id)
);
ALTER TABLE public.product2chars_value
    ADD CONSTRAINT public_product2chars_value_sku_fk FOREIGN KEY (product_id) REFERENCES public.product (id);
ALTER TABLE public.product2chars_value
    ADD CONSTRAINT public_product2chars_value_chars_value_fk FOREIGN KEY (chars_value_id) REFERENCES public.chars_value (id);
CREATE INDEX ON public.product2chars_value (product_id);
CREATE INDEX ON public.product2chars_value (chars_value_id);

COMMENT ON TABLE public.product2chars_value IS 'Кросс Таблица для соответствия значения характеристик и товара';

-- Следующие 2 таблицы исключительно для админки - для удобства заполнения
CREATE TABLE public.sku2product_category
(
    id                  BIGSERIAL PRIMARY KEY,
    sku_id              INT NOT NULL,
    product_category_id INT NOT NULL,
    CONSTRAINT public_sku2product_category_product_category_sku_ui UNIQUE (sku_id, product_category_id)
);
ALTER TABLE public.sku2product_category
    ADD CONSTRAINT public_sku2product_category_sku_fk FOREIGN KEY (sku_id) REFERENCES public.sku (id);
ALTER TABLE public.sku2product_category
    ADD CONSTRAINT public_sku2product_category_product_category_fk FOREIGN KEY (product_category_id) REFERENCES public.product_category (id);
CREATE INDEX ON public.sku2product_category (sku_id);
CREATE INDEX ON public.sku2product_category (product_category_id);

COMMENT ON TABLE public.sku2product_category IS 'Кросс Таблица для соответствия ТП и категорий продукта';

CREATE TABLE public.product_category2chars_value
(
    id                  SERIAL PRIMARY KEY,
    product_category_id INT NOT NULL,
    chars_value_id      INT NOT NULL,
    CONSTRAINT public_product_category2chars_value_chars_value_sku_ui UNIQUE (product_category_id, chars_value_id)
);
ALTER TABLE public.product_category2chars_value
    ADD CONSTRAINT public_product_category2chars_value_sku_fk FOREIGN KEY (product_category_id) REFERENCES public.product_category (id);
ALTER TABLE public.product_category2chars_value
    ADD CONSTRAINT public_product_category2chars_value_chars_value_fk FOREIGN KEY (chars_value_id) REFERENCES public.chars_value (id);
CREATE INDEX ON public.product_category2chars_value (product_category_id);
CREATE INDEX ON public.product_category2chars_value (chars_value_id);

COMMENT ON TABLE public.sku2product_category IS 'Кросс Таблица для соответствия характеристик и категорий продукта';

-- СКИДКИ

CREATE TABLE public.discount_type
(
    id   SMALLSERIAL PRIMARY KEY,
    type TEXT CHECK ( LENGTH(type) < 255 ) NOT NULL
);

COMMENT ON TABLE public.discount_type IS 'Таблица для обозначения типов скидок';
COMMENT ON COLUMN public.discount_type.type IS 'Для примера, процентные скидки и обычные - в числовом значении';

CREATE TABLE public.discount
(
    id               SERIAL PRIMARY KEY,
    name             TEXT CHECK ( LENGTH(name) < 255 )      NOT NULL,
    value            INT                                    NOT NULL,
    discount_type_id SMALLINT                               NOT NULL,
    sku_id           INT,
    product_id       INT,
    discount_start   TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    discount_end     TIMESTAMP WITH TIME ZONE,
    CONSTRAINT public_discount_name_discount_start_ui UNIQUE (name, discount_start)
);
ALTER TABLE public.discount
    ADD CONSTRAINT public_discount_discount_type_fk FOREIGN KEY (discount_type_id) REFERENCES public.discount_type (id);
ALTER TABLE discount
    ADD CONSTRAINT public_discount_sku_fk FOREIGN KEY (sku_id) REFERENCES sku (id);
ALTER TABLE discount
    ADD CONSTRAINT public_discount_product_fk FOREIGN KEY (product_id) REFERENCES product (id);
ALTER TABLE public.discount
    ADD CONSTRAINT public_discount_value_check CHECK ( value >= 0 );
ALTER TABLE public.discount
    ADD CONSTRAINT public_discount_relationship_check CHECK (
        CASE
            WHEN sku_id ISNULL AND product_id ISNULL THEN FALSE
            WHEN sku_id NOTNULL AND product_id NOTNULL THEN FALSE
            ELSE TRUE
            END
        );
CREATE INDEX ON public.discount (discount_type_id);
CREATE INDEX ON public.discount (product_id);
CREATE INDEX ON public.discount (sku_id);

COMMENT ON TABLE public.discount IS 'Таблица скидок';
COMMENT ON COLUMN public.discount.name IS 'Поле для названия скидок';
COMMENT ON COLUMN public.discount.value IS 'Поле для значения скидок';

-- ДОСТАВКА
CREATE TABLE public.delivery
(
    id             SERIAL PRIMARY KEY,
    name           TEXT CHECK ( LENGTH(name) < 255 ) NOT NULL,
    description    TEXT,
    weight_price   MONEY,
    distance_price MONEY,
    is_active      BOOLEAN
);
COMMENT ON TABLE public.delivery IS 'Таблица способов доставки довара';
COMMENT ON COLUMN public.delivery.weight_price IS 'Цена за кг';
COMMENT ON COLUMN public.delivery.distance_price IS 'Цена 1кг / 1 км';

-- СКЛАДЫ

CREATE TABLE public.storehouse
(
    id        SERIAL PRIMARY KEY,
    name      TEXT                                NOT NULL,
    phone     TEXT CHECK ( LENGTH(phone) < 255 )  NOT NULL,
    email     TEXT CHECK ( LENGTH(email) < 1024),
    country   TEXT CHECK ( LENGTH(country) < 255),
    zip       TEXT CHECK ( LENGTH(zip) < 128),
    region    TEXT CHECK ( LENGTH(region) < 128),
    metro     TEXT,
    street    TEXT,
    building  TEXT,
    room      TEXT,
    currency  TEXT CHECK ( LENGTH(currency) = 3 ) NOT NULL,
    is_active BOOLEAN
);
COMMENT ON TABLE public.storehouse IS 'Таблица складов. Контакты';

CREATE TABLE public.storehouse_available
(
    id            BIGSERIAL PRIMARY KEY,
    storehouse_id INT NOT NULL,
    sku_id        INT,
    product_id    INT,
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
CREATE INDEX ON public.storehouse_available (storehouse_id);
CREATE INDEX ON public.storehouse_available (product_id);
CREATE INDEX ON public.storehouse_available (sku_id);

ALTER TABLE public.storehouse_available
    ADD CONSTRAINT public_storehouse_available_relationship_check CHECK (
        CASE
            WHEN sku_id ISNULL AND product_id ISNULL THEN FALSE
            WHEN sku_id NOTNULL AND product_id NOTNULL THEN FALSE
            ELSE TRUE
            END
        );

COMMENT ON TABLE public.storehouse_available IS 'Наличие товара на складе';
COMMENT ON COLUMN public.storehouse_available.available IS 'Товара в наличии';
COMMENT ON COLUMN public.storehouse_available.reserve IS 'Зарезервировано товара';

-- Дополнительные поля

CREATE TABLE public.field_type
(
    id   SMALLSERIAL PRIMARY KEY,
    name TEXT CHECK ( LENGTH(name) < 255 ) NOT NULL
);
COMMENT ON TABLE public.field_type IS 'Таблица типов дополнительных полей';
COMMENT ON COLUMN public.field_type.name IS 'Название типа дополнительного поля';

CREATE TABLE public.field
(
    id            SERIAL PRIMARY KEY,
    name          TEXT CHECK ( LENGTH(name) < 255 ) NOT NULL,
    field_type_id SMALLINT                          NOT NULL,
    product_id    INT                               NOT NULL,
    CONSTRAINT public_field_name_product_ui UNIQUE (product_id, name)
);
ALTER TABLE public.field
    ADD CONSTRAINT public_field_field_type_fk FOREIGN KEY (field_type_id) REFERENCES public.field_type (id);
ALTER TABLE public.field
    ADD CONSTRAINT public_field_product_fk FOREIGN KEY (product_id) REFERENCES public.product (id);
CREATE INDEX ON public.field (field_type_id);
CREATE INDEX ON public.field (product_id);

COMMENT ON TABLE public.field IS 'Дополнительные поля';
COMMENT ON COLUMN public.field.name IS 'Название дополнительных полей';
COMMENT ON COLUMN public.field.field_type_id IS 'Тип дополнительного поля. Декларативный характер, просто чтобы в админке было понятно, какой тип поля';

CREATE TABLE public.field_type_jsonb
(
    id       SERIAL PRIMARY KEY,
    data     jsonb NOT NULL,
    field_id INT   NOT NULL,
    CONSTRAINT public_field_type_jsonb_data_field_ui UNIQUE (data, field_id)
);
ALTER TABLE public.field_type_jsonb
    ADD CONSTRAINT public_field_type_jsonb_field_fk FOREIGN KEY (field_id) REFERENCES public.field (id);
CREATE INDEX ON public.field_type_jsonb (field_id);

CREATE TABLE public.field_type_int
(
    id       SERIAL PRIMARY KEY,
    data     INT NOT NULL,
    field_id INT NOT NULL,
    CONSTRAINT public_field_type_int_data_field_ui UNIQUE (data, field_id)
);
ALTER TABLE public.field_type_int
    ADD CONSTRAINT public_field_type_int_field_fk FOREIGN KEY (field_id) REFERENCES public.field (id);
CREATE INDEX ON public.field_type_int (field_id);

COMMENT ON TABLE public.field_type_jsonb IS 'Таблица типа дополнительного поля: jsonb';
COMMENT ON TABLE public.field_type_int IS 'Таблица типа дополнительного поля: целое число';

-- ПОЛЬЗОВАТЕЛИ

CREATE TABLE public.customer_address
(
    id       SERIAL PRIMARY KEY,
    phone    TEXT CHECK ( LENGTH(phone) < 255 ),
    country  TEXT CHECK ( LENGTH(country) < 255),
    zip      TEXT CHECK ( LENGTH(zip) < 128),
    region   TEXT CHECK ( LENGTH(region) < 128),
    metro    TEXT CHECK ( LENGTH(metro) < 128),
    street   TEXT CHECK ( LENGTH(street) < 255),
    building TEXT,
    room     TEXT
);
COMMENT ON TABLE public.customer_address IS 'Таблица адресов клиентов';
---------------------------
-- LEGAL
CREATE TABLE public.legal_person
(
    id                 SERIAL PRIMARY KEY,
    inn                TEXT NOT NULL,
    kpp                TEXT NOT NULL,
    ogrn               TEXT NOT NULL,
    rs                 TEXT NOT NULL,
    ks                 TEXT NOT NULL,
    bik                TEXT NOT NULL,
    bank               TEXT NOT NULL,
    city               TEXT NOT NULL,
    building           TEXT NOT NULL,
    room               TEXT NOT NULL,
    legal_address_id   INT  NOT NULL,
    defacto_address_id INT  NOT NULL,
    CONSTRAINT public_legal_person_all_ui UNIQUE (inn, kpp, ogrn, rs, ks, bik, bank, city, building, room,
                                                  legal_address_id, defacto_address_id)
-- тут наверное, много тонкостей, поэтому пока так
);
ALTER TABLE public.legal_person
    ADD CONSTRAINT public_legal_address_customer_address_fk FOREIGN KEY (legal_address_id) REFERENCES public.customer_address (id);
ALTER TABLE public.legal_person
    ADD CONSTRAINT public_defacto_address_customer_address_fk FOREIGN KEY (defacto_address_id) REFERENCES public.customer_address (id);
CREATE INDEX ON public.legal_person (legal_address_id);
CREATE INDEX ON public.legal_person (defacto_address_id);

COMMENT ON TABLE public.legal_person IS 'Таблица для счетов юрлиц';

CREATE TYPE customer_type AS ENUM ('физлицо', 'юрлицо');

CREATE TABLE public.customer
(
    id                  SERIAL PRIMARY KEY,
    name                TEXT CHECK ( LENGTH(name) < 128 )    NOT NULL,
    surname             TEXT CHECK ( LENGTH(surname) < 128 ),
    patronymic          TEXT CHECK ( LENGTH(patronymic) < 128),
    login               TEXT CHECK ( LENGTH(login) < 128)    NOT NULL,
    email               TEXT CHECK ( LENGTH(email) < 128)    NOT NULL,
    password            TEXT CHECK ( LENGTH(password) < 128) NOT NULL,
    type                customer_type                        NOT NULL,
    legal_person_id     INT,
    customer_address_id INT                                  NOT NULL,
    CONSTRAINT public_customer_email_ui UNIQUE (email),
    CONSTRAINT public_customer_login_ui UNIQUE (login)
);
ALTER TABLE public.customer
    ADD CONSTRAINT public_customer_customer_address_fk FOREIGN KEY (customer_address_id) REFERENCES public.customer_address (id);
ALTER TABLE public.customer
    ADD CONSTRAINT public_customer_legel_person_fk FOREIGN KEY (legal_person_id) REFERENCES legal_person (id);
CREATE INDEX ON public.customer (customer_address_id);
CREATE INDEX ON public.customer (email);
CREATE INDEX ON public.customer (login);
CREATE INDEX ON public.customer (legal_person_id);

COMMENT ON TABLE public.customer IS 'Таблица клиентов';
COMMENT ON COLUMN public.customer.type IS 'Тип перечисления. Физическое или Юрлицо';

-- Специалисты сайта

CREATE TABLE public.user_address
(
    id       SERIAL PRIMARY KEY,
    phone    TEXT CHECK ( LENGTH(phone) < 255 ),
    country  TEXT CHECK ( LENGTH(country) < 255),
    zip      TEXT CHECK ( LENGTH(zip) < 128),
    region   TEXT CHECK ( LENGTH(region) < 128),
    metro    TEXT CHECK ( LENGTH(metro) < 128),
    street   TEXT CHECK ( LENGTH(street) < 255),
    building TEXT,
    room     TEXT
);
COMMENT ON TABLE public.user_address IS 'Таблица адресов специалистов, работающих с сайтом';

-- user я его назвать не могу - зарезервированное имя
CREATE TABLE public.site_user
(
    id              SERIAL PRIMARY KEY,
    name            TEXT CHECK ( LENGTH(name) < 128 )    NOT NULL,
    surname         TEXT CHECK ( LENGTH(surname) < 128 ),
    patronymic      TEXT CHECK ( LENGTH(patronymic) < 128),
    login           TEXT CHECK ( LENGTH(login) < 128)    NOT NULL,
    email           TEXT CHECK ( LENGTH(email) < 128)    NOT NULL,
    password        TEXT CHECK ( LENGTH(password) < 128) NOT NULL,
    roles           TEXT                                 NOT NULL,
    user_address_id INT                                  NOT NULL,
    CONSTRAINT public_user_email_ui UNIQUE (email),
    CONSTRAINT public_user_login_ui UNIQUE (login)
);
ALTER TABLE public.site_user
    ADD CONSTRAINT public_user_user_address_fk FOREIGN KEY (user_address_id) REFERENCES public.user_address (id);
CREATE INDEX ON public.site_user (user_address_id);
CREATE INDEX ON public.site_user (email);
CREATE INDEX ON public.site_user (login);

COMMENT ON TABLE public.site_user IS 'Таблица специалистов, работающих с сайтом';
COMMENT ON COLUMN public.site_user.roles IS 'Роли пользователей';

-- ЗАКАЗЫ

CREATE TABLE public.order_address
(
    id       SERIAL PRIMARY KEY,
    phone    TEXT CHECK ( LENGTH(phone) < 255 ),
    country  TEXT CHECK ( LENGTH(country) < 255),
    zip      TEXT CHECK ( LENGTH(zip) < 128),
    region   TEXT CHECK ( LENGTH(region) < 128),
    metro    TEXT CHECK ( LENGTH(metro) < 128),
    street   TEXT CHECK ( LENGTH(street) < 255),
    building TEXT,
    room     TEXT
);
COMMENT ON TABLE public.order_address IS 'Таблица адресов заказа';

CREATE TABLE public.payment
(
    id          SERIAL PRIMARY KEY,
    description TEXT,
    currency    TEXT,
    is_active   BOOLEAN,
    options     JSONB,
    fee         DECIMAL(6, 4),
    inn         TEXT,
    comment     TEXT
);
COMMENT ON TABLE public.payment IS 'Таблица доступных платежных систем';
COMMENT ON COLUMN public.payment.options IS 'Дополнительные опции платежных систем';
COMMENT ON COLUMN public.payment.fee IS 'Комиссия';
COMMENT ON COLUMN public.payment.comment IS 'Комментарий к платежной системе';


-- order тоже зарезервированное слово
CREATE TABLE public.shop_order
(
    id                  BIGSERIAL PRIMARY KEY,
    weight              DECIMAL(10, 4),
    distance            INT,
    cart_cost           MONEY CHECK ( cart_cost :: numeric > 0 ) NOT NULL,
    delivery_cost_money MONEY CHECK ( delivery_cost_money :: numeric >= 0 ),
    cost                MONEY CHECK ( cost :: numeric > 0 )      NOT NULL,
    comment             TEXT,
    order_address_id    INT,
    customer_id         INT                                      NOT NULL,
    payment_id          INT                                      NOT NULL,
    delivery_id         INT                                      NOT NULL
);
ALTER TABLE public.shop_order
    ADD CONSTRAINT public_order_order_address_fk FOREIGN KEY (order_address_id) REFERENCES public.order_address (id);
ALTER TABLE public.shop_order
    ADD CONSTRAINT public_order_delivery_fk FOREIGN KEY (delivery_id) REFERENCES public.delivery (id);
ALTER TABLE public.shop_order
    ADD CONSTRAINT public_order_customer_fk FOREIGN KEY (customer_id) REFERENCES public.customer (id);
ALTER TABLE public.shop_order
    ADD CONSTRAINT public_order_payment_fk FOREIGN KEY (payment_id) REFERENCES public.payment (id);
ALTER TABLE public.shop_order
    ADD CONSTRAINT public_order_customer_created_ui UNIQUE (customer_id, created_at);

CREATE INDEX ON public.shop_order (order_address_id);
CREATE INDEX ON public.shop_order (customer_id);
CREATE INDEX ON public.shop_order (delivery_id);
CREATE INDEX ON public.shop_order (payment_id);

COMMENT ON TABLE public.shop_order IS 'Таблица заказов';
COMMENT ON COLUMN public.shop_order.distance IS 'Поле расстояние - для доставки';
COMMENT ON COLUMN public.shop_order.weight IS 'Поле вес - для доставки';
COMMENT ON COLUMN public.shop_order.cart_cost IS 'Цена по корзине';
COMMENT ON COLUMN public.shop_order.delivery_cost_money IS 'Цена доставки';
COMMENT ON COLUMN public.shop_order.cost IS 'Общая цена';
COMMENT ON COLUMN public.shop_order.comment IS 'Комментарий клиента к заказу';

CREATE TABLE public.order_status
(
    id   SMALLSERIAL PRIMARY KEY,
    name TEXT CHECK ( LENGTH(name) < 255 ) NOT NULL
);
COMMENT ON TABLE public.order_status IS 'Таблица статусов заказов';
COMMENT ON COLUMN public.order_status.name IS 'Поле статусов заказа, к примеру, новый, согласован, оплачен, возврат и так далее';

CREATE TABLE public.order_processing
(
    id            BIGSERIAL PRIMARY KEY,
    site_user_id  INT,
    shop_order_id INT                                         NOT NULL,
    status_id     INT                                         NOT NULL,
    cash_voucher  MONEY CHECK ( cash_voucher :: numeric > 0 ) NOT NULL,
    comment       TEXT
);
ALTER TABLE public.order_processing
    ADD CONSTRAINT public_order_processing_order_ui UNIQUE (shop_order_id);
ALTER TABLE public.order_processing
    ADD CONSTRAINT public_order_processing_user_fk FOREIGN KEY (site_user_id) REFERENCES public.site_user (id);
ALTER TABLE public.order_processing
    ADD CONSTRAINT public_order_processing_order_fk FOREIGN KEY (shop_order_id) REFERENCES public.shop_order (id);
ALTER TABLE public.order_processing
    ADD CONSTRAINT public_order_processing_status_fk FOREIGN KEY (status_id) REFERENCES public.order_status (id);
CREATE INDEX ON public.order_processing (site_user_id);
CREATE INDEX ON public.order_processing (shop_order_id);
CREATE INDEX ON public.order_processing (status_id);

COMMENT ON TABLE public.order_processing IS 'Таблица сопровождения заказа';
COMMENT ON COLUMN public.order_processing.site_user_id IS 'Менеджер сопровождающий заказ';
COMMENT ON COLUMN public.order_processing.cash_voucher IS 'Чек';
COMMENT ON COLUMN public.order_processing.comment IS 'Комментарий менеджера';


CREATE TABLE public.product_sku2order
(
    id            BIGSERIAL PRIMARY KEY,
    sku_id        INT,
    product_id    INT,
    shop_order_id INT NOT NULL,
    quantity      INT NOT NULL,
    CONSTRAINT public_sku2order_sku_order_ui UNIQUE (shop_order_id, sku_id, product_id)
);
ALTER TABLE public.product_sku2order
    ADD CONSTRAINT public_product_sku2order_sku_fk FOREIGN KEY (sku_id) REFERENCES public.sku (id);
ALTER TABLE public.product_sku2order
    ADD CONSTRAINT public_product_sku2order_product_fk FOREIGN KEY (product_id) REFERENCES public.product (id);
ALTER TABLE public.product_sku2order
    ADD CONSTRAINT public_product_sku2order_order_fk FOREIGN KEY (shop_order_id) REFERENCES public.shop_order (id);

CREATE INDEX ON public.product_sku2order (sku_id);
CREATE INDEX ON public.product_sku2order (product_id);
CREATE INDEX ON public.product_sku2order (shop_order_id);
ALTER TABLE public.product_sku2order
    ADD CONSTRAINT public_product_sku2order_relationship_check CHECK (
        CASE
            WHEN sku_id ISNULL AND product_id ISNULL THEN FALSE
            WHEN sku_id NOTNULL AND product_id NOTNULL THEN FALSE
            ELSE TRUE
            END
        );
COMMENT ON TABLE public.product_sku2order IS 'Кросс таблица заказ-артикул-товар и количество на каждый артикул-товар';
COMMENT ON COLUMN public.product_sku2order.quantity IS 'Поле количество на каждый артикул-товар';