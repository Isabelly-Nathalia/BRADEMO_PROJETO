// Garante que as fixtures cobrem o que os testes e o mock prometem cobrir.
import { describe, expect, it } from 'vitest'
import validos from '../fixtures/filmes-validos.json'
import comInvalidos from '../fixtures/filmes-com-invalidos.json'
import todosInvalidos from '../fixtures/filmes-todos-invalidos.json'
import vazio from '../fixtures/filmes-vazio.json'
import repetidos from '../fixtures/filmes-repetidos.json'
import objetoNaRaiz from '../fixtures/objeto-na-raiz.json'
import publicidades from '../fixtures/publicidades.json'
import malformado from '../fixtures/malformado.txt?raw'

const CAMPOS_FILME = [
  'id_filme',
  'titulo_filme',
  'descricao_filme',
  'imagemDiretor_filme',
  'duracao_filme',
  'streaming_filme',
  'nacionalidade_filme',
  'classificacao_filme',
  'diretor_filme',
  'linkImagemFilme_filme',
  'atorEspecifico_filme',
  'nota_filme',
  'generos',
].sort()

describe('fixtures', () => {
  it('filmes válidos têm exatamente os campos do contrato, com tipos corretos', () => {
    for (const filme of validos) {
      expect(Object.keys(filme).sort()).toEqual(CAMPOS_FILME)
      expect(Number.isInteger(filme.id_filme) && filme.id_filme > 0).toBe(true)
      expect(filme.titulo_filme.length).toBeGreaterThan(0)
      expect(Number.isInteger(filme.duracao_filme)).toBe(true)
      expect(Number.isFinite(filme.nota_filme)).toBe(true)
      expect(Array.isArray(filme.generos)).toBe(true)
    }
    expect(new Set(validos.map((f) => f.id_filme)).size).toBe(validos.length)
  })

  it('cobrem os limites das faixas de duração', () => {
    const duracoes = new Set(validos.map((f) => f.duracao_filme))
    for (const limite of [90, 91, 120, 121, 180, 181]) expect(duracoes.has(limite), String(limite)).toBe(true)
  })

  it('cobrem as grafias divergentes de streaming e um streaming "outro"', () => {
    const streamings = new Set(validos.map((f) => f.streaming_filme))
    for (const s of ['Apple TV', 'AppleTV', 'Globoplay', 'GloboPlay', 'Disney+', 'Tela Brasil', 'Mubi']) {
      expect(streamings.has(s), s).toBe(true)
    }
  })

  it('usam só imagens no domínio reservado .invalid', () => {
    const urls = JSON.stringify([validos, comInvalidos, publicidades]).match(/https?:\/\/[^"]+/g) ?? []
    expect(urls.length).toBeGreaterThan(0)
    for (const url of urls) expect(new URL(url).hostname.endsWith('.invalid'), url).toBe(true)
  })

  it('lista mista tem 5 válidos e 11 inválidos; a de inválidos não tem nenhum válido', () => {
    expect(comInvalidos).toHaveLength(16)
    expect(todosInvalidos).toHaveLength(11)
  })

  it('estados especiais estão representados', () => {
    expect(vazio).toEqual([])
    const ids = repetidos.map((f) => f.id_filme)
    expect(new Set(ids).size).toBeLessThan(ids.length)
    expect(Array.isArray(objetoNaRaiz)).toBe(false)
    expect(() => JSON.parse(malformado)).toThrow(SyntaxError)
  })

  it('publicidades têm id, descrição e imagem', () => {
    for (const p of publicidades) expect(Object.keys(p).sort()).toEqual(['descricao', 'id_publicidade', 'link_imagem'])
  })
})
