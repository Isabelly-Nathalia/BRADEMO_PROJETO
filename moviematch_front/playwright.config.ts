import { defineConfig, devices } from '@playwright/test'

// Roda dentro do container oficial do Playwright (perfis B/E, docker/compose.yml), contra a
// imagem de produção do front e o mock da API. BASE_URL vem do Compose.
export default defineConfig({
  testDir: 'tests/e2e',
  outputDir: 'test-results',
  forbidOnly: true,
  retries: 0,
  workers: 2,
  reporter: [['list']],
  timeout: 30_000,
  expect: { timeout: 10_000 },
  use: {
    baseURL: process.env.BASE_URL ?? 'http://127.0.0.1:5173',
    trace: 'retain-on-failure',
    screenshot: 'only-on-failure',
  },
  projects: [
    { name: 'celular', use: { ...devices['Pixel 7'] } },
    { name: 'desktop', use: { ...devices['Desktop Chrome'], viewport: { width: 1280, height: 800 } } },
  ],
})
