// Allowlist, métodos e codificação de caminhos, verificados no que o backend recebe.
import { beforeEach, test } from 'node:test'
import assert from 'node:assert/strict'
import { limparRegistro, pedir, recebidas } from './apoio.mjs'

beforeEach(limparRegistro)

const PERMITIDAS = [
  ['/api/filmes', '/filmes'],
  ['/api/filmes/aleatorios', '/filmes/aleatorios'],
  ['/api/filmes/streaming/Netflix', '/filmes/streaming/Netflix'],
  ['/api/filmes/streaming/outros', '/filmes/streaming/outros'],
  ['/api/filmes/pesquisa/cidade', '/filmes/pesquisa/cidade'],
  ['/api/publicidades', '/publicidades'],
]

for (const [caminho, noBackend] of PERMITIDAS) {
  test(`GET ${caminho} → 200 e o backend recebe ${noBackend}`, async () => {
    const r = await pedir(caminho)
    assert.equal(r.status, 200)
    assert.deepEqual((await recebidas()).map((x) => [x.metodo, x.url]), [['GET', noBackend]])
  })
}

test('HEAD é permitido', async () => {
  const r = await pedir('/api/filmes', { metodo: 'HEAD' })
  assert.equal(r.status, 200)
  assert.equal(r.corpo, '')
})

for (const metodo of ['POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS']) {
  test(`${metodo} /api/filmes → 403 sem chegar ao backend`, async () => {
    const r = await pedir('/api/filmes', { metodo, corpo: metodo === 'OPTIONS' ? undefined : '{}' })
    assert.equal(r.status, 403)
    assert.equal((await recebidas()).length, 0)
  })
}

const BLOQUEADAS = [
  '/api',
  '/api/',
  '/api/usuarios',
  '/api/usuarios/1',
  '/api/usuarios/login',
  '/api/listas',
  '/api/listas/usuario/1',
  '/api/filmes/1',
  '/api/filmes/1/extra',
  '/api/filmes/streaming/',
  '/api/publicidades/1',
  '/api/__requisicoes',
  '/api/__cenario?nome=http-500',
  // %2F decodificado vira "/" e cria um segmento a mais
  '/api/filmes/pesquisa/a%2Fb',
  // segmentos "." / ".." (literais ou %2e) e barras duplas: recusados no caminho bruto
  '/api/usuarios/../filmes',
  '/api/listas/%2e%2e/filmes',
  '/api/filmes/streaming/..',
  '/api/filmes/streaming/%2E',
  '/api//filmes',
  '/api/filmes//aleatorios',
]

for (const caminho of BLOQUEADAS) {
  test(`${caminho} → 404 sem chegar ao backend`, async () => {
    const r = await pedir(caminho)
    assert.equal(r.status, 404)
    assert.equal((await recebidas()).length, 0)
  })
}

test('POST em rota bloqueada também não chega ao backend', async () => {
  const r = await pedir('/api/usuarios', { metodo: 'POST', corpo: '{"email_usuario":"x"}' })
  assert.ok([403, 404].includes(r.status))
  assert.equal((await recebidas()).length, 0)
})

const CODIFICACAO = [
  ['%2B chega sem decodificar', '/api/filmes/streaming/Disney%2B', '/filmes/streaming/Disney%2B'],
  ['"+" literal chega intacto', '/api/filmes/streaming/Disney+', '/filmes/streaming/Disney+'],
  ['espaço codificado chega intacto', '/api/filmes/pesquisa/cidade%20de', '/filmes/pesquisa/cidade%20de'],
  ['acentos codificados chegam intactos', '/api/filmes/pesquisa/a%C3%A7%C3%A3o', '/filmes/pesquisa/a%C3%A7%C3%A3o'],
  ['reticências no termo são permitidas', '/api/filmes/pesquisa/a...b', '/filmes/pesquisa/a...b'],
]

for (const [nome, caminho, noBackend] of CODIFICACAO) {
  test(nome, async () => {
    const r = await pedir(caminho)
    assert.equal(r.status, 200)
    assert.equal((await recebidas())[0]?.url, noBackend)
  })
}

test('query string não é repassada ao backend', async () => {
  await pedir('/api/filmes?x=1&nome=http-500')
  assert.equal((await recebidas())[0]?.url, '/filmes')
})
