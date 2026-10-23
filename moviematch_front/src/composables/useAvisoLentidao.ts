import { onScopeDispose, ref, watch, type Ref } from 'vue'

export const ATRASO_AVISO_MS = 5_000

/**
 * Fica true depois que `carregando` permanece true por `atrasoMs`.
 * É só um aviso visual: não cancela nem refaz a requisição (o timeout é do cliente HTTP).
 */
export function useAvisoLentidao(carregando: Ref<boolean>, atrasoMs = ATRASO_AVISO_MS): Ref<boolean> {
  const lento = ref(false)
  let temporizador: ReturnType<typeof setTimeout> | undefined

  const parar = () => {
    clearTimeout(temporizador)
    temporizador = undefined
    lento.value = false
  }

  watch(
    carregando,
    (ativo) => {
      parar()
      if (ativo) temporizador = setTimeout(() => (lento.value = true), atrasoMs)
    },
    { immediate: true },
  )
  onScopeDispose(parar)

  return lento
}
