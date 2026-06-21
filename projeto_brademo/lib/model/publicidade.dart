class Publicidade {
  final int idPublicidade;
  final String descricao;
  final String linkImagem;

  Publicidade({
    required this.idPublicidade,
    required this.descricao,
    required this.linkImagem,
  });

  factory Publicidade.fromJson(Map<String, dynamic> json) {
    return Publicidade(
      idPublicidade: json['id_publicidade'],
      descricao: json['descricao'],
      linkImagem: json['link_imagem'],
    );
  }
}