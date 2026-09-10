-- ============================================================================
-- MySQL: deadlock и разбор инцидента.
-- Перед стартом: CALL reset_lab(1);
-- ============================================================================

-- [A] 1.
BEGIN;
UPDATE accounts SET balance = balance - 100 WHERE id = 1;

-- [B] 2.
BEGIN;
UPDATE accounts SET balance = balance - 100 WHERE id = 2;

-- [A] 3. ждёт Б
UPDATE accounts SET balance = balance + 100 WHERE id = 2;

-- [B] 4. цикл замкнулся
UPDATE accounts SET balance = balance + 100 WHERE id = 1;
--   ERROR 1213 (40001): Deadlock found when trying to get lock;
--                       try restarting transaction
-- InnoDB находит цикл МГНОВЕННО (обход графа ожиданий), а не через таймаут,
-- как PostgreSQL с его deadlock_timeout = 1s. И убивает ту транзакцию,
-- которая изменила меньше строк, — то есть жертва предсказуема.

-- [выжившая] COMMIT;

-- ---- Разбор последнего дедлока ---------------------------------------------
-- Главное отличие от PostgreSQL: полный протокол доступен прямо из SQL,
-- в лог сервера лезть не нужно.
SHOW ENGINE INNODB STATUS;
-- Секция LATEST DETECTED DEADLOCK: оба запроса целиком, какие локи держались
-- (RECORD LOCKS space id ... index PRIMARY ... lock_mode X), кто стал жертвой.
-- Именно отсюда достаётся порядок захвата, который надо чинить в коде.

-- Кто кого ждёт прямо сейчас:
SELECT r.trx_id                    AS waiting_trx,
       r.trx_mysql_thread_id       AS waiting_thread,
       LEFT(r.trx_query, 60)       AS waiting_query,
       b.trx_id                    AS blocking_trx,
       b.trx_mysql_thread_id       AS blocking_thread,
       LEFT(b.trx_query, 60)       AS blocking_query
FROM performance_schema.data_lock_waits w
JOIN information_schema.innodb_trx r ON r.trx_id = w.requesting_engine_transaction_id
JOIN information_schema.innodb_trx b ON b.trx_id = w.blocking_engine_transaction_id;

-- Сколько дедлоков накопилось с рестарта — метрика для мониторинга.
-- Её рост означает, что порядок захвата строк в коде разъехался.
SHOW GLOBAL STATUS LIKE 'Innodb_deadlocks';

-- Долгие транзакции:
SELECT trx_id, trx_state,
       TIMESTAMPDIFF(SECOND, trx_started, NOW()) AS age_sec,
       trx_rows_locked, trx_rows_modified,
       LEFT(trx_query, 60) AS query
FROM information_schema.innodb_trx
ORDER BY trx_started;

SHOW VARIABLES LIKE 'innodb_lock_wait_timeout';
-- 50 секунд по умолчанию. Для веб-запроса это вечность: в проде обычно
-- ставят 5-10, чтобы запрос падал раньше, чем отвалится клиент.

-- ---- Оверселл под нагрузкой -------------------------------------------------
-- 50 параллельных покупок последнего товара, наивный код (см. ../README.md):
--
--   docker exec cs-mysql bash -c 'for i in $(seq 1 50); do
--       mysql -upractice -psecret lab -e "
--         BEGIN;
--         SELECT qty INTO @q FROM stock WHERE product_id = 1;
--         UPDATE stock SET qty = @q - 1 WHERE product_id = 1 AND @q > 0;
--         INSERT INTO orders (product_id, buyer) VALUES (1, CONCAT(\"c\", $i));
--         COMMIT;" 2>/dev/null &
--   done; wait'
--
-- Затем то же самое атомарно — одним UPDATE с условием и ROW_COUNT():
--
--   BEGIN;
--   UPDATE stock SET qty = qty - 1 WHERE product_id = 1 AND qty > 0;
--   -- если ROW_COUNT() = 0, товар кончился: откатываемся, заказ не создаём
--   INSERT INTO orders (product_id, buyer)
--   SELECT 1, 'buyer' FROM DUAL WHERE ROW_COUNT() = 1;
--   COMMIT;
