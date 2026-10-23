// Mock da API legada para os perfis de teste B, D e E. Node puro, sem dependências.
// NÃO prova compatibilidade com a API real: oferece cenários controlados e determinísticos.
//
// Rotas de dados (iguais às do backend, FilmeController/PublicidadeController):
//   GET /filmes · /filmes/aleatorios · /filmes/streaming/{s} · /filmes/streaming/outros
//   GET /filmes/pesquisa/{t} · /publicidades
//   GET /usuarios e /listas existem aqui só para provar que o proxy as bloqueia.
// Controle (alcançável só na rede de teste, nunca pela allowlist do front):
//   GET /__saude · POST /__cenario?nome=… · GET|DELETE /__requisicoes
//   Porta de controle separada (CONTROLE_PORT, perfil E): POST /__parar fecha a porta de dados
//   (o proxy passa a receber conexão recusada, como com a API fora do ar); POST /__retomar reabre.
// Cenário por requisição: cabeçalho `x-mock-cenario` (tem prioridade sobre o global).
import { createServer } from 'node:http'
import { readFileSync } from 'node:fs'
import { join } from 'node:path'
import { fileURLToPath } from 'node:url'

export const CENARIOS = Object.freeze([
  'normal',
  'vazio',
  'invalidos',
  'todos-invalidos',
  'repetidos',
  'json-malformado',
  'http-500',
  'http-404',
  'pendurado',
  'lento:<ms>',
])

// Mesma lista do JPQL de "outros" (moviematch_back/.../repository/FilmeRepository.java).
const STREAMINGS_FIXOS = ['Netflix', 'HBO Max', 'Disney+', 'Apple TV', 'Globoplay', 'Prime Video', 'Tela Brasil']

function cenarioValido(nome) {
  return /^lento:\d{1,6}$/.test(nome) || CENARIOS.includes(nome)
}

/**
 * @param {{ fixtures: string }} opcoes diretório das fixtures (tests/fixtures)
 */
export function criarServidor({ fixtures }) {
  const ler = (arquivo) => readFileSync(join(fixtures, arquivo), 'utf8')
  const json = (arquivo) => JSON.parse(ler(arquivo))
  const filmesPorCenario = {
    normal: json('filmes-validos.json'),
    vazio: [],
    invalidos: json('filmes-com-invalidos.json'),
    'todos-invalidos': json('filmes-todos-invalidos.json'),
    repetidos: json('filmes-repetidos.json'),
  }
  const publicidades = json('publicidades.json')
  const malformado = ler('malformado.txt')

  let cenarioGlobal = 'normal'
  /** @type {Array<{ metodo: string, url: string, headers: import('node:http').IncomingHttpHeaders }>} */
  const requisicoes = []

  const filtrarTexto = (filmes, campo, alvo) => filmes.filter((f) => f && typeof f === 'object' && f[campo] === alvo)

  function dados(caminho, cenario) {
    const filmes = filmesPorCenario[cenario] ?? filmesPorCenario.normal
    const lista = Array.isArray(filmes) ? filmes : []
    let m
    if (caminho === '/filmes') return lista
    if (caminho === '/filmes/aleatorios') return lista.slice(0, 5)
    if (caminho === '/publicidades') return cenario === 'vazio' ? [] : publicidades
    if (caminho === '/filmes/streaming/outros') {
      return lista.filter((f) => f && typeof f === 'object' && !STREAMINGS_FIXOS.includes(f.streaming_filme))
    }
    if ((m = /^\/filmes\/streaming\/([^/]+)$/.exec(caminho))) {
      return filtrarTexto(lista, 'streaming_filme', decodeURIComponent(m[1]))
    }
    if ((m = /^\/filmes\/pesquisa\/([^/]+)$/.exec(caminho))) {
      const termo = decodeURIComponent(m[1]).toLowerCase()
      return lista.filter((f) => f && typeof f.titulo_filme === 'string' && f.titulo_filme.toLowerCase().includes(termo))
    }
    if (caminho === '/usuarios' || caminho.startsWith('/usuarios/') || caminho === '/listas' || caminho.startsWith('/listas/')) {
      return [{ alerta: 'esta rota nunca deveria ser alcançada pelo front' }]
    }
    return undefined
  }

  const servidor = createServer((req, res) => {
    const url = req.url ?? '/'
    const [caminho, consulta = ''] = url.split('?')

    const responderJson = (status, corpo) => {
      res.writeHead(status, { 'content-type': 'application/json; charset=utf-8' })
      res.end(JSON.stringify(corpo))
    }

    // Controle
    if (caminho === '/__saude') return responderJson(200, { ok: true })
    if (caminho === '/__requisicoes') {
      if (req.method === 'DELETE') requisicoes.length = 0
      return responderJson(200, requisicoes)
    }
    if (caminho === '/__cenario') {
      const nome = new URLSearchParams(consulta).get('nome') ?? ''
      if (req.method !== 'POST' || !cenarioValido(nome)) return responderJson(400, { erro: 'cenário inválido', CENARIOS })
      cenarioGlobal = nome
      return responderJson(200, { cenario: nome })
    }

    // Dados
    requisicoes.push({ metodo: req.method ?? '', url, headers: req.headers })
    const pedido = req.headers['x-mock-cenario']
    const cenario = typeof pedido === 'string' && cenarioValido(pedido) ? pedido : cenarioGlobal

    const responder = () => {
      if (res.destroyed) return
      if (cenario === 'http-500') return responderJson(500, { status: 500, error: 'Internal Server Error' })
      if (cenario === 'http-404') return responderJson(404, { status: 404, error: 'Not Found' })
      const corpo = dados(caminho, cenario)
      if (corpo === undefined) return responderJson(404, { status: 404, error: 'Not Found', path: caminho })
      // Cookie que o proxy deve ocultar do navegador.
      res.setHeader('set-cookie', 'rastreio-mock=1; Path=/')
      if (cenario === 'json-malformado') {
        res.writeHead(200, { 'content-type': 'application/json' })
        return res.end(malformado)
      }
      return responderJson(200, corpo)
    }

    if (cenario === 'pendurado') return // nunca responde
    const lento = /^lento:(\d+)$/.exec(cenario)
    if (lento) return void setTimeout(responder, Number(lento[1]))
    responder()
  })

  return {
    servidor,
    /** Requisições de dados recebidas (cópia). */
    requisicoes: () => [...requisicoes],
  }
}

/**
 * Servidor de controle que liga e desliga a porta de dados sem encerrar o processo (o estado,
 * inclusive o registro de requisições, é preservado).
 * @param {import('node:http').Server} servidor
 * @param {number} porta
 */
export function criarControle(servidor, porta) {
  const ouvir = () =>
    new Promise((resolver, rejeitar) => {
      servidor.once('error', rejeitar)
      servidor.listen(porta, '0.0.0.0', () => {
        servidor.off('error', rejeitar)
        resolver()
      })
    })
  const parar = () =>
    new Promise((resolver) => {
      servidor.close(() => resolver())
      servidor.closeAllConnections()
    })

  return createServer(async (req, res) => {
    const responder = (status, corpo) => {
      res.writeHead(status, { 'content-type': 'application/json; charset=utf-8' })
      res.end(JSON.stringify(corpo))
    }
    if (req.method !== 'POST') return responder(405, { erro: 'use POST' })
    try {
      if (req.url === '/__parar') {
        if (servidor.listening) await parar()
        return responder(200, { dados: 'parado' })
      }
      if (req.url === '/__retomar') {
        if (!servidor.listening) await ouvir()
        return responder(200, { dados: 'ouvindo' })
      }
      return responder(404, { erro: 'rota de controle desconhecida' })
    } catch (erro) {
      return responder(500, { erro: String(erro) })
    }
  })
}

if (process.argv[1] && fileURLToPath(import.meta.url) === process.argv[1]) {
  const porta = Number(process.env.PORT ?? 8081)
  const fixtures = process.env.FIXTURES ?? fileURLToPath(new URL('../../tests/fixtures', import.meta.url))
  const { servidor } = criarServidor({ fixtures })
  servidor.listen(porta, '0.0.0.0', () => console.log(`mock-api ouvindo em :${porta}`))
  const portaControle = Number(process.env.CONTROLE_PORT ?? 0)
  const controle = portaControle ? criarControle(servidor, porta) : null
  controle?.listen(portaControle, '0.0.0.0', () => console.log(`controle ouvindo em :${portaControle}`))
  const encerrar = () => {
    controle?.close()
    servidor.close(() => process.exit(0))
    servidor.closeAllConnections()
  }
  process.on('SIGTERM', encerrar)
  process.on('SIGINT', encerrar)
}
