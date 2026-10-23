// Estado do questionário compartilhado entre páginas, persistido no navegador a cada mudança
// (equivale ao FormProvider + Hive "formulario" do Flutter, provider/formProvider.dart).
// Não guarda dados pessoais. Armazenamento indisponível ou dado corrompido nunca quebra o app.
import { reactive, readonly, watch } from 'vue'
import {
  CLASSIFICACOES,
  DURACOES,
  GENEROS,
  PAISES,
  STREAMINGS,
  respostasVazias,
  type Classificacao,
  type Duracao,
  type Genero,
  type Pais,
  type Respostas,
  type StreamingQuestionario,
} from '../domain/questionario'

export const CHAVE_QUESTIONARIO = 'mm.questionario.v1'
const VERSAO = 1

// Textos literais de form.dart:763-784.
export const ERROS_VALIDACAO = Object.freeze({
  genero: 'Selecione pelo menos um gênero',
  duracao: 'Selecione uma duração',
  streaming: 'Selecione pelo menos uma plataforma de streaming',
})

type ObterArmazenamento = () => Storage | null

function armazenamentoDoNavegador(): Storage | null {
  try {
    return window.localStorage
  } catch {
    return null
  }
}

function filtrar<T extends string>(valor: unknown, opcoes: readonly T[]): T[] {
  if (!Array.isArray(valor)) return []
  return [...new Set(valor.filter((v): v is T => opcoes.includes(v as T)))]
}

function umaDas<T extends string>(valor: unknown, opcoes: readonly T[]): T | null {
  return opcoes.includes(valor as T) ? (valor as T) : null
}

/** Lê e valida o que estiver salvo; qualquer problema resulta em respostas vazias. */
function carregar(obter: ObterArmazenamento): Respostas {
  try {
    const bruto = obter()?.getItem(CHAVE_QUESTIONARIO)
    if (!bruto) return respostasVazias()
    const salvo: unknown = JSON.parse(bruto)
    if (typeof salvo !== 'object' || salvo === null) return respostasVazias()
    const { versao, respostas: r } = salvo as { versao?: unknown; respostas?: Record<string, unknown> }
    if (versao !== VERSAO || typeof r !== 'object' || r === null) return respostasVazias()
    return {
      generos: filtrar(r.generos, GENEROS),
      duracao: umaDas(r.duracao, DURACOES),
      streamings: filtrar(r.streamings, STREAMINGS),
      classificacao: umaDas(r.classificacao, CLASSIFICACOES),
      paises: filtrar(r.paises, PAISES),
      ator: typeof r.ator === 'string' ? r.ator : '',
    }
  } catch {
    return respostasVazias()
  }
}

function alternar<T>(lista: T[], valor: T): void {
  const i = lista.indexOf(valor)
  if (i === -1) lista.push(valor)
  else lista.splice(i, 1)
}

export function criarQuestionario(obter: ObterArmazenamento = armazenamentoDoNavegador) {
  const estado = reactive<Respostas>(carregar(obter))

  const salvar = () => {
    try {
      obter()?.setItem(CHAVE_QUESTIONARIO, JSON.stringify({ versao: VERSAO, respostas: estado }))
    } catch {
      // Cota cheia ou armazenamento bloqueado: segue só em memória.
    }
  }
  watch(estado, salvar, { deep: true, flush: 'sync' })

  return {
    respostas: readonly(estado),
    alternarGenero: (g: Genero) => alternar(estado.generos, g),
    alternarStreaming: (s: StreamingQuestionario) => alternar(estado.streamings, s),
    alternarPais: (p: Pais) => alternar(estado.paises, p),
    definirDuracao: (d: Duracao) => {
      estado.duracao = d
    },
    /** Clicar de novo na mesma classificação desmarca (formProvider.dart:64-72). */
    alternarClassificacao: (c: Classificacao) => {
      estado.classificacao = estado.classificacao === c ? null : c
    },
    definirAtor: (texto: string) => {
      estado.ator = texto
    },
    limpar: () => {
      Object.assign(estado, respostasVazias())
      try {
        obter()?.removeItem(CHAVE_QUESTIONARIO)
      } catch {
        // idem
      }
    },
    /** Primeira mensagem de erro na ordem do Flutter, ou null se as respostas mínimas existirem. */
    validar: (): string | null => {
      if (estado.generos.length === 0) return ERROS_VALIDACAO.genero
      if (estado.duracao === null) return ERROS_VALIDACAO.duracao
      if (estado.streamings.length === 0) return ERROS_VALIDACAO.streaming
      return null
    },
  }
}

let instancia: ReturnType<typeof criarQuestionario> | null = null

/** Instância única da aplicação. */
export function useQuestionario() {
  instancia ??= criarQuestionario()
  return instancia
}
