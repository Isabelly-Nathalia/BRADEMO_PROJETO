// Desempenho (perfil E, F7-T04). Metas definidas antes da medição (plano, F7-T04):
//   JS inicial ≤ 150 KB gzip · LCP de /inicio ≤ 2,5 s (Chromium do perfil E, sem throttle, rede
//   interna). As imagens (≤ 1,5 MB) são verificadas no perfil A (tests/scripts/assets.test.mjs).
// Mede a imagem de produção do front, não o servidor de desenvolvimento. Os números de cada
// execução saem no relatório (anotações) e em docs/metricas.md.
import { gzipSync } from 'node:zlib'
import type { Browser } from '@playwright/test'
import { expect, test } from '../apoio'

const LIMITE_JS_GZIP = 150 * 1024
const LIMITE_LCP_MS = 2_500
const MEDICOES_LCP = 3

const kb = (bytes: number) => `${(bytes / 1024).toFixed(1)} KB`

function anotar(tipo: string, descricao: string) {
  test.info().annotations.push({ type: tipo, description: descricao })
  console.log(`${tipo}: ${descricao}`)
}

test('JS carregado para abrir /inicio ≤ 150 KB gzip', async ({ page }) => {
  const scripts: Array<{ url: string; corpo: Buffer; codificacao: string | undefined }> = []
  page.on('response', async (resposta) => {
    if (resposta.request().resourceType() !== 'script') return
    scripts.push({
      url: new URL(resposta.url()).pathname,
      corpo: await resposta.body(),
      codificacao: (await resposta.allHeaders())['content-encoding'],
    })
  })
  await page.goto('/inicio', { waitUntil: 'networkidle' })
  await expect(page.getByRole('heading', { name: 'Olá!' })).toBeVisible()

  expect(scripts.length).toBeGreaterThan(0)
  const bruto = scripts.reduce((soma, s) => soma + s.corpo.length, 0)
  const gzip = scripts.reduce((soma, s) => soma + gzipSync(s.corpo, { level: 9 }).length, 0)
  const comprimidos = scripts.filter((s) => s.codificacao).length
  anotar('js-inicial', `${scripts.length} arquivos, ${kb(bruto)} sem compressão, ${kb(gzip)} gzip (servidos com compressão: ${comprimidos})`)
  expect(gzip).toBeLessThanOrEqual(LIMITE_JS_GZIP)
})

/** LCP (ms) de uma navegação fria (contexto novo, sem cache). */
async function medirLcp(browser: Browser, baseURL: string) {
  const contexto = await browser.newContext({ baseURL, viewport: { width: 1280, height: 800 } })
  await contexto.addInitScript(() => localStorage.setItem('mm.visitou.v1', '1'))
  const page = await contexto.newPage()
  await page.goto('/inicio')
  await expect(page.locator('.filmes li').first()).toBeVisible()
  const resultado = await page.evaluate(
    () =>
      new Promise<{ lcp: number; fcp: number; elemento: string }>((resolver) => {
        const fcp = performance.getEntriesByName('first-contentful-paint')[0]?.startTime ?? -1
        new PerformanceObserver((lista) => {
          const ultimo = lista.getEntries().at(-1) as PerformanceEntry & { element?: Element | null }
          const el = ultimo.element
          resolver({
            lcp: ultimo.startTime,
            fcp,
            elemento: el ? `${el.tagName.toLowerCase()}${el.className ? '.' + String(el.className).split(' ')[0] : ''}` : '?',
          })
        }).observe({ type: 'largest-contentful-paint', buffered: true })
      }),
  )
  await contexto.close()
  return resultado
}

test('LCP de /inicio ≤ 2,5 s (3 navegações frias)', async ({ browser, baseURL }) => {
  const medicoes = []
  for (let i = 0; i < MEDICOES_LCP; i++) medicoes.push(await medirLcp(browser, baseURL!))
  const lcps = medicoes.map((m) => Math.round(m.lcp))
  anotar(
    'lcp-inicio',
    `${lcps.join(' / ')} ms (FCP ${medicoes.map((m) => Math.round(m.fcp)).join(' / ')} ms; elemento: ${medicoes[0]!.elemento})`,
  )
  expect(Math.max(...lcps)).toBeLessThanOrEqual(LIMITE_LCP_MS)
})
