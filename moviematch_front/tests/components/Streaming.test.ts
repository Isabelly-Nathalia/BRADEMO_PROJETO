import { beforeEach, describe, expect, it, vi } from 'vitest'
import { flushPromises, mount } from '@vue/test-utils'
import { createMemoryHistory } from 'vue-router'
import App from '../../src/App.vue'
import { criarRouter } from '../../src/router'
import { outros, porStreaming } from '../../src/services/filmes'
import { FalhaApi } from '../../src/services/http'
import { mapearFilme, mapearLista } from '../../src/services/mapeadores'
import validos from '../fixtures/filmes-validos.json'

vi.mock('../../src/services/filmes', () => ({ porStreaming: vi.fn(), outros: vi.fn() }))
const porStreamingMock = vi.mocked(porStreaming)
const outrosMock = vi.mocked(outros)

beforeEach(() => {
  porStreamingMock.mockReset().mockImplementation((valor: string) =>
    Promise.resolve(mapearLista(validos.filter((f) => f.streaming_filme === valor), mapearFilme)),
  )
  outrosMock.mockReset().mockImplementation(() =>
    Promise.resolve(mapearLista(validos.filter((f) => f.streaming_filme === 'Mubi'), mapearFilme)),
  )
})

async function abrir(caminho: string) {
  const router = criarRouter(createMemoryHistory())
  await router.push(caminho)
  const wrapper = mount(App, { global: { plugins: [router] } })
  await flushPromises()
  return { wrapper, router }
}

describe('Streaming', () => {
  it('slug é traduzido para o valor da Home e os filmes aparecem em grade', async () => {
    const { wrapper } = await abrir('/streaming/netflix')
    expect(porStreamingMock).toHaveBeenCalledWith('Netflix', expect.anything())
    expect(wrapper.find('h1').text()).toBe('Netflix')
    expect(wrapper.text()).toContain('Últimos lançamentos no catálogo')
    expect(wrapper.findAll('.grade li')).toHaveLength(3)
  })

  it('disney-plus envia "Disney+" (a codificação fica com o cliente HTTP)', async () => {
    await abrir('/streaming/disney-plus')
    expect(porStreamingMock).toHaveBeenCalledWith('Disney+', expect.anything())
  })

  it('"outros" usa a rota própria do backend', async () => {
    const { wrapper } = await abrir('/streaming/outros')
    expect(outrosMock).toHaveBeenCalledTimes(1)
    expect(porStreamingMock).not.toHaveBeenCalled()
    expect(wrapper.find('h1').text()).toBe('Outros Streamings')
  })

  it('slug desconhecido mostra a página não encontrada sem chamar a API', async () => {
    const { wrapper } = await abrir('/streaming/Disney+')
    expect(wrapper.text()).toContain('Página não encontrada')
    expect(porStreamingMock).not.toHaveBeenCalled()
    expect(document.title).toBe('Página não encontrada · MovieMatch')
  })

  it('o título da aba mostra o streaming', async () => {
    await abrir('/streaming/hbo-max')
    expect(document.title).toBe('HBO Max · MovieMatch')
  })

  it('sem filmes: mensagem de vazio', async () => {
    const { wrapper } = await abrir('/streaming/tela-brasil')
    expect(wrapper.findAll('.grade li')).toHaveLength(1)
    porStreamingMock.mockResolvedValueOnce({ itens: [], descartados: 0, repetidos: 0 })
    const segundo = await abrir('/streaming/prime-video')
    expect(segundo.wrapper.text()).toContain('Nenhum filme deste streaming no catálogo.')
  })

  it('trocar de streaming na mesma página recarrega', async () => {
    const { wrapper, router } = await abrir('/streaming/netflix')
    await router.push('/streaming/hbo-max')
    await flushPromises()
    expect(porStreamingMock).toHaveBeenLastCalledWith('HBO Max', expect.anything())
    expect(wrapper.find('h1').text()).toBe('HBO Max')
    expect(wrapper.findAll('.grade li')).toHaveLength(1)
  })

  it('erro com retry', async () => {
    porStreamingMock.mockRejectedValueOnce(new FalhaApi({ tipo: 'timeout' }))
    const { wrapper } = await abrir('/streaming/netflix')
    expect(wrapper.text()).toContain('O servidor demorou demais para responder.')
    await wrapper.find('.streaming .estado button').trigger('click')
    await flushPromises()
    expect(wrapper.findAll('.grade li')).toHaveLength(3)
  })
})
