import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import { FalhaApi } from '../../src/services/http'
import { mapearFilme, mapearLista } from '../../src/services/mapeadores'
import { listarTodos } from '../../src/services/filmes'
import { TTL_CATALOGO_MS, useCatalogo } from '../../src/composables/useCatalogo'
import validos from '../fixtures/filmes-validos.json'

vi.mock('../../src/services/filmes', () => ({ listarTodos: vi.fn() }))

const listarTodosMock = vi.mocked(listarTodos)
const catalogo = () => Promise.resolve(mapearLista(validos, mapearFilme))

beforeEach(() => {
  useCatalogo().invalidar()
  listarTodosMock.mockReset()
  listarTodosMock.mockImplementation(catalogo)
})

afterEach(() => {
  vi.useRealTimers()
})

describe('useCatalogo', () => {
  it('pedidos simultâneos compartilham uma única requisição', async () => {
    const { obter } = useCatalogo()
    const resultados = await Promise.all([obter(), obter(), obter(), obter(), obter()])
    expect(listarTodosMock).toHaveBeenCalledTimes(1)
    expect(new Set(resultados).size).toBe(1)
  })

  it('reutiliza o catálogo dentro do TTL e busca de novo depois dele', async () => {
    vi.useFakeTimers()
    const { obter } = useCatalogo()
    await obter()
    vi.advanceTimersByTime(TTL_CATALOGO_MS - 1)
    await obter()
    expect(listarTodosMock).toHaveBeenCalledTimes(1)
    vi.advanceTimersByTime(1)
    await obter()
    expect(listarTodosMock).toHaveBeenCalledTimes(2)
  })

  it('erro não fica em cache: a próxima chamada refaz a requisição', async () => {
    listarTodosMock.mockRejectedValueOnce(new FalhaApi({ tipo: 'http', status: 500 }))
    const { obter } = useCatalogo()
    await expect(obter()).rejects.toBeInstanceOf(FalhaApi)
    await expect(obter()).resolves.toMatchObject({ descartados: 0 })
    expect(listarTodosMock).toHaveBeenCalledTimes(2)
  })

  it('invalidar força nova requisição', async () => {
    const { obter, invalidar } = useCatalogo()
    await obter()
    invalidar()
    await obter()
    expect(listarTodosMock).toHaveBeenCalledTimes(2)
  })

  it('porId encontra o filme ou devolve undefined', async () => {
    const { porId } = useCatalogo()
    await expect(porId(4)).resolves.toMatchObject({ id: 4, titulo: 'Galáxia Esquecida' })
    await expect(porId(999)).resolves.toBeUndefined()
    expect(listarTodosMock).toHaveBeenCalledTimes(1)
  })

  it('porId propaga erro da API', async () => {
    listarTodosMock.mockRejectedValueOnce(new FalhaApi({ tipo: 'timeout' }))
    await expect(useCatalogo().porId(1)).rejects.toEqual(new FalhaApi({ tipo: 'timeout' }))
  })

  it('uma falha antiga não apaga uma requisição nova que já está no cache', async () => {
    let rejeitarPrimeira!: (erro: unknown) => void
    listarTodosMock.mockImplementationOnce(() => new Promise((_ok, falha) => (rejeitarPrimeira = falha)))
    const { obter, invalidar } = useCatalogo()
    const primeira = obter()
    invalidar()
    const segunda = obter()
    rejeitarPrimeira(new FalhaApi({ tipo: 'rede' }))
    await expect(primeira).rejects.toBeInstanceOf(FalhaApi)
    await segunda
    await obter()
    expect(listarTodosMock).toHaveBeenCalledTimes(2)
  })
})
