-- Перевод между двумя счетами в случайном порядке.
-- Половина транзакций идёт 1->2, половина 2->1 — гарантированный deadlock.
-- Лечится двумя способами: единый порядок захвата строк и ретрай (--max-tries).
\set from random(1, 2)
\set to 3 - :from
BEGIN;
UPDATE lab.accounts SET balance = balance - 1 WHERE id = :from;
UPDATE lab.accounts SET balance = balance + 1 WHERE id = :to;
END;
