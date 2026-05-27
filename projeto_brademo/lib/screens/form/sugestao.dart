import 'package:flutter/material.dart';
import '../home/detalheFilme.dart';
import '../../../widgets/button.dart';

class SugestaoFilmes extends StatelessWidget {
  const SugestaoFilmes({super.key});

  final Color cinza = const Color(0xFF222425);
  final List<Map<String, dynamic>> filmes = const [
    {
      "imagem":
          "https://upload.wikimedia.org/wikipedia/pt/thumb/5/57/Ainda_Estou_Aqui_2024_poster.jpg/250px-Ainda_Estou_Aqui_2024_poster.jpg",
      "titulo": "Ainda Estou Aqui",
      "nota": "5",
      "duracao": "2h17min",
      "diretor": "Walter Salles",
      "streaming": "GloboPlay",
      "fotoDiretor":
          "https://upload.wikimedia.org/wikipedia/commons/8/80/Walter_Salles_in_2024.jpg",
      "descricao":
          "Uma mulher casada com um ex-político durante a ditadura militar no Brasil é forçada a se reinventar.",
      "elenco": ["Fernanda Torres", "Selton Mello"],
    },

    {
      "imagem":
          "https://m.media-amazon.com/images/M/MV5BMWI3YTg2YmItY2QzYi00NTc2LWExNTQtYWE4ZmIzNjE3ZjMyXkEyXkFqcGc@._V1_.jpg",
      "titulo": "Central do Brasil",
      "nota": "5",
      "duracao": "1h50min",
      "diretor": "Walter Salles",
      "streaming": "Netflix",
      "fotoDiretor":
          "https://upload.wikimedia.org/wikipedia/commons/8/80/Walter_Salles_in_2024.jpg",
      "descricao": "Uma ex-professora conhece um menino que perdeu a mãe.",
      "elenco": ["Fernanda Montenegro", "Vinícius de Oliveira"],
    },

    {
      "imagem":
          "https://upload.wikimedia.org/wikipedia/pt/thumb/1/10/CidadedeDeus.jpg/250px-CidadedeDeus.jpg",
      "titulo": "Cidade de Deus",
      "nota": "5",
      "duracao": "2h10min",
      "diretor": "Fernando Meirelles",
      "streaming": "HBO MAX",
      "fotoDiretor":
          "https://s2.glbimg.com/Z__UfzReUwJbUEjcSCE2ZkPBXzE=/540x300/e.glbimg.com/og/ed/f/original/2014/03/21/fernando_meirelles.jpg",
      "descricao": "Um jovem cresce em uma comunidade dominada pelo crime.",
      "elenco": ["Alice Braga", "Alexandre Rodrigues"],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cinza,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(width: 15),

                  const Expanded(
                    child: Text(
                      "Sugestões com base nas suas respostas",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              Column(
                children: List.generate(filmes.length, (index) {
                  final filme = filmes[index];
                  final bool esquerda = index % 2 == 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 35),
                    child: Row(
                      mainAxisAlignment:
                          esquerda
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.end,
                      children: [
                        if (!esquerda)
                          Expanded(
                            child: _infoFilme(filme),
                          ),
                        if (!esquerda) const SizedBox(width: 20),
                        _cardFilme(context, filme),
                        if (esquerda) const SizedBox(width: 20),
                        if (esquerda)
                          Expanded(
                            child: _infoFilme(filme),
                          ),
                      ],
                    ),
                  );
                }),
              ),

              const SizedBox(height: 20),

              Center(
                child: Botao(
                  text: "Novas sugestões",
                  onPressed: () {
                    // LÓGICA REFRESH
                  },
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardFilme(BuildContext context, Map<String, dynamic> filme) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => DetalheFilme(
                  titulo: filme["titulo"],
                  imagem: filme["imagem"],
                  descricao: filme["descricao"],
                  nota: filme["nota"],
                  duracao: filme["duracao"],
                  diretor: filme["diretor"],
                  streaming: filme["streaming"],
                  elenco: List<String>.from(filme["elenco"]),
                  fotoDiretor: filme["fotoDiretor"],
                ),
          ),
        );
      },

      child: Container(
        height: 200,
        width: 130,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: NetworkImage(filme["imagem"]),
            fit: BoxFit.cover,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              blurRadius: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoFilme(Map<String, dynamic> filme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          filme["titulo"],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          "Disponível em ${filme["streaming"]}",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
