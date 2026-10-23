// Estados da interface com a API em cada cenário do mock (cabeçalho x-mock-cenario, que o proxy
// repassa). O mock não prova compatibilidade com a API real.
import { expect, test } from '../apoio'

test.describe('lista vazia', () => {
  test.use({ extraHTTPHeaders: { 'x-mock-cenario': 'vazio' } })
  test('início mostra mensagens de vazio', async ({ page }) => {
    await page.goto('/inicio')
    await expect(page.getByText('Nenhum filme disponível no momento.')).toBeVisible()
    await expect(page.getByText('Nenhuma novidade no momento.')).toBeVisible()
  })
})

test.describe('itens inválidos misturados', () => {
  test.use({ extraHTTPHeaders: { 'x-mock-cenario': 'invalidos' } })
  test('início mostra só os filmes válidos (A-01)', async ({ page }) => {
    await page.goto('/inicio')
    // aleatórios = 5 primeiros da lista mista: 4 válidos e 1 inválido
    await expect(page.locator('.filmes li')).toHaveCount(4)
  })
})

test.describe('todos inválidos', () => {
  test.use({ extraHTTPHeaders: { 'x-mock-cenario': 'todos-invalidos' } })
  test('é erro de formato, não lista vazia', async ({ page }) => {
    await page.goto('/inicio')
    await expect(page.getByText('Os dados recebidos estão em um formato inesperado.').first()).toBeVisible()
    await expect(page.getByText('Nenhum filme disponível no momento.')).toHaveCount(0)
  })
})

test.describe('JSON malformado', () => {
  test.use({ extraHTTPHeaders: { 'x-mock-cenario': 'json-malformado' } })
  test('mostra erro de formato com "Tentar novamente"', async ({ page }) => {
    await page.goto('/streaming/netflix')
    await expect(page.getByText('Os dados recebidos estão em um formato inesperado.')).toBeVisible()
    await expect(page.getByRole('button', { name: 'Tentar novamente' })).toBeVisible()
  })
})

test.describe('erro do servidor', () => {
  test.use({ extraHTTPHeaders: { 'x-mock-cenario': 'http-500' } })
  test('mostra erro e o retry refaz a busca', async ({ page }) => {
    await page.goto('/filmes/1')
    await expect(page.getByText('O servidor encontrou um erro.')).toBeVisible()
    let pedidos = 0
    page.on('request', (r) => {
      if (r.url().includes('/api/filmes')) pedidos++
    })
    await page.getByRole('button', { name: 'Tentar novamente' }).click()
    await expect(page.getByText('O servidor encontrou um erro.')).toBeVisible()
    expect(pedidos).toBe(1)
  })
})

test.describe('ids repetidos', () => {
  test.use({ extraHTTPHeaders: { 'x-mock-cenario': 'repetidos' } })
  test('cada filme aparece uma vez', async ({ page }) => {
    await page.goto('/inicio')
    await expect(page.locator('.filmes li')).toHaveCount(3)
  })
})
