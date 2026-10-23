// Gera (na saída padrão) o SQL de dados sintéticos do perfil C a partir das fixtures, para o
// MySQL DESCARTÁVEL do perfil C. Nunca usar em banco real.
// Tabelas e colunas: criadas pelo próprio backend (ddl-auto=update), confirmadas na F6-T02:
//   filme, filme_generos(filme_id_filme, generos), publicidade.
import { readFileSync } from 'node:fs'

const ler = (arquivo) => JSON.parse(readFileSync(new URL(`../tests/fixtures/${arquivo}`, import.meta.url), 'utf8'))

/** @param {unknown} valor */
export function sql(valor) {
  if (valor === null || valor === undefined) return 'NULL'
  if (typeof valor === 'number') {
    if (!Number.isFinite(valor)) throw new Error(`número inválido: ${valor}`)
    return String(valor)
  }
  if (typeof valor === 'string') return `'${valor.replace(/\\/g, '\\\\').replace(/'/g, "''")}'`
  throw new Error(`tipo não suportado: ${typeof valor}`)
}

const COLUNAS_FILME = [
  ['id_filme', 'id_filme'],
  ['titulo_filme', 'titulo_filme'],
  ['descricao_filme', 'descricao_filme'],
  ['imagem_diretor_filme', 'imagemDiretor_filme'],
  ['duracao_filme', 'duracao_filme'],
  ['streaming_filme', 'streaming_filme'],
  ['nacionalidade_filme', 'nacionalidade_filme'],
  ['classificacao_filme', 'classificacao_filme'],
  ['diretor_filme', 'diretor_filme'],
  ['link_imagem_filme_filme', 'linkImagemFilme_filme'],
  ['ator_especifico_filme', 'atorEspecifico_filme'],
  ['nota_filme', 'nota_filme'],
]

/** Filme real possível no schema (duração e textos nulos), ausente das fixtures de lista. */
export const FILME_COM_NULOS = {
  id_filme: 99,
  titulo_filme: 'Só o título',
  descricao_filme: null,
  imagemDiretor_filme: null,
  duracao_filme: null,
  streaming_filme: null,
  nacionalidade_filme: null,
  classificacao_filme: null,
  diretor_filme: null,
  linkImagemFilme_filme: null,
  atorEspecifico_filme: null,
  nota_filme: 4,
  generos: [],
}

export function gerarSeed() {
  const filmes = [...ler('filmes-validos.json'), FILME_COM_NULOS]
  const publicidades = ler('publicidades.json')
  const linhas = ['SET NAMES utf8mb4;', 'START TRANSACTION;']
  for (const f of filmes) {
    linhas.push(
      `INSERT INTO filme (${COLUNAS_FILME.map(([c]) => c).join(', ')}) VALUES (${COLUNAS_FILME.map(([, k]) => sql(f[k])).join(', ')});`,
    )
    for (const g of f.generos) linhas.push(`INSERT INTO filme_generos (filme_id_filme, generos) VALUES (${sql(f.id_filme)}, ${sql(g)});`)
  }
  for (const p of publicidades) {
    linhas.push(
      `INSERT INTO publicidade (id_publicidade, descricao, link_imagem) VALUES (${sql(p.id_publicidade)}, ${sql(p.descricao)}, ${sql(p.link_imagem)});`,
    )
  }
  linhas.push('COMMIT;', '')
  return linhas.join('\n')
}

if (import.meta.url === `file://${process.argv[1]}`) process.stdout.write(gerarSeed())
