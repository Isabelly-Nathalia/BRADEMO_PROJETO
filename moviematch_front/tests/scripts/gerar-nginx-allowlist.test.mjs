import { test } from 'node:test'
import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'
import { carregarAllowlist, criarVerificador, validarAllowlist } from '../../scripts/allowlist.mjs'
import { DESTINO, gerarConfiguracao, regexDasRotas } from '../../scripts/gerar-nginx-allowlist.mjs'
import { CASOS } from './casos-allowlist.mjs'

const allowlist = carregarAllowlist()

test('a geração é determinística (mesma entrada, mesmos bytes)', () => {
  assert.equal(gerarConfiguracao(allowlist), gerarConfiguracao(carregarAllowlist()))
})

test('o arquivo versionado está em dia com api-allowlist.json', () => {
  assert.equal(readFileSync(DESTINO, 'utf8'), gerarConfiguracao(allowlist))
})

test('mudar a allowlist muda o arquivo gerado', () => {
  const outra = validarAllowlist({ ...allowlist, rotas: [...allowlist.rotas, '/extra'] })
  assert.notEqual(gerarConfiguracao(outra), gerarConfiguracao(allowlist))
})

test('o bloco só libera GET/HEAD e inclui o proxy', () => {
  const conf = gerarConfiguracao(allowlist)
  assert.match(conf, /limit_except GET \{\s+deny all;\s+\}/)
  assert.match(conf, /include \/etc\/nginx\/conf\.d\/api-proxy\.inc;/)
})

// A regex gerada (PCRE simples, compatível com RegExp do JS) decide exatamente como o verificador
// da allowlist. O Nginx casa a URI decodificada, então os casos usam caminhos decodificados.
const regex = new RegExp(regexDasRotas(allowlist.rotas))
const permitido = criarVerificador(allowlist)
const metodosLiberados = new Set(['GET', 'HEAD'])

for (const [metodo, caminho, esperado] of CASOS) {
  test(`Nginx ≡ verificador: ${metodo} ${JSON.stringify(caminho)}`, () => {
    const decideNginx = regex.test(`/api${caminho}`) && metodosLiberados.has(metodo.toUpperCase())
    assert.equal(decideNginx, esperado)
    assert.equal(decideNginx, permitido(metodo, caminho))
  })
}
