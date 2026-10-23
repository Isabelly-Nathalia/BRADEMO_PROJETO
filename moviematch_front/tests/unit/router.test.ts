import { describe, expect, it } from 'vitest'
import { createMemoryHistory } from 'vue-router'
import { criarRouter, tituloDaPagina } from '../../src/router'

function novoRouter() {
  return criarRouter(createMemoryHistory())
}

describe('rotas', () => {
  it.each([
    ['/boas-vindas', 'boas-vindas'],
    ['/inicio', 'inicio'],
    ['/pesquisa', 'pesquisa'],
    ['/pesquisa?q=cidade', 'pesquisa'],
    ['/streaming/netflix', 'streaming'],
    ['/filmes/42', 'filme'],
    ['/questionario', 'questionario'],
    ['/questionario/1', 'questionario'],
    ['/questionario/8', 'questionario'],
    ['/sugestoes', 'sugestoes'],
  ])('%s resolve para %s', (caminho, nome) => {
    expect(novoRouter().resolve(caminho).name).toBe(nome)
  })

  it.each([
    '/x/y',
    '/filmes/abc',
    '/filmes/',
    '/filmes/1/extra',
    '/questionario/0',
    '/questionario/9',
    '/questionario/12',
    '/streaming',
    '/usuarios',
    '/listas/1',
  ])('%s cai na página não encontrada', (caminho) => {
    expect(novoRouter().resolve(caminho).name).toBe('nao-encontrado')
  })

  it('a raiz redireciona para o início', async () => {
    const router = novoRouter()
    await router.push('/')
    expect(router.currentRoute.value.name).toBe('inicio')
  })

  it('preserva parâmetros da rota', () => {
    const router = novoRouter()
    expect(router.resolve('/filmes/42').params.id).toBe('42')
    expect(router.resolve('/streaming/disney-plus').params.slug).toBe('disney-plus')
    expect(router.resolve('/pesquisa?q=a%C3%A7%C3%A3o').query.q).toBe('ação')
  })

  it('define o título do documento após navegar', async () => {
    const router = novoRouter()
    await router.push('/pesquisa')
    expect(document.title).toBe('Pesquisa · MovieMatch')
    await router.push('/nao/existe')
    expect(document.title).toBe('Página não encontrada · MovieMatch')
  })

  it('não duplica o sufixo quando o título já é o nome do produto', () => {
    expect(tituloDaPagina('MovieMatch')).toBe('MovieMatch')
  })
})
