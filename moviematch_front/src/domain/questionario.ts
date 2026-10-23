// Opções do questionário, idênticas ao Flutter (projeto_brademo/lib/screens/form/form.dart:20-66),
// inclusive ordem, grafia e acentos (NFC). Os valores são comparados por igualdade exata com os
// dados da API na pontuação (domain/recomendacao.ts).
// A-03: os campos livres "Outro streaming" e "Outro país" não existem aqui; no Flutter eles não
// tinham controller nem onChanged, ou seja, nunca pontuaram.

export const GENEROS = [
  'Ação',
  'Aventura',
  'Comédia',
  'Drama',
  'Romance',
  'Terror',
  'Ficção',
  'Fantasia',
  'Animação',
  'Documentário',
  'Mistério',
  'Musical',
] as const

export const DURACOES = ['Até 1h30', '1h30 - 2h', '2h - 3h', '3h+'] as const

// A-05: grafias do Flutter mantidas ("AppleTV", "GloboPlay"), mesmo divergindo da Home
// e do backend. Se elas casam com os dados reais é BLOQUEADO até haver dados (perfil C).
export const STREAMINGS = ['Netflix', 'Prime Video', 'Disney+', 'HBO Max', 'AppleTV', 'GloboPlay'] as const

export const CLASSIFICACOES = [
  'Livre',
  'Não recomendável para menores de 10 anos',
  'Não recomendável para menores de 12 anos',
  'Não recomendável para menores de 14 anos',
  'Não recomendável para menores de 16 anos',
  '18+',
] as const

export const PAISES = [
  'Argentina',
  'Brasil',
  'Canadá',
  'China',
  'Coreia do Sul',
  'Estados Unidos',
  'França',
  'Itália',
  'Japão',
  'Portugal',
] as const

export type Genero = (typeof GENEROS)[number]
export type Duracao = (typeof DURACOES)[number]
export type StreamingQuestionario = (typeof STREAMINGS)[number]
export type Classificacao = (typeof CLASSIFICACOES)[number]
export type Pais = (typeof PAISES)[number]

/** Respostas do questionário (equivale ao estado do FormProvider do Flutter). */
export interface Respostas {
  generos: Genero[]
  duracao: Duracao | null
  streamings: StreamingQuestionario[]
  classificacao: Classificacao | null
  paises: Pais[]
  ator: string
}

/** Respostas para quem só lê (ex.: a regra de recomendação), sem exigir listas mutáveis. */
export type RespostasLeitura = {
  readonly [K in keyof Respostas]: Respostas[K] extends Array<infer U> ? readonly U[] : Respostas[K]
}

export function respostasVazias(): Respostas {
  return { generos: [], duracao: null, streamings: [], classificacao: null, paises: [], ator: '' }
}
