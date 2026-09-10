-- Права на создание схем под задания и на LOAD DATA LOCAL INFILE.
CREATE DATABASE IF NOT EXISTS blog CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
CREATE DATABASE IF NOT EXISTS shop CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
CREATE DATABASE IF NOT EXISTS bench CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
CREATE DATABASE IF NOT EXISTS lab   CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
GRANT ALL PRIVILEGES ON blog.*  TO 'practice'@'%';
GRANT ALL PRIVILEGES ON shop.*  TO 'practice'@'%';
GRANT ALL PRIVILEGES ON bench.* TO 'practice'@'%';
GRANT ALL PRIVILEGES ON lab.*   TO 'practice'@'%';
GRANT PROCESS ON *.* TO 'practice'@'%';  -- нужен для EXPLAIN ANALYZE и performance_schema
FLUSH PRIVILEGES;
