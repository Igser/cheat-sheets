-- Атомарная покупка: условие и списание в одном UPDATE, заказ создаётся только
-- если строка реально обновилась. Никаких блокировок в коде приложения.
WITH taken AS (
    UPDATE lab.stock SET qty = qty - 1
    WHERE product_id = 1 AND qty > 0
    RETURNING product_id
)
INSERT INTO lab.orders (product_id, buyer)
SELECT product_id, 'client-' || :client_id FROM taken;
