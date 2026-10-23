// Regra de recomendação: paridade exata com o Flutter
// (projeto_brademo/lib/screens/form/sugestao.dart:42-113). Nenhuma correção silenciosa:
//   - comparações exatas e sensíveis a maiúsculas (gênero, streaming, classificação, país);
//   - ator/diretor: substring sem diferenciar maiúsculas, SEM trim e sem remover acentos;
//   - filmes com 0 ponto entram no top 3;
//   - empate preserva a ordem de entrada (sort estável). No Dart a estabilidade não é garantida,
//     então isto é uma definição, não uma equivalência comprovada.
import type { RespostasLeitura } from './questionario'
import type { Filme } from '../types/modelos'

export const PESOS = Object.freeze({ genero: 3, duracao: 2, streaming: 3, classificacao: 2, pais: 1, atorOuDiretor: 1 })

export type FilmePontuavel = Pick<
  Filme,
  'generos' | 'duracaoMin' | 'streaming' | 'classificacao' | 'nacionalidade' | 'diretor' | 'atores'
>

function duracaoNaFaixa(faixa: RespostasLeitura['duracao'], minutos: number | null): boolean {
  // A-07: sem duração informada, o filme não pontua por duração.
  if (minutos === null) return false
  switch (faixa) {
    case 'Até 1h30':
      return minutos <= 90
    case '1h30 - 2h':
      return minutos > 90 && minutos <= 120
    case '2h - 3h':
      return minutos > 120 && minutos <= 180
    case '3h+':
      return minutos > 180
    case null:
      return false
  }
}

export function calcularPontuacao(filme: FilmePontuavel, respostas: RespostasLeitura): number {
  const contem = (lista: readonly string[], valor: string) => lista.includes(valor)
  let pontos = 0

  if (filme.generos.some((g) => contem(respostas.generos, g))) pontos += PESOS.genero
  if (duracaoNaFaixa(respostas.duracao, filme.duracaoMin)) pontos += PESOS.duracao
  if (contem(respostas.streamings, filme.streaming)) pontos += PESOS.streaming
  if (respostas.classificacao === filme.classificacao) pontos += PESOS.classificacao
  if (contem(respostas.paises, filme.nacionalidade)) pontos += PESOS.pais
  if (respostas.ator !== '') {
    const busca = respostas.ator.toLowerCase()
    if (filme.diretor.toLowerCase().includes(busca) || filme.atores.toLowerCase().includes(busca)) {
      pontos += PESOS.atorOuDiretor
    }
  }
  return pontos
}

/** Os `quantidade` filmes de maior pontuação, em ordem decrescente; empate mantém a ordem de entrada. */
export function ordenarSugestoes<T extends FilmePontuavel>(filmes: readonly T[], respostas: RespostasLeitura, quantidade = 3): T[] {
  return filmes
    .map((filme) => ({ filme, pontos: calcularPontuacao(filme, respostas) }))
    .sort((a, b) => b.pontos - a.pontos)
    .slice(0, quantidade)
    .map(({ filme }) => filme)
}
