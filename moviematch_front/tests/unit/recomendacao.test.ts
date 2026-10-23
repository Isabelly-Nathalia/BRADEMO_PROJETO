// Casos tabelados da regra de recomendação (plano, F3-T04), em paridade com sugestao.dart:42-113.
import { describe, expect, it } from 'vitest'
import { PESOS, calcularPontuacao, ordenarSugestoes, type FilmePontuavel } from '../../src/domain/recomendacao'
import { respostasVazias, type Respostas } from '../../src/domain/questionario'

// Filme neutro: não pontua com respostas vazias nem por acaso.
function filme(parcial: Partial<FilmePontuavel> = {}): FilmePontuavel {
  return {
    generos: ['Western'],
    duracaoMin: 0,
    streaming: 'Nenhum',
    classificacao: 'Sem classificação',
    nacionalidade: 'Lugar Nenhum',
    diretor: 'Fulano',
    atores: 'Beltrano',
    ...parcial,
  }
}

function respostas(parcial: Partial<Respostas> = {}): Respostas {
  return { ...respostasVazias(), ...parcial }
}

describe('calcularPontuacao', () => {
  it.each<[string, Partial<FilmePontuavel>, Partial<Respostas>, number]>([
    ['1 · gênero coincide', { generos: ['Drama'] }, { generos: ['Drama'] }, 3],
    ['2 · dois gêneros coincidem: não soma por gênero', { generos: ['Drama', 'Ação'] }, { generos: ['Ação', 'Drama'] }, 3],
    ['3 · gênero diferencia maiúsculas', { generos: ['drama'] }, { generos: ['Drama'] }, 0],
    ['4 · 90 min em "Até 1h30"', { duracaoMin: 90 }, { duracao: 'Até 1h30' }, 2],
    ['5 · 91 min em "1h30 - 2h"', { duracaoMin: 91 }, { duracao: '1h30 - 2h' }, 2],
    ['6 · 180 min em "2h - 3h"', { duracaoMin: 180 }, { duracao: '2h - 3h' }, 2],
    ['7 · 181 min em "3h+"', { duracaoMin: 181 }, { duracao: '3h+' }, 2],
    ['8 · 90 min fora de "1h30 - 2h" (limite)', { duracaoMin: 90 }, { duracao: '1h30 - 2h' }, 0],
    ['9 · "Apple TV" do filme × "AppleTV" do questionário', { streaming: 'Apple TV' }, { streamings: ['AppleTV'] }, 0],
    ['10 · classificação igual', { classificacao: 'Livre' }, { classificacao: 'Livre' }, 2],
    ['11 · país igual', { nacionalidade: 'Brasil' }, { paises: ['Brasil'] }, 1],
    ['12 · ator encontrado no diretor', { diretor: 'Walter Prado' }, { ator: 'walter' }, 1],
    ['13 · ator encontrado no elenco', { atores: 'Helena Prado, Marisa Luz' }, { ator: 'MARISA' }, 1],
    ['14 · sem remover acentos', { diretor: 'Conceição Alves' }, { ator: 'conceicao' }, 0],
  ])('%s → %i', (_caso, f, r, esperado) => {
    expect(calcularPontuacao(filme(f), respostas(r))).toBe(esperado)
  })

  it('15 · ator só com espaços não é vazio (sem trim, como no Dart)', () => {
    expect(calcularPontuacao(filme({ atores: 'Ana  Lima' }), respostas({ ator: '  ' }))).toBe(1)
    expect(calcularPontuacao(filme({ atores: 'Ana Lima' }), respostas({ ator: '  ' }))).toBe(0)
  })

  it('16 · todos os critérios: 12 pontos', () => {
    const completo = filme({
      generos: ['Drama'],
      duracaoMin: 100,
      streaming: 'Netflix',
      classificacao: 'Livre',
      nacionalidade: 'Brasil',
      diretor: 'Ana Ribeiro',
    })
    const todas = respostas({
      generos: ['Drama'],
      duracao: '1h30 - 2h',
      streamings: ['Netflix'],
      classificacao: 'Livre',
      paises: ['Brasil'],
      ator: 'ribeiro',
    })
    expect(calcularPontuacao(completo, todas)).toBe(12)
    expect(Object.values(PESOS).reduce((a, b) => a + b, 0)).toBe(12)
  })

  it('respostas vazias não pontuam um filme neutro', () => {
    expect(calcularPontuacao(filme(), respostasVazias())).toBe(0)
  })

  it('classificação nula não casa com classificação vazia vinda da API', () => {
    expect(calcularPontuacao(filme({ classificacao: '' }), respostas({ classificacao: null }))).toBe(0)
  })
})

describe('ordenarSugestoes', () => {
  const nomeado = (titulo: string, parcial: Partial<FilmePontuavel> = {}) => ({ titulo, ...filme(parcial) })

  it('17 · com 2 filmes devolve os 2', () => {
    expect(ordenarSugestoes([nomeado('A'), nomeado('B')], respostasVazias())).toHaveLength(2)
  })

  it('18 · empate preserva a ordem de entrada', () => {
    const filmes = [nomeado('A'), nomeado('B'), nomeado('C'), nomeado('D')]
    expect(ordenarSugestoes(filmes, respostasVazias()).map((f) => f.titulo)).toEqual(['A', 'B', 'C'])
  })

  it('19 · sem filmes devolve lista vazia', () => {
    expect(ordenarSugestoes([], respostasVazias())).toEqual([])
  })

  it('20 · filme com 0 ponto entra no top 3', () => {
    const r = respostas({ generos: ['Drama'] })
    const filmes = [nomeado('Zero1'), nomeado('Drama', { generos: ['Drama'] }), nomeado('Zero2')]
    expect(ordenarSugestoes(filmes, r).map((f) => f.titulo)).toEqual(['Drama', 'Zero1', 'Zero2'])
  })

  it('ordena por pontuação decrescente e corta em 3', () => {
    const r = respostas({ generos: ['Drama'], streamings: ['Netflix'], paises: ['Brasil'] })
    const filmes = [
      nomeado('1pt', { nacionalidade: 'Brasil' }),
      nomeado('7pt', { generos: ['Drama'], streaming: 'Netflix', nacionalidade: 'Brasil' }),
      nomeado('0pt'),
      nomeado('3pt', { streaming: 'Netflix' }),
      nomeado('6pt', { generos: ['Drama'], streaming: 'Netflix' }),
    ]
    expect(ordenarSugestoes(filmes, r).map((f) => f.titulo)).toEqual(['7pt', '6pt', '3pt'])
  })

  it('não altera a lista recebida', () => {
    const filmes = [nomeado('A'), nomeado('B', { generos: ['Drama'] })]
    const copia = [...filmes]
    ordenarSugestoes(filmes, respostas({ generos: ['Drama'] }))
    expect(filmes).toEqual(copia)
  })

  it('preserva o tipo completo do filme (não só os campos pontuáveis)', () => {
    const [primeiro] = ordenarSugestoes([nomeado('Com título')], respostasVazias())
    expect(primeiro?.titulo).toBe('Com título')
  })
})
