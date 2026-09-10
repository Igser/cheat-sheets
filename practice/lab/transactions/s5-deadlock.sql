-- ============================================================================
-- Сценарий 5. Deadlock: как получить, как прочитать, как не допустить.
-- Перед стартом: SELECT lab.reset();
-- ============================================================================

-- ---- Воспроизведение -------------------------------------------------------
-- Две транзакции берут те же две строки в противоположном порядке.

-- [A] 1.
BEGIN;
UPDATE lab.accounts SET balance = balance - 100 WHERE id = 1;   -- захватил строку 1

-- [B] 2.
BEGIN;
UPDATE lab.accounts SET balance = balance - 100 WHERE id = 2;   -- захватил строку 2

-- [A] 3. Тянется за строкой 2 — ждёт Б.
UPDATE lab.accounts SET balance = balance + 100 WHERE id = 2;

-- [B] 4. Тянется за строкой 1 — ждёт А. Цикл замкнулся.
UPDATE lab.accounts SET balance = balance + 100 WHERE id = 1;

-- Через deadlock_timeout (по умолчанию 1 секунда) PostgreSQL находит цикл
-- и убивает ОДНУ из транзакций:
--   ERROR: deadlock detected            (SQLSTATE 40P01)
--   DETAIL: Process 123 waits for ShareLock on transaction 456; blocked by process 789.
--   HINT: See server log for query details.
-- Вторая транзакция при этом спокойно продолжает работу.

-- [выжившая] COMMIT;   [убитая] ROLLBACK;

-- ---- Как читать инцидент ---------------------------------------------------
-- Полный текст обоих запросов есть только в логе сервера:
--   docker compose logs postgres | Select-String -Context 0,12 "deadlock detected"
-- Именно оттуда достаётся порядок захвата, который надо чинить.

SHOW deadlock_timeout;      -- 1s: сколько ждём перед проверкой на цикл
-- Снижать не нужно: детектор обходит граф ожиданий, на нагруженной базе
-- частые проверки стоят дороже редких дедлоков.

-- ---- Профилактика №1: единый порядок захвата -------------------------------
SELECT lab.reset();
-- Оба переводят деньги, но строки берут по возрастанию id — цикла не будет.

-- [A]
BEGIN;
SELECT id FROM lab.accounts WHERE id IN (1, 2) ORDER BY id FOR UPDATE;
UPDATE lab.accounts SET balance = balance - 100 WHERE id = 1;
UPDATE lab.accounts SET balance = balance + 100 WHERE id = 2;
-- [B] честно ждёт в очереди, а не устраивает цикл
BEGIN;
SELECT id FROM lab.accounts WHERE id IN (1, 2) ORDER BY id FOR UPDATE;
-- [A]
COMMIT;
-- [B]
UPDATE lab.accounts SET balance = balance - 100 WHERE id = 2;
UPDATE lab.accounts SET balance = balance + 100 WHERE id = 1;
COMMIT;

-- ---- Профилактика №2: ретрай -----------------------------------------------
-- Deadlock нельзя исключить полностью, поэтому код записи оборачивают в ретрай.
-- Ловим SQLSTATE 40P01 (deadlock) и 40001 (serialization failure), повторяем
-- транзакцию целиком с экспоненциальной задержкой и джиттером, 3-5 попыток.
--
--   try {
--       $retry->run(fn() => $this->placeOrder($cart));   // вся транзакция внутри
--   } catch (DeadlockException $e) { ... }
--
-- Повторять отдельный запрос бессмысленно: транзакция уже откачена целиком.

-- ---- Измерение под нагрузкой ------------------------------------------------
-- Из PowerShell, 20 клиентов, 400 транзакций (файлы в pgbench/):
--
--   docker exec cs-postgres pgbench -U practice -d practice -n -c 20 -j 4 -t 20 `
--       --failures-detailed -f /tmp/pgb/deadlock.sql
--   -> number of deadlock failures: ~90%
--
--   ... тот же запуск с --max-tries 10  -> провалов почти нет, но видно retried
--   ... запуск deadlock_ordered.sql     -> 0 дедлоков без единого ретрая
--
-- Вывод для собеседования: ретрай — страховка, порядок захвата — решение.
