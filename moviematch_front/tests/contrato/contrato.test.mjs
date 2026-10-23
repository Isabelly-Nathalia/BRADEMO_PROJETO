// Contrato da API legada, observado no backend ORIGINAL (moviematch-back:baseline) com MySQL
// descartável e o seed de scripts/seed-perfil-c.mjs. Chama o backend direto, sem o proxy.
import { test } from 'node:test'
import assert from 'node:assert/strict'

const BACKEND = process.env.BACKEND ?? 'http://backend:8080'

async function get(caminho, init) {
  const r = await fetch(`${BACKEND}${caminho}`, init)
  const texto = await r.text()
  let json
  try {
    json = JSON.parse(texto)
  } catch {
    json = undefined
  }
  return { status: r.status, headers: r.headers, texto, json }
}
const titulos = (lista) => lista.map((f) => f.titulo_filme)

const CAMPOS_FILME = [
  'atorEspecifico_filme', 'classificacao_filme', 'descricao_filme', 'diretor_filme', 'duracao_filme',
  'generos', 'id_filme', 'imagemDiretor_filme', 'linkImagemFilme_filme', 'nacionalidade_filme',
  'nota_filme', 'streaming_filme', 'titulo_filme',
]

test('GET /filmes: JSON com exatamente os 13 campos do contrato em cada filme', async () => {
  const r = await get('/filmes')
  assert.equal(r.status, 200)
  assert.match(r.headers.get('content-type') ?? '', /application\/json/)
  assert.equal(r.json.length, 14)
  for (const f of r.json) assert.deepEqual(Object.keys(f).sort(), CAMPOS_FILME)
})

test('tipos: id e nota numéricos, gêneros sempre lista, acentos preservados', async () => {
  const { json } = await get('/filmes')
  for (const f of json) {
    assert.equal(typeof f.id_filme, 'number')
    assert.equal(typeof f.nota_filme, 'number')
    assert.ok(Array.isArray(f.generos))
  }
  assert.ok(titulos(json).includes('Ação e Reação'))
  assert.deepEqual(json.find((f) => f.id_filme === 1).generos.sort(), ['Ação', 'Drama'])
})

test('campos nulos chegam como null; gêneros vazios como []; nota inteira como número', async () => {
  const f = (await get('/filmes')).json.find((x) => x.id_filme === 99)
  assert.equal(f.duracao_filme, null)
  assert.equal(f.streaming_filme, null)
  assert.equal(f.descricao_filme, null)
  assert.deepEqual(f.generos, [])
  assert.equal(f.nota_filme, 4)
})

test('GET /filmes/aleatorios: 5 filmes do catálogo', async () => {
  const todos = new Set((await get('/filmes')).json.map((f) => f.id_filme))
  const { status, json } = await get('/filmes/aleatorios')
  assert.equal(status, 200)
  assert.equal(json.length, 5)
  for (const f of json) assert.ok(todos.has(f.id_filme))
})

test('GET /filmes/{id} não existe: 404 em JSON do Spring', async () => {
  const r = await get('/filmes/1')
  assert.equal(r.status, 404)
  assert.equal(r.json.status, 404)
  assert.equal(r.json.error, 'Not Found')
})

test('streaming: "+" literal e %2B chegam como "Disney+"', async () => {
  assert.deepEqual(titulos((await get('/filmes/streaming/Disney%2B')).json), ['Galáxia Esquecida'])
  assert.deepEqual(titulos((await get('/filmes/streaming/Disney+')).json), ['Galáxia Esquecida'])
})

test('streaming no MySQL padrão (utf8mb4_0900_ai_ci): igualdade ignora maiúsculas', async () => {
  // "GloboPlay" casa "Globoplay" e "GloboPlay"; no mock (comparação exata) só o segundo.
  assert.deepEqual(titulos((await get('/filmes/streaming/GloboPlay')).json).sort(), ['Canção do Mar', 'Sombras do Vale'])
  assert.deepEqual(titulos((await get('/filmes/streaming/netflix')).json).length, 3)
})

test('"outros": NOT IN também ignora maiúsculas; NULL fica de fora', async () => {
  // GloboPlay é tratado como Globoplay (fora de "outros"); AppleTV ≠ Apple TV (espaço) entra;
  // streaming nulo não satisfaz NOT IN (lógica de três valores do SQL) e fica de fora.
  assert.deepEqual(titulos((await get('/filmes/streaming/outros')).json), ['Pequenos Heróis', 'Dragão de Jade'])
})

test('pesquisa: LIKE ignora maiúsculas e acentos', async () => {
  const comAcento = titulos((await get('/filmes/pesquisa/a%C3%A7%C3%A3o')).json)
  assert.deepEqual(comAcento, ['Coração em Seul', 'Ação e Reação'])
  assert.deepEqual(titulos((await get('/filmes/pesquisa/ACAO')).json), comAcento)
})

test('pesquisa com %2F: 400 do Tomcat (o proxy já bloqueia antes)', async () => {
  const r = await get('/filmes/pesquisa/a%2Fb')
  assert.equal(r.status, 400)
})

test('GET /publicidades: 3 itens com os 3 campos', async () => {
  const { status, json } = await get('/publicidades')
  assert.equal(status, 200)
  assert.equal(json.length, 3)
  for (const p of json) assert.deepEqual(Object.keys(p).sort(), ['descricao', 'id_publicidade', 'link_imagem'])
})

test('sem CORS: nenhum Access-Control-Allow-Origin, nem no preflight (proxy é obrigatório)', async () => {
  const pre = await get('/filmes', { method: 'OPTIONS', headers: { origin: 'http://front.invalid', 'access-control-request-method': 'GET' } })
  assert.equal(pre.headers.get('access-control-allow-origin'), null)
  const simples = await get('/filmes', { headers: { origin: 'http://front.invalid' } })
  assert.equal(simples.headers.get('access-control-allow-origin'), null)
})
