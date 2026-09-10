-- Расширения, которые нужны заданиям из sql.html и nosql.html.
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;  -- топ медленных запросов (задание 6)
CREATE EXTENSION IF NOT EXISTS pg_trgm;             -- опечатки и LIKE '%...%' (nosql, задание 7)
CREATE EXTENSION IF NOT EXISTS btree_gin;           -- составные GIN по jsonb + скаляр (задание 6 nosql)
CREATE EXTENSION IF NOT EXISTS btree_gist;          -- EXCLUDE-ограничения, диапазоны
CREATE EXTENSION IF NOT EXISTS unaccent;            -- снятие диакритики для FTS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS pgcrypto;            -- gen_random_uuid, digest для контрольных сумм (задание 15)
CREATE EXTENSION IF NOT EXISTS tablefunc;           -- crosstab для отчётов

-- Русская конфигурация FTS с нормализацией регистра/диакритики.
CREATE TEXT SEARCH CONFIGURATION ru (COPY = russian);
ALTER TEXT SEARCH CONFIGURATION ru
    ALTER MAPPING FOR hword, hword_part, word
    WITH unaccent, russian_stem;

-- Отдельные схемы, чтобы задания не мешали друг другу.
CREATE SCHEMA IF NOT EXISTS blog;      -- задания 1-4 sql.html
CREATE SCHEMA IF NOT EXISTS shop;      -- задания 5-9 sql.html
CREATE SCHEMA IF NOT EXISTS bench;     -- нагрузочные таблицы: 1-2 млн строк
