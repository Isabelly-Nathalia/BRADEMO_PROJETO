import 'package:flutter/material.dart';
import 'package:projeto_brademo/screens/detalhe_filme.dart';
import 'package:projeto_brademo/widgets/button.dart';

class SugestaoFilmes extends StatelessWidget {
  const SugestaoFilmes({super.key});

  final Color cinza = const Color(0xFF222425);
  final Color azul = const Color(0xFF001C30);
  final Color vermelho = const Color(0xFF681F10);

  // LISTA FILMES
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
    final filmePrincipal = filmes[0];
    final filme2 = filmes[1];
    final filme3 = filmes[2];

    return Scaffold(
      backgroundColor: cinza,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [
              const SizedBox(height: 15),

              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),

                    child: const Icon(Icons.arrow_back, color: Colors.white),
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

              // FILME PRINCIPAL
              _cardGrande(context, filmePrincipal),

              const SizedBox(height: 25),

              // FILMES MENORES
              Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  _cardPequeno(context, filme2),

                  const SizedBox(width: 20),

                  _cardPequeno(context, filme3),
                ],
              ),

              const SizedBox(height: 45),

              Botao(
                text: "Novas sugestões",
                onPressed: () {
                  // COLOCAR LOGICA DE REFRESH
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // CARD GRANDE
  Widget _cardGrande(BuildContext context, Map<String, dynamic> filme) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetalheFilme(
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

      child: Column(
        children: [
          Container(
            height: 280,
            width: 190,

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),

              image: DecorationImage(
                image: NetworkImage(filme["imagem"]),
                fit: BoxFit.cover,
              ),

              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),

            decoration: BoxDecoration(
              color: vermelho,
              borderRadius: BorderRadius.circular(20),
            ),

            child: Text(filme["titulo"], style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // CARD PEQUENO
  Widget _cardPequeno(BuildContext context, Map<String, dynamic> filme) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetalheFilme(
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

      child: Column(
        children: [
          Container(
            height: 210,
            width: 140,

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),

              image: DecorationImage(
                image: NetworkImage(filme["imagem"]),
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),

            decoration: BoxDecoration(
              color: azul,
              borderRadius: BorderRadius.circular(20),
            ),

            child: Text(
              filme["titulo"],
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
