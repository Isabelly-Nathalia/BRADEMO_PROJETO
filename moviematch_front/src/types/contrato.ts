// Formas esperadas das respostas da API legada (Spring Boot), inferidas do código do backend
// (moviematch_back/.../model/Filme.java e Publicidade.java). Não validadas em execução.
// Qualquer campo pode vir nulo: as entidades não têm @NotNull. Nada daqui sai de src/services/.

export interface FilmeApi {
  id_filme: number | null
  titulo_filme: string | null
  descricao_filme: string | null
  imagemDiretor_filme: string | null
  duracao_filme: number | null
  streaming_filme: string | null
  nacionalidade_filme: string | null
  classificacao_filme: string | null
  diretor_filme: string | null
  linkImagemFilme_filme: string | null
  atorEspecifico_filme: string | null
  nota_filme: number | null
  generos: string[] | null
}

export interface PublicidadeApi {
  id_publicidade: number | null
  descricao: string | null
  link_imagem: string | null
}
