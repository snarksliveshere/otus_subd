CREATE OR REPLACE FUNCTION public.upd_updated_at() RETURNS TRIGGER
    LANGUAGE plpgsql
AS
$$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;
-- CATEGORY
CREATE TABLE public.product_category
(
    id          SERIAL PRIMARY KEY,
    title       TEXT CHECK ( LENGTH(title) < 255 )        NOT NULL,
    longtitle   TEXT CHECK ( LENGTH(longtitle) < 255 ),
    image_intro TEXT CHECK ( LENGTH(image_intro) < 1024),
    image       TEXT CHECK ( LENGTH(image) < 1024),
    slug        TEXT CHECK ( LENGTH(slug) < 255),
    intro       TEXT CHECK ( LENGTH(intro) < 1024),
    description TEXT,
    content     TEXT,
    is_deleted  BOOLEAN,
    is_publish  BOOLEAN,
    parent_id   INT,
    created_at  TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at  TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL,
    CONSTRAINT public_product_category_product_category_fk FOREIGN KEY (parent_id) REFERENCES public.product_category (id)
);
ALTER TABLE public.product_category
    ADD CONSTRAINT public_product_title_parent_id_ui UNIQUE (title, parent_id);
CREATE INDEX ON public.product_category (parent_id);
CREATE INDEX ON public.product_category (title);

CREATE INDEX public_product_category_partial_active_list ON public.product_category (id, title, image_intro, intro, slug, parent_id)
    WHERE is_deleted = FALSE AND is_publish = TRUE

CREATE INDEX public_product_category_partial_active_item ON public.product_category (id, title, longtitle, image, description, content, slug, parent_id)
    WHERE is_deleted = FALSE AND is_publish = TRUE

CREATE TRIGGER t_public_product_category
    BEFORE UPDATE
    ON public.product_category
    FOR EACH ROW
EXECUTE PROCEDURE public.upd_updated_at();
-----------------------
-- PRODUCT STATUS
CREATE TABLE public.product_status
(
    id     SMALLSERIAL PRIMARY KEY,
    status TEXT CHECK ( LENGTH(status) < 255 ) NOT NULL
);
-----------------------------------
-- VENDOR
CREATE TABLE public.vendor
(
    id      SMALLSERIAL PRIMARY KEY,
    name    TEXT CHECK ( LENGTH(name) < 255 ) NOT NULL,
    country TEXT CHECK ( LENGTH(country) < 128 ),
    page    TEXT CHECK ( LENGTH(page) < 255),
    email   TEXT CHECK ( LENGTH(email) < 255),
    phone   TEXT CHECK ( LENGTH(phone) < 128),
    logo    TEXT CHECK ( LENGTH(logo) < 1024)
);
-------------------------------
-- PRODUCT
CREATE TABLE public.product
(
    id                  SERIAL PRIMARY KEY,
    title               TEXT CHECK ( LENGTH(title) < 255 )        NOT NULL,
    longtitle           TEXT CHECK ( LENGTH(title) < 255 ),
    image_intro         TEXT CHECK ( LENGTH(title) < 1024),
    image               TEXT CHECK ( LENGTH(title) < 1024),
    slug                TEXT CHECK ( LENGTH(title) < 255),
    intro               TEXT CHECK ( LENGTH(title) < 1024),
    description         TEXT,
    content             TEXT,
    is_deleted          BOOLEAN,
    is_publish          BOOLEAN,
    special             BOOLEAN,
    novelty             BOOLEAN,
    popular             BOOLEAN,
    product_category_id INT,
    product_status_id   INT,
    vendor_id           INT,
    created_at          TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at          TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL,
    CONSTRAINT public_product_product_category FOREIGN KEY (product_category_id) REFERENCES public.product_category (id)
);
ALTER TABLE public.product ADD CONSTRAINT public_product_product_status_fk FOREIGN KEY (product_status_id) REFERENCES public.product_status (id);
ALTER TABLE public.product ADD CONSTRAINT public_product_vendor_fk FOREIGN KEY (vendor_id) REFERENCES public.vendor (id);

ALTER TABLE public.product
    ADD CONSTRAINT public_product_title_product_category_ui UNIQUE (title, product_category_id);

CREATE INDEX ON public.product (product_category_id);
CREATE INDEX ON public.product (title);
CREATE INDEX ON public.product (vendor_id);
CREATE INDEX ON public.product (product_status_id);

CREATE TRIGGER t_public_product
    BEFORE UPDATE
    ON public.product
    FOR EACH ROW
EXECUTE PROCEDURE public.upd_updated_at();

-----------------------------------------
-- SKU
CREATE TABLE public.sku
(
    id                SERIAL PRIMARY KEY,
    sku               TEXT                                      NOT NULL,
    price             MONEY,
    old_price         MONEY,
    image             TEXT,
    description       TEXT,
    content           TEXT,
    is_deleted        BOOLEAN,
    is_publish        BOOLEAN,
    product_id        INT                                       NOT NULL,
    product_status_id INT,
    created_at        TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at        TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL,
    CONSTRAINT public_sku_product_fk FOREIGN KEY (product_id) REFERENCES public.product (id),
    CONSTRAINT public_sku_product_sku_ui UNIQUE (sku),
    CONSTRAINT public_sku_price_check CHECK (
        CASE WHEN price NOTNULL AND price >= 0 :: money THEN TRUE ELSE FALSE END),
    CONSTRAINT public_sku_old_price_check CHECK (
        CASE WHEN old_price NOTNULL AND old_price >= 0 :: money THEN TRUE ELSE FALSE END)
);

CREATE INDEX ON public.sku (sku);
CREATE TRIGGER t_public_sku
    BEFORE UPDATE
    ON public.sku
    FOR EACH ROW
EXECUTE PROCEDURE public.upd_updated_at();

--------------------------
-- PRODUCT CHARS (product_characteristics)
CREATE TABLE public.product_chars
(
    id   SERIAL PRIMARY KEY,
    name TEXT NOT NULL
);
-----------------------------
-- CHARS VALUE
CREATE TABLE public.chars_value
(
    id               SERIAL PRIMARY KEY,
    value            TEXT CHECK ( LENGTH(value) < 255 ) NOT NULL,
    product_chars_id INT                                NOT NULL,
    CONSTRAINT public_chars_value_product_chars_fk FOREIGN KEY (product_chars_id) REFERENCES public.product_chars (id),
    CONSTRAINT public_value_product_chars_fk_ui UNIQUE (value, product_chars_id)
);
CREATE INDEX ON public.chars_value (product_chars_id);
CREATE INDEX ON public.chars_value (value);
----------------------------------
-- Sku 2 chars_value (CROSS TABLE)
CREATE TABLE public.sku2chars_value
(
    id             BIGSERIAL PRIMARY KEY,
    sku_id         INT NOT NULL,
    chars_value_id INT NOT NULL,
    CONSTRAINT public_sku2chars_value_sku_fk FOREIGN KEY (sku_id) REFERENCES public.sku (id),
    CONSTRAINT public_sku2chars_value_chars_value_fk FOREIGN KEY (chars_value_id) REFERENCES public.chars_value (id),
    CONSTRAINT public_sku2chars_value_chars_value_sku_ui UNIQUE (sku_id, chars_value_id)
);
CREATE INDEX ON public.sku2chars_value (sku_id);
CREATE INDEX ON public.sku2chars_value (chars_value_id);
----------------------------------------
-- DISCOUNT TYPE
CREATE TABLE public.discount_type
(
    id   SERIAL PRIMARY KEY,
    type TEXT NOT NULL
);
------------------------
-- DISCOUNT
CREATE TABLE public.discount
(
    id               SERIAL PRIMARY KEY,
    name             TEXT CHECK ( LENGTH(name) < 255 )         NOT NULL,
    value            INT                                       NOT NULL,
    discount_type_id INT                                       NOT NULL,
    discount_start   TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL,
    discount_end     TIMESTAMP WITHOUT TIME ZONE,
    CONSTRAINT public_discount_discount_type_fk FOREIGN KEY (discount_type_id) REFERENCES public.discount_type (id),
    CONSTRAINT public_discount_name_discount_start_ui UNIQUE (name, discount_start)
);
ALTER TABLE public.discount
    ADD CONSTRAINT public_discount_value_check CHECK ( value >= 0 );
CREATE INDEX ON public.discount (discount_type_id);
CREATE INDEX public_discount_discount_start_to_date ON public.discount ((CAST(discount_start AS DATE)));
CREATE INDEX public_discount_discount_end_to_date ON public.discount ((discount_end :: DATE));
----
-- ARTICLE CATEGORY
CREATE TABLE public.article_category
(
    id          SERIAL PRIMARY KEY,
    title       TEXT CHECK ( LENGTH(title) < 255 )        NOT NULL,
    longtitle   TEXT CHECK ( LENGTH(longtitle) < 255 ),
    image_intro TEXT CHECK ( LENGTH(image_intro) < 1024),
    image       TEXT CHECK ( LENGTH(image) < 1024),
    slug        TEXT CHECK ( LENGTH(slug) < 255),
    intro       TEXT CHECK ( LENGTH(intro) < 1024),
    description TEXT,
    content     TEXT,
    is_deleted  BOOLEAN,
    is_publish  BOOLEAN,
    parent_id   INT,
    created_at  TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at  TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL,
--     CONSTRAINT public_article_category_article_category_fk FOREIGN KEY (parent_id) REFERENCES public.article_category (parent_id),
    CONSTRAINT public_article_category_title_parent_id_ui UNIQUE (title, parent_id)
);
ALTER TABLE public.article_category
    ADD CONSTRAINT public_article_category_article_category_fk FOREIGN KEY (parent_id) REFERENCES public.article_category (parent_id);
CREATE INDEX ON public.article_category (parent_id);
CREATE INDEX ON public.article_category (title);
CREATE TRIGGER t_public_article_category
    BEFORE UPDATE
    ON public.article_category
    FOR EACH ROW
EXECUTE PROCEDURE public.upd_updated_at();

----------------------
-- ARTICLE
CREATE TABLE public.article
(
    id                  SERIAL PRIMARY KEY,
    title               TEXT CHECK ( LENGTH(title) < 255 )        NOT NULL,
    longtitle           TEXT CHECK ( LENGTH(longtitle) < 255 ),
    image_intro         TEXT CHECK ( LENGTH(image_intro) < 1024),
    image               TEXT CHECK ( LENGTH(image) < 1024),
    slug                TEXT CHECK ( LENGTH(slug) < 255),
    intro               TEXT CHECK ( LENGTH(intro) < 1024),
    description         TEXT,
    content             TEXT,
    is_deleted          BOOLEAN,
    is_publish          BOOLEAN,
    article_category_id INT,
    created_at          TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at          TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL,
    CONSTRAINT public_article_article_category_fk FOREIGN KEY (article_category_id) REFERENCES public.article_category (id),
    CONSTRAINT public_article_title_article_category_id_ui UNIQUE (title, article_category_id)
);
CREATE INDEX ON public.article (article_category_id);
CREATE INDEX ON public.article (title);
CREATE TRIGGER t_public_article
    BEFORE UPDATE
    ON public.article
    FOR EACH ROW
EXECUTE PROCEDURE public.upd_updated_at();
---------------------------------------
-- DELIVERY
CREATE TABLE public.delivery
(
    id             SERIAL PRIMARY KEY,
    name           TEXT CHECK ( LENGTH(name) < 255 ) NOT NULL,
    description    TEXT,
    weight_price   MONEY,
    distance_price MONEY,
    is_active      BOOLEAN
);
------------------------------
-- STOREHOUSE
CREATE TABLE public.storehouse
(
    id        SERIAL PRIMARY KEY,
    name      TEXT                                NOT NULL,
    phone     TEXT CHECK ( LENGTH(phone) < 255 ),
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
------------------------------
-- STOREHOUSE AVAILABLE
CREATE TABLE public.storehouse_available
(
    id            SERIAL PRIMARY KEY,
    storehouse_id INT NOT NULL,
    sku_id        INT NOT NULL,
    available     INT,
    reserve       INT,
    CONSTRAINT public_storeshouse_available_reserve_less_available CHECK ( reserve <= available )
);
ALTER TABLE public.storehouse_available ADD CONSTRAINT storehouse_available_storehouse_fk FOREIGN KEY (storehouse_id) REFERENCES public.storehouse (id);
CREATE INDEX ON public.storehouse_available (storehouse_id);
---------------------------------
-- USERS --
--CUSTOMER
CREATE TABLE public.customer
(
    id                  SERIAL PRIMARY KEY,
    name                TEXT CHECK ( LENGTH(name) < 128 )         NOT NULL,
    surname             TEXT CHECK ( LENGTH(surname) < 128 ),
    patronymic          TEXT CHECK ( LENGTH(patronymic) < 128),
    login               TEXT CHECK ( LENGTH(login) < 128)         NOT NULL,
    email               TEXT CHECK ( LENGTH(email) < 128)         NOT NULL,
    password            TEXT CHECK ( LENGTH(password) < 128)      NOT NULL,
    type                SMALLINT                                  NOT NULL,
    customer_address_id INT                                       NOT NULL,
    created_at          TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at          TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL,
    CONSTRAINT public_customer_customer_address_fk FOREIGN KEY (customer_address_id) REFERENCES public.customer_address (id),
    CONSTRAINT public_customer_email_ui UNIQUE (email),
    CONSTRAINT public_customer_login_ui UNIQUE (login)
);
CREATE INDEX ON public.customer (customer_address_id);
CREATE INDEX ON public.customer (email);
CREATE INDEX ON public.customer (login);
CREATE TRIGGER t_public_customer
    BEFORE UPDATE
    ON public.customer
    FOR EACH ROW
EXECUTE PROCEDURE public.upd_updated_at();
ALTER TABLE public.customer
    ADD COLUMN legal_person_id INT;
ALTER TABLE public.customer
    ADD CONSTRAINT public_customer_legel_person_fk FOREIGN KEY (legal_person_id) REFERENCES legal_person (id);
CREATE INDEX ON public.customer (legal_person_id);

----------------------
-- CUSTOMER ADDRESS
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
---------------------------
-- LEGAL
CREATE TABLE public.legal_person
(
    id                 SERIAL PRIMARY KEY,
    inn                TEXT                                      NOT NULL,
    kpp                TEXT                                      NOT NULL,
    ogrn               TEXT                                      NOT NULL,
    rs                 TEXT                                      NOT NULL,
    ks                 TEXT                                      NOT NULL,
    bik                TEXT                                      NOT NULL,
    bank               TEXT                                      NOT NULL,
    city               TEXT                                      NOT NULL,
    building           TEXT                                      NOT NULL,
    room               TEXT                                      NOT NULL,
    legal_address_id   INT                                       NOT NULL,
    defacto_address_id INT                                       NOT NULL,
    created_at         TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at         TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL,
    CONSTRAINT public_legal_address_customer_address_fk FOREIGN KEY (legal_address_id) REFERENCES public.customer_address (id),
    CONSTRAINT public_defacto_address_customer_address_fk FOREIGN KEY (defacto_address_id) REFERENCES public.customer_address (id),
    CONSTRAINT public_legal_person_all_ui UNIQUE (inn, kpp, ogrn, rs, ks, bik, bank, city, building, room,
                                                  legal_address_id, defacto_address_id)
-- тут наверное, много тонкостей, поэтому пока так
);

CREATE INDEX ON public.legal_person (legal_address_id);
CREATE INDEX ON public.legal_person (defacto_address_id);
CREATE TRIGGER t_public_legal_person
    BEFORE UPDATE
    ON public.legal_person
    FOR EACH ROW
EXECUTE PROCEDURE public.upd_updated_at();
-------------------------------------
-- USER ADDRESS
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
-----------------------
-- USER
CREATE TABLE public.user
(
    id              SERIAL PRIMARY KEY,
    name            TEXT CHECK ( LENGTH(name) < 128 )         NOT NULL,
    surname         TEXT CHECK ( LENGTH(surname) < 128 ),
    patronymic      TEXT CHECK ( LENGTH(patronymic) < 128),
    login           TEXT CHECK ( LENGTH(login) < 128)         NOT NULL,
    email           TEXT CHECK ( LENGTH(email) < 128)         NOT NULL,
    password        TEXT CHECK ( LENGTH(password) < 128)      NOT NULL,
    roles           TEXT                                      NOT NULL,
    user_address_id INT                                       NOT NULL,
    created_at      TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at      TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL,
    CONSTRAINT public_user_user_address_fk FOREIGN KEY (user_address_id) REFERENCES public.user_address (id),
    CONSTRAINT public_user_email_ui UNIQUE (email),
    CONSTRAINT public_user_login_ui UNIQUE (login)
);
CREATE INDEX ON public.user (user_address_id);
CREATE INDEX ON public.user (email);
CREATE INDEX ON public.user (login);
CREATE TRIGGER t_public_user
    BEFORE UPDATE
    ON public.user
    FOR EACH ROW
EXECUTE PROCEDURE public.upd_updated_at();

----------------------------------
-- ADDITIONAL FIELDS --
-- FIELDS
CREATE TABLE public.field
(
    id            SERIAL PRIMARY KEY,
    name          TEXT CHECK ( LENGTH(name) < 255 ) NOT NULL,
    field_type_id INT                               NOT NULL,
    product_id    INT                               NOT NULL,
    CONSTRAINT public_field_field_type_fk FOREIGN KEY (field_type_id) REFERENCES public.field_type (id),
    CONSTRAINT public_field_product_fk FOREIGN KEY (product_id) REFERENCES public.product (id),
    CONSTRAINT public_field_name_product_ui UNIQUE (product_id, name)
);
CREATE INDEX ON public.field (field_type_id);
CREATE INDEX ON public.field (product_id);

------------------
-- FIELD TYPE
CREATE TABLE public.field_type
(
    id   SERIAL PRIMARY KEY,
    name TEXT CHECK ( LENGTH(name) < 255 ) NOT NULL
);
-------------------
-- TYPES
CREATE TABLE public.field_type_jsonb
(
    id       SERIAL PRIMARY KEY,
    data     jsonb NOT NULL,
    field_id INT   NOT NULL,
    CONSTRAINT public_field_type_jsonb_field_fk FOREIGN KEY (field_id) REFERENCES public.field (id),
    CONSTRAINT public_field_type_jsonb_data_field_ui UNIQUE (data, field_id)
);
CREATE INDEX ON public.field_type_jsonb (field_id);
----------
CREATE TABLE public.field_type_int
(
    id       SERIAL PRIMARY KEY,
    data     INT NOT NULL,
    field_id INT NOT NULL,
    CONSTRAINT public_field_type_int_field_fk FOREIGN KEY (field_id) REFERENCES public.field (id),
    CONSTRAINT public_field_type_int_data_field_ui UNIQUE (data, field_id)
);
CREATE INDEX ON public.field_type_int (field_id);
-----------------------------------
-- ORDERS --
-- ORDER ADDRESS
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
-----------------------------
-- ORDER
CREATE TABLE public.order
(
    id                  BIGSERIAL PRIMARY KEY,
    weight              DECIMAL(10, 4),
    distance            INT,
    cart_cost           MONEY CHECK ( cart_cost :: numeric > 0 )  NOT NULL,
    delivery_cost_money MONEY CHECK ( delivery_cost_money :: numeric >= 0 ),
    cost                MONEY CHECK ( cost :: numeric > 0 )       NOT NULL,
    comment             TEXT,
    order_address_id    INT,
    customer_id         INT                                       NOT NULL,
    payment_id          INT                                       NOT NULL,
    delivery_id         INT                                       NOT NULL,
    created_at          TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at          TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL,
    CONSTRAINT public_order_order_address_fk FOREIGN KEY (order_address_id) REFERENCES public.order_address (id),
    CONSTRAINT public_order_delivery_fk FOREIGN KEY (delivery_id) REFERENCES public.delivery (id),
    CONSTRAINT public_order_customer_fk FOREIGN KEY (customer_id) REFERENCES public.customer (id),
    CONSTRAINT public_order_payment_fk FOREIGN KEY (payment_id) REFERENCES public.payment (id)

);
CREATE INDEX ON public.order (order_address_id);
CREATE INDEX ON public.order (customer_id);
CREATE INDEX ON public.order (delivery_id);
CREATE INDEX ON public.order (payment_id);
CREATE TRIGGER t_public_order
    BEFORE UPDATE
    ON public.order
    FOR EACH ROW
EXECUTE PROCEDURE public.upd_updated_at();
------------------------------------------------
--  CROSS SKU 2 ORDER
CREATE TABLE public.sku2order
(
    id       BIGSERIAL PRIMARY KEY,
    sku_id   INT NOT NULL,
    order_id INT NOT NULL,
    quantity INT NOT NULL,
    CONSTRAINT public_sku2order_sku_fk FOREIGN KEY (sku_id) REFERENCES public.sku (id),
    CONSTRAINT public_sku2order_order_fk FOREIGN KEY (order_id) REFERENCES public.order (id),
    CONSTRAINT public_sku2order_sku_order_ui UNIQUE (order_id, sku_id)
);
CREATE INDEX ON public.sku2order (sku_id);
CREATE INDEX ON public.sku2order (order_id);
-------------------------------
-- ORDER STATUS
CREATE TABLE public.order_status
(
    id   BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL
);
-------------------
-- PAYMENT
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
-----------------
-- ORDER PROCESSING
CREATE TABLE public.order_processing
(
    id           BIGSERIAL PRIMARY KEY,
    user_id      INT,
    order_id     INT                                         NOT NULL,
    status_id    INT                                         NOT NULL,
    cash_voucher MONEY CHECK ( cash_voucher :: numeric > 0 ) NOT NULL,
    comment      TEXT,
    created_at   TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW()   NOT NULL,
    updated_at   TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW()   NOT NULL,
    CONSTRAINT public_order_processing_user_fk FOREIGN KEY (user_id) REFERENCES public.user (id),
    CONSTRAINT public_order_processing_order_fk FOREIGN KEY (order_id) REFERENCES public.order (id),
    CONSTRAINT public_order_processing_status_fk FOREIGN KEY (status_id) REFERENCES public.order_status (id)
);
CREATE TRIGGER t_public_order_processing
    BEFORE UPDATE
    ON public.order_processing
    FOR EACH ROW
EXECUTE PROCEDURE public.upd_updated_at();
CREATE INDEX ON public.order_processing (user_id);
CREATE INDEX ON public.order_processing (order_id);
CREATE INDEX ON public.order_processing (status_id);
----------------------

