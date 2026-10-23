import { describe, expect, it } from 'vitest'
import { CHAVE_VISITA, criarPrimeiraVisita } from '../../src/composables/usePrimeiraVisita'

function armazenamento(falhar = false) {
  const dados = new Map<string, string>()
  const verificar = () => {
    if (falhar) throw new DOMException('bloqueado', 'SecurityError')
  }
  const storage = {
    getItem: (k: string) => (verificar(), dados.get(k) ?? null),
    setItem: (k: string, v: string) => (verificar(), void dados.set(k, v)),
    removeItem: (k: string) => (verificar(), void dados.delete(k)),
    clear: () => dados.clear(),
    key: () => null,
    get length() {
      return dados.size
    },
  } satisfies Storage
  return { storage, dados }
}

describe('usePrimeiraVisita', () => {
  it('primeira visita: ainda não visitou', () => {
    const { storage } = armazenamento()
    expect(criarPrimeiraVisita(() => storage).jaVisitou()).toBe(false)
  })

  it('marcar grava a chave e vale para novas instâncias (próximas visitas)', () => {
    const { storage, dados } = armazenamento()
    criarPrimeiraVisita(() => storage).marcarVisita()
    expect(dados.get(CHAVE_VISITA)).toBe('1')
    expect(criarPrimeiraVisita(() => storage).jaVisitou()).toBe(true)
  })

  it('armazenamento bloqueado: vale a marca em memória, sem erro e sem loop', () => {
    const { storage } = armazenamento(true)
    const visita = criarPrimeiraVisita(() => storage)
    expect(visita.jaVisitou()).toBe(false)
    visita.marcarVisita()
    expect(visita.jaVisitou()).toBe(true)
  })

  it('sem armazenamento: idem', () => {
    const visita = criarPrimeiraVisita(() => null)
    visita.marcarVisita()
    expect(visita.jaVisitou()).toBe(true)
  })

  it('valor salvo diferente de "1" não conta como visita', () => {
    const { storage, dados } = armazenamento()
    dados.set(CHAVE_VISITA, 'true')
    expect(criarPrimeiraVisita(() => storage).jaVisitou()).toBe(false)
  })
})
