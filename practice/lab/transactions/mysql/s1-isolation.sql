-- ============================================================================
-- MySQL/InnoDB: чем уровни изоляции отличаются от PostgreSQL.
-- Две сессии: docker exec -it cs-mysql mysql -upractice -psecret lab
-- Перед стартом: CALL reset_lab(1);
-- ============================================================================

-- ---- 1. Грязное чтение здесь РЕАЛЬНО существует ----------------------------
-- [A]
BEGIN;
UPDATE accounts SET balance = balance - 500 WHERE id = 1;
-- не коммитим

-- [B]
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
BEGIN;
SELECT id, owner, balance FROM accounts ORDER BY id;   -- 500 / 1000 (!)
-- Б видит незакоммиченные данные. В PostgreSQL это невозможно в принципе.
COMMIT;

-- [A]
ROLLBACK;      -- и данных, которые Б уже показал пользователю, никогда не было
-- [B]
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;   -- вернули дефолт

-- ---- 2. REPEATABLE READ: снимок есть, ошибки сериализации нет ---------------
-- [A]
BEGIN;
SELECT id, balance FROM accounts ORDER BY id;      -- 1000 / 1000, снимок взят

-- [B]
UPDATE accounts SET balance = balance - 500 WHERE id = 1;   -- autocommit

-- [A]
SELECT id, balance FROM accounts ORDER BY id;      -- всё ещё 1000 / 1000
-- А вот теперь ключевое отличие от PostgreSQL:
UPDATE accounts SET balance = balance + 100 WHERE id = 1;
-- НЕ ошибка 40001. InnoDB для записи читает строку в текущей версии
-- (consistent read становится locking read) и применяет изменение к 500.
SELECT id, balance FROM accounts WHERE id = 1;     -- 600, снимок разъехался
COMMIT;

-- Вывод: в MySQL внутри одной транзакции чтение и запись могут видеть
-- РАЗНЫЕ версии одной строки. Отсюда берутся тихие расхождения, которые
-- на PostgreSQL проявились бы честной ошибкой сериализации и ретраем.

-- ---- 3. Фантомы и gap-локи --------------------------------------------------
CALL reset_lab(1);
-- [A] блокируем диапазон по индексу
BEGIN;
SELECT * FROM jobs WHERE priority BETWEEN 20 AND 40 FOR UPDATE;

-- [B] пробуем вставить строку ВНУТРЬ диапазона
BEGIN;
INSERT INTO jobs (priority, payload) VALUES (25, 'job-25');
--   ждёт... затем ERROR 1205 (HY000): Lock wait timeout exceeded
-- Заблокированы не только существующие строки, но и промежутки между ними.
-- Это gap-lock: InnoDB давит фантомы блокировками, а не снимком.

-- [B] а вставка ВНЕ диапазона проходит сразу
INSERT INTO jobs (priority, payload) VALUES (60, 'job-60');   -- ок

-- Посмотреть сами локи (видно и RECORD, и GAP):
SELECT object_name, index_name, lock_type, lock_mode, lock_status, lock_data
FROM performance_schema.data_locks
WHERE object_schema = 'lab';

-- [A] COMMIT;   [B] COMMIT;

-- Практическое следствие: на REPEATABLE READ диапазонный SELECT ... FOR UPDATE
-- блокирует вставки соседей и легко даёт deadlock там, где на PostgreSQL его
-- не было бы. Многие проекты по этой причине держат MySQL на READ COMMITTED:
--   SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
-- (gap-локи почти исчезают, но возвращаются фантомы — это осознанный размен)

-- ---- 4. Ошибка не убивает транзакцию ---------------------------------------
CALL reset_lab(1);
BEGIN;
INSERT INTO orders (product_id, buyer) VALUES (1, 'Алиса');
INSERT INTO orders (product_id, buyer) VALUES (999, 'Борис');   -- FK, ошибка
SELECT COUNT(*) FROM orders;    -- РАБОТАЕТ и возвращает 1.
COMMIT;                          -- и Алиса сохраняется
SELECT COUNT(*) FROM orders;     -- 1
-- В PostgreSQL после ошибки транзакция переходит в aborted и не выполняет
-- вообще ничего до ROLLBACK. Отсюда классический баг переносимого кода:
-- на MySQL коммитится «половина транзакции», на PostgreSQL падает всё.

-- ---- 5. DDL — неявный коммит ------------------------------------------------
CALL reset_lab(1);
BEGIN;
INSERT INTO orders (product_id, buyer) VALUES (1, 'Алиса');
ALTER TABLE orders ADD COLUMN note VARCHAR(50) NULL;   -- неявный COMMIT
ROLLBACK;                                              -- откатывать уже нечего
SELECT COUNT(*) FROM orders;    -- 1: заказ сохранился вопреки ROLLBACK
ALTER TABLE orders DROP COLUMN note;
-- В PostgreSQL DDL транзакционный: CREATE, ALTER и DROP откатываются вместе
-- с транзакцией. Это решает, можно ли катить миграцию «всё или ничего».
