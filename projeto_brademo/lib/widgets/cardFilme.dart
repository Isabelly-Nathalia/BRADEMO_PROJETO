import 'package:flutter/material.dart';
import '../screens/home/detalheFilme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../service/filmeService.dart';

class CardFilme extends StatelessWidget {
  final Map<String, dynamic> filme;

  const CardFilme({super.key, required this.filme});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetalheFilme(
              idFilme: filme["idFilme"],
              titulo: filme["titulo"] ?? "",
              imagem: filme["imagem"] ?? "",
              descricao: filme["descricao"] ?? "",
              nota: filme["nota"] ?? "",
              duracao: filme["duracao"] ?? "",
              diretor: filme["diretor"] ?? "",
              fotoDiretor: filme["fotoDiretor"] ?? "",
              streaming: filme["streaming"] ?? "",
              elenco: List<String>.from(filme["elenco"] ?? []),
            ),
          ),
        );
      },

      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 6, left: 6),

        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: CachedNetworkImage(
                imageUrl: filme["imagem"],
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,

                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),

                errorWidget: (context, url, error) =>
                    const Icon(Icons.broken_image, color: Colors.white),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF001C30),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(10),
                ),
              ),

              child: Column(
                children: [
                  Text(
                    filme["titulo"].toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),

                  const SizedBox(height: 5),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.white, size: 12),

                      const SizedBox(width: 3),

                      Text(
                        filme["nota"] ?? "",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),

                      const SizedBox(width: 10),

                      const Icon(
                        Icons.access_time,
                        color: Colors.white,
                        size: 12,
                      ),

                      const SizedBox(width: 3),

                      Text(
                        FilmeService.formatarDuracao(filme["duracao"]),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
