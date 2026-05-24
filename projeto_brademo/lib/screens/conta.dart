import 'package:flutter/material.dart';
import 'package:projeto_brademo/widgets/headerRotas.dart';
import 'home.dart';
import 'form.dart';
import 'mapa.dart';
import 'detalhe_filme.dart';
import 'editarConta.dart';

class Conta extends StatelessWidget {
  const Conta({super.key});

  final Color cinza = const Color(0xFF222425);
  final Color azul = const Color(0xFF001C30);
  final Color vermelho = const Color(0xFF681F10);

  // LISTA FILMES
  final List<Map<String, dynamic>> filmes = const [
    {
      "titulo": "Cidade de Deus",
      "imagem":
          "https://upload.wikimedia.org/wikipedia/pt/thumb/1/10/CidadedeDeus.jpg/250px-CidadedeDeus.jpg",
      "descricao":
          "Dois jovens seguem caminhos diferentes em uma favela marcada pela violência.",
      "nota": "4",
      "duracao": "2h 10m",
      "diretor": "Fernando Meirelles",
      "fotoDiretor":
          "https://s2.glbimg.com/Z__UfzReUwJbUEjcSCE2ZkPBXzE=/540x300/e.glbimg.com/og/ed/f/original/2014/03/21/fernando_meirelles.jpg",
      "streaming": "Netflix",
      "elenco": ["Alexandre Rodrigues", "Leandro Firmino", "Seu Jorge"],
    },

    {
      "titulo": "Central do Brasil",
      "imagem":
          "https://m.media-amazon.com/images/M/MV5BMWI3YTg2YmItY2QzYi00NTc2LWExNTQtYWE4ZmIzNjE3ZjMyXkEyXkFqcGc@._V1_.jpg",
      "descricao":
          "Uma ex-professora ajuda um menino a encontrar o pai pelo interior do Brasil.",
      "nota": "5",
      "duracao": "1h 50m",
      "diretor": "Walter Salles",
      "fotoDiretor":
          "https://upload.wikimedia.org/wikipedia/commons/8/80/Walter_Salles_in_2024.jpg",
      "streaming": "Globoplay",
      "elenco": ["Fernanda Montenegro", "Vinícius de Oliveira"],
    },

    {
      "titulo": "La La Land",
      "imagem":
          "https://i5.walmartimages.com/seo/Rolled-Poster-La-La-Land-Movie-24-x-36-Poster_20f02811-01b4-4aea-9bb2-a79942bd2642_1.856c035d66f8fd216f6d933259bc3dfb.jpeg",
      "descricao":
          "Um pianista e uma atriz vivem um romance enquanto perseguem seus sonhos.",
      "nota": "4",
      "duracao": "2h 08m",
      "diretor": "Damien Chazelle",
      "fotoDiretor":
          "https://s2.glbimg.com/Z__UfzReUwJbUEjcSCE2ZkPBXzE=/540x300/e.glbimg.com/og/ed/f/original/2014/03/21/fernando_meirelles.jpg",
      "streaming": "Prime Video",
      "elenco": ["Ryan Gosling", "Emma Stone"],
    },

    {
      "titulo": "Her",
      "imagem": "https://upload.wikimedia.org/wikipedia/pt/9/9b/Her.jpg",
      "descricao":
          "Um homem solitário desenvolve uma relação com uma inteligência artificial.",
      "nota": "5",
      "duracao": "2h 06m",
      "diretor": "Spike Jonze",
      "fotoDiretor":
          "https://s2.glbimg.com/Z__UfzReUwJbUEjcSCE2ZkPBXzE=/540x300/e.glbimg.com/og/ed/f/original/2014/03/21/fernando_meirelles.jpg",
      "streaming": "HBO Max",
      "elenco": ["Joaquin Phoenix", "Scarlett Johansson"],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cinza,

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // TOPO
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  // FOTO + INFO
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.white24,

                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white54,
                        ),
                      ),

                      const SizedBox(width: 15),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: const [
                          Text(
                            "Usuario123",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 4),

                          Text(
                            "@usuario123",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // BOTÃO EDITAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),

              child: SizedBox(
                width: double.infinity,

                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditarConta(),
                      ),
                    );
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: vermelho,

                    padding: const EdgeInsets.symmetric(vertical: 14),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),

                  child: const Text(
                    "Editar perfil",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // TÍTULO
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),

              child: Align(
                alignment: Alignment.centerLeft,

                child: Text(
                  "Filmes curtidos",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // GRID FILMES
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),

                itemCount: filmes.length,

                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.62,
                ),

                itemBuilder: (context, index) {
                  final filme = filmes[index];

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
                            fotoDiretor: filme["fotoDiretor"],
                            streaming: filme["streaming"],
                            elenco: List<String>.from(filme["elenco"]),
                          ),
                        ),
                      );
                    },

                    child: Column(
                      children: [
                        Container(
                          height: 250,

                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),

                            image: DecorationImage(
                              image: NetworkImage(filme["imagem"]),

                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          filme["titulo"],

                          textAlign: TextAlign.center,

                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // MENU
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),

              child: MenuWidget(
                onHome: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Home()),
                  );
                },

                onForm: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SecondScreen(),
                    ),
                  );
                },

                onMapa: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Mapa()),
                  );
                },

                onConta: () {},
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
