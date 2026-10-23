// Controle de egresso do perfil C. Roda no namespace de rede do BACKEND (network_mode:
// service:backend), ANTES de qualquer dado ser inserido. Falha (exit 1) se o backend conseguir
// alcançar o Aiven (produção) ou qualquer endereço externo. O MySQL local deve responder.
import { lookup } from 'node:dns/promises'
import { connect } from 'node:net'

const AIVEN = 'moviematch-db-moviematch-db.k.aivencloud.com'

function tcp(host, porta) {
  return new Promise((ok) => {
    const s = connect({ host, port: porta, timeout: 4000 }, () => {
      s.destroy()
      ok('CONECTOU')
    })
    s.on('error', (e) => ok(`falhou:${e.code}`))
    s.on('timeout', () => {
      s.destroy()
      ok('falhou:timeout')
    })
  })
}

const resultado = {}
try {
  await lookup(AIVEN)
  resultado.dnsAiven = 'RESOLVEU'
} catch (e) {
  resultado.dnsAiven = `falhou:${e.code}`
}
resultado.tcpAiven = await tcp(AIVEN, 22246)
resultado.tcpInternet = await tcp('1.1.1.1', 443)
resultado.tcpDnsPublico = await tcp('8.8.8.8', 53)
resultado.tcpMysqlLocal = await tcp('mysql', 3306)

console.log(JSON.stringify(resultado))
const vazou =
  resultado.dnsAiven === 'RESOLVEU' ||
  [resultado.tcpAiven, resultado.tcpInternet, resultado.tcpDnsPublico].includes('CONECTOU')
if (vazou || resultado.tcpMysqlLocal !== 'CONECTOU') {
  console.error('egresso: FALHOU (o backend alcança a rede externa ou não alcança o MySQL local)')
  process.exit(1)
}
console.log('egresso: ok (sem saída externa; MySQL local alcançável)')
