// Checagem cruzada: toda chamada que a tabela de streamings gera passa na allowlist.
// Fica em tests/scripts porque usa a allowlist (Node); o Node 24 importa o .ts diretamente.
import { test } from 'node:test'
import assert from 'node:assert/strict'
import { carregarAllowlist, criarVerificador } from '../../scripts/allowlist.mjs'
import { STREAMINGS_HOME } from '../../src/domain/streamings.ts'

const permitido = criarVerificador(carregarAllowlist())

for (const s of STREAMINGS_HOME) {
  const caminho = s.filtro.tipo === 'valor' ? `/filmes/streaming/${s.filtro.valor}` : '/filmes/streaming/outros'
  test(`${s.slug}: GET ${caminho} é permitido`, () => {
    assert.equal(permitido('GET', caminho), true)
  })
}
