-- ============================================================================
-- Сценарий 7. Ошибки внутри транзакции, SAVEPOINT и вложенность.
-- Одна сессия, второе окно не нужно.
-- Перед стартом: SELECT lab.reset();
-- ============================================================================

-- ---- Часть 1. Первая же ошибка убивает всю транзакцию ----------------------
BEGIN;
INSERT INTO lab.orders (product_id, buyer) VALUES (1, 'Алиса');
INSERT INTO lab.orders (product_id, buyer) VALUES (999, 'Борис');   -- нет такого товара
--   ERROR: insert or update on table "orders" violates foreign key constraint

SELECT 1;
--   ERROR: current transaction is aborted, commands ignored until end of transaction block
-- Транзакция в состоянии aborted: до ROLLBACK не работает НИЧЕГО, включая SELECT.
-- Это отличие от MySQL, где после ошибки транзакция продолжает жить.

COMMIT;      -- ведёт себя как ROLLBACK, в psql видно «ROLLBACK» в ответе
SELECT count(*) FROM lab.orders;    -- 0 — первый INSERT тоже не сохранился

-- ---- Часть 2. SAVEPOINT: откатить часть работы -----------------------------
BEGIN;
INSERT INTO lab.orders (product_id, buyer) VALUES (1, 'Алиса');

SAVEPOINT before_risky;
INSERT INTO lab.orders (product_id, buyer) VALUES (999, 'Борис');   -- падает
ROLLBACK TO SAVEPOINT before_risky;    -- транзакция снова рабочая

SELECT count(*) FROM lab.orders;       -- 1 — Алиса на месте
INSERT INTO lab.orders (product_id, buyer) VALUES (1, 'Виктор');
COMMIT;

SELECT id, buyer FROM lab.orders ORDER BY id;   -- Алиса и Виктор

-- ---- Часть 3. Цена сейвпоинтов ---------------------------------------------
-- Каждый SAVEPOINT — отдельный subtransaction id. Если открывать их в цикле
-- на десятки тысяч итераций, кэш subxid переполняется, и вся база начинает
-- тормозить на чтении (SubtransSLRU, «subtransaction wraparound»).
-- Практическое правило: сейвпоинт — точечный инструмент, не обёртка каждой
-- операции в цикле.

-- Так делать НЕ надо:
--   BEGIN;
--   FOR i IN 1..100000 LOOP  SAVEPOINT s; ... ; RELEASE SAVEPOINT s;  END LOOP;
-- Правильно: разбить на пакеты по 1000 строк, каждый пакет — своя транзакция.

-- ---- Часть 4. Вложенных транзакций не существует ---------------------------
BEGIN;
BEGIN;      -- WARNING: there is already a transaction in progress
COMMIT;     -- закрывает ЕДИНСТВЕННУЮ транзакцию
COMMIT;     -- WARNING: there is no transaction in progress

-- Именно поэтому ORM (Doctrine, Eloquent) реализуют «вложенные транзакции»
-- через SAVEPOINT и счётчик вложенности. Проверьте у себя в проекте:
-- при выключенном savepoint-режиме внутренний rollback откатит ВСЁ,
-- включая работу внешнего вызова, и это выяснится в проде.

-- ---- Часть 5. Транзакция, забытая открытой ---------------------------------
BEGIN;
SELECT 1;
-- и приложение ушло думать / упало / ждёт ответа внешнего API

-- В другом окне:
--   SELECT * FROM lab.activity;   -- state = 'idle in transaction', xact_age растёт
--
-- Чем это плохо: висящая транзакция держит горизонт видимости, autovacuum
-- не может убрать мёртвые версии строк, таблицы пухнут, планы деградируют.
-- Защита на стороне сервера:
--   SET idle_in_transaction_session_timeout = '30s';   -- сессию убьют
-- Защита на стороне кода: никаких HTTP-вызовов и sleep внутри транзакции.
ROLLBACK;
