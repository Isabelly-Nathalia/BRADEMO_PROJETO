import { defineConfig, mergeConfig } from 'vitest/config'
import viteConfig from './vite.config'

export default mergeConfig(
  viteConfig,
  defineConfig({
    test: {
      environment: 'jsdom',
      include: ['tests/unit/**/*.test.ts', 'tests/components/**/*.test.ts'],
      // Por padrão o Vitest devolve CSS vazio; os testes de tokens leem src/styles/*.css.
      css: { include: [/src\/styles\/.+\.css/] },
      restoreMocks: true,
      unstubGlobals: true,
    },
  }),
)
