import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/apiConfig.dart';

class UsuarioService {
  String converterData(String dataForm) {
    final partes = dataForm.split('/');
    return '${partes[2]}-${partes[1]}-${partes[0]}';
  }

  Future<bool> cadastrarUsuario({
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

      //REMOVER DEPOSI SOMENTE VERIFICAÇÃO DE ERROS //REMOVER
      // print('STATUS: ${response.statusCode}'); 
      // print('BODY: ${response.body}');

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
       print('erro: $e');
      return false;
    }
  }
}
