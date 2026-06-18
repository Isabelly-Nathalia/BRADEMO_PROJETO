import 'package:flutter/material.dart';
import '../../../service/filmeService.dart';
import '../../../model/filme.dart';
import '../../../widgets/cardFilme.dart';
import 'detalheFilme.dart';

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
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
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
                                fotoDiretor: filme.fotoDiretor,
                                streaming: filme.streaming,
                                elenco: [filme.atores],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: 180,
                          decoration: BoxDecoration(
                            color: const Color(0xFF001C30),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  bottomLeft: Radius.circular(12),
                                ),
                                child: Image.network(
                                  filme.imagem,
                                  width: 120,
                                  height: 180,
                                  fit: BoxFit.cover,
                                ),
                              ),

                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        filme.titulo,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            color: Colors.white70,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            filme.nota.toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 6),

                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.access_time,
                                            color: Colors.white70,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            FilmeService.formatarDuracao(
                                              filme.duracao,
                                            ),
                                            style: const TextStyle(
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 10),

                                      Expanded(
                                        child: Text(
                                          filme.descricao,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
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
