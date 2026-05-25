import 'package:flutter/material.dart';
import 'package:projeto_brademo/widgets/headerRotas.dart';
import 'home.dart';
import 'form.dart';
import 'mapa.dart';
import 'detalhe_filme.dart';
import 'editarConta.dart';
import 'package:projeto_brademo/widgets/cardFilme.dart';

class Conta extends StatefulWidget {
  const Conta({super.key});

  @override
  State<Conta> createState() => _ContaState();
}

class _ContaState extends State<Conta> {
  final Color cinza = const Color(0xFF222425);
  final Color azul = const Color(0xFF001C30);
  final Color vermelho = const Color(0xFF681F10);

  int abaSelecionada = 0;
  bool editandoLista = false;

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
  ];

  final List<Map<String, dynamic>> minhasListas = [
    {
      "tituloLista": "Ver Depois",
      "cor": const Color(0xFF222425),
      "filmes": [
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
      ],
    },

    {
      "tituloLista": "Favoritos",
      "cor": const Color(0xFF222425),
      "filmes": [
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
      ],
    },

    {
      "tituloLista": "Vencedores do Oscar",
      "cor": const Color(0xFF222425),
      "filmes": [
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
      ],
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, size: 40, color: Colors.white54),
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
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

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

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => setState(() => abaSelecionada = 0),
                  child: Column(
                    children: [
                      Text(
                        "Filmes que Curti",
                        style: TextStyle(
                          color: abaSelecionada == 0
                              ? Colors.white
                              : Colors.white54,
                        ),
                      ),
                      Container(
                        height: 2,
                        width: 120,
                        color: abaSelecionada == 0
                            ? vermelho
                            : Colors.transparent,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 25),
                GestureDetector(
                  onTap: () => setState(() => abaSelecionada = 1),
                  child: Column(
                    children: [
                      Text(
                        "Minha Lista",
                        style: TextStyle(
                          color: abaSelecionada == 1
                              ? Colors.white
                              : Colors.white54,
                        ),
                      ),
                      Container(
                        height: 2,
                        width: 90,
                        color: abaSelecionada == 1
                            ? vermelho
                            : Colors.transparent,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Expanded(
              child: abaSelecionada == 0
                  ? GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filmes.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 20,
                            childAspectRatio: 0.62,
                          ),
                      itemBuilder: (context, index) {
                        return CardFilme(filme: filmes[index]);
                      },
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: minhasListas.length,
                      itemBuilder: (context, index) {
                        final lista = minhasListas[index];
                        final filmesLista = lista["filmes"] as List;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 25),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: lista["cor"],
                            borderRadius: BorderRadius.circular(15),
                            border: lista["cor"] == const Color(0xFF222425)
                                ? Border.all(color: Colors.white24)
                                : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    lista["tituloLista"],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        editandoLista = !editandoLista;
                                      });
                                    },
                                    icon: Icon(
                                      editandoLista ? Icons.check : Icons.edit,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 15),

                              SizedBox(
                                height: 320,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: filmesLista.length,
                                  itemBuilder: (context, i) {
                                    return Stack(
                                      children: [
                                        CardFilme(filme: filmesLista[i]),
                                        if (editandoLista)
                                          Positioned(
                                            top: 5,
                                            right: 10,
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  filmesLista.removeAt(i);
                                                });
                                              },
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
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
