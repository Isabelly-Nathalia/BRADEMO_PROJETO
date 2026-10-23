// Headers de segurança, cache, cookies e o que o backend recebe de cabeçalhos.
import { before, beforeEach, test } from 'node:test'
import assert from 'node:assert/strict'
import { limparRegistro, pedir, recebidas } from './apoio.mjs'

let asset

before(async () => {
  const indice = await pedir('/')
  asset = /src="(\/assets\/[^"]+\.js)"/.exec(indice.corpo)?.[1]
  assert.ok(asset, 'index.html deveria referenciar um /assets/*.js')
})

beforeEach(limparRegistro)

const SEGURANCA = {
  'content-security-policy': /default-src 'self'.*script-src 'self'.*frame-ancestors 'none'/,
  'x-content-type-options': /^nosniff$/,
  'referrer-policy': /^no-referrer$/,
  'x-frame-options': /^DENY$/,
}

for (const nome of ['/', '/index.html', 'asset', '/api/filmes', '/rota/da/spa']) {
  test(`headers de segurança em ${nome}`, async () => {
    const r = await pedir(nome === 'asset' ? asset : nome)
    assert.equal(r.status, 200)
    for (const [cabecalho, formato] of Object.entries(SEGURANCA)) {
      assert.match(String(r.headers[cabecalho] ?? ''), formato, `${cabecalho} em ${nome}`)
    }
  })
}

test('cache: assets imutáveis, index.html revalidado, API sem cache', async () => {
  assert.match(String((await pedir(asset)).headers['cache-control']), /max-age=31536000.*immutable/)
  assert.equal((await pedir('/')).headers['cache-control'], 'no-cache')
  assert.equal((await pedir('/index.html')).headers['cache-control'], 'no-cache')
  assert.equal((await pedir('/api/filmes')).headers['cache-control'], 'no-store')
})

test('rotas da SPA recebem o index.html', async () => {
  for (const rota of ['/filmes/42', '/questionario/3', '/qualquer/coisa']) {
    const r = await pedir(rota)
    assert.equal(r.status, 200)
    assert.match(r.corpo, /<div id="app"><\/div>/)
  }
})

test('asset inexistente → 404 (não cai no index.html)', async () => {
  assert.equal((await pedir('/assets/nao-existe.js')).status, 404)
})

test('Set-Cookie do backend não chega ao navegador', async () => {
  const r = await pedir('/api/filmes')
  assert.equal(r.headers['set-cookie'], undefined)
})

test('Cookie, Authorization e Origin do navegador não chegam ao backend', async () => {
  await pedir('/api/filmes', {
    headers: { cookie: 'sessao=1', authorization: 'Bearer x', origin: 'http://malicioso.invalid' },
  })
  const [r] = await recebidas()
  assert.equal(r?.headers.cookie, undefined)
  assert.equal(r?.headers.authorization, undefined)
  assert.equal(r?.headers.origin, undefined)
})

test('Host enviado ao backend é o configurado (API_HOST)', async () => {
  await pedir('/api/filmes')
  assert.equal((await recebidas())[0]?.headers.host, 'mock-api:8081')
})

test('versão do Nginx não é exposta', async () => {
  assert.equal((await pedir('/')).headers.server, 'nginx')
})

test('/healthz responde 200 em texto', async () => {
  const r = await pedir('/healthz')
  assert.equal(r.status, 200)
  assert.equal(r.corpo, 'ok\n')
})
