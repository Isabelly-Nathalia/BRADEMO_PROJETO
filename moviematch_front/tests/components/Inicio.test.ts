import { beforeEach, describe, expect, it, vi } from 'vitest'
import { flushPromises, mount } from '@vue/test-utils'
import { createMemoryHistory } from 'vue-router'
import Inicio from '../../src/pages/Inicio.vue'
import { criarRouter } from '../../src/router'
import { aleatorios } from '../../src/services/filmes'
import { listarPublicidades } from '../../src/services/publicidades'
import { FalhaApi } from '../../src/services/http'
import { mapearFilme, mapearLista, mapearPublicidade } from '../../src/services/mapeadores'
import validos from '../fixtures/filmes-validos.json'
import publicidades from '../fixtures/publicidades.json'

vi.mock('../../src/services/filmes', () => ({ aleatorios: vi.fn() }))
vi.mock('../../src/services/publicidades', () => ({ listarPublicidades: vi.fn() }))

const aleatoriosMock = vi.mocked(aleatorios)
const publicidadesMock = vi.mocked(listarPublicidades)
const cinco = () => Promise.resolve(mapearLista(validos.slice(0, 5), mapearFilme))
const tres = () => Promise.resolve(mapearLista(publicidades, mapearPublicidade))
const vazio = () => Promise.resolve({ itens: [], descartados: 0, repetidos: 0 })

beforeEach(() => {
  aleatoriosMock.mockReset().mockImplementation(cinco)
  publicidadesMock.mockReset().mockImplementation(tres)
})

async function montar() {
  const router = criarRouter(createMemoryHistory())
  await router.push('/inicio')
  const wrapper = mount(Inicio, { global: { plugins: [router] } })
  await flushPromises()
  return wrapper
}

describe('Início', () => {
  it('mostra saudação, publicidades, 5 sugestões e 8 streamings', async () => {
    const wrapper = await montar()
    expect(wrapper.find('h1').text()).toBe('Olá!')
    expect(wrapper.text()).toContain('Encontre o filme perfeito para sua noite')
    expect(wrapper.findAll('.carrossel .slide')).toHaveLength(3)
    // Rolável pelo teclado: os slides não têm nada focável.
    expect(wrapper.find('.carrossel').attributes('tabindex')).toBe('0')
    expect(wrapper.findAll('.filmes a')).toHaveLength(5)
    expect(wrapper.findAll('.streamings a')).toHaveLength(8)
  })

  it('cartões levam ao detalhe e logos levam à página do streaming', async () => {
    const wrapper = await montar()
    expect(wrapper.find('.filmes a').attributes('href')).toBe('/filmes/1')
    const destinos = wrapper.findAll('.streamings a').map((a) => a.attributes('href'))
    expect(destinos).toContain('/streaming/disney-plus')
    expect(destinos).toContain('/streaming/outros')
  })

  it('logos têm o nome do streaming como texto alternativo', async () => {
    const wrapper = await montar()
    const nomes = wrapper.findAll('.streamings img').map((i) => i.attributes('alt'))
    expect(nomes).toEqual(['Netflix', 'HBO Max', 'Disney+', 'Apple TV', 'GloboPlay', 'Prime Video', 'Tela Brasil', 'Outros Streamings'])
  })

  it('falha nas publicidades não impede as sugestões', async () => {
    publicidadesMock.mockRejectedValue(new FalhaApi({ tipo: 'http', status: 500 }))
    const wrapper = await montar()
    expect(wrapper.text()).toContain('O servidor encontrou um erro.')
    expect(wrapper.findAll('.filmes a')).toHaveLength(5)
  })

  it('erro nas sugestões oferece retry, que refaz só aquela busca', async () => {
    aleatoriosMock.mockRejectedValueOnce(new FalhaApi({ tipo: 'timeout' }))
    const wrapper = await montar()
    const secao = wrapper.find('[aria-labelledby="titulo-sugestoes"]')
    expect(secao.text()).toContain('O servidor demorou demais para responder.')
    await secao.find('button').trigger('click')
    await flushPromises()
    expect(aleatoriosMock).toHaveBeenCalledTimes(2)
    expect(publicidadesMock).toHaveBeenCalledTimes(1)
    expect(wrapper.findAll('.filmes a')).toHaveLength(5)
  })

  it('listas vazias mostram mensagens próprias', async () => {
    aleatoriosMock.mockImplementation(vazio)
    publicidadesMock.mockImplementation(vazio)
    const wrapper = await montar()
    expect(wrapper.text()).toContain('Nenhum filme disponível no momento.')
    expect(wrapper.text()).toContain('Nenhuma novidade no momento.')
  })

  it('tem atalho para a pesquisa e nenhum sino de notificações (A-06)', async () => {
    const wrapper = await montar()
    expect(wrapper.find('.atalho').attributes('href')).toBe('/pesquisa')
    expect(wrapper.find('.atalho').text()).toBe('Pesquisar filmes')
    expect(wrapper.text().toLowerCase()).not.toContain('notifica')
  })

  it('sair da página cancela as buscas em andamento', async () => {
    const sinais: AbortSignal[] = []
    aleatoriosMock.mockImplementation(({ signal } = {}) => {
      sinais.push(signal!)
      return new Promise(() => {})
    })
    const wrapper = await montar()
    wrapper.unmount()
    expect(sinais[0]!.aborted).toBe(true)
  })
})
