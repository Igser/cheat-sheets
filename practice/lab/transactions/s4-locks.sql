-- ============================================================================
-- Сценарий 4. FOR UPDATE, NOWAIT, SKIP LOCKED, advisory locks.
-- Перед стартом: SELECT lab.reset();
-- ============================================================================

-- ---- FOR UPDATE: ждать -----------------------------------------------------
-- [A]
BEGIN;
SELECT * FROM lab.stock WHERE product_id = 1 FOR UPDATE;

-- [B] висит, пока А не завершится. В веб-запросе это утекший таймаут.
BEGIN;
SELECT * FROM lab.stock WHERE product_id = 1 FOR UPDATE;

-- [B] Пока висит — смотрим из ТРЕТЬЕГО окна, кто кого держит:
--     SELECT * FROM lab.blockers;
--     SELECT * FROM lab.activity;

-- [A]
COMMIT;
-- [B] разблокировалась
ROLLBACK;

-- ---- NOWAIT: не ждать, а падать сразу --------------------------------------
-- [A]
BEGIN;
SELECT * FROM lab.stock WHERE product_id = 1 FOR UPDATE;
-- [B]
BEGIN;
SELECT * FROM lab.stock WHERE product_id = 1 FOR UPDATE NOWAIT;
--   ERROR: could not obtain lock on row in relation "stock"  (SQLSTATE 55P03)
-- Честный быстрый отказ вместо зависшего запроса. Для интерактивных операций
-- это лучше, чем ожидание: пользователю сразу «попробуйте ещё раз».
ROLLBACK;
-- [A]
COMMIT;

-- Альтернатива без ошибки — ограничить ожидание временем:
--   SET lock_timeout = '2s';   -- и тогда FOR UPDATE упадёт через 2 секунды

-- ---- SKIP LOCKED: очередь задач без единой коллизии ------------------------
-- Так пишется воркер, который забирает задачи из таблицы.
-- Запустите в двух сессиях подряд и сравните выданные id — пересечений не будет.

-- [A]
BEGIN;
WITH picked AS (
    SELECT id FROM lab.jobs
    WHERE status = 'new'
    ORDER BY id
    LIMIT 3
    FOR UPDATE SKIP LOCKED          -- занятые другими воркерами строки пропускаем
)
UPDATE lab.jobs j
SET status = 'processing', locked_by = 'worker-A', locked_at = now()
FROM picked WHERE j.id = picked.id
RETURNING j.id, j.payload;          -- 1, 2, 3

-- [B] не ждёт ни секунды и берёт следующие
BEGIN;
WITH picked AS (
    SELECT id FROM lab.jobs
    WHERE status = 'new'
    ORDER BY id
    LIMIT 3
    FOR UPDATE SKIP LOCKED
)
UPDATE lab.jobs j
SET status = 'processing', locked_by = 'worker-B', locked_at = now()
FROM picked WHERE j.id = picked.id
RETURNING j.id, j.payload;          -- 4, 5, 6

-- [A] COMMIT;   [B] COMMIT;
SELECT locked_by, count(*), min(id), max(id) FROM lab.jobs
WHERE locked_by IS NOT NULL GROUP BY 1;

-- Без SKIP LOCKED второй воркер встал бы в очередь за первым, и добавление
-- воркеров не увеличивало бы пропускную способность.

-- ---- Advisory lock: блокировка без строки ----------------------------------
-- Когда защищать нужно процесс, а не запись: «эта крон-задача выполняется
-- в одном экземпляре на весь кластер».

-- [A]
SELECT pg_try_advisory_lock(42);    -- true, лок живёт до конца СЕССИИ
-- [B]
SELECT pg_try_advisory_lock(42);    -- false — второй экземпляр не запустится
-- [A]
SELECT pg_advisory_unlock(42);

-- Вариант pg_advisory_xact_lock(42) снимается автоматически на COMMIT —
-- его сложнее забыть отпустить.
