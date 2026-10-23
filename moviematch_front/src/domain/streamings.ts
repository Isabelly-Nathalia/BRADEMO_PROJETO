// Streamings da página inicial, na ordem e com os valores da Home do Flutter
// (projeto_brademo/lib/screens/home/home.dart:300-337).
// A-05: `valor` é enviado como está para GET /filmes/streaming/{valor} (igualdade exata no
// backend). "GloboPlay" diverge do "Globoplay" usado no JPQL de "outros"; se casa com os dados
// reais é BLOQUEADO até haver dados (perfil C). O slug é só para a URL do frontend.

export type FiltroStreaming = { tipo: 'valor'; valor: string } | { tipo: 'outros' }

export interface StreamingHome {
  slug: string
  rotulo: string
  /** Nome-base do arquivo do logo (assets entram na F4-T01). */
  logo: string
  filtro: FiltroStreaming
}

export const STREAMINGS_HOME: readonly StreamingHome[] = Object.freeze([
  { slug: 'netflix', rotulo: 'Netflix', logo: 'netflix', filtro: { tipo: 'valor', valor: 'Netflix' } },
  { slug: 'hbo-max', rotulo: 'HBO Max', logo: 'hbomax', filtro: { tipo: 'valor', valor: 'HBO Max' } },
  { slug: 'disney-plus', rotulo: 'Disney+', logo: 'disney', filtro: { tipo: 'valor', valor: 'Disney+' } },
  { slug: 'apple-tv', rotulo: 'Apple TV', logo: 'appletv', filtro: { tipo: 'valor', valor: 'Apple TV' } },
  { slug: 'globoplay', rotulo: 'GloboPlay', logo: 'globoplay', filtro: { tipo: 'valor', valor: 'GloboPlay' } },
  { slug: 'prime-video', rotulo: 'Prime Video', logo: 'prime', filtro: { tipo: 'valor', valor: 'Prime Video' } },
  { slug: 'tela-brasil', rotulo: 'Tela Brasil', logo: 'telaBrasil', filtro: { tipo: 'valor', valor: 'Tela Brasil' } },
  { slug: 'outros', rotulo: 'Outros Streamings', logo: 'outros', filtro: { tipo: 'outros' } },
])

export function streamingPorSlug(slug: string): StreamingHome | undefined {
  return STREAMINGS_HOME.find((s) => s.slug === slug)
}
