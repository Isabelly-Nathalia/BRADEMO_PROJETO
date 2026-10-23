// Metas de tamanho dos assets (plano, F4-T01) e consistência com a tabela de streamings.
import { test } from 'node:test'
import assert from 'node:assert/strict'
import { readdirSync, statSync } from 'node:fs'
import { join } from 'node:path'
import { fileURLToPath } from 'node:url'
import { STREAMINGS_HOME } from '../../src/domain/streamings.ts'

const assets = fileURLToPath(new URL('../../src/assets/', import.meta.url))

/** Caminhos absolutos de todos os arquivos sob src/assets/<pasta>. */
function arquivos(pasta) {
  return readdirSync(join(assets, pasta), { recursive: true, withFileTypes: true })
    .filter((e) => e.isFile())
    .map((e) => join(e.parentPath, e.name))
}

test('total de imagens em src/assets ≤ 1,5 MB', () => {
  const total = arquivos('').reduce((soma, caminho) => soma + statSync(caminho).size, 0)
  assert.ok(total > 0 && total <= 1.5 * 1024 * 1024, `total: ${total} bytes`)
})

test('cada pôster ≤ 150 KB', () => {
  const posteres = arquivos('posteres')
  assert.equal(posteres.length, 6)
  for (const caminho of posteres) {
    assert.ok(statSync(caminho).size <= 150 * 1024, `${caminho}: ${statSync(caminho).size} bytes`)
  }
})

test('existe um logo para cada streaming da tabela', () => {
  for (const { logo, slug } of STREAMINGS_HOME) {
    assert.ok(statSync(join(assets, 'streamings', `${logo}.webp`)).isFile(), `logo ausente para ${slug}`)
  }
})
