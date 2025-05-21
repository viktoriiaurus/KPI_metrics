-- Таблиця користувачів
CREATE TABLE public.users (
    user_id SERIAL PRIMARY KEY,
    birth_date DATE,
    sex VARCHAR(100)
);

-- Таблиця продуктів
CREATE TABLE public.products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    price NUMERIC(10, 25)
);

-- Таблиця кур'єрів
CREATE TABLE public.couriers (
    courier_id SERIAL PRIMARY KEY,
    birth_date DATE,
    sex VARCHAR(100)
);

-- Таблиця замовлень
CREATE TABLE public.orders (
    order_id SERIAL PRIMARY KEY,
    creation_time TIMESTAMP,
    product_ids INTEGER[]
);

-- Таблиця дій користувачів
CREATE TABLE public.user_actions (
    user_id INTEGER NOT NULL,
    order_id INTEGER,
    action VARCHAR(100),
    time TIMESTAMP,
    CONSTRAINT fk_user_actions_user FOREIGN KEY (user_id) REFERENCES public.users(user_id),
    CONSTRAINT fk_user_actions_order FOREIGN KEY (order_id) REFERENCES public.orders(order_id)
);

-- Таблиця дій кур'єрів
CREATE TABLE public.courier_actions (
    courier_id INTEGER NOT NULL,
    order_id INTEGER,
    action VARCHAR(100),
    time TIMESTAMP,
    CONSTRAINT fk_courier_actions_courier FOREIGN KEY (courier_id) REFERENCES public.couriers(courier_id),
    CONSTRAINT fk_courier_actions_order FOREIGN KEY (order_id) REFERENCES public.orders(order_id)
);

ALTER TABLE public.users OWNER TO postgres;
ALTER TABLE public.products OWNER TO postgres;
ALTER TABLE public.couriers OWNER TO postgres;
ALTER TABLE public.orders OWNER TO postgres;
ALTER TABLE public.user_actions OWNER TO postgres;
ALTER TABLE public.courier_actions OWNER TO postgres;

-- Індекси для швидкості пошуку та JOIN операцій
CREATE INDEX idx_user_actions_user_id ON public.user_actions(user_id);
CREATE INDEX idx_user_actions_order_id ON public.user_actions(order_id);

CREATE INDEX idx_courier_actions_courier_id ON public.courier_actions(courier_id);
CREATE INDEX idx_courier_actions_order_id ON public.courier_actions(order_id);

CREATE INDEX idx_orders_order_id ON public.orders(order_id);
CREATE INDEX idx_products_product_id ON public.products(product_id);

CREATE INDEX idx_users_user_id ON public.users(user_id);
CREATE INDEX idx_couriers_courier_id ON public.couriers(courier_id);