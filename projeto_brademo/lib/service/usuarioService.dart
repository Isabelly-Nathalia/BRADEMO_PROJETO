import 'dart:convert';
import 'package:http/http.dart' as http;
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

      //REMOVER DEPOSI SOMENTE VERIFICAÇÃO DE ERROS
      print('STATUS: ${response.statusCode}');
      print('BODY: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Usuario.fromJson(jsonDecode(response.body));
      }

      return null;
    } catch (e) {
      print('ERRO CADASTRO: $e');
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
      print('ERRO LOGIN: $e');
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

      print("UPDATE STATUS: ${response.statusCode}");
      print("UPDATE BODY: ${response.body}");

      if (response.statusCode == 200) {
        return Usuario.fromJson(jsonDecode(response.body));
      }

      return null;
    } catch (e) {
      print('ERRO UPDATE: $e');
      return null;
    }
  }
}
