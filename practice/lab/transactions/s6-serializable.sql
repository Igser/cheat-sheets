-- ============================================================================
-- Сценарий 6. SERIALIZABLE и write skew — аномалия, которую видно только здесь.
-- Перед стартом: SELECT lab.reset();
-- ============================================================================

-- Инвариант: на дежурстве всегда хотя бы один врач.
-- Каждая транзакция проверяет инвариант ПЕРЕД снятием себя со смены.
SELECT * FROM lab.duty;    -- Алиса true, Борис true

-- ---- Часть 1. На REPEATABLE READ инвариант ломается ------------------------

-- [A]
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT count(*) FROM lab.duty WHERE on_call;        -- 2, можно уходить
-- [B]
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT count(*) FROM lab.duty WHERE on_call;        -- тоже 2, тоже можно
-- [A]
UPDATE lab.duty SET on_call = false WHERE doctor = 'Алиса';
COMMIT;
-- [B]
UPDATE lab.duty SET on_call = false WHERE doctor = 'Борис';
COMMIT;                                             -- прошло без ошибок!

SELECT count(*) FROM lab.duty WHERE on_call;        -- 0 — смена пустая

-- Обе транзакции писали в РАЗНЫЕ строки, поэтому конфликта записи нет.
-- Каждая по отдельности корректна. Инвариант нарушен вместе. Это write skew.
-- Ни FOR UPDATE на своей строке, ни REPEATABLE READ здесь не помогают.

-- ---- Часть 2. SERIALIZABLE ловит ------------------------------------------
SELECT lab.reset();

-- [A]
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT count(*) FROM lab.duty WHERE on_call;        -- 2
-- [B]
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT count(*) FROM lab.duty WHERE on_call;        -- 2
-- [A]
UPDATE lab.duty SET on_call = false WHERE doctor = 'Алиса';
COMMIT;                                             -- ок
-- [B]
UPDATE lab.duty SET on_call = false WHERE doctor = 'Борис';
--   ERROR: could not serialize access due to read/write dependencies among transactions
--   DETAIL: Reason code: Canceled on identification as a pivot, during write.
--   HINT: The transaction might succeed if retried.       (SQLSTATE 40001)
ROLLBACK;

SELECT count(*) FROM lab.duty WHERE on_call;        -- 1 — инвариант цел

-- Цена: ошибка прилетает в произвольный момент — на UPDATE (как здесь) или
-- на COMMIT, в зависимости от того, когда детектор увидел опасный цикл
-- зависимостей. Планировать надо худший случай: COMMIT.
-- Отсюда два требования к коду:
--   * ретрай оборачивает ВСЮ транзакцию, а не отдельный запрос;
--   * внутри транзакции не должно быть побочных эффектов — письмо, отправленное
--     до COMMIT, уйдёт повторно на каждой попытке.

-- ---- Часть 3. То же самое без SERIALIZABLE ---------------------------------
SELECT lab.reset();
-- Материализуем конфликт: блокируем ВСЕ строки, которые читаем.
-- Дешевле по CPU, но сериализует всех дежурных на одной очереди.

-- [A]
BEGIN;
SELECT count(*) FROM lab.duty WHERE on_call FOR UPDATE;   -- захватили обе строки
-- [B] ждёт здесь
BEGIN;
SELECT count(*) FROM lab.duty WHERE on_call FOR UPDATE;
-- [A]
UPDATE lab.duty SET on_call = false WHERE doctor = 'Алиса';
COMMIT;
-- [B] проснулась, пересчитала и видит уже 1 — уходить нельзя
COMMIT;

-- Когда что брать:
--   SERIALIZABLE      — инвариант сложный, нагрузка на запись умеренная,
--                       ретрай в приложении уже есть. Меньше кода в запросах.
--   FOR UPDATE вручную — горячая точка, ретраи дороги, инвариант локальный.
--                       Больше контроля, больше шансов забыть строку.
