import 'package:flutter/material.dart';
import '../../../service/filmeService.dart';
import '../../../model/filme.dart';
import '../../../widgets/cardFilme.dart';

class Pesquisa extends StatefulWidget {
  const Pesquisa({super.key});

  @override
  State<Pesquisa> createState() => _PesquisaState();
}

class _PesquisaState extends State<Pesquisa> {
  final Color cinza = const Color(0xFF222425);

  final TextEditingController pesquisaController = TextEditingController();
  final FilmeService filmeService = FilmeService();

  List<Filme> filmes = [];

  bool pesquisou = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cinza,

      appBar: AppBar(backgroundColor: cinza, title: const Text("Pesquisa")),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            TextField(
              controller: pesquisaController,
              style: const TextStyle(color: Colors.white),

              decoration: const InputDecoration(
                hintText: "Pesquisar",
                hintStyle: TextStyle(color: Colors.white24),
                prefixIcon: Icon(Icons.search, color: Colors.white24),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 2),
                ),
              ),

              onSubmitted: (valor) async {
                final resultado = await filmeService.pesquisarFilmes(valor);

                setState(() {
                  filmes = resultado;
                  pesquisou = true;
                });
              },
            ),

            const SizedBox(height: 20),

            if (!pesquisou)
              const SizedBox.shrink()
            else if (filmes.isEmpty)
              const Center(
                child: Text(
                  "Filme não localizado no catálogo",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: filmes.length,
                  itemBuilder: (context, index) {
                    final filme = filmes[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: CardFilme(
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

  @override
  void dispose() {
    pesquisaController.dispose();
    super.dispose();
  }
}
