import 'package:flutter/material.dart';
import 'package:projeto_brademo/widgets/headerRotas.dart';
import 'package:projeto_brademo/screens/home.dart';
import 'package:projeto_brademo/screens/form.dart';
import 'package:projeto_brademo/screens/mapa.dart';
import 'package:projeto_brademo/screens/conta.dart';

class FilmeStreaming extends StatelessWidget {
  final String nomeStreaming;
  const FilmeStreaming({super.key, required this.nomeStreaming});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> filmes = [
      {
        "imagem":
            "https://m.media-amazon.com/images/M/MV5BMWI3YTg2YmItY2QzYi00NTc2LWExNTQtYWE4ZmIzNjE3ZjMyXkEyXkFqcGc@._V1_.jpg",
        "titulo": "Central do Brasil",
        "nota": "5",
        "duracao": "1h50min",
      },
      {
        "imagem":
            "https://upload.wikimedia.org/wikipedia/pt/thumb/1/10/CidadedeDeus.jpg/250px-CidadedeDeus.jpg",
        "titulo": "Cidade de Deus",
        "nota": "5",
        "duracao": "2h10min",
      },
      {
        "imagem":
            "https://upload.wikimedia.org/wikipedia/pt/thumb/5/57/Ainda_Estou_Aqui_2024_poster.jpg/250px-Ainda_Estou_Aqui_2024_poster.jpg",
        "titulo": "Ainda Estou Aqui",
        "nota": "5",
        "duracao": "2h17min",
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
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF222425),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
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
                              "Últimos lançamentos no catálogo",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Center(
                        child: Text(
                          nomeStreaming,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filmes.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 20,
                              crossAxisSpacing: 15,
                              childAspectRatio: 0.58,
                            ),
                        itemBuilder: (context, index) {
                          final filme = filmes[index];
                          return _cardFilme(
                            imagem: filme["imagem"]!,
                            titulo: filme["titulo"]!,
                            nota: filme["nota"]!,
                            duracao: filme["duracao"]!,
                          );
                        },
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),

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
                onConta: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Conta()),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _cardFilme({
    required String imagem,
    required String titulo,
    required String nota,
    required String duracao,
  }) {
    return Column(
      children: [
        Container(
          height: 220,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            image: DecorationImage(
              image: NetworkImage(imagem),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Color(0xFF001C30),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
          ),
          child: Column(
            children: [
              Text(
                titulo.toUpperCase(),
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
                    nota,
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),

                  const SizedBox(width: 10),

                  const Icon(Icons.access_time, color: Colors.white, size: 12),

                  const SizedBox(width: 3),

                  Text(
                    duracao,
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
