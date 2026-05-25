import 'package:flutter/material.dart';
import 'conta.dart';
import 'form.dart';
import 'mapa.dart';
import 'package:projeto_brademo/widgets/headerRotas.dart';
import 'detalhe_filme.dart';
import 'notificacao.dart';
import 'pesquisa.dart';
import 'filmeStreaming.dart';

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
                                return _cardFilme(
                                  imagem: filme["imagem"]!,
                                  titulo: filme["titulo"]!,
                                  nota: filme["nota"]!,
                                  duracao: filme["duracao"]!,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetalheFilme(
                                          titulo: filme["titulo"]!,
                                          imagem: filme["imagem"]!,
                                          descricao: filme["descricao"]!,
                                          nota: filme["nota"]!,
                                          duracao: filme["duracao"]!,
                                          diretor: filme["diretor"]!,
                                          streaming: filme["streaming"]!,
                                          elenco: List<String>.from(
                                            filme["elenco"],
                                          ),
                                          fotoDiretor: filme["fotoDiretor"]!,
                                        ),
                                      ),
                                    );
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
                                  child: _cardFilme(
                                    imagem: filme["imagem"]!,
                                    titulo: filme["titulo"]!,
                                    nota: filme["nota"]!,
                                    duracao: filme["duracao"]!,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DetalheFilme(
                                            titulo: filme["titulo"]!,
                                            imagem: filme["imagem"]!,
                                            descricao: filme["descricao"]!,
                                            nota: filme["nota"]!,
                                            duracao: filme["duracao"]!,
                                            diretor: filme["diretor"]!,
                                            streaming: filme["streaming"]!,
                                            elenco: List<String>.from(
                                              filme["elenco"],
                                            ),
                                            fotoDiretor: filme["fotoDiretor"]!,
                                          ),
                                        ),
                                      );
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
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),
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

  Widget _cardFilme({
    required String imagem,
    required String titulo,
    required String nota,
    required String duracao,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        child: Column(
          children: [
            Container(
              height: 220,
              width: 150,
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
            Container(
              width: 150,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Azul,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(10),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    titulo.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.white, size: 12),
                      const SizedBox(width: 3),
                      Text(
                        nota,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.access_time,
                        color: Colors.white,
                        size: 12,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        duracao,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
