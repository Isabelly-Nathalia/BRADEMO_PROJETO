class Lista {
  final int idLista;
  final String nomeLista;

  Lista({
    required this.idLista,
    required this.nomeLista,
  });

  factory Lista.fromJson(Map<String, dynamic> json) {
    return Lista(
      idLista: json['id_lista'],
      nomeLista: json['nome_lista'],
    );
  }
}