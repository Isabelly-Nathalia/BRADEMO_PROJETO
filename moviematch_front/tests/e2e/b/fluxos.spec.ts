import { expect, semRolagemHorizontal, test } from '../apoio'

test('fluxo principal: boas-vindas → questionário → sugestões → detalhe', async ({ page }) => {
  await page.goto('/')
  await page.getByRole('link', { name: 'Começar questionário' }).click()
  await page.getByRole('button', { name: 'COMEÇAR' }).click()

  await page.getByText('Romance', { exact: true }).click()
  await page.getByRole('button', { name: 'Próximo passo' }).click()
  await page.getByText('1h30 - 2h', { exact: true }).click()
  await page.getByRole('button', { name: 'Próximo passo' }).click()
  await page.getByText('Netflix', { exact: true }).click()
  await page.getByRole('button', { name: 'Próximo passo' }).click()
  await expect(page.getByRole('heading', { name: 'Falta pouco!' })).toBeVisible()
  await page.getByRole('button', { name: 'FINALIZAR' }).click()

  await expect(page).toHaveURL(/\/sugestoes$/)
  const titulos = page.locator('.lista .titulo')
  await expect(titulos).toHaveText(['Coração em Seul', 'Noites de Lisboa', 'Canção do Mar'])
  await semRolagemHorizontal(page)

  await titulos.first().click()
  await expect(page).toHaveURL(/\/filmes\/11$/)
  await expect(page.getByRole('heading', { level: 1 })).toHaveText('Coração em Seul')
})

test('finalizar sem respostas mínimas mostra o primeiro erro do Flutter', async ({ page }) => {
  await page.goto('/questionario/5')
  await page.getByRole('button', { name: 'FINALIZAR' }).click()
  await expect(page.getByRole('alert')).toHaveText('Selecione pelo menos um gênero')
})

test('questionário pelo teclado (Espaço marca a opção)', async ({ page }) => {
  await page.goto('/questionario/2')
  await page.getByRole('checkbox', { name: 'Ação', exact: true }).focus()
  await page.keyboard.press('Space')
  await expect(page.getByRole('checkbox', { name: 'Ação', exact: true })).toBeChecked()
})

test('pesquisa: termo na URL, acentos e "voltar"', async ({ page }) => {
  await page.goto('/pesquisa')
  await page.getByRole('searchbox', { name: 'Pesquisar filmes por título' }).fill('ação')
  await page.keyboard.press('Enter')
  await expect(page).toHaveURL(/\?q=a%C3%A7%C3%A3o$/)
  await expect(page.locator('.resultados .titulo')).toHaveText(['Coração em Seul', 'Ação e Reação'])

  await page.getByRole('searchbox').fill('riso')
  await page.keyboard.press('Enter')
  await expect(page.locator('.resultados .titulo')).toHaveText(['Riso Solto'])
  await page.goBack()
  await expect(page.locator('.resultados .titulo')).toHaveText(['Coração em Seul', 'Ação e Reação'])
})

test('pesquisa sem resultados', async ({ page }) => {
  await page.goto('/pesquisa?q=inexistente')
  await expect(page.getByText('Filme não localizado no catálogo')).toBeVisible()
})

test('streaming: logo da página inicial, Disney+ e "outros" @so-mock', async ({ page }) => {
  await page.goto('/inicio')
  await page.getByRole('link', { name: 'Disney+' }).click()
  await expect(page).toHaveURL(/\/streaming\/disney-plus$/)
  await expect(page.locator('.grade .titulo')).toHaveText(['Galáxia Esquecida'])
  await expect(page).toHaveTitle('Disney+ · MovieMatch')

  await page.goto('/streaming/outros')
  // GloboPlay e AppleTV fora da lista fixa do backend caem em "outros" (A-05).
  await expect(page.locator('.grade .titulo')).toHaveText(['Canção do Mar', 'Pequenos Heróis', 'Dragão de Jade'])
})

test('detalhe: "voltar" sem histórico leva ao início', async ({ page }) => {
  await page.goto('/filmes/1')
  await page.getByRole('button', { name: 'Voltar' }).click()
  await expect(page).toHaveURL(/\/inicio$/)
})
