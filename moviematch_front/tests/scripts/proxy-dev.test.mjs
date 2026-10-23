// Sobe o servidor de desenvolvimento do Vite de verdade, com um upstream HTTP local,
// e verifica o que o upstream efetivamente recebeu. Sem rede externa.
import { after, before, test } from 'node:test'
import assert from 'node:assert/strict'
import { createServer as criarHttp } from 'node:http'
import { fileURLToPath } from 'node:url'
import { createServer as criarVite } from 'vite'
import { proxyApiDev } from '../../scripts/proxy-dev.mjs'

const raiz = fileURLToPath(new URL('../..', import.meta.url))

/** @type {Array<{ metodo: string, url: string, headers: import('node:http').IncomingHttpHeaders }>} */
const recebidas = []
let upstream
let portaUpstream
let comUpstream
let semUpstream

async function subirVite(opcoesProxy) {
  const api = proxyApiDev(opcoesProxy)
  const servidor = await criarVite({
    root: raiz,
    configFile: false,
    logLevel: 'silent',
    plugins: [api.plugin],
    server: { host: '127.0.0.1', port: 0, strictPort: false, proxy: api.proxy, hmr: false, watch: null },
  })
  await servidor.listen()
  const { port } = /** @type {import('node:net').AddressInfo} */ (servidor.httpServer.address())
  return { servidor, base: `http://127.0.0.1:${port}` }
}

before(async () => {
  upstream = criarHttp((req, res) => {
    recebidas.push({ metodo: req.method ?? '', url: req.url ?? '', headers: req.headers })
    res.setHeader('content-type', 'application/json')
    res.end('[]')
  })
  await new Promise((ok) => upstream.listen(0, '127.0.0.1', ok))
  portaUpstream = upstream.address().port
  comUpstream = await subirVite({ upstream: `http://127.0.0.1:${portaUpstream}` })
  semUpstream = await subirVite({})
})

after(async () => {
  await comUpstream?.servidor.close()
  await semUpstream?.servidor.close()
  await new Promise((ok) => upstream.close(ok))
})

async function pedir(caminho, opcoes = {}) {
  recebidas.length = 0
  const resposta = await fetch(`${comUpstream.base}${caminho}`, opcoes)
  await resposta.arrayBuffer()
  return { status: resposta.status, recebidas: [...recebidas] }
}

test('rota permitida chega ao upstream sem o prefixo /api', async () => {
  const { status, recebidas } = await pedir('/api/filmes')
  assert.equal(status, 200)
  assert.deepEqual(recebidas.map((r) => [r.metodo, r.url]), [['GET', '/filmes']])
})

test('%2B chega ao upstream sem decodificar', async () => {
  const { status, recebidas } = await pedir('/api/filmes/streaming/Disney%2B')
  assert.equal(status, 200)
  assert.equal(recebidas[0]?.url, '/filmes/streaming/Disney%2B')
})

test('"+" literal chega intacto', async () => {
  const { recebidas } = await pedir('/api/filmes/streaming/Disney+')
  assert.equal(recebidas[0]?.url, '/filmes/streaming/Disney+')
})

test('espaços e acentos codificados chegam intactos', async () => {
  const { status, recebidas } = await pedir('/api/filmes/pesquisa/a%C3%A7%C3%A3o%20x')
  assert.equal(status, 200)
  assert.equal(recebidas[0]?.url, '/filmes/pesquisa/a%C3%A7%C3%A3o%20x')
})

test('query string não é repassada', async () => {
  const { recebidas } = await pedir('/api/filmes?x=1&y=2')
  assert.equal(recebidas[0]?.url, '/filmes')
})

test('HEAD é permitido', async () => {
  const { status, recebidas } = await pedir('/api/publicidades', { method: 'HEAD' })
  assert.equal(status, 200)
  assert.equal(recebidas[0]?.metodo, 'HEAD')
})

for (const caminho of ['/api/usuarios', '/api/usuarios/1', '/api/listas', '/api/filmes/1', '/api/filmes/streaming/', '/api']) {
  test(`${caminho} → 404 sem chegar ao upstream`, async () => {
    const { status, recebidas } = await pedir(caminho)
    assert.equal(status, 404)
    assert.equal(recebidas.length, 0)
  })
}

test('%2F decodificado vira separador e é bloqueado', async () => {
  const { status, recebidas } = await pedir('/api/filmes/pesquisa/a%2Fb')
  assert.equal(status, 404)
  assert.equal(recebidas.length, 0)
})

test('codificação inválida → 400', async () => {
  const { status, recebidas } = await pedir('/api/filmes/pesquisa/%E0%A4%A')
  assert.equal(status, 400)
  assert.equal(recebidas.length, 0)
})

for (const metodo of ['POST', 'PUT', 'DELETE', 'PATCH']) {
  test(`${metodo} em rota permitida → 403 sem chegar ao upstream`, async () => {
    const { status, recebidas } = await pedir('/api/filmes', { method: metodo })
    assert.equal(status, 403)
    assert.equal(recebidas.length, 0)
  })
}

test('/apix não é tratado como API nem encaminhado', async () => {
  const { recebidas } = await pedir('/apix/filmes')
  assert.equal(recebidas.length, 0)
})

test('Cookie e Origin são removidos; Host passa a ser o do upstream', async () => {
  const { recebidas } = await pedir('/api/filmes', { headers: { cookie: 'sessao=1', origin: 'http://malicioso.invalid' } })
  const headers = recebidas[0]?.headers ?? {}
  assert.equal(headers.cookie, undefined)
  assert.equal(headers.origin, undefined)
  assert.equal(headers.host, `127.0.0.1:${portaUpstream}`)
  assert.notEqual(headers.host, new URL(comUpstream.base).host)
})

test('sem upstream configurado, rota permitida → 503', async () => {
  const resposta = await fetch(`${semUpstream.base}/api/filmes`)
  assert.equal(resposta.status, 503)
  assert.match(await resposta.text(), /MM_API_UPSTREAM/)
})

test('sem upstream configurado, rota proibida continua 404', async () => {
  const resposta = await fetch(`${semUpstream.base}/api/usuarios`)
  assert.equal(resposta.status, 404)
})
