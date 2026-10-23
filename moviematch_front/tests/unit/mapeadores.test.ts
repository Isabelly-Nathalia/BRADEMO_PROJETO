import { describe, expect, it, vi } from 'vitest'
import { FalhaApi } from '../../src/services/http'
import { mapearFilme, mapearLista, mapearPublicidade, separarElenco } from '../../src/services/mapeadores'
import type { FilmeApi } from '../../src/types/contrato'
import validos from '../fixtures/filmes-validos.json'
import comInvalidos from '../fixtures/filmes-com-invalidos.json'
import todosInvalidos from '../fixtures/filmes-todos-invalidos.json'
import vazio from '../fixtures/filmes-vazio.json'
import repetidos from '../fixtures/filmes-repetidos.json'
import objetoNaRaiz from '../fixtures/objeto-na-raiz.json'
import publicidades from '../fixtures/publicidades.json'

const BASE: FilmeApi = validos[0]!

function falhaDe(fn: () => unknown) {
  try {
    fn()
  } catch (erro) {
    if (erro instanceof FalhaApi) return erro.erro
    throw erro
  }
  throw new Error('esperava FalhaApi')
}

describe('mapearFilme', () => {
  it('converte o contrato em modelo interno sem campos da API', () => {
    expect(mapearFilme(BASE)).toEqual({
      id: 1,
      titulo: 'Cidade Partida',
      descricao: 'Dois amigos seguem caminhos opostos numa cidade dividida.',
      imagem: 'https://img.exemplo.invalid/filmes/1.jpg',
      duracaoMin: 130,
      streaming: 'Netflix',
      nacionalidade: 'Brasil',
      classificacao: 'Não recomendável para menores de 16 anos',
      diretor: 'Ana Ribeiro',
      fotoDiretor: 'https://img.exemplo.invalid/diretores/1.jpg',
      atores: 'Carlos Lima, Bia Torres',
      elenco: ['Carlos Lima', 'Bia Torres'],
      nota: 4.5,
      generos: ['Drama', 'Ação'],
    })
  })

  it.each([
    ['id nulo', { id_filme: null }],
    ['id zero', { id_filme: 0 }],
    ['id negativo', { id_filme: -1 }],
    ['id fracionário', { id_filme: 1.5 }],
    ['id texto', { id_filme: '1' }],
    ['título nulo', { titulo_filme: null }],
    ['título vazio', { titulo_filme: '' }],
    ['título só espaços', { titulo_filme: '   ' }],
    ['duração texto', { duracao_filme: '120' }],
    ['duração objeto', { duracao_filme: {} }],
    ['duração negativa', { duracao_filme: -5 }],
    ['duração fracionária', { duracao_filme: 90.5 }],
    ['nota nula', { nota_filme: null }],
    ['nota texto', { nota_filme: '4.5' }],
    ['nota infinita', { nota_filme: Infinity }],
    ['gêneros texto', { generos: 'Drama' }],
    ['gêneros com não-texto', { generos: ['Drama', 3] }],
    ['diretor número', { diretor_filme: 42 }],
    ['streaming objeto', { streaming_filme: {} }],
  ])('descarta filme com %s', (_caso, alteracao) => {
    expect(mapearFilme({ ...BASE, ...alteracao })).toBeNull()
  })

  it.each([null, undefined, 'texto', 42, [], [BASE]])('descarta item que não é objeto: %j', (item) => {
    expect(mapearFilme(item)).toBeNull()
  })

  it.each([null, undefined])('A-07: duração %s é aceita como não informada', (duracao) => {
    expect(mapearFilme({ ...BASE, duracao_filme: duracao })?.duracaoMin).toBeNull()
  })

  it('aceita opcionais nulos ou ausentes, convertendo para vazio', () => {
    const filme = mapearFilme({
      id_filme: 7,
      titulo_filme: 'Só o essencial',
      duracao_filme: 0,
      nota_filme: 0,
    })
    expect(filme).toMatchObject({
      descricao: '',
      streaming: '',
      nacionalidade: '',
      classificacao: '',
      diretor: '',
      atores: '',
      elenco: [],
      generos: [],
      imagem: null,
      fotoDiretor: null,
    })
  })

  it.each([
    ['http', 'http://img.exemplo.invalid/a.jpg'],
    ['javascript', 'javascript:alert(1)'],
    ['data', 'data:image/png;base64,AAAA'],
    ['relativa', '/a.jpg'],
  ])('URL de imagem %s vira null, sem descartar o filme', (_caso, url) => {
    const filme = mapearFilme({ ...BASE, linkImagemFilme_filme: url, imagemDiretor_filme: url })
    expect(filme?.imagem).toBeNull()
    expect(filme?.fotoDiretor).toBeNull()
  })

  it('não altera o objeto recebido', () => {
    const copia = structuredClone(BASE)
    mapearFilme(copia)
    expect(copia).toEqual(BASE)
  })
})

describe('separarElenco (A-02)', () => {
  it.each([
    ['Carlos Lima, Bia Torres', ['Carlos Lima', 'Bia Torres']],
    ['  a ,, b  ,', ['a', 'b']],
    ['Sozinho', ['Sozinho']],
    ['', []],
    [' , ', []],
  ])('%j → %j', (entrada, esperado) => {
    expect(separarElenco(entrada)).toEqual(esperado)
  })
})

describe('mapearLista', () => {
  it('lista válida: todos os itens, nada descartado', () => {
    const r = mapearLista(validos, mapearFilme)
    expect(r.itens).toHaveLength(13)
    expect(r.descartados).toBe(0)
    expect(r.repetidos).toBe(0)
  })

  it('lista mista: mantém os 5 válidos na ordem e conta os 11 inválidos', () => {
    vi.spyOn(console, 'warn').mockImplementation(() => {})
    const r = mapearLista(comInvalidos, mapearFilme)
    expect(r.itens.map((f) => f.id)).toEqual([1, 20, 2, 21, 3])
    expect(r.descartados).toBe(11)
  })

  it('lista vazia é estado vazio, não erro', () => {
    expect(mapearLista(vazio, mapearFilme)).toEqual({ itens: [], descartados: 0, repetidos: 0 })
  })

  it('todos inválidos é erro sistêmico, não lista vazia', () => {
    expect(falhaDe(() => mapearLista(todosInvalidos, mapearFilme))).toEqual({
      tipo: 'formato',
      detalhe: 'nenhum item válido na resposta',
    })
  })

  it.each([
    ['objeto', objetoNaRaiz],
    ['nulo', null],
    ['texto', 'texto'],
  ])('raiz %s é erro sistêmico', (_caso, raiz) => {
    expect(falhaDe(() => mapearLista(raiz, mapearFilme))).toEqual({
      tipo: 'formato',
      detalhe: 'raiz da resposta não é uma lista',
    })
  })

  it('ids repetidos: mantém o primeiro e conta os repetidos', () => {
    vi.spyOn(console, 'warn').mockImplementation(() => {})
    const r = mapearLista(repetidos, mapearFilme)
    expect(r.itens.map((f) => f.id)).toEqual([1, 2, 3])
    expect(r.itens[0]!.titulo).toBe('Cidade Partida')
    expect(r.repetidos).toBe(1)
  })

  it('avisa no console em desenvolvimento quando ignora itens', () => {
    const aviso = vi.spyOn(console, 'warn').mockImplementation(() => {})
    mapearLista(comInvalidos, mapearFilme)
    expect(aviso).toHaveBeenCalledWith('[api] 11 item(ns) inválido(s) e 0 repetido(s) ignorados')
  })
})

describe('mapearPublicidade', () => {
  it('converte as publicidades', () => {
    expect(mapearLista(publicidades, mapearPublicidade).itens[0]).toEqual({
      id: 1,
      descricao: 'Festival de cinema nacional',
      imagem: 'https://img.exemplo.invalid/publicidade/1.jpg',
    })
  })

  it.each([
    ['id ausente', { descricao: 'x', link_imagem: null }],
    ['descrição número', { id_publicidade: 1, descricao: 3, link_imagem: null }],
  ])('descarta publicidade com %s', (_caso, bruto) => {
    expect(mapearPublicidade(bruto)).toBeNull()
  })

  it('imagem insegura vira null', () => {
    expect(mapearPublicidade({ id_publicidade: 1, descricao: null, link_imagem: 'http://x.invalid/a.jpg' })).toEqual({
      id: 1,
      descricao: '',
      imagem: null,
    })
  })
})
