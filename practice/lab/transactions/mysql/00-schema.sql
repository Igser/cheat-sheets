-- Стенд под MySQL/InnoDB. Те же таблицы, что в Postgres, — чтобы сравнивать
-- поведение одних и тех же сценариев на двух движках.
CREATE DATABASE IF NOT EXISTS lab CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE lab;

DROP TABLE IF EXISTS orders, stock, accounts, jobs;

CREATE TABLE accounts (
    id      INT PRIMARY KEY,
    owner   VARCHAR(50)    NOT NULL,
    balance DECIMAL(12,2)  NOT NULL,
    version INT            NOT NULL DEFAULT 0
) ENGINE=InnoDB;

CREATE TABLE stock (
    product_id INT PRIMARY KEY,
    title      VARCHAR(100) NOT NULL,
    qty        INT          NOT NULL
) ENGINE=InnoDB;

CREATE TABLE orders (
    id         BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id INT          NOT NULL,
    buyer      VARCHAR(50)  NOT NULL,
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    CONSTRAINT fk_orders_stock FOREIGN KEY (product_id) REFERENCES stock (product_id)
) ENGINE=InnoDB;

-- Отдельная таблица под gap-локи: важен именно диапазон по индексу.
CREATE TABLE jobs (
    id       BIGINT AUTO_INCREMENT PRIMARY KEY,
    priority INT         NOT NULL,
    payload  VARCHAR(50) NOT NULL,
    status   VARCHAR(20) NOT NULL DEFAULT 'new',
    KEY idx_priority (priority)
) ENGINE=InnoDB;

DROP PROCEDURE IF EXISTS reset_lab;
DELIMITER //
CREATE PROCEDURE reset_lab(IN stock_qty INT)
BEGIN
    DELETE FROM orders;
    ALTER TABLE orders AUTO_INCREMENT = 1;
    DELETE FROM stock;
    INSERT INTO stock VALUES (1, 'Последний ноутбук', stock_qty);
    DELETE FROM accounts;
    INSERT INTO accounts VALUES (1, 'Алиса', 1000.00, 0), (2, 'Борис', 1000.00, 0);
    DELETE FROM jobs;
    ALTER TABLE jobs AUTO_INCREMENT = 1;
    INSERT INTO jobs (priority, payload) VALUES
        (10, 'job-10'), (20, 'job-20'), (30, 'job-30'), (40, 'job-40'), (50, 'job-50');
    SELECT CONCAT('готово: остаток ', stock_qty, ', счета 1000/1000') AS result;
END //
DELIMITER ;

CALL reset_lab(1);
