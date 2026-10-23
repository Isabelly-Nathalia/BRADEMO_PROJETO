import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { proxyApiDev } from './scripts/proxy-dev.mjs'

// MM_API_UPSTREAM só é lido aqui (Node); não entra no bundle do navegador.
const api = proxyApiDev({ upstream: process.env.MM_API_UPSTREAM })

export default defineConfig({
  plugins: [vue(), api.plugin],
  server: { proxy: api.proxy },
  preview: { proxy: api.proxy },
})
