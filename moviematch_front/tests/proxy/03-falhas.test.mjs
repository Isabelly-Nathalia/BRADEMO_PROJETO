// Falhas do upstream e prazos do proxy (cliente 30 s < proxy 35 s).
import { beforeEach, test } from 'node:test'
import assert from 'node:assert/strict'
import { FRONT_SEM_API, limparRegistro, pedir } from './apoio.mjs'

beforeEach(limparRegistro)

test('API fora do ar: healthz continua 200 e a API responde 502 rápido', async () => {
  assert.equal((await pedir('/healthz', { alvo: FRONT_SEM_API })).status, 200)
  const r = await pedir('/api/filmes', { alvo: FRONT_SEM_API })
  assert.equal(r.status, 502)
  assert.ok(r.ms < 10_000, `demorou ${r.ms} ms`)
})

test('API fora do ar: a SPA continua sendo servida', async () => {
  const r = await pedir('/inicio', { alvo: FRONT_SEM_API })
  assert.equal(r.status, 200)
  assert.match(r.corpo, /<div id="app"><\/div>/)
})

test('erro do backend é repassado como está (500)', async () => {
  const r = await pedir('/api/filmes', { headers: { 'x-mock-cenario': 'http-500' } })
  assert.equal(r.status, 500)
})

test('backend lento (32 s): o proxy espera mais que o cliente (30 s) e entrega 200', async () => {
  const r = await pedir('/api/filmes', { headers: { 'x-mock-cenario': 'lento:32000' } })
  assert.equal(r.status, 200)
  assert.ok(r.ms >= 31_000, `respondeu em ${r.ms} ms`)
})

test('backend pendurado: o proxy desiste com 504 por volta de 35 s', async () => {
  const r = await pedir('/api/filmes', { headers: { 'x-mock-cenario': 'pendurado' } })
  assert.equal(r.status, 504)
  assert.ok(r.ms >= 33_000 && r.ms <= 38_000, `respondeu em ${r.ms} ms`)
})
