import 'package:flutter/material.dart';
import '../../../widgets/headerRotas.dart';
import 'home.dart';
import '../form/form.dart';
import '../perfil/conta.dart';
import '../../../widgets/cardFilme.dart';
import '../../../service/filmeService.dart';
import '../../../model/filme.dart';
import '../../../config/sessaoUsuario.dart';
import '../login/semLogin.dart';

class FilmeStreaming extends StatefulWidget {
  final String nomeStreaming;

  const FilmeStreaming({super.key, required this.nomeStreaming});

  @override
  State<FilmeStreaming> createState() => _FilmeStreamingState();
}

class _FilmeStreamingState extends State<FilmeStreaming> {
  final FilmeService filmeService = FilmeService();

  List<Filme> filmes = [];

  @override
  void initState() {
    super.initState();
    carregarFilmes();
  }

  Future<void> carregarFilmes() async {
    List<Filme> resultado;
    if (widget.nomeStreaming == "Outros Streamings") {
      resultado = await filmeService.buscarOutrosStreamings();
    } else {
      resultado = await filmeService.buscarPorStreaming(widget.nomeStreaming);
    }
    setState(() {
      filmes = resultado;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                          widget.nomeStreaming,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      filmes.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : GridView.builder(
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

                                return CardFilme(
                                  filme: {
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
}
