import { describe, expect, it } from 'vitest'
import { formatarDuracao } from '../../src/domain/duracao'

describe('formatarDuracao (paridade com filmeService.dart:50-55)', () => {
  it.each([
    [0, '0h0min'],
    [5, '0h5min'],
    [59, '0h59min'],
    [60, '1h0min'],
    [90, '1h30min'],
    [125, '2h5min'],
    [185, '3h5min'],
  ])('%i min → %s', (minutos, texto) => {
    expect(formatarDuracao(minutos)).toBe(texto)
  })
})
