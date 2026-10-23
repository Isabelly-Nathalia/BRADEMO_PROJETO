// Resiliência (perfil E, F7-T01): lentidão, timeout, API parada e retomada, concorrência.
// Cenários por requisição via cabeçalho x-mock-cenario (o proxy repassa). Parar e retomar a API
// usam a porta de controle do mock (MOCK_CONTROLE): por isso o perfil E roda com 1 worker.
import type { Page } from '@playwright/test'
import { expect, test } from '../apoio'

const MOCK = process.env.MOCK ?? 'http://127.0.0.1:8081'
const MOCK_CONTROLE = process.env.MOCK_CONTROLE ?? 'http://127.0.0.1:8082'

const AVISO_LENTIDAO = 'O servidor pode estar iniciando. Isso pode levar alguns segundos.'
const ERRO_TIMEOUT = 'O servidor demorou demais para responder.'
const ERRO_SERVIDOR = 'O servidor encontrou um erro.'

async function controlar(comando: '/__parar' | '/__retomar') {
  const resposta = await fetch(`${MOCK_CONTROLE}${comando}`, { method: 'POST' })
  expect(resposta.status, `mock ${comando}`).toBe(200)
}

async function requisicoesRecebidas(): Promise<string[]> {
  const lista = (await (await fetch(`${MOCK}/__requisicoes`)).json()) as Array<{ url: string }>
  return lista.map((r) => r.url)
}

/** Instante (ms, relógio do teste) em que o navegador pede a primeira rota da API. */
function inicioDaApi(page: Page): Promise<number> {
  return new Promise((resolver) => {
    const ouvir = (pedido: { url(): string }) => {
      if (new URL(pedido.url()).pathname.startsWith('/api/')) {
        page.off('request', ouvir)
        resolver(Date.now())
      }
    }
    page.on('request', ouvir)
  })
}

test.describe('API lenta (6 s)', () => {
  test.use({ extraHTTPHeaders: { 'x-mock-cenario': 'lento:6000' } })

  test('mostra o aviso de lentidão depois de 5 s e então o conteúdo', async ({ page }) => {
    const inicio = inicioDaApi(page)
    await page.goto('/streaming/netflix')
    await expect(page.getByText('Carregando…')).toBeVisible()
    await expect(page.getByText(AVISO_LENTIDAO)).toBeVisible({ timeout: 7_000 })
    const aviso = Date.now() - (await inicio)
    expect(aviso, 'aviso não aparece antes de 5 s').toBeGreaterThanOrEqual(5_000)
    expect(aviso, 'aviso aparece logo depois de 5 s').toBeLessThan(6_000)
    await expect(page.locator('.grade li')).toHaveCount(3, { timeout: 5_000 })
    await expect(page.getByText(AVISO_LENTIDAO)).toHaveCount(0)
  })
})

for (const cenario of ['lento:32000', 'pendurado']) {
  test.describe(`API ${cenario}`, () => {
    test.use({ extraHTTPHeaders: { 'x-mock-cenario': cenario } })

    test('o cliente desiste aos 30 s (± 1) com erro de timeout e "Tentar novamente"', async ({ page }) => {
      test.setTimeout(60_000)
      const inicio = inicioDaApi(page)
      await page.goto('/streaming/netflix')
      await expect(page.getByText(ERRO_TIMEOUT)).toBeVisible({ timeout: 35_000 })
      const decorrido = Date.now() - (await inicio)
      expect(decorrido).toBeGreaterThanOrEqual(29_000)
      expect(decorrido).toBeLessThanOrEqual(31_000)
      await expect(page.getByRole('button', { name: 'Tentar novamente' })).toBeVisible()
    })
  })
}

test.describe('API parada', () => {
  test.afterEach(async () => {
    // Nunca deixa a API parada para os testes seguintes, mesmo se este falhar.
    await controlar('/__retomar')
  })

  test('mostra erro; com a API de volta, "Tentar novamente" carrega sem recarregar a página', async ({ page }) => {
    await controlar('/__parar')
    await page.goto('/streaming/netflix')
    // O proxy recebe conexão recusada e responde 502.
    await expect(page.getByText(ERRO_SERVIDOR)).toBeVisible()
    await expect(page.locator('.grade li')).toHaveCount(0)

    // Marca no documento: some se a página for recarregada.
    await page.evaluate(() => ((window as unknown as { __semRecarga: boolean }).__semRecarga = true))
    let recargas = 0
    page.on('load', () => recargas++)

    await controlar('/__retomar')
    await page.getByRole('button', { name: 'Tentar novamente' }).click()
    await expect(page.locator('.grade li')).toHaveCount(3)
    expect(recargas).toBe(0)
    expect(await page.evaluate(() => (window as unknown as { __semRecarga?: boolean }).__semRecarga)).toBe(true)
  })
})

test.describe('concorrência', () => {
  test.use({ extraHTTPHeaders: { 'x-mock-cenario': 'lento:2000' } })

  test('5 telas pedindo o catálogo enquanto ele carrega geram uma única requisição', async ({ page }) => {
    await page.addInitScript(() => {
      localStorage.setItem('mm.visitou.v1', '1')
      localStorage.setItem(
        'mm.questionario.v1',
        JSON.stringify({
          versao: 1,
          respostas: { generos: ['Drama'], duracao: '3h+', streamings: ['Netflix'], classificacao: null, paises: [], ator: '' },
        }),
      )
    })
    await fetch(`${MOCK}/__requisicoes`, { method: 'DELETE' })

    // Primeira tela pela URL; as outras 4 por navegação interna (mesma instância do app),
    // todas antes de o catálogo (2 s) chegar.
    await page.goto('/filmes/1')
    await expect(page.getByText('Carregando…')).toBeVisible()
    for (const caminho of ['/filmes/2', '/sugestoes', '/filmes/3', '/filmes/4']) {
      await page.evaluate((destino) => {
        history.pushState({}, '', destino)
        dispatchEvent(new PopStateEvent('popstate'))
      }, caminho)
      await expect(page).toHaveURL(caminho)
    }
    await expect(page.getByRole('heading', { level: 1 })).toHaveText('Galáxia Esquecida', { timeout: 15_000 })

    const catalogo = (await requisicoesRecebidas()).filter((url) => url === '/filmes')
    expect(catalogo).toHaveLength(1)
  })
})
