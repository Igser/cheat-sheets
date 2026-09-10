// Сборка страницы из данных: метаданные + HTML-фрагмент + нужные таблицы стилей.
// Общая точка для витрины (pages/index.astro) и остальных конспектов (pages/[sheet].astro).
import { sheets } from './sheets.js';

const bodies = import.meta.glob('../content/sheets/*.html', { query: '?raw', import: 'default', eager: true });
const styles = import.meta.glob('../styles/**/*.css', { query: '?raw', import: 'default', eager: true });

export function page(slug) {
  const meta = sheets.find((s) => s.slug === slug);
  if (!meta) throw new Error(`Нет записи о странице «${slug}» в src/data/sheets.js`);
  const html = bodies[`../content/sheets/${slug}.html`];
  if (!html) throw new Error(`Нет файла src/content/sheets/${slug}.html`);
  return {
    ...meta,
    css: meta.styles.map((name) => styles[`../styles/${name}`]).join('\n'),
    html,
  };
}
