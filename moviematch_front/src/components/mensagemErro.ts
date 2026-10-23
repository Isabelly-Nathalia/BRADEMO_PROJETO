import { FalhaApi } from '../services/http'

/** Texto para o usuário a partir de qualquer erro de carregamento. */
export function mensagemErro(erro: unknown): string {
  if (!(erro instanceof FalhaApi)) return 'Algo deu errado ao carregar.'
  const falha = erro.erro
  switch (falha.tipo) {
    case 'rede':
      return 'Não foi possível conectar ao servidor.'
    case 'timeout':
      return 'O servidor demorou demais para responder.'
    case 'formato':
      return 'Os dados recebidos estão em um formato inesperado.'
    case 'cancelado':
      return 'O carregamento foi interrompido.'
    case 'http':
      if (falha.status === 404) return 'Conteúdo não encontrado.'
      if (falha.status >= 500) return 'O servidor encontrou um erro.'
      return `Erro ao carregar (código ${falha.status}).`
  }
}
