import { afterEach, describe, expect, it, vi } from 'vitest'
import { FalhaApi, caminhoApi, getJson, type ErroApi } from '../../src/services/http'

type Chamada = { url: string; init: RequestInit }

function simularFetch(responder: (chamada: Chamada) => Promise<Response> | Response) {
  const chamadas: Chamada[] = []
  vi.stubGlobal(
    'fetch',
    vi.fn((url: string, init: RequestInit) => {
      const chamada = { url, init }
      chamadas.push(chamada)
      return Promise.resolve(responder(chamada))
    }),
  )
  return chamadas
}

/** fetch que só termina quando o sinal é abortado (servidor pendurado). */
function simularFetchPendurado() {
  vi.stubGlobal(
    'fetch',
    vi.fn(
      (_url: string, init: RequestInit) =>
        new Promise<Response>((_ok, falha) => {
          init.signal?.addEventListener('abort', () => falha(new DOMException('abortado', 'AbortError')))
        }),
    ),
  )
}

async function erroDe(promessa: Promise<unknown>): Promise<ErroApi> {
  try {
    await promessa
  } catch (erro) {
    if (erro instanceof FalhaApi) return erro.erro
    throw erro
  }
  throw new Error('esperava FalhaApi, mas a promessa foi resolvida')
}

function corpoEmPedacos(pedacos: number, tamanho: number): ReadableStream<Uint8Array> {
  let enviados = 0
  return new ReadableStream({
    pull(controlador) {
      if (enviados++ >= pedacos) return controlador.close()
      controlador.enqueue(new Uint8Array(tamanho).fill(0x20))
    },
  })
}

afterEach(() => {
  vi.useRealTimers()
})

describe('getJson', () => {
  it('faz GET em /api + caminho, sem credenciais, e devolve o JSON', async () => {
    const chamadas = simularFetch(() => Response.json([{ id_filme: 1 }]))
    await expect(getJson('/filmes')).resolves.toEqual([{ id_filme: 1 }])
    expect(chamadas[0]!.url).toBe('/api/filmes')
    expect(chamadas[0]!.init.method).toBe('GET')
    expect(chamadas[0]!.init.credentials).toBe('omit')
  })

  it.each([404, 500, 502, 504])('status %i → erro http com o status', async (status) => {
    simularFetch(() => new Response('erro', { status }))
    expect(await erroDe(getJson('/filmes'))).toEqual({ tipo: 'http', status })
  })

  it('JSON malformado → erro de formato', async () => {
    simularFetch(() => new Response('[{"id_filme": 1,'))
    expect(await erroDe(getJson('/filmes'))).toEqual({ tipo: 'formato', detalhe: 'JSON inválido' })
  })

  it('corpo vazio (ex.: login com falha do backend) → erro de formato', async () => {
    simularFetch(() => new Response(''))
    expect(await erroDe(getJson('/filmes'))).toEqual({ tipo: 'formato', detalhe: 'corpo vazio' })
  })

  it('Content-Length acima do limite → erro sem ler o corpo', async () => {
    simularFetch(() => new Response('[]', { headers: { 'content-length': String(10 * 1024 * 1024) } }))
    expect(await erroDe(getJson('/filmes'))).toEqual({ tipo: 'formato', detalhe: 'corpo acima do limite' })
  })

  it('corpo em streaming acima do limite, sem Content-Length → erro', async () => {
    simularFetch(() => new Response(corpoEmPedacos(10, 1024)))
    expect(await erroDe(getJson('/filmes', { limiteBytes: 4096 }))).toEqual({
      tipo: 'formato',
      detalhe: 'corpo acima do limite',
    })
  })

  it('corpo dentro do limite é lido por inteiro', async () => {
    const json = JSON.stringify([{ titulo_filme: 'Ação e reação' }])
    simularFetch(() => new Response(json))
    await expect(getJson('/filmes', { limiteBytes: json.length * 4 })).resolves.toEqual([{ titulo_filme: 'Ação e reação' }])
  })

  it('servidor pendurado → timeout após 30 s, não antes', async () => {
    vi.useFakeTimers()
    simularFetchPendurado()
    const promessa = erroDe(getJson('/filmes'))
    let terminou = false
    void promessa.then(() => (terminou = true))
    await vi.advanceTimersByTimeAsync(29_999)
    expect(terminou).toBe(false)
    await vi.advanceTimersByTimeAsync(1)
    expect(await promessa).toEqual({ tipo: 'timeout' })
  })

  it('cabeçalhos chegam mas o corpo trava → timeout (o prazo cobre a leitura do corpo)', async () => {
    vi.useFakeTimers()
    // Como no navegador: abortar o sinal interrompe o stream do corpo.
    simularFetch(({ init }) => {
      const corpo = new ReadableStream<Uint8Array>({
        start(controlador) {
          controlador.enqueue(new TextEncoder().encode('[{"id_filme":'))
          init.signal?.addEventListener('abort', () => controlador.error(new DOMException('abortado', 'AbortError')))
        },
      })
      return new Response(corpo)
    })
    const promessa = erroDe(getJson('/filmes'))
    await vi.advanceTimersByTimeAsync(30_000)
    expect(await promessa).toEqual({ tipo: 'timeout' })
  })

  it('cancelamento externo → erro cancelado (não timeout)', async () => {
    simularFetchPendurado()
    const controle = new AbortController()
    const promessa = erroDe(getJson('/filmes', { signal: controle.signal }))
    controle.abort()
    expect(await promessa).toEqual({ tipo: 'cancelado' })
  })

  it('sinal já abortado → cancelado sem chamar fetch', async () => {
    const chamadas = simularFetch(() => Response.json([]))
    const controle = new AbortController()
    controle.abort()
    expect(await erroDe(getJson('/filmes', { signal: controle.signal }))).toEqual({ tipo: 'cancelado' })
    expect(chamadas).toHaveLength(0)
  })

  it('falha de rede → erro de rede', async () => {
    vi.stubGlobal('fetch', vi.fn(() => Promise.reject(new TypeError('Failed to fetch'))))
    expect(await erroDe(getJson('/filmes'))).toEqual({ tipo: 'rede' })
  })
})

describe('caminhoApi', () => {
  it('codifica cada segmento (Disney+ → Disney%2B; espaço e acentos)', () => {
    expect(caminhoApi('filmes', 'streaming', 'Disney+')).toBe('/filmes/streaming/Disney%2B')
    expect(caminhoApi('filmes', 'pesquisa', 'ação x')).toBe('/filmes/pesquisa/a%C3%A7%C3%A3o%20x')
  })

  it.each(['a/b', '/', '', '.', '..'])('recusa o segmento %j', (segmento) => {
    expect(() => caminhoApi('filmes', 'pesquisa', segmento)).toThrow(RangeError)
  })
})
