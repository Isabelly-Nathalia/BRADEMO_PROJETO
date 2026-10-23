import { describe, expect, it } from 'vitest'
import { CHAVE_QUESTIONARIO, ERROS_VALIDACAO, criarQuestionario, useQuestionario } from '../../src/composables/useQuestionario'

/** Storage em memória; `falhar` faz todas as operações lançarem (modo privado, bloqueio). */
function armazenamentoFalso(inicial: Record<string, string> = {}, falhar = false) {
  const dados = new Map(Object.entries(inicial))
  const verificar = () => {
    if (falhar) throw new DOMException('bloqueado', 'SecurityError')
  }
  const storage = {
    getItem: (k: string) => (verificar(), dados.get(k) ?? null),
    setItem: (k: string, v: string) => (verificar(), void dados.set(k, v)),
    removeItem: (k: string) => (verificar(), void dados.delete(k)),
    clear: () => dados.clear(),
    key: () => null,
    get length() {
      return dados.size
    },
  } satisfies Storage
  return { storage, dados }
}

const salvo = (dados: Map<string, string>) => JSON.parse(dados.get(CHAVE_QUESTIONARIO) ?? 'null')

describe('useQuestionario', () => {
  it('começa vazio sem nada salvo', () => {
    const { storage } = armazenamentoFalso()
    expect(criarQuestionario(() => storage).respostas).toEqual({
      generos: [],
      duracao: null,
      streamings: [],
      classificacao: null,
      paises: [],
      ator: '',
    })
  })

  it('alterna gênero, streaming e país (marcar e desmarcar)', () => {
    const { storage } = armazenamentoFalso()
    const q = criarQuestionario(() => storage)
    q.alternarGenero('Drama')
    q.alternarGenero('Ação')
    q.alternarGenero('Drama')
    q.alternarStreaming('Netflix')
    q.alternarPais('Brasil')
    q.alternarPais('Japão')
    q.alternarPais('Brasil')
    expect(q.respostas.generos).toEqual(['Ação'])
    expect(q.respostas.streamings).toEqual(['Netflix'])
    expect(q.respostas.paises).toEqual(['Japão'])
  })

  it('duração é única; classificação desmarca ao clicar de novo', () => {
    const { storage } = armazenamentoFalso()
    const q = criarQuestionario(() => storage)
    q.definirDuracao('3h+')
    q.definirDuracao('2h - 3h')
    expect(q.respostas.duracao).toBe('2h - 3h')
    q.alternarClassificacao('Livre')
    expect(q.respostas.classificacao).toBe('Livre')
    q.alternarClassificacao('18+')
    expect(q.respostas.classificacao).toBe('18+')
    q.alternarClassificacao('18+')
    expect(q.respostas.classificacao).toBeNull()
  })

  it('salva a cada mudança e restaura numa nova instância', () => {
    const { storage, dados } = armazenamentoFalso()
    const q = criarQuestionario(() => storage)
    q.alternarGenero('Ficção')
    q.definirDuracao('Até 1h30')
    q.definirAtor('Helena')
    expect(salvo(dados)).toMatchObject({ versao: 1, respostas: { generos: ['Ficção'], ator: 'Helena' } })
    const restaurado = criarQuestionario(() => storage)
    expect(restaurado.respostas).toMatchObject({ generos: ['Ficção'], duracao: 'Até 1h30', ator: 'Helena' })
  })

  it('limpar zera as respostas e remove o dado salvo', () => {
    const { storage, dados } = armazenamentoFalso()
    const q = criarQuestionario(() => storage)
    q.alternarGenero('Drama')
    q.limpar()
    expect(q.respostas.generos).toEqual([])
    expect(dados.has(CHAVE_QUESTIONARIO)).toBe(false)
  })

  it.each([
    ['JSON corrompido', '{"versao":1,"respostas":'],
    ['versão desconhecida', JSON.stringify({ versao: 2, respostas: { generos: ['Drama'] } })],
    ['raiz não-objeto', '"texto"'],
    ['respostas ausentes', JSON.stringify({ versao: 1 })],
  ])('%s → começa vazio, sem erro', (_caso, conteudo) => {
    const { storage } = armazenamentoFalso({ [CHAVE_QUESTIONARIO]: conteudo })
    expect(criarQuestionario(() => storage).respostas.generos).toEqual([])
  })

  it('descarta valores salvos que não são opções válidas', () => {
    const { storage } = armazenamentoFalso({
      [CHAVE_QUESTIONARIO]: JSON.stringify({
        versao: 1,
        respostas: {
          generos: ['Drama', 'Inventado', 'Drama', 42],
          duracao: '5h',
          streamings: 'Netflix',
          classificacao: 'Livre',
          paises: ['Brasil', 'Atlântida'],
          ator: 7,
        },
      }),
    })
    expect(criarQuestionario(() => storage).respostas).toEqual({
      generos: ['Drama'],
      duracao: null,
      streamings: [],
      classificacao: 'Livre',
      paises: ['Brasil'],
      ator: '',
    })
  })

  it('armazenamento que lança exceção: funciona só em memória', () => {
    const { storage } = armazenamentoFalso({}, true)
    const q = criarQuestionario(() => storage)
    q.alternarGenero('Drama')
    q.limpar()
    q.alternarStreaming('Netflix')
    expect(q.respostas.streamings).toEqual(['Netflix'])
  })

  it('sem armazenamento disponível: funciona só em memória', () => {
    const q = criarQuestionario(() => null)
    q.alternarGenero('Drama')
    expect(q.respostas.generos).toEqual(['Drama'])
  })

  it('valida na ordem do Flutter, com os textos literais', () => {
    const { storage } = armazenamentoFalso()
    const q = criarQuestionario(() => storage)
    expect(q.validar()).toBe(ERROS_VALIDACAO.genero)
    q.alternarGenero('Drama')
    expect(q.validar()).toBe('Selecione uma duração')
    q.definirDuracao('3h+')
    expect(q.validar()).toBe('Selecione pelo menos uma plataforma de streaming')
    q.alternarStreaming('HBO Max')
    expect(q.validar()).toBeNull()
  })

  it('classificação, países e ator são opcionais', () => {
    const { storage } = armazenamentoFalso()
    const q = criarQuestionario(() => storage)
    q.alternarGenero('Drama')
    q.definirDuracao('3h+')
    q.alternarStreaming('Netflix')
    expect(q.respostas.classificacao).toBeNull()
    expect(q.validar()).toBeNull()
  })

  it('as respostas expostas são somente leitura', () => {
    const { storage } = armazenamentoFalso()
    const q = criarQuestionario(() => storage)
    // @ts-expect-error: readonly
    q.respostas.ator = 'x'
    expect(q.respostas.ator).toBe('')
  })

  it('useQuestionario devolve sempre a mesma instância', () => {
    expect(useQuestionario()).toBe(useQuestionario())
  })
})
