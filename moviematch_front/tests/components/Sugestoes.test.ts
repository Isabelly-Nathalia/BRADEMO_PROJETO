import { beforeEach, describe, expect, it, vi } from 'vitest'
import { flushPromises, mount } from '@vue/test-utils'
import { createMemoryHistory } from 'vue-router'
import App from '../../src/App.vue'
import { criarRouter } from '../../src/router'
import { listarTodos } from '../../src/services/filmes'
import { FalhaApi } from '../../src/services/http'
import { mapearFilme, mapearLista } from '../../src/services/mapeadores'
import { useCatalogo } from '../../src/composables/useCatalogo'
import { useQuestionario } from '../../src/composables/useQuestionario'
import { ordenarSugestoes } from '../../src/domain/recomendacao'
import validos from '../fixtures/filmes-validos.json'

vi.mock('../../src/services/filmes', () => ({ listarTodos: vi.fn() }))
const listarTodosMock = vi.mocked(listarTodos)
const catalogo = () => Promise.resolve(mapearLista(validos, mapearFilme))

function responderMinimo() {
  const q = useQuestionario()
  q.alternarGenero('Romance')
  q.definirDuracao('1h30 - 2h')
  q.alternarStreaming('Netflix')
}

beforeEach(() => {
  useQuestionario().limpar()
  useCatalogo().invalidar()
  listarTodosMock.mockReset().mockImplementation(catalogo)
})

async function abrir(caminho = '/sugestoes') {
  const router = criarRouter(createMemoryHistory())
  await router.push(caminho)
  const wrapper = mount(App, { global: { plugins: [router] } })
  await flushPromises()
  return { wrapper, router }
}

describe('Sugestões', () => {
  it('sem as respostas mínimas, redireciona ao passo 1 sem buscar o catálogo', async () => {
    const { router } = await abrir()
    expect(router.currentRoute.value.name).toBe('questionario')
    expect(router.currentRoute.value.params.passo).toBe('1')
    expect(listarTodosMock).not.toHaveBeenCalled()
  })

  it('mostra o top 3 da regra de recomendação, na ordem', async () => {
    responderMinimo()
    const { wrapper } = await abrir()
    const esperado = ordenarSugestoes(mapearLista(validos, mapearFilme).itens, useQuestionario().respostas).map((f) => f.titulo)
    // Romance + 91–120 min + Netflix: "Coração em Seul" soma 8; "Noites de Lisboa" soma 5.
    expect(esperado.slice(0, 2)).toEqual(['Coração em Seul', 'Noites de Lisboa'])
    expect(wrapper.findAll('.lista .titulo').map((t) => t.text())).toEqual(esperado)
    expect(wrapper.find('h1').text()).toBe('Sugestões com base nas suas respostas')
    expect(wrapper.text()).toContain('Disponível em Netflix')
  })

  it('cada sugestão leva ao detalhe do filme', async () => {
    responderMinimo()
    const { wrapper } = await abrir()
    expect(wrapper.find('.lista .titulo').attributes('href')).toBe('/filmes/11')
  })

  it('alterna o lado do pôster (zigue-zague)', async () => {
    responderMinimo()
    const { wrapper } = await abrir()
    expect(wrapper.findAll('.sugestao').map((s) => s.classes().includes('invertida'))).toEqual([false, true, false])
  })

  it('"Refazer questionário" limpa as respostas e volta ao passo 1', async () => {
    responderMinimo()
    const { wrapper, router } = await abrir()
    await wrapper.findAll('button').find((b) => b.text() === 'Refazer questionário')!.trigger('click')
    await vi.waitFor(() => expect(router.currentRoute.value.params.passo).toBe('1'))
    expect(useQuestionario().respostas.generos).toEqual([])
  })

  it('catálogo vazio mostra mensagem', async () => {
    responderMinimo()
    listarTodosMock.mockResolvedValueOnce({ itens: [], descartados: 0, repetidos: 0 })
    const { wrapper } = await abrir()
    expect(wrapper.text()).toContain('Nenhum filme no catálogo no momento.')
  })

  it('erro com retry que busca o catálogo de novo', async () => {
    responderMinimo()
    listarTodosMock.mockRejectedValueOnce(new FalhaApi({ tipo: 'rede' }))
    const { wrapper } = await abrir()
    expect(wrapper.text()).toContain('Não foi possível conectar ao servidor.')
    await wrapper.find('.estado button').trigger('click')
    await flushPromises()
    expect(wrapper.findAll('.lista li')).toHaveLength(3)
    expect(listarTodosMock).toHaveBeenCalledTimes(2)
  })
})
