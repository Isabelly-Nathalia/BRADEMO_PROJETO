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
      return dados.map((filme) => Filme.fromJson(filme)).toList();
    }
    return [];
  }

  Future<List<Filme>> buscarPorStreaming(String streaming) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/filmes/streaming/$streaming'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> dados = jsonDecode(response.body);
        return dados.map((filme) => Filme.fromJson(filme)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Filme>> buscarOutrosStreamings() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/filmes/streaming/outros'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> dados = jsonDecode(response.body);
        return dados.map((filme) => Filme.fromJson(filme)).toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  static String formatarDuracao(int minutos) {
    int horas = minutos ~/ 60;
    int minutosRestantes = minutos % 60;

    return "${horas}h${minutosRestantes}min";
  }

  Future<List<Filme>> pesquisarFilmes(String titulo) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/filmes/pesquisa/$titulo'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> dados = jsonDecode(response.body);
        return dados.map((filme) => Filme.fromJson(filme)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Filme>> buscarTodosFilmes() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/filmes'));
      if (response.statusCode == 200) {
        final List<dynamic> dados = jsonDecode(response.body);
        return dados.map((filme) => Filme.fromJson(filme)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}