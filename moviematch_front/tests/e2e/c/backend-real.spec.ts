// Só no perfil C: comportamento do backend ORIGINAL com MySQL padrão (utf8mb4_0900_ai_ci),
// diferente do mock (comparação exata). Ver docs/contrato.md.
import { expect, test } from '../apoio'

test('streaming "GloboPlay" traz Globoplay e GloboPlay (igualdade ignora maiúsculas)', async ({ page }) => {
  await page.goto('/streaming/globoplay')
  await expect(page.locator('.grade .titulo')).toHaveText(['Sombras do Vale', 'Canção do Mar'])
})

test('"Outros Streamings" no backend real', async ({ page }) => {
  await page.goto('/streaming/outros')
  await expect(page.locator('.grade .titulo')).toHaveText(['Pequenos Heróis', 'Dragão de Jade'])
})

test('pesquisa sem acento encontra títulos acentuados', async ({ page }) => {
  await page.goto('/pesquisa?q=acao')
  await expect(page.locator('.resultados .titulo')).toHaveText(['Coração em Seul', 'Ação e Reação'])
})

// A-07 (decidido em 2026-10-23): duração nula é aceita como "não informada".
test('filme com duração nula aparece na pesquisa e no detalhe como "não informada"', async ({ page }) => {
  await page.goto('/pesquisa?q=t%C3%ADtulo')
  await expect(page.locator('.resultados .titulo')).toHaveText(['Só o título'])
  await expect(page.locator('.resultados')).toContainText('não informada')
  await page.goto('/filmes/99')
  await expect(page.getByRole('heading', { level: 1 })).toHaveText('Só o título')
  await expect(page.locator('.meta')).toContainText('não informada')
})

test('filme com duração nula no meio do catálogo não quebra as listas', async ({ page }) => {
  await page.goto('/inicio')
  await expect(page.getByRole('heading', { name: 'Você pode gostar' })).toBeVisible()
  await expect(page.getByText('Os dados recebidos estão em um formato inesperado.')).toHaveCount(0)
})
