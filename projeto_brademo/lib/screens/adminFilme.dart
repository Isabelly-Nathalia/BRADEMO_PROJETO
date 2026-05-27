import 'package:flutter/material.dart';
import 'addFilme.dart';

class AdminFilmes extends StatefulWidget {
  const AdminFilmes({super.key});
  @override
  State<AdminFilmes> createState() => _AdminFilmesState();
}

class _AdminFilmesState extends State<AdminFilmes> {
  List<Map<String, dynamic>> filmes = [
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF222425),
      appBar: AppBar(
        backgroundColor: const Color(0xFF222425),
        foregroundColor: Colors.white,
        title: const Text("Painel do Desenvolvedor"),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF681F10),
        onPressed: () async {
          final novoFilme = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddFilme()),
          );
          if (novoFilme != null) {
            setState(() {
              filmes.add(novoFilme);
            });
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Gerencie os filmes do aplicativo",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.builder(
                itemCount: filmes.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.55,
                ),
                itemBuilder: (context, index) {
                  final filme = filmes[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF001C30),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              Container(
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
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: IconButton(
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.all(8),
                                        onPressed: () async {
                                          final filmeAtualizado =
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      AddFilme(filme: filme),
                                                ),
                                              );
                                          if (filmeAtualizado != null) {
                                            setState(() {
                                              filmes[index] = filmeAtualizado;
                                            });
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: IconButton(
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.all(8),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                backgroundColor: const Color(
                                                  0xFF222425,
                                                ),
                                                title: const Text(
                                                  "Excluir filme",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                content: const Text(
                                                  "Deseja realmente excluir este filme?",
                                                  style: TextStyle(
                                                    color: Colors.white70,
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text(
                                                      "Cancelar",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        filmes.removeAt(index);
                                                      });
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text(
                                                      "Excluir",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            filme["titulo"],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
