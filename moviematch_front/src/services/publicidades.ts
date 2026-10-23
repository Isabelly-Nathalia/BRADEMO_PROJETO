// GET /publicidades (moviematch_back/.../controller/PublicidadeController.java).
import { getJson } from './http'
import { mapearLista, mapearPublicidade } from './mapeadores'
import type { OpcoesConsulta } from './filmes'
import type { Publicidade, ResultadoLista } from '../types/modelos'

export async function listarPublicidades(opcoes?: OpcoesConsulta): Promise<ResultadoLista<Publicidade>> {
  return mapearLista(await getJson('/publicidades', opcoes), mapearPublicidade)
}
