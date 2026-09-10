-- Тот же перевод, но строки всегда захватываются по возрастанию id.
-- Deadlock исчезает без единого ретрая — цена нулевая.
\set from random(1, 2)
\set to 3 - :from
\set lo least(:from, :to)
\set hi greatest(:from, :to)
BEGIN;
SELECT id FROM lab.accounts WHERE id IN (:lo, :hi) ORDER BY id FOR UPDATE;
UPDATE lab.accounts SET balance = balance - 1 WHERE id = :from;
UPDATE lab.accounts SET balance = balance + 1 WHERE id = :to;
END;
