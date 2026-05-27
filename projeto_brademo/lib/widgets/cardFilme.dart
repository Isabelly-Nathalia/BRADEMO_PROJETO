import 'package:flutter/material.dart';
import '../screens/detalheFilme.dart';

class CardFilme extends StatelessWidget {
  final Map<String, dynamic> filme;

  const CardFilme({
    super.key,
    required this.filme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetalheFilme(
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
        margin: const EdgeInsets.only(right: 15),

        child: Column(
          children: [
            Container(
              height: 220,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                image: DecorationImage(
                  image: NetworkImage(filme["imagem"]),
                  fit: BoxFit.cover,
                ),
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 12,
                      ),

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
                        filme["duracao"] ?? "",
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