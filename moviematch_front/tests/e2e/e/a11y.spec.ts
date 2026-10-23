// Acessibilidade (perfil E, F7-T02): axe em todas as rotas e estados, em largura de desktop e de
// celular (a navegação muda de lugar), e o questionário completo só pelo teclado.
// Critério do plano: 0 violações `serious` ou `critical`.
import AxeBuilder from '@axe-core/playwright'
import type { Page } from '@playwright/test'
import { expect, test } from '../apoio'

const RESPOSTAS = JSON.stringify({
  versao: 1,
  respostas: { generos: ['Romance'], duracao: '1h30 - 2h', streamings: ['Netflix'], classificacao: null, paises: [], ator: '' },
})

const ROTAS_COM_API = ['/inicio', '/pesquisa?q=a', '/streaming/netflix', '/filmes/4', '/sugestoes']
const ROTAS_SEM_API = [
  '/boas-vindas',
  '/pesquisa',
  ...[1, 2, 3, 4, 5, 6, 7, 8].map((passo) => `/questionario/${passo}`),
  '/rota/inexistente',
]

const ESTADOS = [
  { estado: 'sucesso', cenario: 'normal', rotas: [...ROTAS_COM_API, ...ROTAS_SEM_API] },
  { estado: 'vazio', cenario: 'vazio', rotas: ROTAS_COM_API },
  { estado: 'erro', cenario: 'http-500', rotas: ROTAS_COM_API },
] as const

/** Violações graves (serious/critical), resumidas para a mensagem do teste. */
async function violacoesGraves(page: Page) {
  const { violations } = await new AxeBuilder({ page }).analyze()
  return violations
    .filter((v) => v.impact === 'serious' || v.impact === 'critical')
    .map((v) => `${v.impact} ${v.id}: ${v.nodes.map((n) => n.target.join(' ')).join(' | ')}`)
}

async function semCarregamento(page: Page) {
  await expect(page.locator('#conteudo')).toBeVisible()
  await expect(page.locator('[role="status"]')).toHaveCount(0)
}

for (const largura of [1280, 375]) {
  for (const { estado, cenario, rotas } of ESTADOS) {
    test.describe(`axe ${largura}px, ${estado}`, () => {
      test.use({ viewport: { width: largura, height: 800 }, extraHTTPHeaders: { 'x-mock-cenario': cenario } })
      test.beforeEach(async ({ page }) => {
        await page.addInitScript((respostas) => {
          localStorage.setItem('mm.visitou.v1', '1')
          localStorage.setItem('mm.questionario.v1', respostas)
        }, RESPOSTAS)
      })

      for (const rota of rotas) {
        test(`${rota}`, async ({ page }) => {
          await page.goto(rota)
          await semCarregamento(page)
          expect(await violacoesGraves(page)).toEqual([])
        })
      }
    })
  }
}

test('axe: erro de validação do questionário', async ({ page }) => {
  await page.goto('/questionario/5')
  await page.getByRole('button', { name: 'FINALIZAR' }).click()
  await expect(page.getByRole('alert')).toBeVisible()
  expect(await violacoesGraves(page)).toEqual([])
})

/**
 * Aperta Tab até o foco chegar ao controle com este nome (rótulo do chip ou texto do botão/link,
 * sem o conteúdo decorativo aria-hidden). Falha se não chegar em 40 tabulações.
 */
async function tabAte(page: Page, nome: string) {
  for (let i = 0; i < 40; i++) {
    await page.keyboard.press('Tab')
    const atual = await page.evaluate(() => {
      const el = document.activeElement
      if (!el) return ''
      const alvo = el.closest('label') ?? el
      const copia = alvo.cloneNode(true) as Element
      copia.querySelectorAll('[aria-hidden="true"]').forEach((n) => n.remove())
      return (copia.textContent ?? '').replace(/\s+/g, ' ').trim()
    })
    if (atual === nome) return
  }
  throw new Error(`o foco não chegou a "${nome}" pelo teclado`)
}

test('questionário completo só pelo teclado', async ({ page }) => {
  await page.addInitScript(() => localStorage.setItem('mm.visitou.v1', '1'))
  await page.goto('/questionario/1')

  await tabAte(page, 'COMEÇAR')
  await page.keyboard.press('Enter')
  await expect(page).toHaveURL(/\/questionario\/2$/)

  await tabAte(page, 'Drama')
  await page.keyboard.press('Space')
  await expect(page.getByRole('checkbox', { name: 'Drama' })).toBeChecked()
  await tabAte(page, 'Próximo passo')
  await page.keyboard.press('Enter')
  await expect(page).toHaveURL(/\/questionario\/3$/)

  // Grupo de rádio: Tab entra na primeira opção, as setas mudam a seleção (padrão nativo).
  await tabAte(page, 'Até 1h30')
  await page.keyboard.press('Space')
  await expect(page.getByRole('radio', { name: 'Até 1h30' })).toBeChecked()
  for (let i = 0; i < 3; i++) await page.keyboard.press('ArrowRight')
  await expect(page.getByRole('radio', { name: '3h+' })).toBeChecked()
  await tabAte(page, 'Próximo passo')
  await page.keyboard.press('Enter')
  await expect(page).toHaveURL(/\/questionario\/4$/)

  await tabAte(page, 'Netflix')
  await page.keyboard.press('Space')
  await expect(page.getByRole('checkbox', { name: 'Netflix' })).toBeChecked()
  await tabAte(page, 'Próximo passo')
  await page.keyboard.press('Enter')
  await expect(page).toHaveURL(/\/questionario\/5$/)

  await tabAte(page, 'FINALIZAR')
  await page.keyboard.press('Enter')
  await expect(page).toHaveURL(/\/sugestoes$/)
  await expect(page.getByRole('heading', { name: 'Sugestões com base nas suas respostas' })).toBeVisible()
})
