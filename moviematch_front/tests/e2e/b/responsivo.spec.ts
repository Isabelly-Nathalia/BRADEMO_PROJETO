// Layout responsivo em 6 larguras × rotas do MVP (@responsivo). Roda uma vez (no projeto
// "desktop"), mas cada largura cria o próprio contexto: abaixo de 900 px emula um aparelho de
// toque (isMobile), porque o Chromium móvel dá larguras mínimas diferentes a controles de
// formulário (o campo de pesquisa estourava a 375 px só com emulação móvel).
// Verifica comportamento observável, não detalhes de CSS.
import { devices, type Page } from '@playwright/test'
import { expect, test } from '../apoio'

const LARGURAS = [360, 375, 412, 768, 900, 1280] as const
const BREAKPOINT_NAV_TOPO = 900

const ROTAS = [
  { caminho: '/boas-vindas', comNav: false },
  { caminho: '/inicio', comNav: true },
  { caminho: '/pesquisa?q=a', comNav: true },
  { caminho: '/streaming/netflix', comNav: true },
  { caminho: '/filmes/4', comNav: true },
  { caminho: '/questionario/2', comNav: false },
  { caminho: '/questionario/8', comNav: false },
  { caminho: '/sugestoes', comNav: true },
  { caminho: '/rota/inexistente', comNav: true },
] as const

const RESPOSTAS = JSON.stringify({
  versao: 1,
  respostas: { generos: ['Romance'], duracao: '1h30 - 2h', streamings: ['Netflix'], classificacao: null, paises: [], ator: '' },
})

test.beforeEach(async ({ page }, info) => {
  test.skip(info.project.name !== 'desktop', 'larguras definidas pelo próprio teste')
  await page.addInitScript((respostas) => {
    localStorage.setItem('mm.visitou.v1', '1')
    localStorage.setItem('mm.questionario.v1', respostas)
  }, RESPOSTAS)
})

async function abrir(page: Page, caminho: string) {
  await page.goto(caminho)
  await expect(page.locator('#conteudo h1, #conteudo .chamada').first()).toBeVisible()
  // Espera o fim das cargas da API (estado de carregamento some).
  await expect(page.locator('[role="status"]')).toHaveCount(0)
}

/** Elementos interativos visíveis menores que 44×44 px. */
async function alvosPequenos(page: Page) {
  return page.evaluate(() => {
    const visivel = (el: Element) => {
      const b = el.getBoundingClientRect()
      const s = getComputedStyle(el)
      return b.width > 2 && b.height > 2 && s.visibility !== 'hidden' && !el.closest('.visualmente-oculto')
    }
    return [...document.querySelectorAll('a, button, input:not(.visualmente-oculto), label.chip')]
      .filter(visivel)
      .filter((el) => {
        const b = el.getBoundingClientRect()
        return b.width < 44 || b.height < 44
      })
      .map((el) => `${(el.textContent ?? '').trim().slice(0, 20) || el.tagName} ${Math.round(el.getBoundingClientRect().width)}x${Math.round(el.getBoundingClientRect().height)}`)
  })
}

/** Imagens visíveis desenhadas com proporção diferente da original e sem object-fit (distorção). */
async function imagensDistorcidas(page: Page) {
  return page.evaluate(() =>
    [...document.querySelectorAll('img')]
      .filter((img) => img.complete && img.naturalWidth > 0 && img.getBoundingClientRect().width > 2)
      .filter((img) => {
        const b = img.getBoundingClientRect()
        const fit = getComputedStyle(img).objectFit
        const diferenca = Math.abs(b.width / b.height - img.naturalWidth / img.naturalHeight)
        return fit === 'fill' && diferenca > 0.05
      })
      .map((img) => img.getAttribute('src') ?? ''),
  )
}

const TOQUE = devices['Pixel 7']

for (const largura of LARGURAS) {
  test.describe(`${largura}px`, () => {
    const toque = largura < BREAKPOINT_NAV_TOPO
    test.use({
      viewport: { width: largura, height: 800 },
      isMobile: toque,
      hasTouch: toque,
      deviceScaleFactor: toque ? TOQUE.deviceScaleFactor : 1,
      ...(toque ? { userAgent: TOQUE.userAgent } : {}),
    })

    for (const { caminho, comNav } of ROTAS) {
      test(`@responsivo ${largura}px ${caminho}`, async ({ page }) => {
        await abrir(page, caminho)

        // 1. Sem rolagem horizontal involuntária
        const { rolagem, janela } = await page.evaluate(() => ({
          rolagem: document.documentElement.scrollWidth,
          janela: document.documentElement.clientWidth,
        }))
        expect(rolagem, 'largura do conteúdo').toBeLessThanOrEqual(janela)

        // 2. Alvos de toque ≥ 44×44 px
        expect(await alvosPequenos(page), 'alvos menores que 44×44').toEqual([])

        // 3. Imagens sem distorção
        expect(await imagensDistorcidas(page), 'imagens distorcidas').toEqual([])

        // 4. Navegação adequada à largura, sem cobrir o conteúdo
        const nav = page.getByRole('navigation', { name: 'Navegação principal' })
        if (!comNav) {
          await expect(nav).toHaveCount(0)
          return
        }
        await expect(nav).toBeVisible()
        const caixa = (await nav.boundingBox())!
        if (largura >= BREAKPOINT_NAV_TOPO) {
          expect(caixa.y, 'navegação no topo').toBeLessThanOrEqual(1)
          const topoConteudo = (await page.locator('#conteudo').boundingBox())!.y
          expect(topoConteudo, 'conteúdo abaixo do cabeçalho').toBeGreaterThanOrEqual(caixa.y + caixa.height - 1)
        } else {
          expect(caixa.y + caixa.height, 'navegação no rodapé').toBeGreaterThanOrEqual(799)
          await page.evaluate(() => window.scrollTo(0, document.documentElement.scrollHeight))
          const fimConteudo = await page.evaluate(() => {
            const filhos = [...document.querySelectorAll('#conteudo *')].filter((el) => el.getBoundingClientRect().height > 0)
            return Math.max(...filhos.map((el) => el.getBoundingClientRect().bottom))
          })
          const navDepois = (await nav.boundingBox())!
          expect(fimConteudo, 'conteúdo não fica atrás da barra inferior').toBeLessThanOrEqual(navDepois.y + 1)
        }
      })
    }

    test(`@responsivo ${largura}px detalhe: pôster em retrato sem distorção e layout adequado`, async ({ page }) => {
      await abrir(page, '/filmes/4')
      const poster = (await page.locator('.detalhe .poster').boundingBox())!
      const proporcao = poster.height / poster.width
      expect(proporcao, 'pôster em retrato 2:3').toBeGreaterThan(1.4)
      expect(proporcao, 'pôster em retrato 2:3').toBeLessThan(1.6)
      const titulo = (await page.locator('.detalhe h1').boundingBox())!
      if (largura >= 768) {
        expect(titulo.x, 'informações à direita do pôster').toBeGreaterThanOrEqual(poster.x + poster.width - 1)
      } else {
        expect(titulo.y, 'informações abaixo do pôster').toBeGreaterThanOrEqual(poster.y + poster.height - 1)
      }
    })
  })
}
