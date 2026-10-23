import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import { mount } from '@vue/test-utils'
import StateView from '../../src/components/StateView.vue'
import { mensagemErro } from '../../src/components/mensagemErro'
import { FalhaApi, type ErroApi } from '../../src/services/http'

const AVISO = 'O servidor pode estar iniciando'

beforeEach(() => {
  vi.useFakeTimers()
})

afterEach(() => {
  vi.useRealTimers()
})

describe('StateView', () => {
  it('carregando: aviso de lentidão ausente em 4,9 s e presente aos 5 s', async () => {
    const wrapper = mount(StateView, { props: { estado: 'carregando' } })
    expect(wrapper.find('[role="status"]').text()).toContain('Carregando')
    await vi.advanceTimersByTimeAsync(4_900)
    expect(wrapper.text()).not.toContain(AVISO)
    await vi.advanceTimersByTimeAsync(100)
    expect(wrapper.text()).toContain(AVISO)
  })

  it('o aviso some quando o carregamento termina e reinicia do zero numa nova carga', async () => {
    const wrapper = mount(StateView, { props: { estado: 'carregando' } })
    await vi.advanceTimersByTimeAsync(5_000)
    await wrapper.setProps({ estado: 'sucesso' })
    await wrapper.setProps({ estado: 'carregando' })
    await vi.advanceTimersByTimeAsync(4_000)
    expect(wrapper.text()).not.toContain(AVISO)
  })

  it('erro: mostra a mensagem e emite tentarNovamente só quando clicado', async () => {
    const wrapper = mount(StateView, {
      props: { estado: 'erro', erro: new FalhaApi({ tipo: 'timeout' }) },
    })
    expect(wrapper.text()).toContain('O servidor demorou demais para responder.')
    await vi.advanceTimersByTimeAsync(60_000)
    expect(wrapper.emitted('tentarNovamente')).toBeUndefined()
    await wrapper.find('button').trigger('click')
    expect(wrapper.emitted('tentarNovamente')).toHaveLength(1)
  })

  it('vazio: mostra a mensagem configurada', () => {
    const wrapper = mount(StateView, {
      props: { estado: 'vazio', mensagemVazio: 'Filme não localizado no catálogo' },
    })
    expect(wrapper.text()).toBe('Filme não localizado no catálogo')
  })

  it('sucesso: renderiza o conteúdo do slot e nada mais', () => {
    const wrapper = mount(StateView, {
      props: { estado: 'sucesso' },
      slots: { default: '<ul><li>Filme</li></ul>' },
    })
    expect(wrapper.find('li').text()).toBe('Filme')
    expect(wrapper.find('button').exists()).toBe(false)
  })

  it('anuncia mudanças para leitores de tela', () => {
    const wrapper = mount(StateView, { props: { estado: 'vazio' } })
    expect(wrapper.attributes('aria-live')).toBe('polite')
  })
})

describe('mensagemErro', () => {
  it.each<[ErroApi, string]>([
    [{ tipo: 'rede' }, 'Não foi possível conectar ao servidor.'],
    [{ tipo: 'timeout' }, 'O servidor demorou demais para responder.'],
    [{ tipo: 'formato', detalhe: 'x' }, 'Os dados recebidos estão em um formato inesperado.'],
    [{ tipo: 'cancelado' }, 'O carregamento foi interrompido.'],
    [{ tipo: 'http', status: 404 }, 'Conteúdo não encontrado.'],
    [{ tipo: 'http', status: 500 }, 'O servidor encontrou um erro.'],
    [{ tipo: 'http', status: 504 }, 'O servidor encontrou um erro.'],
    [{ tipo: 'http', status: 429 }, 'Erro ao carregar (código 429).'],
  ])('%j → %s', (erro, texto) => {
    expect(mensagemErro(new FalhaApi(erro))).toBe(texto)
  })

  it('erro desconhecido recebe mensagem genérica sem expor detalhes', () => {
    expect(mensagemErro(new Error('stack interna'))).toBe('Algo deu errado ao carregar.')
  })
})
