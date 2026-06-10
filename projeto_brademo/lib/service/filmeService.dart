import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/apiConfig.dart';
import '../model/filme.dart';

class FilmeService {
  Future<List<Filme>> buscarFilmes() async {
  final response = await http.get(
    Uri.parse('${ApiConfig.baseUrl}/filmes/aleatorios'),
  );
  if (response.statusCode == 200) {
    final List<dynamic> dados = jsonDecode(response.body);
    return dados
        .map((filme) => Filme.fromJson(filme))
        .toList();
  }
  return [];
}
}