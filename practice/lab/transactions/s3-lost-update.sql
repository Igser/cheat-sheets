-- ============================================================================
-- Сценарий 3. Lost update — аномалия, которую не лечит ни один уровень изоляции.
-- Перед стартом: SELECT lab.reset();
-- ============================================================================

-- ---- Часть 1. Как теряется обновление -------------------------------------
-- Типовой код: прочитали в PHP, посчитали в PHP, записали обратно.

-- [A] 1.
BEGIN;
SELECT balance FROM lab.accounts WHERE id = 1;     -- 1000, приложение запомнило

-- [B] 2.
BEGIN;
SELECT balance FROM lab.accounts WHERE id = 1;     -- тоже 1000

-- [A] 3. Списываем 100: 1000 - 100 = 900, записываем абсолютное значение.
UPDATE lab.accounts SET balance = 900 WHERE id = 1;
COMMIT;

-- [B] 4. Списываем 200 от СВОЕГО прочитанного значения: 1000 - 200 = 800.
UPDATE lab.accounts SET balance = 800 WHERE id = 1;
COMMIT;

-- [A] 5. Проверяем.
SELECT balance FROM lab.accounts WHERE id = 1;
-- 800. Списали 100 и 200, а ушло 200. Первое списание потеряно.
-- Ни READ COMMITTED, ни REPEATABLE READ, ни SERIALIZABLE это не чинят:
-- обе транзакции корректны с точки зрения СУБД. Ошибка в коде приложения.

-- ---- Часть 2. Лечение №1: атомарный UPDATE --------------------------------
SELECT lab.reset();
-- Значение считает база, а не приложение. Гонки нет вообще.

-- [A]
BEGIN;
UPDATE lab.accounts SET balance = balance - 100 WHERE id = 1;
-- [B] выполнится только после COMMIT [A] — вторая сессия ждёт на строке.
BEGIN;
UPDATE lab.accounts SET balance = balance - 200 WHERE id = 1;
-- [A]
COMMIT;
-- [B]
COMMIT;
SELECT balance FROM lab.accounts WHERE id = 1;     -- 700, оба списания на месте

-- ---- Часть 3. Лечение №2: оптимистичная блокировка ------------------------
SELECT lab.reset();
-- Когда пересчёт нельзя выразить одним UPDATE (сложная доменная логика).

-- [A] читает вместе с версией
BEGIN;
SELECT balance, version FROM lab.accounts WHERE id = 1;   -- 1000, version 0

-- [B] делает то же и успевает записать первым
BEGIN;
UPDATE lab.accounts SET balance = 800, version = version + 1
WHERE id = 1 AND version = 0;                              -- UPDATE 1
COMMIT;

-- [A] пишет со своей версией
UPDATE lab.accounts SET balance = 900, version = version + 1
WHERE id = 1 AND version = 0;                              -- UPDATE 0 ← конфликт!
COMMIT;
-- Приложение обязано проверить число затронутых строк. Ноль — данные устарели,
-- нужно перечитать и повторить бизнес-операцию. Doctrine делает это через
-- @Version и бросает OptimisticLockException.

-- ---- Часть 4. Лечение №3: пессимистичная блокировка -----------------------
SELECT lab.reset();

-- [A]
BEGIN;
SELECT balance FROM lab.accounts WHERE id = 1 FOR UPDATE;  -- строка захвачена
-- [B] повиснет здесь до COMMIT [A]
BEGIN;
SELECT balance FROM lab.accounts WHERE id = 1 FOR UPDATE;
-- [A]
UPDATE lab.accounts SET balance = 900 WHERE id = 1;
COMMIT;
-- [B] разблокировалась и видит уже 900 — читает актуальное значение
UPDATE lab.accounts SET balance = 700 WHERE id = 1;
COMMIT;

-- Итог: три инструмента под разные задачи.
--   атомарный UPDATE  — когда пересчёт выражается в SQL. Самый дешёвый.
--   версионность      — когда между чтением и записью есть бизнес-логика
--                       или пауза (форма редактирования у пользователя).
--   FOR UPDATE        — когда нужно захватить несколько строк и держать
--                       инвариант до конца транзакции. Самый дорогой:
--                       очередь на строке, риск deadlock.
