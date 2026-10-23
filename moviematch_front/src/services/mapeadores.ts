// Única porta de entrada dos dados da API: valida e converte o JSON bruto em modelos internos.
// A-01: um item inválido é descartado e contado; erros sistêmicos não viram "lista vazia".
import { FalhaApi } from './http'
import { urlHttpsOuNull } from './url'
import type { Filme, Publicidade, ResultadoLista } from '../types/modelos'

type Registro = Record<string, unknown>

const ehRegistro = (valor: unknown): valor is Registro =>
  typeof valor === 'object' && valor !== null && !Array.isArray(valor)

const ehIdValido = (valor: unknown): valor is number => Number.isInteger(valor) && (valor as number) > 0

/** Texto opcional: string é mantida; null/ausente vira ''; outro tipo invalida o item. */
function textoOpcional(valor: unknown): string | undefined {
  if (valor === null || valor === undefined) return ''
  return typeof valor === 'string' ? valor : undefined
}

export function separarElenco(atores: string): string[] {
  return atores
    .split(',')
    .map((nome) => nome.trim())
    .filter((nome) => nome !== '')
}

export function mapearFilme(bruto: unknown): Filme | null {
  if (!ehRegistro(bruto)) return null

  const { id_filme: id, titulo_filme: titulo, duracao_filme: duracao, nota_filme: nota, generos } = bruto
  if (!ehIdValido(id)) return null
  if (typeof titulo !== 'string' || titulo.trim() === '') return null
  if (!Number.isInteger(duracao) || (duracao as number) < 0) return null
  if (typeof nota !== 'number' || !Number.isFinite(nota)) return null

  let listaGeneros: string[]
  if (generos === null || generos === undefined) listaGeneros = []
  else if (Array.isArray(generos) && generos.every((g) => typeof g === 'string')) listaGeneros = [...generos]
  else return null

  const descricao = textoOpcional(bruto.descricao_filme)
  const streaming = textoOpcional(bruto.streaming_filme)
  const nacionalidade = textoOpcional(bruto.nacionalidade_filme)
  const classificacao = textoOpcional(bruto.classificacao_filme)
  const diretor = textoOpcional(bruto.diretor_filme)
  const atores = textoOpcional(bruto.atorEspecifico_filme)
  if ([descricao, streaming, nacionalidade, classificacao, diretor, atores].includes(undefined)) return null

  return {
    id,
    titulo,
    descricao: descricao!,
    imagem: urlHttpsOuNull(bruto.linkImagemFilme_filme),
    duracaoMin: duracao as number,
    streaming: streaming!,
    nacionalidade: nacionalidade!,
    classificacao: classificacao!,
    diretor: diretor!,
    fotoDiretor: urlHttpsOuNull(bruto.imagemDiretor_filme),
    atores: atores!,
    elenco: separarElenco(atores!),
    nota,
    generos: listaGeneros,
  }
}

export function mapearPublicidade(bruto: unknown): Publicidade | null {
  if (!ehRegistro(bruto) || !ehIdValido(bruto.id_publicidade)) return null
  const descricao = textoOpcional(bruto.descricao)
  if (descricao === undefined) return null
  return { id: bruto.id_publicidade, descricao, imagem: urlHttpsOuNull(bruto.link_imagem) }
}

/**
 * Converte uma lista da API. Lança FalhaApi('formato') se a raiz não for lista ou se
 * uma lista não vazia não tiver nenhum item válido (problema sistêmico do contrato).
 */
export function mapearLista<T extends { id: number }>(
  bruto: unknown,
  mapear: (item: unknown) => T | null,
): ResultadoLista<T> {
  if (!Array.isArray(bruto)) throw new FalhaApi({ tipo: 'formato', detalhe: 'raiz da resposta não é uma lista' })

  const itens: T[] = []
  const vistos = new Set<number>()
  let descartados = 0
  let repetidos = 0
  for (const item of bruto) {
    const mapeado = mapear(item)
    if (mapeado === null) descartados++
    else if (vistos.has(mapeado.id)) repetidos++
    else {
      vistos.add(mapeado.id)
      itens.push(mapeado)
    }
  }

  if (bruto.length > 0 && itens.length === 0) {
    throw new FalhaApi({ tipo: 'formato', detalhe: 'nenhum item válido na resposta' })
  }
  if (import.meta.env.DEV && (descartados > 0 || repetidos > 0)) {
    console.warn(`[api] ${descartados} item(ns) inválido(s) e ${repetidos} repetido(s) ignorados`)
  }
  return { itens, descartados, repetidos }
}
