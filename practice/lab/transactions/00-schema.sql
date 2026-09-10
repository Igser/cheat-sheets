-- Стенд для темы «транзакции»: минимум таблиц, максимум наблюдаемых эффектов.
-- Это не схема магазина из задания 5 sql.html — там проектирование ваше.
-- Здесь только подложка, на которой видно аномалии и блокировки.

DROP SCHEMA IF EXISTS lab CASCADE;
CREATE SCHEMA lab;

-- Счета: перевод денег. На нём видно lost update, deadlock и write skew.
CREATE TABLE lab.accounts (
    id      int PRIMARY KEY,
    owner   text          NOT NULL,
    balance numeric(12,2) NOT NULL CHECK (balance >= 0),
    version int           NOT NULL DEFAULT 0   -- для оптимистичной блокировки
);

-- Склад: последний товар, за который дерутся 50 покупателей.
-- CHECK на qty намеренно НЕ ставим — сначала нужно увидеть оверселл своими глазами.
CREATE TABLE lab.stock (
    product_id int  PRIMARY KEY,
    title      text NOT NULL,
    qty        int  NOT NULL
);

CREATE TABLE lab.orders (
    id         bigserial PRIMARY KEY,
    product_id int         NOT NULL REFERENCES lab.stock,
    buyer      text        NOT NULL,
    created_at timestamptz NOT NULL DEFAULT clock_timestamp()
);

-- Очередь задач: площадка для FOR UPDATE SKIP LOCKED.
CREATE TABLE lab.jobs (
    id        bigserial PRIMARY KEY,
    payload   text NOT NULL,
    status    text NOT NULL DEFAULT 'new',
    locked_by text,
    locked_at timestamptz
);

-- Дежурства: классический write skew (инвариант «хотя бы один на смене»).
CREATE TABLE lab.duty (
    doctor  text PRIMARY KEY,
    on_call boolean NOT NULL
);

-- Возврат стенда в исходное состояние перед каждым сценарием.
-- SELECT lab.reset();      -- 1 товар на складе
-- SELECT lab.reset(5);     -- 5 товаров
CREATE OR REPLACE FUNCTION lab.reset(stock_qty int DEFAULT 1)
RETURNS text LANGUAGE plpgsql AS $$
BEGIN
    TRUNCATE lab.orders RESTART IDENTITY;
    TRUNCATE lab.jobs   RESTART IDENTITY;

    DELETE FROM lab.stock;
    INSERT INTO lab.stock (product_id, title, qty)
    VALUES (1, 'Последний ноутбук', stock_qty);

    DELETE FROM lab.accounts;
    INSERT INTO lab.accounts (id, owner, balance) VALUES
        (1, 'Алиса', 1000.00),
        (2, 'Борис', 1000.00);

    INSERT INTO lab.jobs (payload)
    SELECT 'job-' || i FROM generate_series(1, 20) i;

    DELETE FROM lab.duty;
    INSERT INTO lab.duty (doctor, on_call) VALUES ('Алиса', true), ('Борис', true);

    RETURN format('готово: остаток %s, счета 1000/1000, 20 задач в очереди', stock_qty);
END $$;

-- Что происходит прямо сейчас: чьи транзакции висят и кто кого ждёт.
CREATE OR REPLACE VIEW lab.activity AS
SELECT pid,
       state,
       wait_event_type || ':' || coalesce(wait_event, '') AS waiting_on,
       now() - xact_start AS xact_age,
       left(regexp_replace(query, '\s+', ' ', 'g'), 70)   AS query
FROM pg_stat_activity
WHERE datname = current_database()
  AND pid <> pg_backend_pid()
  AND state IS NOT NULL
ORDER BY xact_start NULLS LAST;

-- Кто кого блокирует. Первое, что открывают, когда «приложение висит».
CREATE OR REPLACE VIEW lab.blockers AS
SELECT blocked.pid                        AS blocked_pid,
       left(blocked.query, 50)            AS blocked_query,
       blocking.pid                       AS blocking_pid,
       left(blocking.query, 50)           AS blocking_query,
       now() - blocked.xact_start         AS blocked_for
FROM pg_stat_activity blocked
JOIN LATERAL unnest(pg_blocking_pids(blocked.pid)) AS b(pid) ON true
JOIN pg_stat_activity blocking ON blocking.pid = b.pid
WHERE cardinality(pg_blocking_pids(blocked.pid)) > 0;

SELECT lab.reset();
