import { describe, expect, it } from 'vitest'
import tokensCss from '../../src/styles/tokens.css?raw'

type Rgba = [number, number, number, number]

function lerTokens(css: string): Map<string, string> {
  const tokens = new Map<string, string>()
  for (const [, nome, valor] of css.matchAll(/(--cor-[\w-]+)\s*:\s*([^;]+);/g)) {
    tokens.set(nome!, valor!.trim())
  }
  return tokens
}

function paraRgba(valor: string): Rgba {
  const hex = /^#([0-9a-f]{6})$/i.exec(valor)
  if (hex) {
    const n = parseInt(hex[1]!, 16)
    return [(n >> 16) & 255, (n >> 8) & 255, n & 255, 1]
  }
  const rgba = /^rgba\((\d+),\s*(\d+),\s*(\d+),\s*([\d.]+)\)$/.exec(valor)
  if (rgba) {
    return [Number(rgba[1]), Number(rgba[2]), Number(rgba[3]), Number(rgba[4])]
  }
  throw new Error(`cor não suportada: ${valor}`)
}

function sobrepor([r, g, b, a]: Rgba, [fr, fg, fb]: Rgba): Rgba {
  return [r * a + fr * (1 - a), g * a + fg * (1 - a), b * a + fb * (1 - a), 1]
}

// WCAG 2.x: luminância relativa e razão de contraste.
function luminancia([r, g, b]: Rgba): number {
  const canal = (c: number) => {
    const s = c / 255
    return s <= 0.03928 ? s / 12.92 : ((s + 0.055) / 1.055) ** 2.4
  }
  return 0.2126 * canal(r) + 0.7152 * canal(g) + 0.0722 * canal(b)
}

function contraste(texto: Rgba, fundo: Rgba): number {
  const a = luminancia(sobrepor(texto, fundo))
  const b = luminancia(fundo)
  return (Math.max(a, b) + 0.05) / (Math.min(a, b) + 0.05)
}

const tokens = lerTokens(tokensCss)
const cor = (nome: string) => {
  const valor = tokens.get(nome)
  if (!valor) throw new Error(`token ausente: ${nome}`)
  return paraRgba(valor)
}

// Combinações de texto e fundo permitidas na interface.
const PARES: Array<[string, string]> = [
  ['--cor-texto', '--cor-fundo'],
  ['--cor-texto', '--cor-superficie'],
  ['--cor-texto', '--cor-azul'],
  ['--cor-texto', '--cor-vermelho-escuro'],
  ['--cor-texto', '--cor-destaque'],
  ['--cor-texto-secundario', '--cor-fundo'],
  ['--cor-texto-secundario', '--cor-superficie'],
  ['--cor-texto-secundario', '--cor-azul'],
  ['--cor-texto-secundario', '--cor-destaque'],
  ['--cor-texto-terciario', '--cor-fundo'],
  ['--cor-texto-terciario', '--cor-superficie'],
  ['--cor-texto-terciario', '--cor-azul'],
]

describe('tokens de cor', () => {
  it.each(PARES)('%s sobre %s tem contraste >= 4.5:1', (texto, fundo) => {
    expect(contraste(cor(texto), cor(fundo))).toBeGreaterThanOrEqual(4.5)
  })

  it('foco tem contraste >= 3:1 com todos os fundos', () => {
    for (const fundo of ['--cor-fundo', '--cor-superficie', '--cor-azul', '--cor-vermelho-escuro', '--cor-destaque']) {
      expect(contraste(cor('--cor-foco'), cor(fundo)), fundo).toBeGreaterThanOrEqual(3)
    }
  })

  it('o cálculo reproduz valores de referência da WCAG', () => {
    expect(contraste([0, 0, 0, 1], [255, 255, 255, 1])).toBeCloseTo(21, 5)
    expect(contraste([119, 119, 119, 1], [255, 255, 255, 1])).toBeCloseTo(4.48, 2)
  })
})
