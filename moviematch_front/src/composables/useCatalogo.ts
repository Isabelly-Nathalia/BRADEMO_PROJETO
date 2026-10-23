// Cache em memória do catálogo completo (GET /filmes).
// Justificativa: não existe GET /filmes/{id}; detalhe e sugestões precisam do catálogo inteiro.
// Regras: TTL de 5 min · pedidos simultâneos compartilham uma requisição · erro nunca fica em cache ·
// invalidar() antes de "Tentar novamente". A requisição compartilhada não é cancelada por um
// consumidor; uma página desmontada simplesmente ignora o resultado.
import { listarTodos } from '../services/filmes'
import type { Filme, ResultadoLista } from '../types/modelos'

export const TTL_CATALOGO_MS = 5 * 60 * 1000

let cache: { promessa: Promise<ResultadoLista<Filme>>; criadoEm: number } | null = null

function obter(): Promise<ResultadoLista<Filme>> {
  const agora = Date.now()
  if (cache && agora - cache.criadoEm < TTL_CATALOGO_MS) return cache.promessa

  const promessa = listarTodos()
  cache = { promessa, criadoEm: agora }
  promessa.catch(() => {
    if (cache?.promessa === promessa) cache = null
  })
  return promessa
}

async function porId(id: number): Promise<Filme | undefined> {
  const { itens } = await obter()
  return itens.find((filme) => filme.id === id)
}

function invalidar(): void {
  cache = null
}

export function useCatalogo() {
  return { obter, porId, invalidar }
}
