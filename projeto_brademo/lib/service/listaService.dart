import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/apiConfig.dart';
import '../model/lista.dart';

class ListaService {

  Future<Lista?> criarLista(
    int idUsuario,
    String nomeLista,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/listas/$idUsuario',),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'nome_lista': nomeLista,}),
      );
      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        return Lista.fromJson(
          jsonDecode(response.body),
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> adicionarFilme(
    int idLista,
    int idFilme,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/listas/$idLista/filme/$idFilme',),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<List<Lista>> buscarListasUsuario(
    int idUsuario,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/listas/usuario/$idUsuario',),
      );

      if (response.statusCode == 200) {
        final List<dynamic> dados = jsonDecode(response.body);
        return dados.map((lista) => Lista.fromJson(lista)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}