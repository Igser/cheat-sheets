-- Наивная покупка: прочитали остаток, проверили в приложении, записали новое значение.
-- Ровно так выглядит код, который проходит ревью и разваливается на конкуренции.
BEGIN;
SELECT qty AS avail FROM lab.stock WHERE product_id = 1 \gset
\if :avail > 0
    UPDATE lab.stock SET qty = :avail - 1 WHERE product_id = 1;
    INSERT INTO lab.orders (product_id, buyer) VALUES (1, 'client-' || :client_id);
\endif
END;
