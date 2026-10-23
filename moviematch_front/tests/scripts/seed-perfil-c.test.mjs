import { test } from 'node:test'
import assert from 'node:assert/strict'
import { gerarSeed, sql } from '../../scripts/seed-perfil-c.mjs'

test('valores SQL: nulos, números e escape de aspas e barras', () => {
  assert.equal(sql(null), 'NULL')
  assert.equal(sql(undefined), 'NULL')
  assert.equal(sql(4.5), '4.5')
  assert.equal(sql("D'Ávila"), "'D''Ávila'")
  assert.equal(sql('a\\b'), "'a\\\\b'")
  assert.throws(() => sql(Infinity))
  assert.throws(() => sql({}))
})

test('seed é determinístico, em utf8mb4 e transacional', () => {
  const seed = gerarSeed()
  assert.equal(seed, gerarSeed())
  assert.ok(seed.startsWith('SET NAMES utf8mb4;\nSTART TRANSACTION;'))
  assert.ok(seed.trimEnd().endsWith('COMMIT;'))
})

test('seed traz os 13 filmes das fixtures, o filme com nulos e as publicidades', () => {
  const seed = gerarSeed()
  assert.equal((seed.match(/INSERT INTO filme \(/g) ?? []).length, 14)
  assert.equal((seed.match(/INSERT INTO publicidade /g) ?? []).length, 3)
  assert.match(seed, /VALUES \(99, 'Só o título', NULL/)
  assert.match(seed, /INSERT INTO filme_generos \(filme_id_filme, generos\) VALUES \(1, 'Drama'\);/)
})

test('seed só insere nas tabelas de catálogo (nunca usuários ou listas)', () => {
  const tabelas = new Set([...gerarSeed().matchAll(/INSERT INTO (\w+)/g)].map((m) => m[1]))
  assert.deepEqual([...tabelas].sort(), ['filme', 'filme_generos', 'publicidade'])
})
