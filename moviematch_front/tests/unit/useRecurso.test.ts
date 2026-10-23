import { describe, expect, it, vi } from 'vitest'
import { effectScope } from 'vue'
import { flushPromises } from '@vue/test-utils'
import { useRecurso } from '../../src/composables/useRecurso'
import { FalhaApi } from '../../src/services/http'

function emEscopo<T>(fn: () => T) {
  const escopo = effectScope()
  const resultado = escopo.run(fn)!
  return { resultado, parar: () => escopo.stop() }
}

/** Busca controlável: cada chamada devolve uma promessa resolvida/rejeitada pelo teste. */
function buscaControlada<T>() {
  const chamadas: Array<{ signal: AbortSignal; ok: (v: T) => void; falha: (e: unknown) => void }> = []
  const buscar = vi.fn(
    (signal: AbortSignal) =>
      new Promise<T>((ok, falha) => {
        chamadas.push({ signal, ok, falha })
      }),
  )
  return { buscar, chamadas }
}

describe('useRecurso', () => {
  it('começa carregando e passa a sucesso', async () => {
    const { buscar, chamadas } = buscaControlada<number[]>()
    const { resultado: r } = emEscopo(() => useRecurso(buscar, (d) => d.length === 0))
    expect(r.estado.value).toBe('carregando')
    chamadas[0]!.ok([1, 2])
    await flushPromises()
    expect(r.estado.value).toBe('sucesso')
    expect(r.dados.value).toEqual([1, 2])
  })

  it('resultado vazio vira estado vazio', async () => {
    const { buscar, chamadas } = buscaControlada<number[]>()
    const { resultado: r } = emEscopo(() => useRecurso(buscar, (d) => d.length === 0))
    chamadas[0]!.ok([])
    await flushPromises()
    expect(r.estado.value).toBe('vazio')
  })

  it('falha vira estado de erro com o erro original', async () => {
    const { buscar, chamadas } = buscaControlada<number[]>()
    const { resultado: r } = emEscopo(() => useRecurso(buscar, () => false))
    const falha = new FalhaApi({ tipo: 'http', status: 500 })
    chamadas[0]!.falha(falha)
    await flushPromises()
    expect(r.estado.value).toBe('erro')
    expect(r.erro.value).toBe(falha)
  })

  it('recarregar refaz a busca e limpa o erro', async () => {
    const { buscar, chamadas } = buscaControlada<number[]>()
    const { resultado: r } = emEscopo(() => useRecurso(buscar, () => false))
    chamadas[0]!.falha(new FalhaApi({ tipo: 'rede' }))
    await flushPromises()
    void r.recarregar()
    expect(r.estado.value).toBe('carregando')
    expect(r.erro.value).toBeNull()
    chamadas[1]!.ok([3])
    await flushPromises()
    expect(r.estado.value).toBe('sucesso')
    expect(buscar).toHaveBeenCalledTimes(2)
  })

  it('não tenta de novo sozinho depois de um erro', async () => {
    vi.useFakeTimers()
    const { buscar, chamadas } = buscaControlada<number[]>()
    emEscopo(() => useRecurso(buscar, () => false))
    chamadas[0]!.falha(new FalhaApi({ tipo: 'timeout' }))
    await vi.advanceTimersByTimeAsync(120_000)
    expect(buscar).toHaveBeenCalledTimes(1)
    vi.useRealTimers()
  })

  it('resposta de uma carga antiga é ignorada', async () => {
    const { buscar, chamadas } = buscaControlada<string>()
    const { resultado: r } = emEscopo(() => useRecurso(buscar, () => false))
    void r.recarregar()
    expect(chamadas[0]!.signal.aborted).toBe(true)
    chamadas[1]!.ok('nova')
    chamadas[0]!.ok('antiga')
    await flushPromises()
    expect(r.dados.value).toBe('nova')
  })

  it('sair da página cancela a requisição e não altera o estado depois', async () => {
    const { buscar, chamadas } = buscaControlada<string>()
    const { resultado: r, parar } = emEscopo(() => useRecurso(buscar, () => false))
    parar()
    expect(chamadas[0]!.signal.aborted).toBe(true)
    chamadas[0]!.ok('tarde demais')
    await flushPromises()
    expect(r.estado.value).toBe('carregando')
    expect(r.dados.value).toBeNull()
  })

  it('cancelamento não é mostrado como erro', async () => {
    const { buscar, chamadas } = buscaControlada<string>()
    const { resultado: r } = emEscopo(() => useRecurso(buscar, () => false))
    chamadas[0]!.falha(new FalhaApi({ tipo: 'cancelado' }))
    await flushPromises()
    expect(r.estado.value).not.toBe('erro')
  })
})
