import 'package:flutter/material.dart';
import '../../widgets/button.dart';
import 'login.dart';
import 'form.dart';

class Apresentacao extends StatelessWidget {
  const Apresentacao({super.key});

  @override
  Widget build(BuildContext context) {

    final largura = MediaQuery.of(context).size.width;
    final altura = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF222425),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,

            children: [

              // GRID DOS FILMES
              Column(
                children: const [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MovieCard('assets/filme1.png'),
                      SizedBox(width: 10),
                      MovieCard('assets/filme2.png'),
                    ],
                  ),

                  SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MovieCard('assets/filme3.png'),
                      SizedBox(width: 10),
                      MovieCard('assets/filme4.jpg'),
                    ],
                  ),

                  SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MovieCard('assets/filme5.jpg'),
                      SizedBox(width: 10),
                      MovieCard('assets/filme6.png'),
                    ],
                  ),
                ],
              ),

              // TEXOS
              Column(
                children: [

                  const Text(
                    "Bem-vindo(a) ao MovieMatch",
                    textAlign: TextAlign.center,

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: altura * 0.015),

                  Text(
                    "Descubra novos filmes e conheça o seu próximo favorito para assistir",
                    textAlign: TextAlign.center,

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: largura * 0.043,
                    ),
                  ),
                ],
              ),

              // BOTAO
              Botao(
                text: "Fazer Login",

                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  );
                },
              ),

              Botao(
                text: "Formulário",

                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SecondScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MovieCard extends StatelessWidget {

  final String imagePath;

  const MovieCard(this.imagePath, {super.key});

  @override
  Widget build(BuildContext context) {

    final largura = MediaQuery.of(context).size.width;

    return SizedBox(
      width: largura * 0.34,
      height: largura * 0.49,

      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),

        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}