import { test } from 'node:test'
import assert from 'node:assert/strict'
import { carregarAllowlist, criarVerificador, validarAllowlist } from '../../scripts/allowlist.mjs'
import { CASOS } from './casos-allowlist.mjs'

const permitido = criarVerificador(carregarAllowlist())

for (const [metodo, caminho, esperado] of CASOS) {
  test(`${metodo} ${JSON.stringify(caminho)} → ${esperado ? 'permitido' : 'bloqueado'}`, () => {
    assert.equal(permitido(metodo, caminho), esperado)
  })
}

const base = { versao: 1, metodos: ['GET'], rotas: ['/filmes'] }

const INVALIDAS = [
  ['raiz nula', null, /raiz/],
  ['versão errada', { ...base, versao: 2 }, /versao/],
  ['campo desconhecido', { ...base, extra: true }, /desconhecidos/],
  ['método de escrita', { ...base, metodos: ['GET', 'POST'] }, /método não permitido: POST/],
  ['métodos vazios', { ...base, metodos: [] }, /metodos/],
  ['rotas vazias', { ...base, rotas: [] }, /rotas/],
  ['rota /usuarios', { ...base, rotas: ['/usuarios'] }, /proibida/],
  ['rota sob /usuarios', { ...base, rotas: ['/usuarios/{segmento}'] }, /proibida/],
  ['rota /listas', { ...base, rotas: ['/listas/{segmento}/filme'] }, /proibida/],
  ['coringa desconhecido', { ...base, rotas: ['/filmes/{id}'] }, /segmento inválido/],
  ['barra final', { ...base, rotas: ['/filmes/'] }, /rota inválida/],
  ['sem barra inicial', { ...base, rotas: ['filmes'] }, /rota inválida/],
  ['segmento vazio', { ...base, rotas: ['/filmes//x'] }, /segmento inválido/],
  ['maiúsculas', { ...base, rotas: ['/Filmes'] }, /segmento inválido/],
  ['duplicada', { ...base, rotas: ['/filmes', '/filmes'] }, /duplicada/],
]

for (const [nome, dados, erro] of INVALIDAS) {
  test(`allowlist inválida: ${nome}`, () => {
    assert.throws(() => validarAllowlist(dados), erro)
  })
}

test('/usuarios continua bloqueado mesmo que alguém tente prefixo parecido', () => {
  const v = criarVerificador(validarAllowlist({ ...base, rotas: ['/usuariosx'] }))
  assert.equal(v('GET', '/usuariosx'), true)
  assert.equal(v('GET', '/usuarios'), false)
})
