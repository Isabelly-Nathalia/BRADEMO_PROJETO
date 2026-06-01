import 'package:flutter/material.dart';
import '../perfil/conta.dart';
import '../form/form.dart';
import 'detalheFilme.dart';
import 'notificacao.dart';
import 'pesquisa.dart';
import 'filmeStreaming.dart';
import 'notificacaoService.dart';
import '../../../widgets/headerRotas.dart';
import '../../../widgets/cardFilme.dart';

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

  // carrosel ad fotos
  final List<String> imagensCarrossel = [
    "https://www.gov.br/cultura/pt-br/assuntos/noticias/tela-brasil-a-plataforma-publica-de-streaming-comeca-a-funcionar-neste-sabado-30/37ebd366-06a1-4075-91b1-a031b8ed8451.png",
    "https://www.gamersegames.com.br/wp-content/uploads/2026/03/O-Agente-Secreto-na-Netflix-.webp",
    "https://img.youtube.com/vi/E2xtmPkuksA/maxresdefault.jpg",
  ];

  // carrosel sugestao infos
  final List<Map<String, dynamic>> filmes = [
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
  ];

  final Color Cinza = const Color(0xFF222425);
  final Color Azul = const Color(0xFF001C30);
  final Color vermelhoEscuro = const Color(0xFF250203);
  final Color vermelho = const Color(0xFF681F10);

  bool notificacaoEnviada = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (!notificacaoEnviada) {
        mostrarNotificacao();
        notificacaoEnviada = true;
      }
    });
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
                                return CardFilme(filme: filme);
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
                                return Expanded(child: CardFilme(filme: filme));
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
                            "AppleTV",
                            "assets/appletv.png",
                          ),
                          _streamingLogo(
                            context,
                            "GloboPlay",
                            "assets/globoplay.png",
                          ),
                          _streamingLogo(
                            context,
                            "PrimeVideo",
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
