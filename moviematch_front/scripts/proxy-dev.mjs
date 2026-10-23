// Proxy de desenvolvimento (vite dev e vite preview) restrito à allowlist.
// Espelha o comportamento do Nginx de produção:
//   caminho fora da allowlist → 404 · método fora da allowlist → 403 ·
//   caminho repassado sem decodificar e sem query string · Cookie e Origin removidos.
// É conectividade, não segurança: a API continua pública para quem a acessar direto.
import { carregarAllowlist, criarVerificador } from './allowlist.mjs'

export const PREFIXO = '/api'

/** Casa /api, /api/... e /api?..., mas não /apix. */
const CHAVE_PROXY = '^/api(?:/|$|\\?)'

/**
 * @param {import('node:http').ServerResponse} res
 * @param {number} status
 * @param {string} mensagem
 */
function responder(res, status, mensagem) {
  res.statusCode = status
  res.setHeader('content-type', 'text/plain; charset=utf-8')
  res.end(mensagem)
}

/** @param {string} url */
function ehRotaDaApi(url) {
  return url === PREFIXO || url.startsWith(`${PREFIXO}/`) || url.startsWith(`${PREFIXO}?`)
}

/** @param {string} url caminho sem /api e sem query, ainda codificado */
function caminhoBruto(url) {
  return url.slice(PREFIXO.length).split('?')[0] ?? ''
}

/**
 * @param {{ upstream?: string, allowlist?: import('./allowlist.mjs').Allowlist }} [opcoes]
 * @returns {{ plugin: import('vite').Plugin, proxy: Record<string, import('vite').ProxyOptions> }}
 */
export function proxyApiDev({ upstream, allowlist = carregarAllowlist() } = {}) {
  const permitido = criarVerificador(allowlist)
  const metodos = new Set(allowlist.metodos)

  /** @type {import('vite').Connect.NextHandleFunction} */
  const filtro = (req, res, next) => {
    const url = req.url ?? ''
    if (!ehRotaDaApi(url)) return next()

    let decodificado
    try {
      decodificado = decodeURIComponent(caminhoBruto(url))
    } catch {
      return responder(res, 400, 'caminho com codificação inválida')
    }
    if (!permitido('GET', decodificado)) return responder(res, 404, 'rota de API não permitida')
    if (!metodos.has((req.method ?? '').toUpperCase())) return responder(res, 403, 'método não permitido')
    if (!upstream) return responder(res, 503, 'API não configurada: defina MM_API_UPSTREAM')
    next()
  }

  /** @type {import('vite').Plugin} */
  const plugin = {
    name: 'moviematch:allowlist-api',
    configureServer(server) {
      server.middlewares.use(filtro)
    },
    configurePreviewServer(server) {
      server.middlewares.use(filtro)
    },
  }

  /** @type {Record<string, import('vite').ProxyOptions>} */
  const proxy = upstream
    ? {
        [CHAVE_PROXY]: {
          target: upstream,
          changeOrigin: true,
          rewrite: caminhoBruto,
          configure(servidorProxy) {
            servidorProxy.on('proxyReq', (requisicao) => {
              requisicao.removeHeader('cookie')
              requisicao.removeHeader('origin')
            })
          },
        },
      }
    : {}

  return { plugin, proxy }
}
