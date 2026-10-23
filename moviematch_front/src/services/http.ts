// Cliente HTTP do frontend: somente GET, via proxy de mesma origem (/api).
// Timeout explícito, cancelamento, limite de corpo e erros tipados.
// Não há retry automático: a interface oferece "Tentar novamente".

export type ErroApi =
  | { tipo: 'rede' }
  | { tipo: 'timeout' }
  | { tipo: 'http'; status: number }
  | { tipo: 'formato'; detalhe: string }
  | { tipo: 'cancelado' }

export class FalhaApi extends Error {
  readonly erro: ErroApi

  constructor(erro: ErroApi) {
    super(`falha na API: ${erro.tipo}`)
    this.name = 'FalhaApi'
    this.erro = erro
  }
}

export const TIMEOUT_PADRAO_MS = 30_000
// Hipótese a recalibrar com o tamanho real de GET /filmes (plano, seção 4.4).
export const LIMITE_CORPO_BYTES = 5 * 1024 * 1024

const BASE = import.meta.env.VITE_API_BASE ?? '/api'

export interface OpcoesGet {
  timeoutMs?: number
  signal?: AbortSignal
  limiteBytes?: number
}

/**
 * Monta um caminho da API codificando cada segmento dinâmico.
 * Recusa segmentos vazios, "." e "..", e segmentos com "/": a API recebe esses valores
 * no caminho, e uma barra mudaria a rota.
 */
export function caminhoApi(...segmentos: string[]): string {
  return segmentos
    .map((segmento) => {
      if (segmento === '' || segmento === '.' || segmento === '..' || segmento.includes('/')) {
        throw new RangeError(`segmento de caminho inválido: ${JSON.stringify(segmento)}`)
      }
      return `/${encodeURIComponent(segmento)}`
    })
    .join('')
}

async function lerCorpo(resposta: Response, limite: number): Promise<string> {
  const declarado = Number(resposta.headers.get('content-length'))
  if (Number.isFinite(declarado) && declarado > limite) {
    throw new FalhaApi({ tipo: 'formato', detalhe: 'corpo acima do limite' })
  }
  if (!resposta.body) return ''

  const leitor = resposta.body.getReader()
  const partes: Uint8Array[] = []
  let total = 0
  for (;;) {
    const { done, value } = await leitor.read()
    if (done) break
    total += value.byteLength
    if (total > limite) {
      await leitor.cancel()
      throw new FalhaApi({ tipo: 'formato', detalhe: 'corpo acima do limite' })
    }
    partes.push(value)
  }
  const bytes = new Uint8Array(total)
  let posicao = 0
  for (const parte of partes) {
    bytes.set(parte, posicao)
    posicao += parte.byteLength
  }
  return new TextDecoder('utf-8').decode(bytes)
}

/** GET que devolve o JSON da resposta como `unknown`; quem chama valida a forma. */
export async function getJson(caminho: string, opcoes: OpcoesGet = {}): Promise<unknown> {
  const { timeoutMs = TIMEOUT_PADRAO_MS, signal, limiteBytes = LIMITE_CORPO_BYTES } = opcoes

  if (signal?.aborted) throw new FalhaApi({ tipo: 'cancelado' })

  const controle = new AbortController()
  let expirou = false
  const temporizador = setTimeout(() => {
    expirou = true
    controle.abort()
  }, timeoutMs)
  const aoCancelar = () => controle.abort()
  signal?.addEventListener('abort', aoCancelar, { once: true })

  const motivoDoAbort = (): ErroApi => (expirou ? { tipo: 'timeout' } : { tipo: 'cancelado' })

  try {
    let resposta: Response
    try {
      resposta = await fetch(`${BASE}${caminho}`, {
        method: 'GET',
        headers: { Accept: 'application/json' },
        credentials: 'omit',
        signal: controle.signal,
      })
    } catch {
      throw new FalhaApi(controle.signal.aborted ? motivoDoAbort() : { tipo: 'rede' })
    }

    if (!resposta.ok) throw new FalhaApi({ tipo: 'http', status: resposta.status })

    let texto: string
    try {
      texto = await lerCorpo(resposta, limiteBytes)
    } catch (erro) {
      if (erro instanceof FalhaApi) throw erro
      throw new FalhaApi(controle.signal.aborted ? motivoDoAbort() : { tipo: 'rede' })
    }

    if (texto.trim() === '') throw new FalhaApi({ tipo: 'formato', detalhe: 'corpo vazio' })
    try {
      return JSON.parse(texto) as unknown
    } catch {
      throw new FalhaApi({ tipo: 'formato', detalhe: 'JSON inválido' })
    }
  } finally {
    clearTimeout(temporizador)
    signal?.removeEventListener('abort', aoCancelar)
  }
}
