import 'package:flutter/material.dart';
import '../../widgets/button.dart';
import 'sugestao.dart';
import 'home.dart';

class SecondScreen extends StatefulWidget {
  const SecondScreen({super.key});

  @override
  State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  final PageController controller = PageController();

  int paginaAtual = 0;
  List<String> generosSelecionados = [];
  List<String> streamingSelecionados = [];
  List<String> paisesSelecionados = [];
  String? duracaoSelecionada;
  String? classificacaoSelecionada;
  TextEditingController atorController = TextEditingController();

  final List<String> generos = [
    "Ação",
    "Aventura",
    "Comédia",
    "Drama",
    "Romance",
    "Terror",
    "Ficção",
    "Fantasia",
    "Animação",
    "Documentário",
    "Mistério",
    "Musical",
  ];

  final List<String> duracoes = ["Até 1h30", "1h30 - 2h", "2h - 3h", "3h+"];

  final List<String> streamings = [
    "Netflix",
    "Prime Video",
    "Disney+",
    "HBO Max",
    "AppleTV",
    "GloboPlay",
  ];

  final List<String> classificacao = [
    "Livre",
    "Não recomendável para menores de 10 anos",
    "Não recomendável para menores de 12 anos",
    "Não recomendável para menores de 14 anos",
    "Não recomendável para menores de 16 anos",
    "18+",
  ];

  final List<String> paises = [
    "Argentina",
    "Brasil",
    "Canadá",
    "China",
    "Coreia do Sul",
    "Estados Unidos",
    "França",
    "Itália",
    "Japão",
    "Portugal",
  ];

  final Color cinza = const Color(0xFF222425);
  final Color azul = const Color(0xFF001C30);
  final Color vermelhoEscuro = const Color(0xFF250203);
  final Color vermelho = const Color(0xFF681F10);

  void proximaPagina() {
    controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cinza,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: LinearProgressIndicator(
                value: (paginaAtual + 1) / 8,
                backgroundColor: Colors.white24,
                color: vermelho,
              ),
            ),

            Expanded(
              child: PageView(
                controller: controller,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (value) {
                  setState(() {
                    paginaAtual = value;
                  });
                },
                children: [
                  telaIntro(),
                  telaGeneros(),
                  telaDuracao(),
                  telaStreaming(),
                  telaOpcional(),
                  telaClassificacao(),
                  telaPaises(),
                  telaAtor(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget telaIntro() {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
          const Text(
            "Descubra filmes perfeitos para você",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "Responda algumas perguntas rápidas e encontraremos filmes do seu jeito.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),

          const SizedBox(height: 50),

          Botao(text: "COMEÇAR", onPressed: proximaPagina),
          const SizedBox(height: 20),
          Botao(
            text: "PÁGINA INICIAL",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Home()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget telaGeneros() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Quais gêneros você gosta?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 40),

                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.8,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: generos.map((genero) {
                      bool selecionado = generosSelecionados.contains(genero);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (selecionado) {
                              generosSelecionados.remove(genero);
                            } else {
                              generosSelecionados.add(genero);
                            }
                          });
                        },

                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selecionado ? azul : vermelho,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            genero,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    controller.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                ),
                IconButton(
                  onPressed: proximaPagina,
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget telaDuracao() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Qual a duração de filme ideal pra você?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 40),

                  Column(
                    children: duracoes.map((duracao) {
                      bool selecionado = duracaoSelecionada == duracao;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            duracaoSelecionada = duracao;
                          });
                        },

                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 15),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: selecionado ? azul : vermelho,
                            borderRadius: BorderRadius.circular(20),
                          ),

                          child: Text(
                            duracao,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    controller.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                ),
                IconButton(
                  onPressed: proximaPagina,
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget telaStreaming() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Onde você costuma assistir?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 40),

                  Column(
                    children: streamings.map((streaming) {
                      bool selecionado = streamingSelecionados.contains(
                        streaming,
                      );
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (selecionado) {
                              streamingSelecionados.remove(streaming);
                            } else {
                              streamingSelecionados.add(streaming);
                            }
                          });
                        },

                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 15),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: selecionado ? azul : vermelho,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            streaming,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    controller.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                ),
                IconButton(
                  onPressed: proximaPagina,
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget telaOpcional() {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Falta pouco!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "As próximas perguntas são opcionais e ajudam a personalizar ainda mais suas recomendações.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),

                  const SizedBox(height: 40),

                  Botao(text: "CONTINUAR", onPressed: proximaPagina),
                  const SizedBox(height: 20),
                  Botao(
                    text: "FINALIZAR",
                    onPressed: () {
                      enviarFormulario();
                    },
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () {
                    controller.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget telaClassificacao() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Qual classificação indicativa você prefere?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 40),

                  Column(
                    children: classificacao.map((item) {
                      bool selecionado = classificacaoSelecionada == item;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            classificacaoSelecionada = item;
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 15),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: selecionado ? azul : vermelho,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            item,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    controller.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                ),
                IconButton(
                  onPressed: proximaPagina,
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget telaPaises() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Tem preferência por algum país?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 40),

                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.8,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: paises.map((pais) {
                      bool selecionado = paisesSelecionados.contains(pais);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (selecionado) {
                              paisesSelecionados.remove(pais);
                            } else {
                              paisesSelecionados.add(pais);
                            }
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selecionado ? azul : vermelho,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            pais,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 25),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Outro país",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Digite outro país...",
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: vermelho,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    controller.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                ),
                IconButton(
                  onPressed: proximaPagina,
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget telaAtor() {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Algum ator ou diretor favorito?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    "Isso ajuda a personalizar ainda mais suas recomendações.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),

                  const SizedBox(height: 30),

                  TextField(
                    controller: atorController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Ex: Fernanda Montenegro",
                      hintStyle: const TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: vermelho,
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Row(
                    children: [
                      Expanded(
                        child: Botao(
                          text: "LIMPAR",
                          onPressed: limparFormulario,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Botao(
                          text: "FINALIZAR",
                          onPressed: () {
                            enviarFormulario();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () {
                    controller.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void enviarFormulario() {
    if (generosSelecionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecione pelo menos um gênero")),
      );
      return;
    }
    if (duracaoSelecionada == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Selecione uma duração")));
      return;
    }
    if (streamingSelecionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Selecione pelo menos uma plataforma de streaming"),
        ),
      );
      return;
    }
    // implementar
    //final dadosFormulario = {
    //   "generos": generosSelecionados,
    //   "duracao": duracaoSelecionada,
    //   "streamings": streamingSelecionados,
    //   "paises": paisesSelecionados,
    //   "classificacao": classificacaoSelecionada,
    //   "ator": atorController.text,
    // };
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SugestaoFilmes()),
    );
  }

  void limparFormulario() {
    setState(() {
      generosSelecionados.clear();
      duracaoSelecionada = null;
      streamingSelecionados.clear();
      paisesSelecionados.clear();
      classificacaoSelecionada = null;
      atorController.clear();
    });
    controller.jumpToPage(0);
  }
}
