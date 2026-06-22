import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../model/filme.dart';
import '../../../service/filmeService.dart';
import '../../provider/formProvider.dart';
import '../../../widgets/headerRotas.dart';
import '../../../config/sessaoUsuario.dart';
import '../home/detalheFilme.dart';
import '../home/home.dart';
import '../form/form.dart';
import '../perfil/conta.dart';
import '../login/semLogin.dart';

class SugestaoFilmes extends StatefulWidget {
  const SugestaoFilmes({super.key});

  @override
  State<SugestaoFilmes> createState() => _SugestaoFilmesState();
}

class _SugestaoFilmesState extends State<SugestaoFilmes> {
  final Color cinza = const Color(0xFF222425);

  final FilmeService filmeService = FilmeService();

  List<Filme> filmes = [];

  @override
  void initState() {
    super.initState();
    carregarFilmes();
  }

  Future<void> carregarFilmes() async {
    final resultado = await filmeService.buscarTodosFilmes();
    print("Filmes encontrados: ${resultado.length}");
    setState(() {
      filmes = resultado;
    });
  }

  int calcularPontuacao(Filme filme, FormProvider form) {
    int pontos = 0;

    // GÊNEROS (+3)
    if (filme.generos.any((g) => form.generosSelecionados.contains(g))) {
      pontos += 3;
    }

    // DURAÇÃO (+2)
    if (form.duracaoSelecionada == "Até 1h30" && filme.duracao <= 90) {
      pontos += 2;
    }

    if (form.duracaoSelecionada == "1h30 - 2h" &&
        filme.duracao > 90 &&
        filme.duracao <= 120) {
      pontos += 2;
    }

    if (form.duracaoSelecionada == "2h - 3h" &&
        filme.duracao > 120 &&
        filme.duracao <= 180) {
      pontos += 2;
    }

    if (form.duracaoSelecionada == "3h+" && filme.duracao > 180) {
      pontos += 2;
    }

    // STREAMING (+3)
    if (form.streamingSelecionados.contains(filme.streaming)) {
      pontos += 3;
    }

    // CLASSIFICAÇÃO (+2)
    if (form.classificacaoSelecionada == filme.classificacao) {
      pontos += 2;
    }

    // PAÍS (+1)
    if (form.paisesSelecionados.contains(filme.nacionalidade)) {
      pontos += 1;
    }

    // ATOR OU DIRETOR (+1)
    if (form.ator.isNotEmpty) {
      final busca = form.ator.toLowerCase();

      if (filme.diretor.toLowerCase().contains(busca) ||
          filme.atores.toLowerCase().contains(busca)) {
        pontos += 1;
      }
    }

    return pontos;
  }

  @override
  Widget build(BuildContext context) {
    print("ENTROU NA TELA DE SUGESTÕES");
    final formProvider = context.watch<FormProvider>();

    final filmesOrdenados = [...filmes];

    filmesOrdenados.sort(
      (a, b) => calcularPontuacao(
        b,
        formProvider,
      ).compareTo(calcularPontuacao(a, formProvider)),
    );

    final top3 = filmesOrdenados.take(3).toList();

    return Scaffold(
      backgroundColor: cinza,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: filmes.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                      padding: const EdgeInsets.all(20),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 15),

                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SecondScreen(),
                                      ),
                                      (route) => false,
                                    );
                                  },
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

                            const SizedBox(height: 30),

                            Column(
                              children: List.generate(top3.length, (index) {
                                final filme = top3[index];

                                final esquerda = index % 2 == 0;

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 35),
                                  child: Row(
                                    mainAxisAlignment: esquerda
                                        ? MainAxisAlignment.start
                                        : MainAxisAlignment.end,
                                    children: [
                                      if (!esquerda)
                                        Expanded(child: _infoFilme(filme)),

                                      if (!esquerda) const SizedBox(width: 20),

                                      _cardFilmeSugestao(context, filme),

                                      if (esquerda) const SizedBox(width: 20),

                                      if (esquerda)
                                        Expanded(child: _infoFilme(filme)),
                                    ],
                                  ),
                                );
                              }),
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
                  if (SessaoUsuario.usuarioLogado == null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SemLogin()),
                    );
                    return;
                  }

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

  Widget _cardFilmeSugestao(BuildContext context, Filme filme) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetalheFilme(
              idFilme: filme.idFilme,
              titulo: filme.titulo,
              imagem: filme.imagem,
              descricao: filme.descricao,
              nota: filme.nota.toString(),
              duracao: filme.duracao,
              diretor: filme.diretor,
              streaming: filme.streaming,
              elenco: filme.atores.split(','),
              fotoDiretor: filme.fotoDiretor,
            ),
          ),
        );
      },
      child: Container(
        height: 193,
        width: 125,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: NetworkImage(filme.imagem),
            fit: BoxFit.cover,
          ),
          boxShadow: const [BoxShadow(color: Colors.black, blurRadius: 20)],
        ),
      ),
    );
  }

  Widget _infoFilme(Filme filme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          filme.titulo,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "Disponível em ${filme.streaming}",
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ],
    );
  }
}