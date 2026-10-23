import { beforeEach, describe, expect, it, vi } from 'vitest'
import { flushPromises, mount } from '@vue/test-utils'
import { createMemoryHistory, createWebHistory } from 'vue-router'
import App from '../../src/App.vue'
import { criarRouter } from '../../src/router'
import { listarTodos } from '../../src/services/filmes'
import { FalhaApi } from '../../src/services/http'
import { mapearFilme, mapearLista } from '../../src/services/mapeadores'
import { useCatalogo } from '../../src/composables/useCatalogo'
import validos from '../fixtures/filmes-validos.json'

vi.mock('../../src/services/filmes', () => ({ listarTodos: vi.fn() }))
const listarTodosMock = vi.mocked(listarTodos)
const catalogo = () => Promise.resolve(mapearLista(validos, mapearFilme))

beforeEach(() => {
  useCatalogo().invalidar()
  listarTodosMock.mockReset().mockImplementation(catalogo)
})

async function abrir(caminho: string) {
  const router = criarRouter(createMemoryHistory())
  await router.push(caminho)
  const wrapper = mount(App, { global: { plugins: [router] } })
  await flushPromises()
  return { wrapper, router }
}

describe('Detalhe do filme', () => {
  it('abrir a URL direto carrega o filme pelo catálogo', async () => {
    const { wrapper } = await abrir('/filmes/1')
    expect(wrapper.find('h1').text()).toBe('Cidade Partida')
    expect(wrapper.text()).toContain('BOA ESCOLHA!')
    expect(wrapper.text()).toContain('4.5')
    expect(wrapper.text()).toContain('2h10min')
    expect(wrapper.text()).toContain('Ana Ribeiro')
    expect(wrapper.text()).toContain('Dois amigos seguem caminhos opostos numa cidade dividida.')
    expect(wrapper.text()).toContain('Netflix')
    expect(wrapper.findAll('.elenco li').map((li) => li.text())).toEqual(['Carlos Lima', 'Bia Torres'])
    expect(listarTodosMock).toHaveBeenCalledTimes(1)
  })

  it('não oferece Curtir nem Minha Lista (fora do MVP)', async () => {
    const { wrapper } = await abrir('/filmes/1')
    const texto = wrapper.text().toLowerCase()
    expect(texto).not.toContain('curtir')
    expect(texto).not.toContain('minha lista')
  })

  it('id inexistente mostra "não encontrado" com caminho de volta', async () => {
    const { wrapper } = await abrir('/filmes/999')
    expect(wrapper.text()).toContain('Filme não encontrado no catálogo.')
    expect(wrapper.find('.detalhe a[href="/inicio"]').exists()).toBe(true)
  })

  it('seções vazias são omitidas (sem elenco, sem diretor)', async () => {
    const { wrapper } = await abrir('/filmes/9')
    expect(wrapper.find('h1').text()).toBe('Arquivo Vivo')
    expect(wrapper.find('.elenco').exists()).toBe(false)
  })

  it('trocar de filme na mesma página recarrega os dados', async () => {
    const { wrapper, router } = await abrir('/filmes/1')
    await router.push('/filmes/4')
    await flushPromises()
    expect(wrapper.find('h1').text()).toBe('Galáxia Esquecida')
    expect(listarTodosMock).toHaveBeenCalledTimes(1)
  })

  it('erro na API oferece retry que invalida o cache e busca de novo', async () => {
    listarTodosMock.mockRejectedValueOnce(new FalhaApi({ tipo: 'rede' }))
    const { wrapper } = await abrir('/filmes/1')
    expect(wrapper.text()).toContain('Não foi possível conectar ao servidor.')
    await wrapper.find('.detalhe button.botao').trigger('click')
    await flushPromises()
    expect(wrapper.find('h1').text()).toBe('Cidade Partida')
    expect(listarTodosMock).toHaveBeenCalledTimes(2)
  })

  it('voltar com histórico retorna à página anterior (histórico do navegador)', async () => {
    const router = criarRouter(createWebHistory())
    await router.push('/pesquisa')
    const wrapper = mount(App, { global: { plugins: [router] } })
    await router.push('/filmes/1')
    await flushPromises()
    await wrapper.find('.voltar').trigger('click')
    await vi.waitFor(() => expect(router.currentRoute.value.name).toBe('pesquisa'))
    wrapper.unmount()
  })

  it('voltar sem histórico no app leva ao início', async () => {
    const { wrapper, router } = await abrir('/filmes/1')
    await wrapper.find('.voltar').trigger('click')
    await vi.waitFor(() => expect(router.currentRoute.value.name).toBe('inicio'))
  })
})
