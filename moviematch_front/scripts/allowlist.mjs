// Fonte única das rotas de API alcançáveis pelo frontend (api-allowlist.json).
// Usado pelo proxy de desenvolvimento (vite.config.ts) e pelo gerador do Nginx.
// A allowlist é uma fronteira de conectividade, não segurança da API.
import { readFileSync } from 'node:fs'

export const CAMINHO_PADRAO = new URL('../api-allowlist.json', import.meta.url)

/** Métodos que podem constar na allowlist: somente leitura. */
export const METODOS_ACEITOS = Object.freeze(['GET', 'HEAD'])

/** Prefixos que nunca podem ser liberados (dados pessoais e contas). */
export const PREFIXOS_PROIBIDOS = Object.freeze(['/usuarios', '/listas'])

export const CORINGA = '{segmento}'

const SEGMENTO_LITERAL = /^[a-z0-9-]+$/

/**
 * @typedef {{ versao: 1, metodos: string[], rotas: string[] }} Allowlist
 */

/**
 * Valida a estrutura e as regras da allowlist; lança Error com motivo.
 * @param {unknown} dados
 * @returns {Allowlist}
 */
export function validarAllowlist(dados) {
  if (typeof dados !== 'object' || dados === null) throw new Error('allowlist: raiz deve ser um objeto')
  const { versao, metodos, rotas, ...extras } = /** @type {Record<string, unknown>} */ (dados)
  if (Object.keys(extras).length > 0) throw new Error(`allowlist: campos desconhecidos: ${Object.keys(extras).join(', ')}`)
  if (versao !== 1) throw new Error('allowlist: versao deve ser 1')

  if (!Array.isArray(metodos) || metodos.length === 0) throw new Error('allowlist: metodos deve ser lista não vazia')
  for (const metodo of metodos) {
    if (!METODOS_ACEITOS.includes(metodo)) throw new Error(`allowlist: método não permitido: ${metodo}`)
  }

  if (!Array.isArray(rotas) || rotas.length === 0) throw new Error('allowlist: rotas deve ser lista não vazia')
  const vistas = new Set()
  for (const rota of rotas) {
    if (typeof rota !== 'string' || !rota.startsWith('/') || rota.endsWith('/')) {
      throw new Error(`allowlist: rota inválida: ${String(rota)}`)
    }
    if (PREFIXOS_PROIBIDOS.some((p) => rota === p || rota.startsWith(`${p}/`))) {
      throw new Error(`allowlist: rota proibida: ${rota}`)
    }
    for (const segmento of rota.slice(1).split('/')) {
      if (segmento !== CORINGA && !SEGMENTO_LITERAL.test(segmento)) {
        throw new Error(`allowlist: segmento inválido "${segmento}" em ${rota}`)
      }
    }
    if (vistas.has(rota)) throw new Error(`allowlist: rota duplicada: ${rota}`)
    vistas.add(rota)
  }

  return /** @type {Allowlist} */ ({ versao, metodos, rotas })
}

/**
 * @param {URL | string} [caminho]
 * @returns {Allowlist}
 */
export function carregarAllowlist(caminho = CAMINHO_PADRAO) {
  return validarAllowlist(JSON.parse(readFileSync(caminho, 'utf8')))
}

/**
 * Cria o verificador de requisições.
 * `caminhoDecodificado` é o caminho da API sem o prefixo /api e sem query string,
 * já decodificado (um %2F vira "/" e passa a contar como separador).
 * @param {Allowlist} allowlist
 * @returns {(metodo: string, caminhoDecodificado: string) => boolean}
 */
export function criarVerificador(allowlist) {
  const metodos = new Set(allowlist.metodos)
  const padroes = allowlist.rotas.map((rota) => rota.slice(1).split('/'))

  return (metodo, caminhoDecodificado) => {
    if (!metodos.has(metodo.toUpperCase())) return false
    if (!caminhoDecodificado.startsWith('/')) return false
    const segmentos = caminhoDecodificado.slice(1).split('/')
    if (segmentos.some((s) => s === '' || s === '.' || s === '..')) return false
    return padroes.some(
      (padrao) =>
        padrao.length === segmentos.length &&
        padrao.every((parte, i) => parte === CORINGA || parte === segmentos[i]),
    )
  }
}
