-- ============================================================================
-- Сценарий 2. REPEATABLE READ: снимок данных и ошибка сериализации.
-- Перед стартом: SELECT lab.reset();
-- ============================================================================

-- [A] 1. Фиксируем снимок. Важно: снимок берётся на ПЕРВОМ запросе, не на BEGIN.
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT id, owner, balance FROM lab.accounts ORDER BY id;   -- 1000 / 1000

-- [B] 2. Вторая сессия меняет данные и коммитит.
UPDATE lab.accounts SET balance = balance - 500 WHERE id = 1;
INSERT INTO lab.accounts (id, owner, balance) VALUES (3, 'Виктор', 700);

-- [A] 3. Повторяем запрос: А по-прежнему в своём снимке.
SELECT id, owner, balance FROM lab.accounts ORDER BY id;   -- те же 1000 / 1000
SELECT count(*) FROM lab.accounts;                          -- 2, строки Виктора нет
-- Неповторяющегося чтения нет. Фантомов тоже нет — в PostgreSQL их
-- давит сам снимок, а не блокировки диапазонов, как в InnoDB.

-- [A] 4. А теперь пробуем ПИСАТЬ в строку, изменённую после снимка.
UPDATE lab.accounts SET balance = balance + 100 WHERE id = 1;
--   ERROR: could not serialize access due to concurrent update  (SQLSTATE 40001)
-- Транзакция обязана откатиться и начаться заново. Это цена уровня.
ROLLBACK;

-- Что увидели:
--   * REPEATABLE READ даёт согласованный снимок на всю транзакцию;
--   * платим ошибкой 40001 на конкурентной записи — приложение обязано
--     иметь ретрай, иначе пользователь получит 500;
--   * ретраить можно только транзакцию целиком: повторить один запрос нельзя,
--     снимок уже испорчен.
--
-- Проверьте разницу с MySQL: mysql/s2-repeatable-read.sql — там тот же уровень
-- ведёт себя иначе (gap-локи вместо ошибки сериализации).
