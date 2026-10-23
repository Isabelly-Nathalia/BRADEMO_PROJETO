import { describe, expect, it, vi } from 'vitest'
import { FalhaApi } from '../../src/services/http'
import { aleatorios, listarTodos, outros, pesquisar, porStreaming } from '../../src/services/filmes'
import { listarPublicidades } from '../../src/services/publicidades'
import validos from '../fixtures/filmes-validos.json'
import publicidades from '../fixtures/publicidades.json'

function simularResposta(corpo: unknown, status = 200) {
  const urls: string[] = []
  vi.stubGlobal(
    'fetch',
    vi.fn((url: string) => {
      urls.push(url)
      return Promise.resolve(new Response(JSON.stringify(corpo), { status }))
    }),
  )
  return urls
}

const CHAMADAS = [
  ['listarTodos', () => listarTodos(), '/api/filmes', validos],
  ['aleatorios', () => aleatorios(), '/api/filmes/aleatorios', validos.slice(0, 5)],
  ['porStreaming', () => porStreaming('Disney+'), '/api/filmes/streaming/Disney%2B', validos.slice(3, 4)],
  ['outros', () => outros(), '/api/filmes/streaming/outros', validos.slice(9, 10)],
  ['pesquisar', () => pesquisar('ação e'), '/api/filmes/pesquisa/a%C3%A7%C3%A3o%20e', validos.slice(11, 12)],
  ['listarPublicidades', () => listarPublicidades(), '/api/publicidades', publicidades],
] as const

describe('serviços de catálogo', () => {
  it.each(CHAMADAS)('%s chama %s e devolve itens mapeados', async (_nome, chamar, urlEsperada, corpo) => {
    const urls = simularResposta(corpo)
    const resultado = await chamar()
    expect(urls).toEqual([urlEsperada])
    expect(resultado.itens).toHaveLength(corpo.length)
    expect(resultado.descartados).toBe(0)
    for (const item of resultado.itens) expect(item).not.toHaveProperty('id_filme')
  })

  it.each(CHAMADAS)('%s propaga erro HTTP como FalhaApi', async (_nome, chamar) => {
    simularResposta({ erro: true }, 500)
    await expect(chamar()).rejects.toEqual(new FalhaApi({ tipo: 'http', status: 500 }))
  })

  it.each(CHAMADAS)('%s rejeita resposta que não é lista', async (_nome, chamar) => {
    simularResposta({ filmes: [] })
    await expect(chamar()).rejects.toBeInstanceOf(FalhaApi)
  })

  it('cancelar durante a requisição aborta o fetch e rejeita como cancelado', async () => {
    const espiao = vi.fn<typeof fetch>(
      (_url, init) =>
        new Promise<Response>((_ok, falha) => {
          init?.signal?.addEventListener('abort', () => falha(new DOMException('abortado', 'AbortError')))
        }),
    )
    vi.stubGlobal('fetch', espiao)
    const controle = new AbortController()
    const promessa = listarTodos({ signal: controle.signal })
    controle.abort()
    await expect(promessa).rejects.toEqual(new FalhaApi({ tipo: 'cancelado' }))
    expect(espiao.mock.calls[0]![1]!.signal!.aborted).toBe(true)
  })

  it('porStreaming recusa "outros" (é rota própria do backend)', () => {
    expect(() => porStreaming('outros')).toThrow(RangeError)
  })

  it('pesquisar recusa termo com barra sem chamar a API', () => {
    const urls = simularResposta([])
    expect(() => pesquisar('a/b')).toThrow(RangeError)
    expect(urls).toHaveLength(0)
  })
})
