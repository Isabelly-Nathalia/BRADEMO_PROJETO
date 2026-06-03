import 'package:flutter/material.dart';
import '../../../widgets/headerRotas.dart';
import 'home.dart';
import '../form/form.dart';
import '../perfil/conta.dart';
import '../../../widgets/cardFilme.dart';

class FilmeStreaming extends StatelessWidget {
  final String nomeStreaming;
  const FilmeStreaming({super.key, required this.nomeStreaming});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> filmes = [
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
        "descricao":
            "Uma ex-professora que escreve cartas para analfabetos conhece um menino que acaba de perder a mãe e decide ajudá-lo a encontrar o pai, iniciando uma jornada emocionante que transforma a vida de ambos.",
        "elenco": [
          "Fernanda Montenegro (Dora)",
          "Vinícius de Oliveira (Josué)",
          "Marília Pêra (Irene)",
        ],
      },
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
            "Uma mulher casada com um ex-político durante a ditadura militar no Brasil é forçada a se reinventar e traçar um novo caminho para si e para seus filhos depois que a vida de sua família é impactada por um ato violento e arbitrário.",
        "elenco": [
          "Fernanda Torres (Eunice Paiva)",
          "Selton Mello (Rubens Paiva)",
          "Fernanda Montenegro (Eunice Paiva)",
        ],
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
        "descricao":
            "Um jovem cresce em uma comunidade dominada pelo crime no Rio de Janeiro e tenta seguir um caminho diferente, enquanto acompanha a ascensão violenta de traficantes e a dura realidade da favela.",
        "elenco": [
          "Alice Braga (Angélica)",
          "Alexandre Rodrigues (Buscapé)",
          "Douglas Silva (Zé Pequeno)",
        ],
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
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 15,
                              childAspectRatio: 0.66,
                            ),
                        itemBuilder: (context, index) {
                          final filme = filmes[index];
                          return CardFilme(filme: filme);
                        },
                      ),
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
}
