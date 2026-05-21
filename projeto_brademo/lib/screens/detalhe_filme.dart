import 'package:flutter/material.dart';
import 'package:projeto_brademo/widgets/headerRotas.dart';
import 'package:projeto_brademo/screens/conta.dart';
import 'package:projeto_brademo/screens/form.dart';
import 'package:projeto_brademo/screens/mapa.dart';

class DetalheFilme extends StatelessWidget {
  final String titulo;
  final String imagem;
  final String descricao;
  final String nota;
  final String duracao;
  final String diretor;
  final List<String> elenco;
  final String fotoDiretor;
  final String streaming;

  const DetalheFilme({
    super.key,
    required this.titulo,
    required this.imagem,
    required this.descricao,
    required this.nota,
    required this.duracao,
    required this.diretor,
    required this.elenco,
    required this.fotoDiretor,
    required this.streaming,
  });

  final Color cinza = const Color(0xFF222425);
  final Color vermelho = const Color(0xFF681F10);
  final Color azul = const Color(0xFF001C30);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cinza,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),

            Stack(
              children: [
                const Center(
                  child: Text(
                    "BOA ESCOLHA!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Positioned(
                  left: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // img filme
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Container(
                    height: 320,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      image: DecorationImage(
                        image: NetworkImage(imagem),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // info filme
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: azul,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(10),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            titulo.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const Icon(Icons.star, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(nota, style: const TextStyle(color: Colors.white)),

                        const SizedBox(width: 15),

                        const Icon(
                          Icons.access_time,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          duracao,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(color: Colors.white24),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(fotoDiretor),
                  ),
                  const SizedBox(width: 10),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Direção",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        diretor,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: vermelho,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.thumb_up, color: Colors.white, size: 14),
                        SizedBox(width: 5),
                        Text(
                          "Curtir",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(color: Colors.white24),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Descrição",
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    descricao,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Text(
                    "Disponível em: ",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),

                  Text(
                    streaming,
                    style: const TextStyle(
                      color: Colors.white70, 
                      fontSize: 15,                      
                      fontWeight: FontWeight.bold,                      
                      ),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(color: Colors.white24),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Elenco", style: TextStyle(color: Colors.white)),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: elenco.map((ator) {
                  return Text(
                    "• $ator",
                    style: const TextStyle(color: Colors.white70),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 15),

            // footer rotas menu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: MenuWidget(
                onHome: () => Navigator.pop(context),
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
                onConta: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Conta()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _iconeTopo(IconData icone) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: vermelho, shape: BoxShape.circle),
      child: Icon(icone, color: Colors.white, size: 18),
    );
  }
}
