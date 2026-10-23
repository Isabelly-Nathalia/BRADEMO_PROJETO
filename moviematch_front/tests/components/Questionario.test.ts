import { beforeEach, describe, expect, it, vi } from 'vitest'
import { flushPromises, mount } from '@vue/test-utils'
import { createMemoryHistory } from 'vue-router'
import App from '../../src/App.vue'
import { criarRouter } from '../../src/router'
import { useQuestionario } from '../../src/composables/useQuestionario'

beforeEach(() => {
  useQuestionario().limpar()
})

async function abrir(caminho = '/questionario/1') {
  const router = criarRouter(createMemoryHistory())
  await router.push(caminho)
  const wrapper = mount(App, { global: { plugins: [router] }, attachTo: document.body })
  await flushPromises()
  return { wrapper, router }
}

type Montado = Awaited<ReturnType<typeof abrir>>

const titulo = ({ wrapper }: Montado) => wrapper.find('h1').text()

async function clicarBotao({ wrapper }: Montado, texto: string) {
  const botao = wrapper.findAll('button, a').find((b) => b.text().replace(/\s+/g, ' ').trim() === texto)
  if (!botao) throw new Error(`botão "${texto}" não encontrado`)
  await botao.trigger('click')
  await flushPromises()
}

async function proximo(m: Montado) {
  await clicarBotao(m, '›Próximo passo')
}

async function marcar({ wrapper }: Montado, opcao: string) {
  const label = wrapper.findAll('label.chip').find((l) => l.text() === opcao)
  if (!label) throw new Error(`opção "${opcao}" não encontrada`)
  await label.find('input').trigger('click')
}

describe('Questionário', () => {
  it('passo 1: textos do Flutter, sem barra de navegação e sem ✕', async () => {
    const m = await abrir('/questionario')
    expect(titulo(m)).toBe('Descubra filmes perfeitos para você')
    expect(m.wrapper.find('.fechar').exists()).toBe(false)
    expect(m.wrapper.find('.passos').exists()).toBe(false)
    expect(m.wrapper.find('progress').attributes('aria-label')).toBe('Passo 1 de 8')
    m.wrapper.unmount()
  })

  it('percorre os 8 passos na ordem do Flutter', async () => {
    const m = await abrir()
    await clicarBotao(m, 'COMEÇAR')
    const titulos = [titulo(m)]
    for (const destino of [3, 4]) {
      await proximo(m)
      expect(m.router.currentRoute.value.params.passo).toBe(String(destino))
      titulos.push(titulo(m))
    }
    await proximo(m)
    titulos.push(titulo(m))
    await clicarBotao(m, 'CONTINUAR')
    titulos.push(titulo(m))
    await proximo(m)
    titulos.push(titulo(m))
    await proximo(m)
    titulos.push(titulo(m))
    expect(titulos).toEqual([
      'Quais gêneros você gosta?',
      'Qual a duração de filme ideal pra você?',
      'Onde você costuma assistir?',
      'Falta pouco!',
      'Qual classificação indicativa você prefere?',
      'Tem preferência por algum país?',
      'Algum ator ou diretor favorito?',
    ])
    expect(m.wrapper.find('progress').attributes('aria-label')).toBe('Passo 8 de 8')
    m.wrapper.unmount()
  })

  it('passos 5 e 8 só têm "anterior"; os demais têm as duas setas', async () => {
    for (const [p, setas] of [[2, 2], [5, 1], [6, 2], [8, 1]] as const) {
      const m = await abrir(`/questionario/${p}`)
      expect(m.wrapper.findAll('.passos button'), `passo ${p}`).toHaveLength(setas)
      m.wrapper.unmount()
    }
  })

  it('marcar opções atualiza as respostas compartilhadas', async () => {
    const m = await abrir('/questionario/2')
    await marcar(m, 'Drama')
    await marcar(m, 'Ação')
    await marcar(m, 'Drama')
    expect(useQuestionario().respostas.generos).toEqual(['Ação'])
    m.wrapper.unmount()
  })

  it('duração é única e classificação desmarca ao clicar de novo', async () => {
    const d = await abrir('/questionario/3')
    await marcar(d, '3h+')
    await marcar(d, 'Até 1h30')
    expect(useQuestionario().respostas.duracao).toBe('Até 1h30')
    d.wrapper.unmount()
    const c = await abrir('/questionario/6')
    await marcar(c, 'Livre')
    expect(useQuestionario().respostas.classificacao).toBe('Livre')
    await marcar(c, 'Livre')
    expect(useQuestionario().respostas.classificacao).toBeNull()
    c.wrapper.unmount()
  })

  it('não há campos "Outro" (A-03)', async () => {
    for (const p of [4, 7]) {
      const m = await abrir(`/questionario/${p}`)
      expect(m.wrapper.findAll('input[type="text"]')).toHaveLength(0)
      expect(m.wrapper.text().toLowerCase()).not.toContain('outro')
      m.wrapper.unmount()
    }
  })

  it('FINALIZAR valida na ordem do Flutter e só segue com as respostas mínimas', async () => {
    const m = await abrir('/questionario/5')
    await clicarBotao(m, 'FINALIZAR')
    expect(m.wrapper.find('[role="alert"]').text()).toBe('Selecione pelo menos um gênero')
    useQuestionario().alternarGenero('Drama')
    await clicarBotao(m, 'FINALIZAR')
    expect(m.wrapper.find('[role="alert"]').text()).toBe('Selecione uma duração')
    useQuestionario().definirDuracao('3h+')
    await clicarBotao(m, 'FINALIZAR')
    expect(m.wrapper.find('[role="alert"]').text()).toBe('Selecione pelo menos uma plataforma de streaming')
    useQuestionario().alternarStreaming('Netflix')
    await clicarBotao(m, 'FINALIZAR')
    await vi.waitFor(() => expect(m.router.currentRoute.value.name).toBe('sugestoes'))
    m.wrapper.unmount()
  })

  it('o campo de ator grava a resposta', async () => {
    const m = await abrir('/questionario/8')
    await m.wrapper.find('#campo-ator').setValue('Helena')
    expect(useQuestionario().respostas.ator).toBe('Helena')
    m.wrapper.unmount()
  })

  it('LIMPAR zera as respostas e volta ao passo 1', async () => {
    useQuestionario().alternarGenero('Drama')
    useQuestionario().definirAtor('Helena')
    const m = await abrir('/questionario/8')
    await clicarBotao(m, 'LIMPAR')
    expect(useQuestionario().respostas.generos).toEqual([])
    expect(useQuestionario().respostas.ator).toBe('')
    expect(m.router.currentRoute.value.params.passo).toBe('1')
    m.wrapper.unmount()
  })

  it('✕ sai para o início', async () => {
    const m = await abrir('/questionario/4')
    expect(m.wrapper.find('.fechar').attributes('href')).toBe('/inicio')
    m.wrapper.unmount()
  })

  it('"voltar" do navegador volta um passo', async () => {
    const m = await abrir('/questionario/2')
    await proximo(m)
    expect(titulo(m)).toBe('Qual a duração de filme ideal pra você?')
    m.router.back()
    await vi.waitFor(() => expect(m.router.currentRoute.value.params.passo).toBe('2'))
    await flushPromises()
    expect(titulo(m)).toBe('Quais gêneros você gosta?')
    m.wrapper.unmount()
  })

  it('ao trocar de passo o foco vai para o título', async () => {
    const m = await abrir('/questionario/2')
    await proximo(m)
    expect(document.activeElement?.textContent?.trim()).toBe('Qual a duração de filme ideal pra você?')
    m.wrapper.unmount()
  })

  it('as respostas sobrevivem a recarregar a página (F5)', async () => {
    const a = await abrir('/questionario/2')
    await marcar(a, 'Terror')
    a.wrapper.unmount()
    const b = await abrir('/questionario/2')
    const terror = b.wrapper.findAll('label.chip').find((l) => l.text() === 'Terror')!
    expect((terror.find('input').element as HTMLInputElement).checked).toBe(true)
    b.wrapper.unmount()
  })
})
