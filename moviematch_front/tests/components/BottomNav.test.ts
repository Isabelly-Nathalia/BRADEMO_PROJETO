import { describe, expect, it } from 'vitest'
import { mount, flushPromises } from '@vue/test-utils'
import { createMemoryHistory } from 'vue-router'
import App from '../../src/App.vue'
import { criarRouter } from '../../src/router'

async function montarEm(caminho: string) {
  const router = criarRouter(createMemoryHistory())
  await router.push(caminho)
  const wrapper = mount(App, { global: { plugins: [router] } })
  await flushPromises()
  return { wrapper, router }
}

describe('navegação inferior', () => {
  it.each(['/inicio', '/pesquisa', '/sugestoes', '/filmes/1', '/streaming/netflix', '/nao/existe'])(
    'aparece em %s',
    async (caminho) => {
      const { wrapper } = await montarEm(caminho)
      expect(wrapper.find('nav[aria-label="Navegação principal"]').exists()).toBe(true)
    },
  )

  it.each(['/boas-vindas', '/questionario', '/questionario/3'])('fica oculta em %s', async (caminho) => {
    const { wrapper } = await montarEm(caminho)
    expect(wrapper.find('nav').exists()).toBe(false)
  })

  it('só aponta para rotas existentes do MVP', async () => {
    const { wrapper, router } = await montarEm('/inicio')
    const destinos = wrapper.findAll('nav a').map((a) => a.attributes('href'))
    expect(destinos).toEqual(['/inicio', '/questionario'])
    for (const destino of destinos) {
      expect(router.resolve(destino!).name).not.toBe('nao-encontrado')
    }
  })

  it('marca o item ativo com aria-current', async () => {
    const { wrapper } = await montarEm('/inicio')
    const [inicio, questionario] = wrapper.findAll('nav a')
    expect(inicio!.attributes('aria-current')).toBe('page')
    expect(questionario!.attributes('aria-current')).toBeUndefined()
  })

  it('nenhum item fica ativo fora das rotas da navegação', async () => {
    const { wrapper } = await montarEm('/pesquisa')
    expect(wrapper.findAll('nav a[aria-current]')).toHaveLength(0)
  })

  it('fica oculta antes de a primeira rota ser resolvida (não pisca)', () => {
    const router = criarRouter(createMemoryHistory())
    const wrapper = mount(App, { global: { plugins: [router] } })
    expect(wrapper.find('nav').exists()).toBe(false)
  })

  it('oferece atalho para pular ao conteúdo', async () => {
    const { wrapper } = await montarEm('/inicio')
    expect(wrapper.find('a[href="#conteudo"]').exists()).toBe(true)
    expect(wrapper.find('main#conteudo').exists()).toBe(true)
  })
})
