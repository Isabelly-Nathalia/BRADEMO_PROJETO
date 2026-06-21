import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/apiConfig.dart';
import '../model/publicidade.dart';

class PublicidadeService {

  Future<List<Publicidade>> buscarPublicidades() async {

    try {

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/publicidades'),
      );

      if (response.statusCode == 200) {

        final List<dynamic> dados =
            jsonDecode(response.body);

        return dados
            .map((p) => Publicidade.fromJson(p))
            .toList();
      }

      return [];

    } catch (e) {
      return [];
    }
  }
}