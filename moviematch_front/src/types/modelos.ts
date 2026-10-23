// Modelos internos do frontend. Só eles circulam por páginas, componentes e composables.

export interface Filme {
  id: number
  titulo: string
  descricao: string
  /** URL https do pôster, ou null. */
  imagem: string | null
  duracaoMin: number
  streaming: string
  nacionalidade: string
  classificacao: string
  diretor: string
  /** URL https da foto do diretor, ou null. */
  fotoDiretor: string | null
  /** Texto original de atores (usado na pontuação, como no Flutter). */
  atores: string
  /** Atores separados por vírgula, sem espaços extras (A-02). */
  elenco: string[]
  nota: number
  generos: string[]
}

export interface Publicidade {
  id: number
  descricao: string
  imagem: string | null
}

export interface ResultadoLista<T> {
  itens: T[]
  /** Itens ignorados por não satisfazerem o contrato (A-01). */
  descartados: number
  /** Itens ignorados por repetirem um id já visto. */
  repetidos: number
}
