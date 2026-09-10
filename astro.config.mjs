import { defineConfig } from 'astro/config';

export default defineConfig({
  // format:'file' — сборка кладёт oop.astro в dist/oop.html, поэтому
  // все внутренние ссылки вида href="oop.html" остаются рабочими,
  // а страницы по-прежнему открываются напрямую с диска.
  build: { format: 'file' },
  // вёрстка конспектов пишется руками — не схлопываем пробелы
  compressHTML: false,
});
