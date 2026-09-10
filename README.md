# PHP Developer Notes

Библиотека конспектов: 29 тем + витрина `index.html`. Собирается Astro в статические
самодостаточные HTML-страницы — каждая со своим инлайновым CSS, без JS и внешних
запросов, поэтому файл из `dist/` открывается и с диска, и с любого статик-хостинга.

## Команды

| Команда | Что делает |
|---|---|
| `npm install` | поставить зависимости (только Astro) |
| `npm run dev` | локальный сервер с горячей перезагрузкой на `localhost:4321` |
| `npm run build` | собрать сайт в `dist/` |
| `npm run preview` | посмотреть собранный `dist/` |

## Структура

```
src/
  content/sheets/<slug>.html   тело страницы: всё между <body> и </body>
  data/sheets.js               метаданные: title, description, bodyId, список стилей
  styles/base.css              общая таблица стилей (была продублирована в 30 файлах)
  styles/pages/<slug>.css      правила, специфичные для одной страницы
  layouts/Sheet.astro          <head> и каркас документа
  pages/[sheet].astro          единственный маршрут: собирает страницу из данных
```

Сборка настроена в режиме `build.format: 'file'`, поэтому `src/content/sheets/oop.html`
превращается в `dist/oop.html`: существующие ссылки вида `href="oop.html"` и закладки
продолжают работать без правок.

## Как добавить конспект

1. Положить тело страницы в `src/content/sheets/<slug>.html`.
2. Добавить запись в `src/data/sheets.js` (`slug`, `title`, `description`, `author`,
   `robots`, `bodyId: "top"`, `styles: ["base.css"]`).
3. Нужны свои стили — завести `src/styles/pages/<slug>.css` и дописать его в `styles`.
4. Обновить витрину `src/content/sheets/index.html`: карточку в `.catalog`, строку в
   `#map` и счётчики.

Требования к содержанию конспекта — в `PLAN.md`.
