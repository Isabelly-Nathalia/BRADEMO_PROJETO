/**
 * Devolve a URL normalizada se ela for absoluta e https; caso contrário, null.
 * Usada para toda URL de imagem que vem da API (mapeadores e SafeImage).
 */
export function urlHttpsOuNull(valor: unknown): string | null {
  if (typeof valor !== 'string' || valor === '') return null
  try {
    const url = new URL(valor)
    return url.protocol === 'https:' ? url.href : null
  } catch {
    return null
  }
}
