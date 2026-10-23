import pluginVue from 'eslint-plugin-vue'
import { defineConfigWithVueTs, vueTsConfigs } from '@vue/eslint-config-typescript'

const mensagemStorage = 'Acesse o armazenamento do navegador só pelos composables (src/composables/).'

export default defineConfigWithVueTs(
  {
    ignores: ['dist/**', 'node_modules/**', '.npm-cache/**', 'test-results/**', 'playwright-report/**', 'tests/lint/**'],
  },
  pluginVue.configs['flat/recommended'],
  vueTsConfigs.recommended,
  {
    rules: {
      // Dados da API são exibidos; HTML vindo de fora nunca é interpretado.
      'vue/no-v-html': 'error',
    },
  },
  {
    files: ['src/**/*.{ts,vue}'],
    ignores: ['src/composables/**'],
    rules: {
      'no-restricted-globals': [
        'error',
        { name: 'localStorage', message: mensagemStorage },
        { name: 'sessionStorage', message: mensagemStorage },
      ],
      'no-restricted-properties': [
        'error',
        { object: 'window', property: 'localStorage', message: mensagemStorage },
        { object: 'window', property: 'sessionStorage', message: mensagemStorage },
        { object: 'globalThis', property: 'localStorage', message: mensagemStorage },
        { object: 'globalThis', property: 'sessionStorage', message: mensagemStorage },
      ],
    },
  },
)
