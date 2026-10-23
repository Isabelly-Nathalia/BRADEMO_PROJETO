// Apoio aos testes do perfil D (rodam no container "sonda", rede interna do Compose).
// Usa node:http com caminho BRUTO: fetch normalizaria "..", "//" e codificações antes de enviar.
import { request } from 'node:http'

export const FRONT = new URL(process.env.FRONT ?? 'http://front:8080')
export const FRONT_SEM_API = new URL(process.env.FRONT_SEM_API ?? 'http://front-sem-api:8080')
export const MOCK = process.env.MOCK ?? 'http://mock-api:8081'

/**
 * @param {string} caminho caminho bruto, enviado exatamente como escrito
 * @param {{ metodo?: string, headers?: Record<string, string>, alvo?: URL, corpo?: string }} [opcoes]
 * @returns {Promise<{ status: number, headers: import('node:http').IncomingHttpHeaders, corpo: string, ms: number }>}
 */
export function pedir(caminho, { metodo = 'GET', headers = {}, alvo = FRONT, corpo } = {}) {
  const inicio = Date.now()
  return new Promise((ok, falha) => {
    const req = request(
      { host: alvo.hostname, port: alvo.port, path: caminho, method: metodo, headers },
      (res) => {
        const partes = []
        res.on('data', (p) => partes.push(p))
        res.on('end', () =>
          ok({ status: res.statusCode ?? 0, headers: res.headers, corpo: Buffer.concat(partes).toString('utf8'), ms: Date.now() - inicio }),
        )
      },
    )
    req.on('error', falha)
    if (corpo !== undefined) req.write(corpo)
    req.end()
  })
}

export async function limparRegistro() {
  await fetch(`${MOCK}/__requisicoes`, { method: 'DELETE' })
}

/** Requisições que o mock (o "backend") efetivamente recebeu. */
export async function recebidas() {
  return /** @type {Array<{ metodo: string, url: string, headers: Record<string, string> }>} */ (
    await (await fetch(`${MOCK}/__requisicoes`)).json()
  )
}
