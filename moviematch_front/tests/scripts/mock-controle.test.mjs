// Porta de controle do mock (perfil E): parar e retomar a porta de dados sem perder o estado.
import { after, before, test } from 'node:test'
import assert from 'node:assert/strict'
import { fileURLToPath } from 'node:url'
import { criarControle, criarServidor } from '../../docker/mock-api/server.mjs'

const fixtures = fileURLToPath(new URL('../fixtures', import.meta.url))
const { servidor, requisicoes } = criarServidor({ fixtures })
let porta
let controle
let baseControle

before(async () => {
  await new Promise((ok) => servidor.listen(0, '127.0.0.1', ok))
  porta = servidor.address().port
  // A porta de dados é reaberta no mesmo número depois de /__parar.
  controle = criarControle(servidor, porta)
  await new Promise((ok) => controle.listen(0, '127.0.0.1', ok))
  baseControle = `http://127.0.0.1:${controle.address().port}`
})

after(async () => {
  await new Promise((ok) => controle.close(ok))
  if (servidor.listening) await new Promise((ok) => servidor.close(ok))
})

const dados = () => fetch(`http://127.0.0.1:${porta}/filmes`, { signal: AbortSignal.timeout(2000) })
const comando = (rota, metodo = 'POST') => fetch(`${baseControle}${rota}`, { method: metodo })

test('parar recusa conexões na porta de dados; retomar volta a responder com o mesmo estado', async () => {
  assert.equal((await dados()).status, 200)
  const antes = requisicoes().length

  assert.equal((await comando('/__parar')).status, 200)
  await assert.rejects(dados(), (erro) => erro.cause?.code === 'ECONNREFUSED')

  assert.equal((await comando('/__retomar')).status, 200)
  assert.equal((await dados()).status, 200)
  assert.equal(requisicoes().length, antes + 1)
})

test('parar encerra também requisições penduradas', async () => {
  const pendente = fetch(`http://127.0.0.1:${porta}/filmes`, { headers: { 'x-mock-cenario': 'pendurado' } })
  await new Promise((ok) => setTimeout(ok, 50))
  await comando('/__parar')
  await assert.rejects(pendente)
  await comando('/__retomar')
})

test('comandos são idempotentes e só aceitam POST', async () => {
  assert.equal((await comando('/__retomar')).status, 200)
  assert.equal((await comando('/__parar', 'GET')).status, 405)
  assert.equal((await comando('/__inventado')).status, 404)
  assert.equal((await dados()).status, 200)
})
