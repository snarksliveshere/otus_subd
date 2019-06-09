----- DZ lesson_2
-- set foreign key on status to smallint
ALTER TABLE discount ALTER COLUMN discount_type_id TYPE SMALLINT USING discount_type_id::SMALLINT;
ALTER TABLE product ALTER COLUMN product_status_id TYPE SMALLINT USING product_status_id::SMALLINT;
ALTER TABLE "order" ALTER COLUMN delivery_id TYPE SMALLINT USING delivery_id::SMALLINT;
ALTER TABLE "order" ALTER COLUMN payment_id TYPE SMALLINT USING payment_id::SMALLINT;
ALTER TABLE field ALTER COLUMN field_type_id TYPE SMALLINT USING field_type_id::SMALLINT;
ALTER TABLE order_processing ALTER COLUMN status_id TYPE SMALLINT USING status_id::SMALLINT;


-- article
COMMENT ON TABLE article IS 'Таблица для статей'
COMMENT ON TABLE product_category IS 'Таблица категорий продуктов'

alter table article alter column slug set not null;
-- не, тут все очевидно, просто сплошной копипаст, поставлю на неочевидные поля и буду писать на русском
-- COMMENT ON COLUMN public.article.title IS 'This is a article title';
-- COMMENT ON COLUMN public.article.longtitle IS 'This is a article longtitle';
-- COMMENT ON COLUMN public.article.image_intro IS 'This is a article image intro path';
-- COMMENT ON COLUMN public.article.image IS 'This is a article full imagepath';
-- COMMENT ON COLUMN public.article.slug IS 'This is a article slug';
COMMENT ON COLUMN public.article.title IS NULL
COMMENT ON COLUMN public.article.longtitle IS NULL
COMMENT ON COLUMN public.article.image_intro IS NULL
COMMENT ON COLUMN public.article.image IS NULL
COMMENT ON COLUMN public.article.slug IS NULL

-- product_category
alter table product_category alter column slug set not null;

-- product_status
-- какая-то мешанина получается, статусы у меня будут на русском
-- пока буду все делать на русском
-- пока не буду делать его интернациональным
COMMENT ON TABLE public.product_status IS 'Таблица для отображения статусов продукта'
COMMENT ON TABLE public.product_status IS NULL

COMMENT ON COLUMN public.product_status.status IS 'На данный момент, Может быть вида: в наличии, ожидается, отсутствует';

ALTER TABLE public.product_status ADD COLUMN created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL;
ALTER TABLE public.product_status ADD COLUMN updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL;

CREATE TRIGGER t_public_product_status
    BEFORE UPDATE
    ON public.product_status
    FOR EACH ROW
EXECUTE PROCEDURE public.upd_updated_at();


-- Производитель
COMMENT ON TABLE public.vendor IS 'Таблица для отображения производителей товаров'
ALTER TABLE public.vendor ADD COLUMN created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL;
ALTER TABLE public.vendor ADD COLUMN updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL;
-- поля у этой таблицы самодокументирующиеся
CREATE TRIGGER t_public_vendor
    BEFORE UPDATE
    ON public.vendor
    FOR EACH ROW
EXECUTE PROCEDURE public.upd_updated_at();

-- Продукт
COMMENT ON TABLE public.product IS 'Таблица для отображения товаров'
COMMENT ON COLUMN public.product.popular IS 'Флаг популярный. Может использоваться для Хит продаж';
COMMENT ON COLUMN public.product.novelty IS 'Флаг новинка. Может использоваться для новинка';
COMMENT ON COLUMN public.product.special IS 'Флаг особый, специальный. Кастомное использование';
alter table product alter column slug set not null;

--  Артикул
COMMENT ON TABLE public.sku IS 'Таблица для отображения артикулов товара (товаров с Торговыми предложениями)'
ALTER TABLE public.sku ADD COLUMN name TEXT CHECK ( LENGTH(name) < 255 )
COMMENT ON COLUMN public.sku.name IS 'Название для ТП, nullable';
COMMENT ON COLUMN public.sku.old_price IS 'Поле Старая(прошлая цена). Очень часто используется в маркетинговых целях, часто поставляется по умолчанию';

-- Характеристики
COMMENT ON TABLE public.product_chars IS 'Таблица для отображения названий характеристик продукта'
COMMENT ON COLUMN public.product_chars.name IS 'Поле, в котором содержатся названия характеристик';
ALTER TABLE public.product_chars ADD CONSTRAINT public_product_chars_name_check_length CHECK ( LENGTH(public.product_chars.name) < 255 )

ALTER TABLE public.product_chars ADD COLUMN created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL;
ALTER TABLE public.product_chars ADD COLUMN updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL;
CREATE TRIGGER t_public_product_chars
    BEFORE UPDATE
    ON public.product_chars
    FOR EACH ROW
EXECUTE PROCEDURE public.upd_updated_at();
-----------------------------
-- Соответствие название характеристик их значениям
COMMENT ON TABLE public.chars_value IS 'Таблица для отображения соответствия названий характеристик продукта их значениям'
COMMENT ON COLUMN public.chars_value.value IS 'Поле для записи значения характеристики';
COMMENT ON COLUMN public.chars_value.product_chars_id IS 'Внешний ключ на название характеристики';
CREATE TABLE public.chars_value
(
    id               SERIAL PRIMARY KEY,
    value            TEXT CHECK ( LENGTH(value) < 255 ) NOT NULL,
    product_chars_id INT                                NOT NULL,
    CONSTRAINT public_chars_value_product_chars_fk FOREIGN KEY (product_chars_id) REFERENCES public.product_chars (id),
    CONSTRAINT public_value_product_chars_fk_ui UNIQUE (value, product_chars_id)
);
ALTER TABLE public.chars_value ADD COLUMN created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL;
ALTER TABLE public.chars_value ADD COLUMN updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL;

CREATE TRIGGER t_public_chars_value
    BEFORE UPDATE
    ON public.chars_value
    FOR EACH ROW
EXECUTE PROCEDURE public.upd_updated_at();


-- Соответствие артикула характеристикам
COMMENT ON TABLE public.sku2chars_value IS 'Кросс Таблица для соответствия значения характеристик и артикула - реализация торгового предложения'
-- описывать 2 внешних ключа вроде не особо нужно, т.к. они в достаточной степени самоочевидны
ALTER TABLE public.sku2chars_value ADD COLUMN created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL;
ALTER TABLE public.sku2chars_value ADD COLUMN updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL;

CREATE TRIGGER t_public_sku2chars_value
    BEFORE UPDATE
    ON public.sku2chars_value
    FOR EACH ROW
EXECUTE PROCEDURE public.upd_updated_at();

----------------------------------------
-- DISCOUNT TYPE
COMMENT ON TABLE public.discount_type IS 'Таблица для обозначения типов скидок'
COMMENT ON COLUMN public.discount_type.type IS 'Для примера, процентные скидки и обычные - в числовом значении';
ALTER TABLE public.discount_type ADD COLUMN created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL;
ALTER TABLE public.discount_type ADD COLUMN updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL;
CREATE TRIGGER t_public_discount_type
    BEFORE UPDATE
    ON public.discount_type
    FOR EACH ROW
EXECUTE PROCEDURE public.upd_updated_at();
ALTER TABLE public.discount_type ADD CONSTRAINT public_discount_type_type_check_length CHECK ( LENGTH(public.discount_type.type) < 128 )

--
COMMENT ON TABLE public.discount IS 'Таблица скидок'
COMMENT ON COLUMN public.discount.name IS 'Поле для названия скидок';
COMMENT ON COLUMN public.discount.value IS 'Поле для значения скидок';
-- забыл привзятать скидку к Торговому предложению
ALTER TABLE discount ADD COLUMN sku_id INT;
ALTER TABLE discount ADD CONSTRAINT public_discount_su_fk FOREIGN KEY (sku_id) REFERENCES sku (id)

ALTER TABLE public.discount ADD COLUMN created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL;
ALTER TABLE public.discount ADD COLUMN updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL;
CREATE TRIGGER t_public_discount
    BEFORE UPDATE
    ON public.discount
    FOR EACH ROW
EXECUTE PROCEDURE public.upd_updated_at();

-- Категория статей. все поля самодокументирующиеся
COMMENT ON TABLE public.article_category IS 'Таблица для категорий статей'

--  ДОСТАВКА
COMMENT ON TABLE public.delivery IS 'Таблица способов доставки довара'
COMMENT ON COLUMN public.delivery.weight_price IS 'Цена за кг';
COMMENT ON COLUMN public.delivery.distance_price IS 'Цена 1кг / 1 км';

ALTER TABLE public.delivery ADD COLUMN created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL;
ALTER TABLE public.delivery ADD COLUMN updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL;
CREATE TRIGGER t_public_delivery
    BEFORE UPDATE
    ON public.delivery
    FOR EACH ROW
EXECUTE PROCEDURE public.upd_updated_at();
------------------------------
-- СКЛАД
COMMENT ON TABLE public.storehouse IS 'Таблица складов. Контакты'

ALTER TABLE public.storehouse ADD COLUMN created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL;
ALTER TABLE public.storehouse ADD COLUMN updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL;
CREATE TRIGGER t_public_storehouse
    BEFORE UPDATE
    ON public.storehouse
    FOR EACH ROW
EXECUTE PROCEDURE public.upd_updated_at();

-- Наличие товара на складе

COMMENT ON TABLE public.storehouse_available IS 'Наличие товара на складе'
COMMENT ON COLUMN public.storehouse_available.available IS 'Товара в наличии';
COMMENT ON COLUMN public.storehouse_available.reserve IS 'Зарезервировано товара';

ALTER TABLE public.storehouse_available ADD COLUMN created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL;
ALTER TABLE public.storehouse_available ADD COLUMN updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL;
CREATE TRIGGER t_public_storehouse_available
    BEFORE UPDATE
    ON public.storehouse_available
    FOR EACH ROW
EXECUTE PROCEDURE public.upd_updated_at();
------------------------------
-- КЛИЕНТ
COMMENT ON TABLE public.customer IS 'Таблица клиентов'
CREATE TYPE customer_type AS ENUM ('физлицо', 'юрлицо')
ALTER TABLE customer DROP COLUMN type;
ALTER TABLE customer ADD COLUMN type customer_type NOT NULL;
COMMENT ON COLUMN public.customer.type IS 'Тип перечисления. Физическое или Юрлицо'

-- Адрес клиента
COMMENT ON TABLE public.customer_address IS 'Таблица адресов клиентов'

ALTER TABLE public.customer_address ADD COLUMN created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL;
ALTER TABLE public.customer_address ADD COLUMN updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL;
CREATE TRIGGER t_public_customer_address
    BEFORE UPDATE
    ON public.customer_address
    FOR EACH ROW
EXECUTE PROCEDURE public.upd_updated_at();

-- Юр лицо
COMMENT ON TABLE public.legal_person IS 'Таблица для счетов юрлиц'

-- Таблица адресов специалистов, работающих с сайтом
COMMENT ON TABLE public.user_address IS 'Таблица адресов специалистов, работающих с сайтом'

ALTER TABLE public.user_address ADD COLUMN created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL;
ALTER TABLE public.user_address ADD COLUMN updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL;
CREATE TRIGGER t_public_user_address
    BEFORE UPDATE
    ON public.user_address
    FOR EACH ROW
EXECUTE PROCEDURE public.upd_updated_at();

-- USER
COMMENT ON TABLE public.user IS 'Таблица специалистов, работающих с сайтом'
COMMENT ON COLUMN public.user.roles IS 'Роли пользователей';

-- Дополнительные поля

COMMENT ON TABLE public.field IS 'Дополнительные поля'
COMMENT ON COLUMN public.field.name IS 'Название дополнительных полей';
COMMENT ON COLUMN public.field.field_type_id IS 'Тип дополнительного поля. Декларативный характер, просто чтобы в админке было понятно, какой тип поля';

ALTER TABLE public.field ADD COLUMN created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL;
ALTER TABLE public.field ADD COLUMN updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL;
CREATE TRIGGER t_public_field
    BEFORE UPDATE
    ON public.field
    FOR EACH ROW
EXECUTE PROCEDURE public.upd_updated_at();

-- Типы дополнительныхх полей
COMMENT ON TABLE public.field_type IS 'Таблица типов дополнительных полей'
COMMENT ON COLUMN public.field_type.name IS 'Название типа дополнительного поля';

ALTER TABLE public.field_type ADD COLUMN created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL;
ALTER TABLE public.field_type ADD COLUMN updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL;
CREATE TRIGGER t_public_field_type
    BEFORE UPDATE
    ON public.field_type
    FOR EACH ROW
EXECUTE PROCEDURE public.upd_updated_at();


-- TYPES

COMMENT ON TABLE public.field_type_jsonb IS 'Таблица типа дополнительного поля: jsonb'
COMMENT ON TABLE public.field_type_int IS 'Таблица типа дополнительного поля: целое число'

ALTER TABLE public.field_type_jsonb ADD COLUMN created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL;
ALTER TABLE public.field_type_jsonb ADD COLUMN updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL;
CREATE TRIGGER t_public_field_type_jsonb
    BEFORE UPDATE
    ON public.field_type_jsonb
    FOR EACH ROW
EXECUTE PROCEDURE public.upd_updated_at();
ALTER TABLE public.field_type_int ADD COLUMN created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL;
ALTER TABLE public.field_type_int ADD COLUMN updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL;
CREATE TRIGGER t_public_field_type_int
    BEFORE UPDATE
    ON public.field_type_int
    FOR EACH ROW
EXECUTE PROCEDURE public.upd_updated_at();

-- Адрес заказа
COMMENT ON TABLE public.order_address IS 'Таблица адресов заказа'
ALTER TABLE public.order_address ADD COLUMN created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL;
ALTER TABLE public.order_address ADD COLUMN updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL;
CREATE TRIGGER t_public_order_address
    BEFORE UPDATE
    ON public.order_address
    FOR EACH ROW
EXECUTE PROCEDURE public.upd_updated_at();

-- Заказ
COMMENT ON TABLE public.order IS 'Таблица заказов'
COMMENT ON COLUMN public.order.distance IS 'Поле расстояние - для доставки';
COMMENT ON COLUMN public.order.weight IS 'Поле вес - для доставки';
COMMENT ON COLUMN public.order.cart_cost IS 'Цена по корзине';
COMMENT ON COLUMN public.order.delivery_cost_money IS 'Цена доставки';
COMMENT ON COLUMN public.order.cost IS 'Общая цена';
COMMENT ON COLUMN public.order.comment IS 'Комментарий клиента к заказу';

-- Кросс соответствие заказа артикулу и количество
COMMENT ON TABLE public.sku2order IS 'Кросс таблица заказ-артикул и количество на каждый артикул'
COMMENT ON COLUMN public.sku2order.quantity IS 'Поле количество на каждый артикул';
ALTER TABLE public.sku2order ADD COLUMN created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL;
ALTER TABLE public.sku2order ADD COLUMN updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL;
CREATE TRIGGER t_public_sku2order
    BEFORE UPDATE
    ON public.sku2order
    FOR EACH ROW
EXECUTE PROCEDURE public.upd_updated_at();

-- ORDER STATUS - я не буду тут делат enum, т.к. эти статусы будут добавляться, удаляться, а enum по моей практике - весьма капризный тип

COMMENT ON TABLE public.order_status IS 'Таблица статусов заказов'
COMMENT ON COLUMN public.order_status.name IS 'Поле статусов заказа, к примеру, новый, согласован, оплачен, возврат и так далее';

ALTER TABLE public.order_status ADD COLUMN created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL;
ALTER TABLE public.order_status ADD COLUMN updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL;
CREATE TRIGGER t_public_order_status
    BEFORE UPDATE
    ON public.order_status
    FOR EACH ROW
EXECUTE PROCEDURE public.upd_updated_at();
-------------------
-- Таблица типов платежных систем, которыми клиент может оплатить товар
-- это очень сырое представление, просто заглушка
COMMENT ON TABLE public.payment IS 'Таблица доступных платежных систем'
COMMENT ON COLUMN public.payment.options IS 'Дополнительные опции платежных систем';
COMMENT ON COLUMN public.payment.fee IS 'Комиссия';
COMMENT ON COLUMN public.payment.comment IS 'Комментарий к платежной системе';

ALTER TABLE public.payment ADD COLUMN created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL;
ALTER TABLE public.payment ADD COLUMN updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL;
CREATE TRIGGER t_public_payment
    BEFORE UPDATE
    ON public.payment
    FOR EACH ROW
EXECUTE PROCEDURE public.upd_updated_at();
-----------------
-- Сопровождение заказа
COMMENT ON TABLE public.order_processing IS 'Таблица сопровождения заказа'
COMMENT ON COLUMN public.order_processing.user_id IS 'Менеджер сопровождающий заказ';
COMMENT ON COLUMN public.order_processing.cash_voucher IS 'Чек';
COMMENT ON COLUMN public.order_processing.comment IS 'Комментарий менеджера';

