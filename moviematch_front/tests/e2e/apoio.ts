// Fixture comum dos testes E2E: reprova o teste se houver violação de CSP ou erro de JavaScript
// na página, e se a página ganhar rolagem horizontal.
import { test as base, expect, type Page } from '@playwright/test'

declare global {
  interface Window {
    __violacoesCsp: string[]
  }
}

export const test = base.extend<{ vigiar: void }>({
  vigiar: [
    async ({ page }, usar) => {
      const errosJs: string[] = []
      page.on('pageerror', (erro) => errosJs.push(erro.message))
      await page.addInitScript(() => {
        window.__violacoesCsp = []
        document.addEventListener('securitypolicyviolation', (e) => {
          window.__violacoesCsp.push(`${e.violatedDirective} ${e.blockedURI}`)
        })
      })
      await usar()
      if (!page.isClosed() && page.url().startsWith('http')) {
        const violacoes = await page.evaluate(() => window.__violacoesCsp ?? []).catch(() => [])
        expect(violacoes, 'violações de CSP').toEqual([])
      }
      expect(errosJs, 'erros de JavaScript na página').toEqual([])
    },
    { auto: true },
  ],
})

export { expect }

/** A página não pode rolar para o lado (o bug corrigido em ceabe94). */
export async function semRolagemHorizontal(page: Page) {
  const { rolagem, janela } = await page.evaluate(() => ({
    rolagem: document.documentElement.scrollWidth,
    janela: document.documentElement.clientWidth,
  }))
  expect(rolagem, 'largura do conteúdo').toBeLessThanOrEqual(janela)
}
