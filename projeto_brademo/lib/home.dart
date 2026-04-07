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

  final List<String> imagensCarrossel = [
    "https://www.gamersegames.com.br/wp-content/uploads/2026/03/O-Agente-Secreto-na-Netflix-.webp",
    "https://img.youtube.com/vi/E2xtmPkuksA/maxresdefault.jpg",
  ];

  //
  final Color Cinza = const Color(0xFF222425);
  final Color Azul = const Color(0xFF001C30);
  final Color vermelhoEscuro = const Color(0xFF250203);
  final Color vermelho = const Color(0xFF681F10);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  
      backgroundColor: Cinza,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // menu conta icones
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Olá!", //add o nome pessoa a partir da conta
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Encontre o filme perfeito para sua noite", //verificar
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),

                  Row(//verificar depois se vai ter isso mesmo
                    children: [
                      _iconeTopo(Icons.notifications),
                      const SizedBox(width: 10),
                      _iconeTopo(Icons.search),
                    ],
                  ),
                ],
              ),

              MenuWidget(
              onHome: () {
              },
              onForm: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SecondScreen()),
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

              const SizedBox(height: 20),

              // imagens add, verificar se carrosel s ou n
              //add tempo no carosel pra rodar sozinho
              SizedBox(
                height: 180,
                child: PageView.builder(
                  controller: controladorCarrossel,
                  itemCount: imagensCarrossel.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: NetworkImage(imagensCarrossel[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
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
