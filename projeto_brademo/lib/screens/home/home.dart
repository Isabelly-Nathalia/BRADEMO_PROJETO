import 'package:flutter/material.dart';
import '../perfil/conta.dart';
import '../form/form.dart';
import 'detalheFilme.dart';
import 'notificacao.dart';
import 'pesquisa.dart';
import 'filmeStreaming.dart';
import '../../service/notificacaoService.dart';
import '../../../widgets/headerRotas.dart';
import '../../../widgets/cardFilme.dart';

import '../../../service/filmeService.dart';
import '../../../model/filme.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  final PageController controladorCarrossel = PageController();
  final PageController controllerFIlmes = PageController(
    viewportFraction: 0.46,
  );

  final FilmeService filmeService = FilmeService();

  List<Filme> filmes = [];

  Future<void> carregarFilmes() async {

    final resultado = await filmeService.buscarFilmes();
    setState(() {
       filmes = resultado;
    });
  }

  // carrosel ad fotos
  final List<String> imagensCarrossel = [
    "https://www.gov.br/cultura/pt-br/assuntos/noticias/tela-brasil-a-plataforma-publica-de-streaming-comeca-a-funcionar-neste-sabado-30/37ebd366-06a1-4075-91b1-a031b8ed8451.png",
    "https://www.gamersegames.com.br/wp-content/uploads/2026/03/O-Agente-Secreto-na-Netflix-.webp",
    "https://img.youtube.com/vi/E2xtmPkuksA/maxresdefault.jpg",
  ];


  final Color Cinza = const Color(0xFF222425);
  final Color Azul = const Color(0xFF001C30);
  final Color vermelhoEscuro = const Color(0xFF250203);
  final Color vermelho = const Color(0xFF681F10);

  bool notificacaoEnviada = false;
  static bool notificacaoJaEnviada = false;

  @override
  void initState() {
    super.initState();

    carregarFilmes();

    if (!notificacaoJaEnviada) {
      notificacaoJaEnviada = true;
      Future.delayed(const Duration(seconds: 3), () {
        mostrarNotificacao();
      });
    }
  }

  
  @override
  Widget build(BuildContext context) {
    final largura = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Cinza,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 25),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Olá!",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Encontre o filme perfeito para sua noite",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const Notificacao(),
                                    ),
                                  );
                                },
                                child: _iconeTopo(Icons.notifications),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const Pesquisa(),
                                    ),
                                  );
                                },
                                child: _iconeTopo(Icons.search),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 35),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Stack(
                        children: [
                          SizedBox(
                            height: 260,
                            child: PageView.builder(
                              controller: controladorCarrossel,
                              itemCount: imagensCarrossel.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        imagensCarrossel[index],
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const Positioned(
                            top: 10,
                            left: 10,
                            child: Text(
                              "Em alta",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Positioned(
                            bottom: 10,
                            right: 10,
                            child: Text(
                              "Publicidade",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Você pode gostar",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    if (filmes.isEmpty)
                      const Center(child: CircularProgressIndicator())
                    else
                      largura < 600
                          ? Container(
                              width: double.infinity,
                              height: 320,
                              padding: const EdgeInsets.symmetric(
                                vertical: 20,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: vermelho,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: PageView.builder(
                                controller: controllerFIlmes,
                                padEnds: false,
                                itemCount: filmes.length,
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
                            )
                          : Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: 20,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: vermelho,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: filmes.map((filme) {
                                  return Expanded(
                                    child: CardFilme(
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
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                    const SizedBox(height: 20),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Descubra novos filmes por streaming",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      height: 90,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          _streamingLogo(
                            context,
                            "Netflix",
                            "assets/netflix.png",
                          ),
                          _streamingLogo(
                            context,
                            "HBO Max",
                            "assets/hbomax.png",
                          ),
                          _streamingLogo(
                            context,
                            "Disney+",
                            "assets/disney.png",
                          ),
                          _streamingLogo(
                            context,
                            "Apple TV",
                            "assets/appletv.png",
                          ),
                          _streamingLogo(
                            context,
                            "GloboPlay",
                            "assets/globoplay.png",
                          ),
                          _streamingLogo(
                            context,
                            "Prime Video",
                            "assets/prime.png",
                          ),
                          _streamingLogo(
                            context,
                            "Tela Brasil",
                            "assets/telaBrasil.png",
                          ),
                          _streamingLogo(
                            context,
                            "Outros Streamings",
                            "assets/outros.png",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: MenuWidget(
                onHome: () {},
                onForm: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SecondScreen(),
                    ),
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
            const SizedBox(height: 10),
          ],
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

  Widget _streamingLogo(BuildContext context, String nome, String logo) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FilmeStreaming(nomeStreaming: nome),
          ),
        );
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 15),
        child: Column(
          children: [
            ClipOval(
              child: SizedBox(
                width: 65,
                height: 65,
                child: Image.asset(logo, fit: BoxFit.cover),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
