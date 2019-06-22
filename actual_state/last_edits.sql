ALTER TABLE public.product_category
    DROP CONSTRAINT public_product_category_product_category_fk;
ALTER TABLE public.product_category
    ALTER COLUMN parent_id SET DEFAULT 0;
ALTER TABLE public.product_category
    ALTER COLUMN parent_id SET NOT NULL;

ALTER TABLE article_category
    DROP CONSTRAINT public_article_category_article_category_fk;
ALTER TABLE public.article_category
    ALTER COLUMN parent_id SET DEFAULT 0;
ALTER TABLE public.article_category
    ALTER COLUMN parent_id SET NOT NULL;

DROP TABLE discount_type CASCADE;
DROP TABLE discount CASCADE;

ALTER TABLE storehouse
    ADD COLUMN legal_person_id BIGINT NOT NULL;
ALTER TABLE storehouse
    ADD CONSTRAINT public_storehouse_legal_person_fk FOREIGN KEY (legal_person_id) REFERENCES legal_person (id);

ALTER TABLE shop_order
    DROP CONSTRAINT public_order_payment_fk;
ALTER TABLE public.shop_order
    DROP COLUMN payment_id;

ALTER TABLE order_processing
    ADD COLUMN transaction_id BIGINT;
ALTER TABLE order_processing
    ADD CONSTRAINT public_order_processing_transaction_fk FOREIGN KEY (transaction_id) REFERENCES public.transaction (id);

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





--