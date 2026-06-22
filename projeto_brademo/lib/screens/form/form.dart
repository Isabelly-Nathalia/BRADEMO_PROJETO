import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../widgets/button.dart';
import 'sugestao.dart';
import '../home/home.dart';
import '../../provider/formProvider.dart';

class SecondScreen extends StatefulWidget {
  const SecondScreen({super.key});

  @override
  State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  final PageController controller = PageController();

  int paginaAtual = 0;

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
    final formProvider = context.read<FormProvider>();

    return Scaffold(
      backgroundColor: cinza,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
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

            if (paginaAtual > 0)
              Positioned(
                top: 25,
                left: 10,
                child: IconButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const Home()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.home, color: Colors.white70, size: 24),
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
    final formProvider = context.watch<FormProvider>();
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
                      bool selecionado = formProvider.generosSelecionados
                          .contains(genero);
                      return GestureDetector(
                        onTap: () {
                          formProvider.toggleGenero(genero);
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
          navegacao(),
        ],
      ),
    );
  }

  Widget telaDuracao() {
    final formProvider = context.watch<FormProvider>();
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
                      bool selecionado =
                          formProvider.duracaoSelecionada == duracao;
                      return GestureDetector(
                        onTap: () {
                          formProvider.setDuracao(duracao);
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
          navegacao(),
        ],
      ),
    );
  }

  Widget telaStreaming() {
    final formProvider = context.watch<FormProvider>();
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
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

                          GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 2.8,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: streamings.map((streaming) {
                              bool selecionado = formProvider
                                  .streamingSelecionados
                                  .contains(streaming);
                              return GestureDetector(
                                onTap: () {
                                  formProvider.toggleStreaming(streaming);
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: selecionado ? azul : vermelho,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    streaming,
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
                              "Outro streaming",
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
                              hintText:
                                  "Digite outra plataforma de streaming...",
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
                );
              },
            ),
          ),
          navegacao(),
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
    final formProvider = context.watch<FormProvider>();
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
                      bool selecionado =
                          formProvider.classificacaoSelecionada == item;
                      return GestureDetector(
                        onTap: () {
                          formProvider.setClassificacao(item);
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
          navegacao(),
        ],
      ),
    );
  }

  Widget telaPaises() {
    final formProvider = context.watch<FormProvider>();
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
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
                              bool selecionado = formProvider.paisesSelecionados
                                  .contains(pais);
                              return GestureDetector(
                                onTap: () {
                                  formProvider.togglePais(pais);
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
                );
              },
            ),
          ),
          navegacao(),
        ],
      ),
    );
  }

  Widget telaAtor() {
    final formProvider = context.watch<FormProvider>();
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
                    onChanged: formProvider.setAtor,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      hintText: formProvider.ator.isEmpty
                          ? "Ex: Fernanda Montenegro"
                          : formProvider.ator,
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
    final formProvider = context.read<FormProvider>();
    if (formProvider.generosSelecionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecione pelo menos um gênero")),
      );
      return;
    }
    if (formProvider.duracaoSelecionada == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Selecione uma duração")));
      return;
    }
    if (formProvider.streamingSelecionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Selecione pelo menos uma plataforma de streaming"),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SugestaoFilmes()),
    ).then((_) {
      formProvider.limparFormulario();
    });
  }

  void limparFormulario() {
    context.read<FormProvider>().limparFormulario();
    controller.jumpToPage(0);
  }

  Widget navegacao({bool mostrarVoltar = true, bool mostrarAvancar = true}) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 15, top: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          mostrarVoltar
              ? IconButton(
                  onPressed: () {
                    controller.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                )
              : const SizedBox(width: 48),
          mostrarAvancar
              ? IconButton(
                  onPressed: proximaPagina,
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                  ),
                )
              : const SizedBox(width: 48),
        ],
      ),
    );
  }
}