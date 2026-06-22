import 'filme.dart';

class Lista {
  final int idLista;
  final String nomeLista;
  final List<Filme> filmes;

  Lista({required this.idLista, required this.nomeLista, required this.filmes});

  factory Lista.fromJson(Map<String, dynamic> json) {
    return Lista(
      idLista: json['id_lista'],
      nomeLista: json['nome_lista'],
      filmes: json['filmes'] != null
          ? (json['filmes'] as List).map((f) => Filme.fromJson(f)).toList()
          : [],
    );
  }
}
