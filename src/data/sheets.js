// Метаданные страниц. Тело каждой страницы — src/content/sheets/<slug>.html,
// стили — src/styles/. Добавляя конспект: положить фрагмент в content/sheets/
// и добавить сюда запись; маршрут и вёрстка головы соберутся сами.

export const sheets = [
  {
    "slug": "ai",
    "title": "AI и LLM для PHP-разработчиков — конспект Junior / Middle / Senior",
    "description": "Конспект по AI и LLM для PHP-разработчиков: Junior, Middle, Senior. Messages API, промптинг, structured output, tool use, агенты, мультиагентные системы, RAG, prompt caching, стоимость, безопасность, вопросы для собеседования.",
    "author": "PHP Tech Lead notes",
    "robots": "index, follow",
    "bodyId": "top",
    "styles": [
      "base.css"
    ]
  },
  {
    "slug": "algorithms",
    "title": "Алгоритмы для live-coding на PHP — конспект Junior / Middle / Senior",
    "description": "Конспект по алгоритмам для live-coding на PHP: Junior, Middle, Senior. Протокол решения задачи на собеседовании, оценка сложности, хеш-таблицы и префиксные суммы, два указателя и скользящее окно, бинарный поиск и поиск по ответу, сортировка и интервалы, рекурсия и бэктрекинг, динамическое программирование, обходы графов, куча и топ-K, задачи на строки, компромиссы время-память, граничные случаи, коммуникация во время решения, план подготовки.",
    "author": "PHP Tech Lead notes",
    "robots": "index, follow",
    "bodyId": "top",
    "styles": [
      "base.css"
    ]
  },
  {
    "slug": "async",
    "title": "Асинхронный PHP и реальное время — конспект Junior / Middle / Senior",
    "description": "Конспект по асинхронному PHP и реальному времени для разработчиков: Junior, Middle, Senior. Модель shared-nothing и её цена, фоновые задачи и воркеры, supervisor и cron, доставка данных в браузер (polling, long polling, SSE, WebSocket), долгоживущие процессы на RoadRunner, Swoole и FrankenPHP, утечки состояния между запросами, Fibers и корутины, конкурентные исходящие запросы, Centrifugo и Mercure, аутентификация и каналы, масштабирование соединений, переподключения и восстановление состояния, эксплуатация воркеров и мягкая перезагрузка, вопросы для собеседования.",
    "author": "PHP Tech Lead notes",
    "robots": "index, follow",
    "bodyId": "top",
    "styles": [
      "base.css"
    ]
  },
  {
    "slug": "company-analysis",
    "title": "Как анализировать компанию и вакансию — пошаговая шпаргалка",
    "description": "Практическая шпаргалка по анализу компании и вакансии: бизнес-модель, устойчивость, команда, отзывы, красные флаги, вопросы на собеседовании и оценка оффера.",
    "author": "PHP Tech Lead notes",
    "robots": "index, follow",
    "bodyId": "top",
    "styles": [
      "pages/company-analysis.css"
    ]
  },
  {
    "slug": "data-structures",
    "title": "Структуры данных для PHP-разработчиков — конспект Junior / Middle / Senior",
    "description": "Конспект по структурам данных для PHP-разработчиков: Junior, Middle, Senior. Массивы, списки, хеш-таблицы, деревья, графы, кучи, SPL, вероятностные структуры, вопросы для собеседования.",
    "author": "PHP Tech Lead notes",
    "robots": "index, follow",
    "bodyId": "top",
    "styles": [
      "base.css"
    ]
  },
  {
    "slug": "design-patterns",
    "title": "Паттерны проектирования — конспект Junior / Middle / Senior",
    "description": "Конспект по паттернам проектирования для PHP-разработчиков: Junior, Middle, Senior. Зачем нужны паттерны и когда они вредят, классификация GoF, порождающие паттерны, фабричный метод и абстрактная фабрика, строитель, прототип, одиночка и его альтернативы, структурные паттерны, адаптер, фасад, декоратор, заместитель, компоновщик, мост, приспособленец, поведенческие паттерны, стратегия, шаблонный метод, состояние, команда, наблюдатель, посредник, цепочка обязанностей, итератор, посетитель, хранитель, интерпретатор, паттерн против возможности языка, замыкания и перечисления вместо классов, паттерны внутри Symfony, Laravel и Doctrine, выбор паттерна по оси изменения, цена абстракции и правило трёх, рефакторинг к паттернам и обратно, паттерны корпоративных приложений, репозиторий и unit of work, паттерны распределённых систем, антипаттерны применения, вопросы для собеседования.",
    "author": "PHP Tech Lead notes",
    "robots": "index, follow",
    "bodyId": "top",
    "styles": [
      "base.css"
    ]
  },
  {
    "slug": "docker",
    "title": "Docker — конспект Junior / Middle / Senior",
    "description": "Конспект по Docker для PHP-разработчиков: Junior, Middle, Senior. Модель Docker и отличие от виртуальной машины, образы, слои и контейнеры, Dockerfile и его инструкции, кэш сборки и порядок слоёв, запуск контейнера, порты, тома и переменные окружения, Docker Compose для локальной разработки, многоступенчатая сборка и размер образа, PHP-FPM и CLI в контейнере, расширения и opcache, entrypoint и PID 1, сигналы и корректная остановка, сети и тома, конфигурация и секреты, build args и их следы в образе, healthcheck и порядок запуска сервисов, BuildKit и кэш в CI, воспроизводимость сборки, безопасность образов и непривилегированный пользователь, сканирование уязвимостей, реестр и стратегия тегов, ресурсы и лимиты, OOM и рестарты, драйверы логов, отладка контейнеров, оркестрация и когда нужен Kubernetes, антипаттерны, вопросы для собеседования.",
    "author": "PHP Tech Lead notes",
    "robots": "index, follow",
    "bodyId": "top",
    "styles": [
      "base.css"
    ]
  },
  {
    "slug": "fintech",
    "title": "Финтех и платёжные системы — конспект Junior / Middle / Senior",
    "description": "Конспект по финтеху и платёжным системам для разработчиков: Junior, Middle, Senior. Деньги в коде и минимальные единицы, округление и распределение остатка, участники платежа и роль эквайера, жизненный цикл платежа, авторизация и списание, идемпотентность платёжных запросов, вебхуки провайдера и проверка подписи, неизвестный результат операции, двойная запись и ledger, проводки и балансы, гонки при списании средств, транзакции и блокировки, outbox и надёжная доставка событий, сверка с провайдером и расхождения, возвраты, chargeback и споры, рекуррентные платежи, токенизация карт и 3-D Secure, интеграция с платёжным провайдером, таймауты и повторы, мультипровайдерная маршрутизация и saga, антифрод и скоринг, KYC и AML, PCI DSS и снижение зоны соответствия, аудит и неизменяемый журнал, закрытие периода, метрики платёжного контура и денежные инциденты, вопросы для собеседования.",
    "author": "PHP Tech Lead notes",
    "robots": "index, follow",
    "bodyId": "top",
    "styles": [
      "base.css"
    ]
  },
  {
    "slug": "git",
    "title": "Git и командная работа — конспект Junior / Middle / Senior",
    "description": "Конспект по Git и командной работе для PHP-разработчиков: Junior, Middle, Senior. Модель данных Git, ежедневный цикл, ветки и слияния, хорошие коммиты, rebase против merge, отмена изменений и reflog, стратегии ветвления и релизы, pull request и код-ревью, конфликты, хуки и защита веток, bisect и археология кода, монорепо, инциденты и откаты, договорённости команды, вопросы для собеседования.",
    "author": "PHP Tech Lead notes",
    "robots": "index, follow",
    "bodyId": "top",
    "styles": [
      "base.css"
    ]
  },
  {
    "slug": "http-api",
    "title": "HTTP и дизайн API для PHP-разработчиков — конспект Junior / Middle / Senior",
    "description": "Конспект по HTTP и дизайну API для PHP-разработчиков: Junior, Middle, Senior. Методы и коды ответов, заголовки, REST-контракт, куки и HTTPS, версионирование, пагинация, идемпотентность и ETag, формат ошибок, HTTP-кэширование, OAuth 2.0 и JWT, rate limiting и CORS, REST против GraphQL и gRPC, OpenAPI, вебхуки, долгие операции, производительность и безопасность API, вопросы для собеседования.",
    "author": "PHP Tech Lead notes",
    "robots": "index, follow",
    "bodyId": "top",
    "styles": [
      "base.css"
    ]
  },
  {
    "slug": "index",
    "title": "PHP Developer Notes — конспекты и шпаргалки",
    "description": "Систематизированные конспекты для PHP-разработчиков: PHP, ООП, Symfony, Laravel, SQL, NoSQL и поиск, производительность и профилирование, асинхронный PHP и реальное время, структуры данных, алгоритмы для live-coding, system design, HTTP и дизайн API, тестирование, безопасность, паттерны и архитектура кода, брокеры сообщений, наблюдаемость, Git и командная работа, инфраструктура и деплой, AI, новые версии языка, тимлидство и подготовка к собеседованию.",
    "author": "PHP Tech Lead notes",
    "robots": "index, follow",
    "bodyId": null,
    "styles": [
      "pages/index.css"
    ]
  },
  {
    "slug": "infrastructure",
    "title": "Инфраструктура и деплой для PHP-разработчиков — конспект Junior / Middle / Senior",
    "description": "Конспект по инфраструктуре и деплою для PHP-разработчиков: Junior, Middle, Senior. Linux и systemd, nginx и PHP-FPM, Docker и compose, production-образ, CI/CD, деплой без простоя, миграции в пайплайне, секреты, воркеры и cron, логи и метрики, Kubernetes, расчёт ресурсов, бэкапы, IaC, безопасность инфраструктуры, вопросы для собеседования.",
    "author": "PHP Tech Lead notes",
    "robots": "index, follow",
    "bodyId": "top",
    "styles": [
      "base.css"
    ]
  },
  {
    "slug": "kubernetes",
    "title": "Kubernetes — конспект Junior / Middle / Senior",
    "description": "Конспект по Kubernetes для разработчиков: Junior, Middle, Senior. Зачем нужен оркестратор и его цена, устройство кластера и control plane, основные объекты API, под и его жизненный цикл, init-контейнеры и sidecar, Deployment и ReplicaSet, Service и Ingress, сеть и DNS кластера, ConfigMap и Secret, пробы liveness, readiness и startup, requests и limits, классы QoS, OOMKilled и троттлинг процессора, обновления RollingUpdate, откат релиза, canary и blue-green, PersistentVolume и StatefulSet, Job, CronJob и DaemonSet, воркеры очередей и корректная остановка, автомасштабирование HPA и KEDA, PodDisruptionBudget, планирование подов, affinity и taints, RBAC и ServiceAccount, securityContext и NetworkPolicy, отладка в кластере и типовые симптомы, Helm, Kustomize и GitOps, managed против self-hosted, антипаттерны, вопросы для собеседования.",
    "author": "PHP Tech Lead notes",
    "robots": "index, follow",
    "bodyId": "top",
    "styles": [
      "base.css"
    ]
  },
  {
    "slug": "laravel",
    "title": "Laravel для PHP-разработчиков — конспект Junior / Middle / Senior",
    "description": "Конспект по Laravel для PHP-разработчиков: Junior, Middle, Senior. Роутинг, Eloquent, валидация, контейнер, очереди, события, кэш, тестирование, производительность, безопасность, деплой, вопросы для собеседования.",
    "author": "PHP Tech Lead notes",
    "robots": "index, follow",
    "bodyId": "top",
    "styles": [
      "base.css"
    ]
  },
  {
    "slug": "leadership",
    "title": "Тимлидство для инженеров — конспект новый лид / опытный лид / зрелость",
    "description": "Конспект по тимлидству для PHP-разработчиков: переход в роль, встречи один на один, делегирование, обратная связь, планирование и оценки, приоритеты и работа с продуктом, защита инженерных задач, развитие людей и грейды, найм и онбординг, дежурство и инциденты, сложные разговоры, культура команды, работа с руководством, рост команды, выгорание и собственная устойчивость.",
    "author": "PHP Tech Lead notes",
    "robots": "index, follow",
    "bodyId": "top",
    "styles": [
      "base.css"
    ]
  },
  {
    "slug": "messaging",
    "title": "Брокеры сообщений и очереди — конспект Junior / Middle / Senior",
    "description": "Конспект по брокерам сообщений для PHP-разработчиков: Junior, Middle, Senior. Зачем очереди, базовые понятия, Symfony Messenger и Laravel Queues, RabbitMQ и обменники, семантика доставки и идемпотентность, outbox, повторы и DLQ, Kafka и партиции, выбор брокера, порядок сообщений, контракты и версионирование, паттерны обмена, эксплуатация и мониторинг лага, отказы и реплей, антипаттерны, вопросы для собеседования.",
    "author": "PHP Tech Lead notes",
    "robots": "index, follow",
    "bodyId": "top",
    "styles": [
      "base.css"
    ]
  },
  {
    "slug": "new-in-php",
    "title": "Что нового в PHP — от 7.4 до 8.6",
    "description": "Что нового в PHP 7.4, 8.0, 8.1, 8.2, 8.3, 8.4, 8.5 и 8.6: типизированные свойства, стрелочные функции, атрибуты, именованные аргументы, match, enum, readonly, файберы, хуки свойств, асимметричная видимость, оператор конвейера, clone with. Обратно несовместимые изменения, deprecations, план миграции.",
    "author": "PHP Tech Lead notes",
    "robots": "index, follow",
    "bodyId": "top",
    "styles": [
      "base.css",
      "pages/new-in-php.css"
    ]
  },
  {
    "slug": "nosql",
    "title": "NoSQL и поиск — конспект Junior / Middle / Senior",
    "description": "Конспект по NoSQL и поиску для PHP-разработчиков: Junior, Middle, Senior. Классы хранилищ и модели данных, документные базы и MongoDB, ключ-значение и Redis, полнотекстовый поиск и инвертированный индекс, Postgres как первое решение (JSONB, tsvector, pg_trgm), Elasticsearch на практике, анализаторы и релевантность BM25, фасеты и автодополнение, синхронизация поиска с базой, аналитические хранилища и ClickHouse, OLTP против OLAP, когда не брать Postgres, шардирование и ключ раздела, согласованность и CAP, цена второго хранилища, вопросы для собеседования.",
    "author": "PHP Tech Lead notes",
    "robots": "index, follow",
    "bodyId": "top",
    "styles": [
      "base.css"
    ]
  },
  {
    "slug": "observability",
    "title": "Наблюдаемость и мониторинг — конспект Junior / Middle / Senior",
    "description": "Конспект по наблюдаемости для PHP-разработчиков: Junior, Middle, Senior. Логи, метрики и трассировки, структурированное логирование, типы метрик и кардинальность, распространение контекста, инструментирование приложения, OpenTelemetry, дашборды RED и USE, алерты без шума, SLI и SLO, бюджет ошибок, отладка инцидента по телеметрии, трекинг ошибок и профилирование в проде, конвейер телеметрии, сэмплирование и стоимость, вопросы для собеседования.",
    "author": "PHP Tech Lead notes",
    "robots": "index, follow",
    "bodyId": "top",
    "styles": [
      "base.css"
    ]
  },
  {
    "slug": "oop",
    "title": "ООП в PHP — конспект Junior / Middle / Senior",
    "description": "Конспект по ООП в PHP для разработчиков: Junior, Middle, Senior. Инкапсуляция и состояние объекта, интерфейсы против абстрактных классов, наследование и композиция, трейты и статика, типизация свойств и вариантность, обобщённые типы через статический анализ, иммутабельность и readonly, объекты-значения, идентичность и равенство, клонирование, магические методы и их цена, исключения как часть контракта, стандартные интерфейсы Stringable, Countable, IteratorAggregate и JsonSerializable, инварианты и невозможные состояния, связанность и закон Деметры, рефлексия и атрибуты, эволюция публичного API и обратная совместимость, вопросы для собеседования.",
    "author": "PHP Tech Lead notes",
    "robots": "index, follow",
    "bodyId": "top",
    "styles": [
      "base.css"
    ]
  },
  {
    "slug": "orm",
    "title": "ORM и Doctrine — конспект Junior / Middle / Senior",
    "description": "Конспект по ORM и Doctrine для PHP-разработчиков: Junior, Middle, Senior. Зачем нужен слой отображения, Data Mapper против Active Record, маппинг сущностей атрибутами, жизненный цикл EntityManager, репозитории и запросы, проблема N+1, identity map и unit of work, состояния сущности, ассоциации и владелец связи, ленивая загрузка и прокси, DQL и QueryBuilder, гидрация и DTO, транзакции и блокировки, миграции схемы, агрегаты и границы загрузки, производительность и кэши Doctrine, пакетная обработка больших объёмов, кастомные типы и наследование сущностей, тестирование с ORM, когда выходить в чистый SQL, Eloquent против Doctrine, вопросы для собеседования.",
    "author": "PHP Tech Lead notes",
    "robots": "index, follow",
    "bodyId": "top",
    "styles": [
      "base.css"
    ]
  },
  {
    "slug": "patterns",
    "title": "Паттерны и архитектура кода — конспект Junior / Middle / Senior",
    "description": "Конспект по паттернам и архитектуре кода для PHP-разработчиков: Junior, Middle, Senior. Связность и связанность, SOLID, базовые и продвинутые паттерны, антипаттерны и запахи кода, слои приложения, композиция вместо наследования, тактический DDD, гексагональная архитектура, разделение чтения и записи, рефакторинг, модульные границы, технический долг, работа с легаси, цена абстракции, вопросы для собеседования.",
    "author": "PHP Tech Lead notes",
    "robots": "index, follow",
    "bodyId": "top",
    "styles": [
      "base.css"
    ]
  },
  {
    "slug": "performance",
    "title": "Производительность и профилирование — конспект Junior / Middle / Senior",
    "description": "Конспект по производительности и профилированию для PHP-разработчиков: Junior, Middle, Senior. Перцентили вместо среднего, где уходит время, измерение вместо догадок, N+1 и запросы к базе, память и генераторы, профилировщики Xdebug, Excimer, XHProf и Blackfire, чтение flame graph, кэш на уровне приложения и защита от лавины, OPcache, preload и JIT, настройка FPM, нагрузочное тестирование, бюджеты производительности, убрать работу с горячего пути, ёмкость и стоимость, борьба с регрессиями, вопросы для собеседования.",
    "author": "PHP Tech Lead notes",
    "robots": "index, follow",
    "bodyId": "top",
    "styles": [
      "base.css"
    ]
  },
  {
    "slug": "php",
    "title": "PHP для разработчиков — конспект Junior / Middle / Senior",
    "description": "Конспект по PHP для разработчиков: Junior, Middle, Senior. Типы и сравнения, ООП, исключения, Composer и PSR, генераторы, память и copy-on-write, тесты и статический анализ, безопасность, производительность, FPM и opcache, вопросы для собеседования.",
    "author": "PHP Tech Lead notes",
    "robots": "index, follow",
    "bodyId": "top",
    "styles": [
      "base.css"
    ]
  },
  {
    "slug": "security",
    "title": "Безопасность веб-приложений для PHP-разработчиков — конспект Junior / Middle / Senior",
    "description": "Конспект по безопасности веб-приложений для PHP-разработчиков: Junior, Middle, Senior. Модель угроз, инъекции, XSS и CSP, CSRF, аутентификация и пароли, загрузка файлов, авторизация и IDOR, прикладная криптография, секреты, SSRF и десериализация, зависимости и цепочка поставки, логирование и обнаружение, threat modeling, безопасность в CI, изоляция данных, реагирование на инциденты, вопросы для собеседования.",
    "author": "PHP Tech Lead notes",
    "robots": "index, follow",
    "bodyId": "top",
    "styles": [
      "base.css"
    ]
  },
  {
    "slug": "soft-skills",
    "title": "Софт-скиллы и собеседование — Senior PHP Developer",
    "description": "Софт-скиллы и подготовка к собеседованию Senior PHP Developer: что рекрутер хочет услышать за каждым вопросом, структура ответа, готовые формулировки, планы на пять лет, самый сложный кейс по STAR, конфликт в команде, работа с AI-инструментами, переработки и дежурства, увольнение, гэпы, выгорание, достижения в цифрах, вопросы работодателю, переговоры о деньгах и оффере, тестовое задание, live-coding, системный дизайн, просьба о фидбеке, red flags и шпаргалка.",
    "author": "PHP Tech Lead notes",
    "robots": "index, follow",
    "bodyId": "top",
    "styles": [
      "base.css",
      "pages/soft-skills.css"
    ]
  },
  {
    "slug": "sql",
    "title": "Базы данных для PHP-разработчиков — конспект Junior / Middle / Senior",
    "description": "Конспект по базам данных для PHP-разработчиков: Junior, Middle, Senior. SQL, индексы, транзакции, PDO, ORM, масштабирование, вопросы для собеседования.",
    "author": "PHP Tech Lead notes",
    "robots": "index, follow",
    "bodyId": "top",
    "styles": [
      "base.css"
    ]
  },
  {
    "slug": "symfony",
    "title": "Symfony для PHP-разработчиков — конспект Junior / Middle / Senior",
    "description": "Конспект по Symfony для PHP-разработчиков: Junior, Middle, Senior. HttpKernel и события, роутинг и контроллеры, контейнер и autowiring, Doctrine, формы и валидация, Security, Messenger, кэш, тесты, профайлер, производительность, деплой, вопросы для собеседования.",
    "author": "PHP Tech Lead notes",
    "robots": "index, follow",
    "bodyId": "top",
    "styles": [
      "base.css"
    ]
  },
  {
    "slug": "system-design",
    "title": "System Design для PHP-разработчиков — конспект Junior / Middle / Senior",
    "description": "Конспект по System Design для PHP-разработчиков: Junior, Middle, Senior. Метод разбора задачи, требования и инварианты, оценка нагрузки, контракт API, данные и консистентность, кэш, очереди и outbox, масштабирование, надёжность, наблюдаемость, границы сервисов, миграции без простоя, SLO, шесть разобранных кейсов и вопросы для собеседования.",
    "author": "PHP Tech Lead notes",
    "robots": "index, follow",
    "bodyId": "top",
    "styles": [
      "base.css"
    ]
  },
  {
    "slug": "testing",
    "title": "Тестирование для PHP-разработчиков — конспект Junior / Middle / Senior",
    "description": "Конспект по тестированию для PHP-разработчиков: Junior, Middle, Senior. PHPUnit и структура теста, что тестировать и что нет, тестовые двойники, интеграционные и HTTP-тесты, тестирование внешних интеграций, время и случайность, тесты на легаси, TDD, тесты в CI и борьба с флаки, стратегия покрытия, мутационное тестирование, нагрузочные тесты, вопросы для собеседования.",
    "author": "PHP Tech Lead notes",
    "robots": "index, follow",
    "bodyId": "top",
    "styles": [
      "base.css"
    ]
  }
];
