import 'package:flutter/material.dart';
import 'package:moviematch/screens/login/semLogin.dart';
import '../home/home.dart';
import '../form/form.dart';
import '../home/detalheFilme.dart';
import 'editarConta.dart';
import '../../../widgets/cardFilme.dart';
import '../../../widgets/headerRotas.dart';
import '../../../widgets/button.dart';
import '../../../config/sessaoUsuario.dart';
import 'dart:io';
import '../../../service/usuarioService.dart';
import '../../../model/filme.dart';

class Conta extends StatefulWidget {
  const Conta({super.key});

  @override
  State<Conta> createState() => _ContaState();
}

class _ContaState extends State<Conta> {
  final Color cinza = const Color(0xFF222425);
  final Color azul = const Color(0xFF001C30);
  final Color vermelho = const Color(0xFF681F10);

  @override
  void initState() {
    super.initState();
    carregarCurtidos();
  }

  int abaSelecionada = 0;
  int? listaEditando;

  Future<void> carregarCurtidos() async {
    if (SessaoUsuario.usuarioLogado == null) {
      return;
    }
    final resultado = await usuarioService.buscarCurtidos(
      SessaoUsuario.usuarioLogado!.idUsuario,
    );
    setState(() {
      filmesCurtidos = resultado;
    });
  }
  final UsuarioService usuarioService = UsuarioService();
  List<Filme> filmesCurtidos = [];

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
    final usuario = SessaoUsuario.usuarioLogado;

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
                    backgroundImage:
                        usuario != null && usuario.fotoPerfil.isNotEmpty
                        ? FileImage(File(usuario.fotoPerfil))
                        : null,
                    child: usuario == null || usuario.fotoPerfil.isEmpty
                        ? const Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.white54,
                          )
                        : null,
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        usuario?.nome ?? "Usuário",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "@${usuario?.nomeUsuario ?? ""}",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
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
                  onPressed: () async {
                    if (SessaoUsuario.usuarioLogado == null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SemLogin(),
                        ),
                      );
                      return;
                    }
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditarConta(),
                      ),
                    );

                    setState(() {});
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
                      itemCount: filmesCurtidos.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 20,
                            childAspectRatio: 0.68,
                          ),
                      itemBuilder: (context, index) {
                        final filme = filmesCurtidos[index];

                        return CardFilme(
                          filme: {
                            "idFilme": filme.idFilme,
                            "titulo": filme.titulo,
                            "imagem": filme.imagem,
                            "descricao": filme.descricao,
                            "nota": filme.nota.toString(),
                            "duracao": filme.duracao,
                            "diretor": filme.diretor,
                            "fotoDiretor": filme.fotoDiretor,
                            "streaming": filme.streaming,
                            "elenco": [filme.atores],
                          },
                        );
                      },
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: minhasListas.length,
                      itemBuilder: (context, index) {
                        final lista = minhasListas[index];
                        final filmesLista = lista["filmes"] as List;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 40),
                          padding: const EdgeInsets.all(14),
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

                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            listaEditando =
                                                listaEditando == index
                                                ? null
                                                : index;
                                          });
                                        },
                                        icon: Icon(
                                          listaEditando == index
                                              ? Icons.check
                                              : Icons.edit,
                                          color: Colors.white,
                                        ),
                                      ),

                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                backgroundColor: cinza,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                title: const Text(
                                                  "Excluir lista",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                content: const Text(
                                                  "Deseja realmente excluir esta lista?",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                actions: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Botao(
                                                          text: "Cancelar",
                                                          onPressed: () {
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                          },
                                                        ),
                                                      ),

                                                      const SizedBox(width: 10),

                                                      Expanded(
                                                        child: Botao(
                                                          text: "Excluir",
                                                          onPressed: () {
                                                            setState(() {
                                                              minhasListas
                                                                  .removeAt(
                                                                    index,
                                                                  );
                                                            });

                                                            Navigator.pop(
                                                              context,
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(height: 15),

                              SizedBox(
                                height: 280,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: filmesLista.length,
                                  itemBuilder: (context, i) {
                                    return Stack(
                                      children: [
                                        CardFilme(filme: filmesLista[i]),
                                        if (listaEditando == index)
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
