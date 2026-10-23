// Marca de primeira visita (A-04): a página de boas-vindas aparece só na primeira vez.
// Com armazenamento indisponível, a marca fica em memória: boas-vindas uma vez por sessão, sem loop.
export const CHAVE_VISITA = 'mm.visitou.v1'

type ObterArmazenamento = () => Storage | null

function armazenamentoDoNavegador(): Storage | null {
  try {
    return window.localStorage
  } catch {
    return null
  }
}

export function criarPrimeiraVisita(obter: ObterArmazenamento = armazenamentoDoNavegador) {
  let visitouNestaSessao = false

  return {
    jaVisitou(): boolean {
      if (visitouNestaSessao) return true
      try {
        return obter()?.getItem(CHAVE_VISITA) === '1'
      } catch {
        return false
      }
    },
    marcarVisita(): void {
      visitouNestaSessao = true
      try {
        obter()?.setItem(CHAVE_VISITA, '1')
      } catch {
        // Armazenamento bloqueado: vale só a marca em memória.
      }
    },
  }
}

let instancia: ReturnType<typeof criarPrimeiraVisita> | null = null

export function usePrimeiraVisita() {
  instancia ??= criarPrimeiraVisita()
  return instancia
}
