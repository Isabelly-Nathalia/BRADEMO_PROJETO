// Ciclo de carga de um recurso da API para uma página ou seção:
// estado explícito · cancela ao sair da página · ignora respostas de cargas antigas ·
// retry só quando chamado (botão "Tentar novamente").
import { onScopeDispose, ref, shallowRef, type Ref, type ShallowRef } from 'vue'
import type { EstadoCarga } from '../components/StateView.vue'
import { FalhaApi } from '../services/http'

export interface Recurso<T> {
  estado: Ref<EstadoCarga>
  dados: ShallowRef<T | null>
  erro: ShallowRef<unknown>
  recarregar: () => Promise<void>
}

export function useRecurso<T>(buscar: (signal: AbortSignal) => Promise<T>, ehVazio: (dados: T) => boolean): Recurso<T> {
  const estado = ref<EstadoCarga>('carregando')
  const dados = shallowRef<T | null>(null)
  const erro = shallowRef<unknown>(null)
  let atual: AbortController | null = null

  async function recarregar(): Promise<void> {
    atual?.abort()
    const controle = new AbortController()
    atual = controle
    estado.value = 'carregando'
    erro.value = null
    try {
      const resultado = await buscar(controle.signal)
      if (atual !== controle) return
      dados.value = resultado
      estado.value = ehVazio(resultado) ? 'vazio' : 'sucesso'
    } catch (falha) {
      if (atual !== controle) return
      if (falha instanceof FalhaApi && falha.erro.tipo === 'cancelado') return
      erro.value = falha
      estado.value = 'erro'
    }
  }

  onScopeDispose(() => {
    atual?.abort()
    atual = null
  })
  void recarregar()

  return { estado, dados, erro, recarregar }
}
