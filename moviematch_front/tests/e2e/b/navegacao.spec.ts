import { expect, semRolagemHorizontal, test } from '../apoio'

// Acesso direto e F5 em todas as rotas (o Nginx serve o index.html; o router decide).
const ROTAS: Array<[string, string]> = [
  ['/boas-vindas', 'Bem-vindo(a) ao MovieMatch'],
  ['/inicio', 'Olá!'],
  ['/pesquisa?q=riso', 'Riso Solto'],
  ['/streaming/netflix', 'Netflix'],
  ['/filmes/4', 'Galáxia Esquecida'],
  ['/questionario/3', 'Qual a duração de filme ideal pra você?'],
  ['/filmes/abc', 'Página não encontrada'],
  ['/rota/que/nao/existe', 'Página não encontrada'],
]

for (const [rota, texto] of ROTAS) {
  test(`acesso direto e F5 em ${rota}`, async ({ page }) => {
    await page.goto(rota)
    await expect(page.getByText(texto).first()).toBeVisible()
    await page.reload()
    await expect(page.getByText(texto).first()).toBeVisible()
    await semRolagemHorizontal(page)
  })
}

test('a raiz leva às boas-vindas na primeira visita e ao início depois', async ({ page }) => {
  await page.goto('/')
  await expect(page).toHaveURL(/\/boas-vindas$/)
  await page.goto('/')
  await expect(page).toHaveURL(/\/inicio$/)
})

test('voltar do navegador entre páginas', async ({ page }) => {
  await page.goto('/inicio')
  await page.getByRole('link', { name: 'Pesquisar filmes' }).click()
  await expect(page).toHaveURL(/\/pesquisa$/)
  await page.goBack()
  await expect(page).toHaveURL(/\/inicio$/)
  await expect(page.getByRole('heading', { name: 'Olá!' })).toBeVisible()
})

test('navegação inferior leva ao início e ao questionário', async ({ page }) => {
  await page.goto('/pesquisa')
  const nav = page.getByRole('navigation', { name: 'Navegação principal' })
  await nav.getByRole('link', { name: 'Questionário' }).click()
  await expect(page).toHaveURL(/\/questionario$/)
  await expect(nav).toBeHidden()
})
