-- CATEGORY
CREATE TABLE public.product_category
(
    id          SERIAL PRIMARY KEY,
    title       TEXT CHECK ( LENGTH(title) < 255 )     NOT NULL,
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
    title               TEXT CHECK ( LENGTH(title) < 255 )     NOT NULL,
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
    sku               TEXT                                   NOT NULL,
    price             MONEY,
    old_price         MONEY,
    image             TEXT,
    description       TEXT,
    content           TEXT,
    is_deleted        BOOLEAN,
    is_publish        BOOLEAN,
    product_id        INT                                    NOT NULL,
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
    value            TEXT NOT NULL,
    product_chars_id INT  NOT NULL,
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
    name             TEXT                                   NOT NULL,
    value            INT                                    NOT NULL,
    discount_type_id INT                                    NOT NULL,
    discount_start   TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL,
    discount_end     TIMESTAMP WITHOUT TIME ZONE,
    CONSTRAINT public_discount_discount_type_fk FOREIGN KEY (discount_type_id) REFERENCES public.discount_type (id),
    CONSTRAINT public_discount_name_discount_start_ui UNIQUE (name, discount_start)
);
ALTER TABLE public.discount ADD CONSTRAINT public_discount_value_check CHECK ( value >= 0 );
CREATE INDEX ON public.discount (discount_type_id);
CREATE INDEX public_discount_discount_start_to_date ON public.discount ((CAST(discount_start AS DATE)));
CREATE INDEX public_discount_discount_end_to_date ON public.discount ((discount_end :: DATE));
----
