import { defineConfig } from 'vitest/config'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  test: {
    environment: 'happy-dom',
    include: ['tests/unit/**/*.{test,spec}.{js,ts}'],
    exclude: ['node_modules', 'dist', '.vitepress/cache'],
    globals: true,
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      exclude: [
        'node_modules/',
        'tests/',
        '**/*.config.{js,ts}',
        '.vitepress/cache/'
      ]
    }
  },
  resolve: {
    alias: {
      '@': './.vitepress/theme'
    }
  }
})
