// Referência literal: projeto_brademo/lib/screens/form/form.dart:20-66 (conferida na F3-T01).
import { describe, expect, it } from 'vitest'
import {
  CLASSIFICACOES,
  DURACOES,
  GENEROS,
  PAISES,
  STREAMINGS,
  respostasVazias,
} from '../../src/domain/questionario'

describe('opções do questionário (paridade com o Flutter)', () => {
  it('gêneros: 12, na ordem do form.dart:20-33', () => {
    expect(GENEROS).toEqual([
      'Ação', 'Aventura', 'Comédia', 'Drama', 'Romance', 'Terror',
      'Ficção', 'Fantasia', 'Animação', 'Documentário', 'Mistério', 'Musical',
    ])
  })

  it('durações: 4, form.dart:35', () => {
    expect(DURACOES).toEqual(['Até 1h30', '1h30 - 2h', '2h - 3h', '3h+'])
  })

  it('streamings: 6, form.dart:37-44, com as grafias AppleTV e GloboPlay (A-05)', () => {
    expect(STREAMINGS).toEqual(['Netflix', 'Prime Video', 'Disney+', 'HBO Max', 'AppleTV', 'GloboPlay'])
  })

  it('classificações: 6, form.dart:46-53', () => {
    expect(CLASSIFICACOES).toEqual([
      'Livre',
      'Não recomendável para menores de 10 anos',
      'Não recomendável para menores de 12 anos',
      'Não recomendável para menores de 14 anos',
      'Não recomendável para menores de 16 anos',
      '18+',
    ])
  })

  it('países: 10, form.dart:55-66', () => {
    expect(PAISES).toEqual([
      'Argentina', 'Brasil', 'Canadá', 'China', 'Coreia do Sul',
      'Estados Unidos', 'França', 'Itália', 'Japão', 'Portugal',
    ])
  })

  it('todos os textos estão em NFC (acentos compostos, como no Dart)', () => {
    for (const texto of [...GENEROS, ...DURACOES, ...STREAMINGS, ...CLASSIFICACOES, ...PAISES]) {
      expect(texto.normalize('NFC'), texto).toBe(texto)
    }
  })

  it('não há opção "Outro" (A-03)', () => {
    const todas = [...GENEROS, ...STREAMINGS, ...PAISES].map((t) => t.toLowerCase())
    expect(todas.some((t) => t.startsWith('outro'))).toBe(false)
  })

  it('respostas vazias não compartilham listas entre chamadas', () => {
    const a = respostasVazias()
    a.generos.push('Drama')
    expect(respostasVazias().generos).toEqual([])
  })
})
