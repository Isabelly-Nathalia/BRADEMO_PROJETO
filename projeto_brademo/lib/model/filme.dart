class Filme {
  final int idFilme;
  final String titulo;
  final String descricao;
  final String imagem;
  final int duracao;
  final String streaming;
  final String diretor;
  final String fotoDiretor;
  final String atores;
  final double nota;
  final String nacionalidade;
  final String classificacao;
  final List<String> generos;

  Filme({
    required this.idFilme,
    required this.titulo,
    required this.descricao,
    required this.imagem,
    required this.duracao,
    required this.streaming,
    required this.diretor,
    required this.fotoDiretor,
    required this.atores,
    required this.nota,
    required this.nacionalidade,
    required this.classificacao,
    required this.generos,
  });

  factory Filme.fromJson(Map<String, dynamic> json) {
    return Filme(
      idFilme: json['id_filme'],
      titulo: json['titulo_filme'],
      descricao: json['descricao_filme'],
      imagem: json['linkImagemFilme_filme'],
      duracao: json['duracao_filme'],
      streaming: json['streaming_filme'],
      diretor: json['diretor_filme'],
      fotoDiretor: json['imagemDiretor_filme'],
      atores: json['atorEspecifico_filme'],
      nota: (json['nota_filme'] as num).toDouble(),
      nacionalidade: json['nacionalidade_filme'],
      classificacao: json['classificacao_filme'],
      generos: List<String>.from(json['generos'] ?? []),
    );
  }
}