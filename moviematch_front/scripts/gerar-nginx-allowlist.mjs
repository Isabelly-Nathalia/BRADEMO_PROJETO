// Gera docker/nginx/allowlist.conf a partir de api-allowlist.json (fonte única).
// Saída determinística: mesma entrada → mesmos bytes (sem data, ordem da fonte).
//
//   node scripts/gerar-nginx-allowlist.mjs              grava o arquivo
//   node scripts/gerar-nginx-allowlist.mjs --verificar  falha (exit 1) se o arquivo divergir
//
// A `location` casa a URI já decodificada e normalizada pelo Nginx; o caminho repassado ao
// upstream é o original (variável $mm_api_caminho, definida em default.conf.template).
import { readFileSync, writeFileSync } from 'node:fs'
import { fileURLToPath } from 'node:url'
import { CORINGA, carregarAllowlist } from './allowlist.mjs'

export const DESTINO = new URL('../docker/nginx/allowlist.conf', import.meta.url)

// Um segmento qualquer, exceto "." e ".." (o Nginx já normaliza a URI, mas a regra precisa
// coincidir com a do verificador da allowlist por construção, não por acaso).
const SEGMENTO_LIVRE = '(?!\\.{1,2}(?:/|$))[^/]+'

/**
 * Regex (sintaxe PCRE do Nginx) que casa exatamente as rotas da allowlist sob /api.
 * @param {readonly string[]} rotas
 * @returns {string}
 */
export function regexDasRotas(rotas) {
  const alternativas = rotas.map((rota) =>
    rota
      .slice(1)
      .split('/')
      .map((segmento) => (segmento === CORINGA ? SEGMENTO_LIVRE : segmento))
      .join('/'),
  )
  return `^/api/(?:${alternativas.join('|')})$`
}

/**
 * Conteúdo completo do arquivo gerado.
 * @param {import('./allowlist.mjs').Allowlist} allowlist
 * @returns {string}
 */
export function gerarConfiguracao(allowlist) {
  // limit_except GET também libera HEAD; a validação da allowlist só admite GET e HEAD.
  return [
    '# GERADO por scripts/gerar-nginx-allowlist.mjs a partir de api-allowlist.json.',
    '# Não edite à mão: altere api-allowlist.json e rode `npm run gerar:allowlist`.',
    `location ~ ${regexDasRotas(allowlist.rotas)} {`,
    '    limit_except GET {',
    '        deny all;',
    '    }',
    '    include /etc/nginx/conf.d/api-proxy.inc;',
    '}',
    '',
  ].join('\n')
}

function principal() {
  const conteudo = gerarConfiguracao(carregarAllowlist())
  if (process.argv.includes('--verificar')) {
    let atual = ''
    try {
      atual = readFileSync(DESTINO, 'utf8')
    } catch {
      // ausente conta como divergente
    }
    if (atual !== conteudo) {
      console.error('docker/nginx/allowlist.conf diverge de api-allowlist.json: rode `npm run gerar:allowlist`.')
      process.exit(1)
    }
    console.log('allowlist do Nginx em dia')
    return
  }
  writeFileSync(DESTINO, conteudo)
  console.log(`gerado ${fileURLToPath(DESTINO)}`)
}

if (process.argv[1] && fileURLToPath(import.meta.url) === process.argv[1]) principal()
