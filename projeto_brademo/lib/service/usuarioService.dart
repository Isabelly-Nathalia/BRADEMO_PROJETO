import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:moviematch/model/filme.dart';
import '../config/apiConfig.dart';
import '../model/usuario.dart';

class UsuarioService {
  String converterData(String dataForm) {
    if (dataForm.contains('-')) {
      return dataForm;
    }
    final partes = dataForm.split('/');
    return '${partes[2]}-${partes[1]}-${partes[0]}';
  }

  Future<Usuario?> cadastrarUsuario({
    required String nome,
    required String email,
    required String nomeUsuario,
    required String senha,
    String? fotoPerfil,
    required String dataNascimento,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/usuarios'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome_usuario': nome,
          'email_usuario': email,
          'nomeDeUsuario_usuario': nomeUsuario,
          'senha_usuario': senha,
          'fotoPerfil_usuario': fotoPerfil ?? '',
          'dataNascimento_usuario': converterData(dataNascimento),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Usuario.fromJson(jsonDecode(response.body));
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Usuario?> login({required String email, required String senha}) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/usuarios/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email_usuario': email, 'senha_usuario': senha}),
      );

      if (response.statusCode == 200 && response.body != 'null') {
        return Usuario.fromJson(jsonDecode(response.body));
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Usuario?> atualizarUsuario({
    required int id,
    required String nome,
    required String nomeUsuario,
    required String email,
    required String senha,
    String? fotoPerfil,
    required String dataNascimento,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/usuarios/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_usuario': id,
          'nome_usuario': nome,
          'email_usuario': email,
          'nomeDeUsuario_usuario': nomeUsuario,
          'senha_usuario': senha,
          'fotoPerfil_usuario': fotoPerfil ?? '',
          'dataNascimento_usuario': converterData(dataNascimento),
        }),
      );
      if (response.statusCode == 200) {
        return Usuario.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> excluirUsuario(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/usuarios/$id'),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  Future<bool> curtirFilme(int idUsuario, int idFilme) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/usuarios/$idUsuario/curtir/$idFilme'),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<List<Filme>> buscarCurtidos(int idUsuario) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/usuarios/$idUsuario/curtidos'),
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

  Future<bool> filmeJaCurtido(int idUsuario, int idFilme) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/usuarios/$idUsuario/curtiu/$idFilme'),
      );
      if (response.statusCode == 200) {
        return response.body == "true";
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removerCurtida(int idUsuario, int idFilme) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/usuarios/$idUsuario/curtir/$idFilme'),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
