import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';

export default defineConfig({
  // Сайт живёт на GitHub Pages в подпапке репозитория. Адрес нужен sitemap,
  // canonical и og:url; base — чтобы в них попадала сама подпапка.
  // Внутренние ссылки в конспектах остаются относительными, поэтому
  // страницы по-прежнему открываются и напрямую с диска.
  site: 'https://igser.github.io/cheat-sheets/',
  base: '/cheat-sheets',
  // format:'file' — сборка кладёт oop.astro в dist/oop.html, поэтому
  // все внутренние ссылки вида href="oop.html" остаются рабочими,
  // а страницы по-прежнему открываются напрямую с диска.
  build: { format: 'file' },
  // вёрстка конспектов пишется руками — не схлопываем пробелы
  compressHTML: false,
  integrations: [
    sitemap({
      // Sitemap не знает про build.format:'file' и отдаёт адреса без расширения.
      // Приводим их к реальным файлам, чтобы карта совпадала с canonical.
      serialize: (item) => ({
        ...item,
        url: item.url.endsWith('/') ? `${item.url}index.html` : `${item.url}.html`,
      }),
    }),
  ],
});
