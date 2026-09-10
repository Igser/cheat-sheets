# Песочница баз данных

Стенд под разделы «Практика» из [sql.html](../sql.html) и [nosql.html](../nosql.html).
Порты слушаются только на `127.0.0.1` и смещены так, чтобы не пересекаться с рабочими
стеками (`generium`, `promru`), которые уже занимают 13306/13307/18090/18091.

## Управление

Первый запуск — скопировать настройки: `cp .env.example .env`. Пароль и порты
правятся там же; сам `.env` в репозиторий не коммитится.

Все команды из папки `practice`:

```powershell
docker compose up -d                    # ядро: postgres, mysql, redis, adminer
docker compose --profile all up -d      # всё, включая mongo, elasticsearch, kibana, clickhouse
docker compose --profile nosql up -d    # + mongo
docker compose --profile search up -d   # + elasticsearch
docker compose --profile kibana up -d   # + kibana (и elasticsearch)
docker compose --profile olap up -d     # + clickhouse

docker compose --profile all ps         # статус
docker compose --profile all stop       # погасить, данные остаются
docker compose --profile all down       # снести контейнеры, тома остаются
docker compose --profile all down -v    # снести вместе с данными — чистый старт
```

Логи одного сервиса: `docker compose logs -f postgres`.

## Доступы

Пароль везде `secret` (меняется в `.env`), пользователь — `practice`.

| Сервис | Хост-порт | Подключение |
|---|---|---|
| PostgreSQL 17 | 15432 | `postgresql://practice:secret@127.0.0.1:15432/practice` |
| MySQL 8.4 | 13308 | `mysql://practice:secret@127.0.0.1:13308/practice` (root тоже `secret`) |
| Redis 7 | 16379 | `redis://127.0.0.1:16379` (без пароля) |
| MongoDB 7 | 27017 | `mongodb://practice:secret@127.0.0.1:27017/?authSource=admin` |
| Elasticsearch 8.15 | 19200 | `http://127.0.0.1:19200` (security выключен) |
| Kibana | 15601 | http://127.0.0.1:15601 — Dev Tools для запросов к ES |
| ClickHouse 24.8 | 18123 / 19000 | `http://127.0.0.1:18123`, native 19000 |
| Adminer | 18080 | http://127.0.0.1:18080 — сервер `postgres` или `mysql` |

Консоли внутри контейнеров:

```powershell
docker exec -it cs-postgres psql -U practice -d practice
docker exec -it cs-mysql mysql -upractice -psecret practice
docker exec -it cs-redis redis-cli
docker exec -it cs-mongo mongosh -u practice -p secret
docker exec -it cs-clickhouse clickhouse-client --user practice --password secret -d practice
```

## Что уже настроено

**PostgreSQL** — расширения `pg_stat_statements`, `pg_trgm`, `btree_gin`, `btree_gist`,
`unaccent`, `pgcrypto`, `tablefunc`, `uuid-ossp`; конфигурация FTS `ru` (русский стеммер
+ снятие диакритики); `auto_explain` пишет план любого запроса дольше 500 мс, а запросы
дольше 200 мс попадают в лог. Схемы `blog`, `shop`, `bench` — под разные группы заданий.

Генераторы объёма (данные создаются по команде, не при старте):

```sql
SELECT bench.gen_events(2000000);  -- задание 6 sql.html: медленный отчёт на 2 млн строк
SELECT bench.gen_docs(1000000);    -- задание 3 nosql.html: LIKE против tsvector
```

**MySQL** — включены `performance_schema`, slow log с порогом 0.2 с, `local-infile`
для `LOAD DATA`; заведены базы `blog`, `shop`, `bench`, пользователю выдан `PROCESS`
(нужен для `EXPLAIN ANALYZE`).

**Redis** — AOF включён, `maxmemory 512mb` с политикой `allkeys-lru`: на этом видно
вытеснение ключей в заданиях 4–5 nosql.html.

**Elasticsearch** — single-node, security выключен, куча 1 ГБ. Русский анализатор
(`russian`) доступен из коробки — маппинг для задания 8 пишется без плагинов.

**MongoDB** — root `practice` и отдельный `app` с `readWrite` на базе `practice`.

**ClickHouse** — база `practice` для задания 11 (сравнение с Postgres на 10 млн событий).

## Лаборатории

- [lab/transactions](lab/transactions/README.md) — транзакции, уровни изоляции, блокировки,
  дедлоки и конкурентность: 10 сценариев на две сессии + нагрузочные прогоны pgbench.

## Куда смотреть в конспектах

- `sql.html` → `#practice`, задания 1–14: Postgres/MySQL, `bench.gen_events` для нагрузки.
- `nosql.html` → `#practice`, задания 1–15: Redis (4–5), Postgres JSONB и FTS (3, 6–7),
  Elasticsearch (8–10, 14–15), ClickHouse (11).
- Cassandra (задание 13) — проектирование на бумаге, контейнер не нужен.

## Потребление

Ядро (postgres + mysql + redis + adminer) — около 1.5 ГБ RAM. Полный профиль
с Elasticsearch и Kibana — около 4 ГБ. Если стенд не нужен прямо сейчас:
`docker compose --profile all stop`.

## PhpStorm

Подключения к базам лежат в `.idea/dataSources.xml` — после перезагрузки проекта
они появятся в панели Database (`Alt+1` → вкладка Database, либо `View → Tool Windows → Database`):

| Датасорс | База | Что смотреть |
|---|---|---|
| `cs-postgres` | practice | схемы `lab`, `bench`, `blog`, `shop` |
| `cs-mysql` | lab | плюс `blog`, `shop`, `bench` на том же сервере |
| `cs-redis` | db 0 | ключи, TTL |
| `cs-mongo` | practice | коллекции |
| `cs-clickhouse` | practice | при первом подключении IDE попросит скачать драйвер |

Логин и пароль зашиты прямо в JDBC-строку (`practice` / `secret`), поэтому
диалог с паролем не появится. Пароль и так лежит открытым в `.env` и в этом
README — стенд слушает только `127.0.0.1`. Если так не нравится, уберите
`?user=...&password=...` из URL и введите пароль в диалоге IDE один раз.

Elasticsearch в списке нет: PhpStorm не умеет его как источник данных.
Запросы к нему — через Kibana Dev Tools на http://127.0.0.1:15601.

Заодно настроены диалекты SQL: файлы проекта считаются PostgreSQL, а папки
`init/mysql` и `lab/transactions/mysql` — MySQL. Подсветка и автодополнение
в сценариях будут соответствовать нужной СУБД.

**Запуск SQL прямо из редактора:** открыть любой `.sql` из `lab/transactions`,
выбрать датасорс в выпадающем списке на панели редактора, `Ctrl+Enter` на запросе.
Для сценариев на две сессии этого мало — там нужны два независимых соединения,
поэтому блоки `[A]` и `[B]` удобнее гонять в двух консолях: правый клик по
датасорсу → `New → Query Console` (можно открыть две).
