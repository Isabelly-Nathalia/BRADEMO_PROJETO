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

// COMPORTAMENTO ATUAL, pendente de decisão (A-07, docs/contrato.md): o banco real aceita
// duracao_filme nula; o mapeador descarta o filme (A-01) e, quando ele é o ÚNICO resultado, a
// regra "lista não vazia sem itens válidos = erro sistêmico" mostra erro de formato na pesquisa.
test('filme com duração nula: descartado; como único resultado, a pesquisa mostra erro de formato', async ({ page }) => {
  await page.goto('/pesquisa?q=t%C3%ADtulo')
  await expect(page.getByText('Os dados recebidos estão em um formato inesperado.')).toBeVisible()
  await page.goto('/filmes/99')
  await expect(page.getByText('Filme não encontrado no catálogo.')).toBeVisible()
})

test('filme com duração nula no meio do catálogo não quebra as listas', async ({ page }) => {
  await page.goto('/inicio')
  await expect(page.getByRole('heading', { name: 'Você pode gostar' })).toBeVisible()
  await expect(page.getByText('Os dados recebidos estão em um formato inesperado.')).toHaveCount(0)
})
