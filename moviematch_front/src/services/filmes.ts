// Catálogo de filmes. Endpoints confirmados em moviematch_back/.../controller/FilmeController.java.
// Não existe GET /filmes/{id}: o detalhe é obtido do catálogo completo (useCatalogo).
import { caminhoApi, getJson } from './http'
import { mapearFilme, mapearLista } from './mapeadores'
import type { Filme, ResultadoLista } from '../types/modelos'

export interface OpcoesConsulta {
  signal?: AbortSignal
}

async function listar(caminho: string, opcoes?: OpcoesConsulta): Promise<ResultadoLista<Filme>> {
  return mapearLista(await getJson(caminho, opcoes), mapearFilme)
}

/** GET /filmes: catálogo completo. */
export function listarTodos(opcoes?: OpcoesConsulta) {
  return listar('/filmes', opcoes)
}

/** GET /filmes/aleatorios: até 5 filmes embaralhados pelo backend. */
export function aleatorios(opcoes?: OpcoesConsulta) {
  return listar('/filmes/aleatorios', opcoes)
}

/** GET /filmes/streaming/{valor}: igualdade exata no backend. */
export function porStreaming(valor: string, opcoes?: OpcoesConsulta) {
  // "outros" é uma rota própria do backend, não um streaming: use outros().
  if (valor === 'outros') throw new RangeError('use outros() para a categoria "Outros streamings"')
  return listar(caminhoApi('filmes', 'streaming', valor), opcoes)
}

/** GET /filmes/streaming/outros: filmes fora dos 7 streamings fixos do backend. */
export function outros(opcoes?: OpcoesConsulta) {
  return listar('/filmes/streaming/outros', opcoes)
}

/** GET /filmes/pesquisa/{termo}: título contém o termo, sem diferenciar maiúsculas. */
export function pesquisar(termo: string, opcoes?: OpcoesConsulta) {
  return listar(caminhoApi('filmes', 'pesquisa', termo), opcoes)
}
