// Referência: projeto_brademo/lib/screens/home/home.dart:300-337.
import { describe, expect, it } from 'vitest'
import { STREAMINGS_HOME, streamingPorSlug } from '../../src/domain/streamings'

describe('streamings da Home', () => {
  it('mantém a ordem e os rótulos da Home do Flutter', () => {
    expect(STREAMINGS_HOME.map((s) => s.rotulo)).toEqual([
      'Netflix', 'HBO Max', 'Disney+', 'Apple TV', 'GloboPlay', 'Prime Video', 'Tela Brasil', 'Outros Streamings',
    ])
  })

  it('envia à API os valores exatos da Home (A-05)', () => {
    const valores = Object.fromEntries(
      STREAMINGS_HOME.map((s) => [s.slug, s.filtro.tipo === 'valor' ? s.filtro.valor : '(outros)']),
    )
    expect(valores).toEqual({
      netflix: 'Netflix',
      'hbo-max': 'HBO Max',
      'disney-plus': 'Disney+',
      'apple-tv': 'Apple TV',
      globoplay: 'GloboPlay',
      'prime-video': 'Prime Video',
      'tela-brasil': 'Tela Brasil',
      outros: '(outros)',
    })
  })

  it('slugs são únicos e seguros para URL', () => {
    const slugs = STREAMINGS_HOME.map((s) => s.slug)
    expect(new Set(slugs).size).toBe(slugs.length)
    for (const slug of slugs) expect(slug).toMatch(/^[a-z0-9-]+$/)
  })

  it('nenhum valor de filtro é "outros" (que é rota própria do backend)', () => {
    for (const s of STREAMINGS_HOME) {
      if (s.filtro.tipo === 'valor') expect(s.filtro.valor).not.toBe('outros')
    }
  })

  it('busca por slug', () => {
    expect(streamingPorSlug('disney-plus')?.rotulo).toBe('Disney+')
    expect(streamingPorSlug('outros')?.filtro).toEqual({ tipo: 'outros' })
    expect(streamingPorSlug('Disney+')).toBeUndefined()
    expect(streamingPorSlug('desconhecido')).toBeUndefined()
  })

  it('a tabela é imutável', () => {
    expect(Object.isFrozen(STREAMINGS_HOME)).toBe(true)
  })
})
