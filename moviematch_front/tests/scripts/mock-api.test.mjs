// Sobe o mock em processo (porta efêmera) e verifica rotas, cenários e registro bruto.
import { after, before, beforeEach, test } from 'node:test'
import assert from 'node:assert/strict'
import { fileURLToPath } from 'node:url'
import { criarServidor } from '../../docker/mock-api/server.mjs'

const fixtures = fileURLToPath(new URL('../fixtures', import.meta.url))
const { servidor, requisicoes } = criarServidor({ fixtures })
let base

before(async () => {
  await new Promise((ok) => servidor.listen(0, '127.0.0.1', ok))
  base = `http://127.0.0.1:${servidor.address().port}`
})

after(() => new Promise((ok) => servidor.close(ok)))

beforeEach(async () => {
  await fetch(`${base}/__cenario?nome=normal`, { method: 'POST' })
  await fetch(`${base}/__requisicoes`, { method: 'DELETE' })
})

const getJson = async (caminho, cabecalhos = {}) => {
  const r = await fetch(`${base}${caminho}`, { headers: cabecalhos })
  return { status: r.status, corpo: await r.text(), headers: r.headers }
}
const titulos = (corpo) => JSON.parse(corpo).map((f) => f.titulo_filme)

test('saúde', async () => {
  assert.equal((await getJson('/__saude')).status, 200)
})

test('rotas de dados no cenário normal', async () => {
  assert.equal(JSON.parse((await getJson('/filmes')).corpo).length, 13)
  assert.equal(JSON.parse((await getJson('/filmes/aleatorios')).corpo).length, 5)
  assert.equal(JSON.parse((await getJson('/publicidades')).corpo).length, 3)
  assert.deepEqual(titulos((await getJson('/filmes/streaming/Disney%2B')).corpo), ['Galáxia Esquecida'])
  assert.deepEqual(titulos((await getJson('/filmes/pesquisa/a%C3%A7%C3%A3o')).corpo), ['Coração em Seul', 'Ação e Reação'])
})

test('"outros" usa a mesma lista fixa do JPQL do backend', async () => {
  // GloboPlay e AppleTV não estão na lista fixa (Globoplay, Apple TV): caem em "outros" (A-05).
  assert.deepEqual(titulos((await getJson('/filmes/streaming/outros')).corpo), ['Canção do Mar', 'Pequenos Heróis', 'Dragão de Jade'])
})

test('rota inexistente → 404 no formato do Spring', async () => {
  const { status, corpo } = await getJson('/filmes/1')
  assert.equal(status, 404)
  assert.equal(JSON.parse(corpo).error, 'Not Found')
})

test('registro guarda o caminho bruto, sem decodificar', async () => {
  await getJson('/filmes/streaming/Disney%2B?x=1')
  assert.deepEqual(requisicoes().map((r) => r.url), ['/filmes/streaming/Disney%2B?x=1'])
})

test('o registro também é exposto por HTTP e pode ser limpo', async () => {
  await getJson('/filmes')
  const { corpo } = await getJson('/__requisicoes')
  assert.deepEqual(JSON.parse(corpo).map((r) => r.url), ['/filmes'])
  await fetch(`${base}/__requisicoes`, { method: 'DELETE' })
  assert.deepEqual(JSON.parse((await getJson('/__requisicoes')).corpo), [])
})

test('respostas de dados trazem Set-Cookie (para o proxy ocultar)', async () => {
  assert.match((await getJson('/filmes')).headers.get('set-cookie') ?? '', /rastreio-mock/)
})

const CASOS_CENARIO = [
  ['vazio', (r) => assert.deepEqual(JSON.parse(r.corpo), [])],
  ['invalidos', (r) => assert.equal(JSON.parse(r.corpo).length, 16)],
  ['todos-invalidos', (r) => assert.equal(JSON.parse(r.corpo).length, 11)],
  ['repetidos', (r) => assert.equal(JSON.parse(r.corpo).length, 4)],
  ['json-malformado', (r) => assert.throws(() => JSON.parse(r.corpo))],
  ['http-500', (r) => assert.equal(r.status, 500)],
  ['http-404', (r) => assert.equal(r.status, 404)],
]

for (const [nome, verificar] of CASOS_CENARIO) {
  test(`cenário global "${nome}"`, async () => {
    assert.equal((await fetch(`${base}/__cenario?nome=${nome}`, { method: 'POST' })).status, 200)
    verificar(await getJson('/filmes'))
  })

  test(`cenário por cabeçalho "${nome}" não afeta outras requisições`, async () => {
    verificar(await getJson('/filmes', { 'x-mock-cenario': nome }))
    assert.equal(JSON.parse((await getJson('/filmes')).corpo).length, 13)
  })
}

test('lento:<ms> atrasa a resposta', async () => {
  const inicio = Date.now()
  const { status } = await getJson('/filmes', { 'x-mock-cenario': 'lento:300' })
  assert.equal(status, 200)
  assert.ok(Date.now() - inicio >= 280)
})

test('pendurado nunca responde (o cliente desiste)', async () => {
  await assert.rejects(fetch(`${base}/filmes`, { headers: { 'x-mock-cenario': 'pendurado' }, signal: AbortSignal.timeout(300) }))
})

test('cenário inválido é recusado e o cabeçalho inválido é ignorado', async () => {
  assert.equal((await fetch(`${base}/__cenario?nome=inventado`, { method: 'POST' })).status, 400)
  assert.equal((await getJson('/filmes', { 'x-mock-cenario': 'inventado' })).status, 200)
})

test('rotas de usuários e listas existem no mock (para provar que o proxy bloqueia)', async () => {
  assert.equal((await getJson('/usuarios')).status, 200)
  assert.equal((await getJson('/listas/1')).status, 200)
})
