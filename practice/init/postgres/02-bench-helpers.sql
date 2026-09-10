-- Генераторы объёма: задание 6 sql.html (2+ млн строк) и задание 3 nosql.html (1 млн строк текста).
-- Данные генерируются по команде, а не при старте, чтобы контейнер поднимался быстро.

-- SELECT bench.gen_events(2000000);
CREATE OR REPLACE FUNCTION bench.gen_events(n bigint DEFAULT 2000000)
RETURNS bigint LANGUAGE plpgsql AS $$
BEGIN
    DROP TABLE IF EXISTS bench.events;
    CREATE TABLE bench.events (
        id          bigserial PRIMARY KEY,
        user_id     int         NOT NULL,
        seller_id   int         NOT NULL,
        type        text        NOT NULL,
        amount      numeric(12,2) NOT NULL,
        created_at  timestamptz NOT NULL,
        payload     jsonb       NOT NULL
    );
    INSERT INTO bench.events (user_id, seller_id, type, amount, created_at, payload)
    SELECT floor(random() * 100000)::int + 1,
           floor(random() * 500)::int + 1,
           (ARRAY['view','click','add_to_cart','purchase','refund'])[floor(random() * 5)::int + 1],
           round((random() * 5000)::numeric, 2),
           now() - (random() * interval '365 days'),
           jsonb_build_object('src', (ARRAY['web','ios','android'])[floor(random() * 3)::int + 1],
                              'ab',  (random() < 0.5))
    FROM generate_series(1, n);
    ANALYZE bench.events;
    RETURN n;
END $$;

-- SELECT bench.gen_docs(1000000);  -- LIKE против tsvector
CREATE OR REPLACE FUNCTION bench.gen_docs(n bigint DEFAULT 1000000)
RETURNS bigint LANGUAGE plpgsql AS $$
BEGIN
    DROP TABLE IF EXISTS bench.docs;
    CREATE TABLE bench.docs (
        id    bigserial PRIMARY KEY,
        title text NOT NULL,
        body  text NOT NULL
    );
    INSERT INTO bench.docs (title, body)
    SELECT 'Товар ' || i,
           (SELECT string_agg(w, ' ')
            FROM (SELECT (ARRAY['красный','стол','деревянный','кресло','офисный','набор',
                                'кухонный','стул','металлический','полка','настенная','лампа',
                                'светодиодная','ковёр','шерстяной','зеркало','круглое'])
                         [floor(random() * 17)::int + 1] AS w
                  FROM generate_series(1, 30)) t)
    FROM generate_series(1, n) i;
    ANALYZE bench.docs;
    RETURN n;
END $$;
