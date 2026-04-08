import 'package:flutter/material.dart';
import 'package:projeto_brademo/conta.dart';
import 'package:projeto_brademo/form.dart';
import 'package:projeto_brademo/mapa.dart';
import 'package:projeto_brademo/widgets/headerRotas.dart';

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
  final List<Map<String, String>> filmes = [
    {
      "imagem":
          "https://m.media-amazon.com/images/M/MV5BMWI3YTg2YmItY2QzYi00NTc2LWExNTQtYWE4ZmIzNjE3ZjMyXkEyXkFqcGc@._V1_.jpg",
      "titulo": "Central do Brasil",
      "nota": "5",
      "duracao": "1h50min",
    },
    {
      "imagem":
          "https://upload.wikimedia.org/wikipedia/pt/thumb/5/57/Ainda_Estou_Aqui_2024_poster.jpg/250px-Ainda_Estou_Aqui_2024_poster.jpg",
      "titulo": "Ainda Estou Aqui",
      "nota": "5",
      "duracao": "2h17min",
    },
    {
      "imagem":
          "https://upload.wikimedia.org/wikipedia/pt/thumb/1/10/CidadedeDeus.jpg/250px-CidadedeDeus.jpg",
      "titulo": "Cidade de Deus",
      "nota": "5",
      "duracao": "2h10min",
    },
  ];

  final Color Cinza = const Color(0xFF222425);
  final Color Azul = const Color(0xFF001C30);
  final Color vermelhoEscuro = const Color(0xFF250203);
  final Color vermelho = const Color(0xFF681F10);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cinza,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 25),

            // header saudaçao icons, verificar icons 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Olá!", //depois colocar o nome da pessoa pegando pela conta
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
                  Row( //verificar
                    children: [
                      _iconeTopo(Icons.notifications),
                      const SizedBox(width: 10),
                      _iconeTopo(Icons.search),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            

            const SizedBox(height: 20),

            // carrossel ad
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

            // carrossel sugestao
            Container(
              height: 320,
              padding: const EdgeInsets.symmetric(vertical: 20),
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
                    onTap: () {}, //rota p detalhamneto
                  );
                },
              ),
            ),

            // footer rotas menu
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
          ],
        ),
      ),
    );
  }

  Widget _iconeTopo(IconData icone) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: vermelho,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icone,
        color: Colors.white,
        size: 18,
      ),
    );
  }

  // card filme, img legenda
  Widget _cardFilme({
    required String imagem,
    required String titulo,
    required String nota,
    required String duracao,
    required VoidCallback onTap, //rota p detalhamento
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
                borderRadius: BorderRadius.circular(20),
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 12,
                      ),
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
}