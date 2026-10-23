// Garante que as regras de segurança do ESLint estão ativas.
// A fixture é analisada como se estivesse em src/, onde as regras valem.
import { test } from 'node:test'
import assert from 'node:assert/strict'
import { readFile } from 'node:fs/promises'
import { fileURLToPath } from 'node:url'
import { ESLint } from 'eslint'

const raiz = fileURLToPath(new URL('../..', import.meta.url))
const codigo = await readFile(new URL('./proibido.vue', import.meta.url), 'utf8')
const eslint = new ESLint({ cwd: raiz })

async function regrasVioladas(caminhoVirtual) {
  const [resultado] = await eslint.lintText(codigo, { filePath: caminhoVirtual })
  return resultado.messages.map((m) => m.ruleId)
}

test('em src/pages: v-html e acesso direto ao storage são erros', async () => {
  const regras = await regrasVioladas('src/pages/Proibido.vue')
  assert.ok(regras.includes('vue/no-v-html'), `regras: ${regras}`)
  assert.ok(regras.includes('no-restricted-globals'), `regras: ${regras}`)
  assert.ok(regras.includes('no-restricted-properties'), `regras: ${regras}`)
})

test('em src/composables: storage permitido, v-html continua proibido', async () => {
  const regras = await regrasVioladas('src/composables/Permitido.vue')
  assert.ok(regras.includes('vue/no-v-html'), `regras: ${regras}`)
  assert.ok(!regras.includes('no-restricted-globals'), `regras: ${regras}`)
  assert.ok(!regras.includes('no-restricted-properties'), `regras: ${regras}`)
})
