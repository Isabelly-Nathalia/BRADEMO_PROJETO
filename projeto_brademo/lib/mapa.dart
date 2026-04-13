import 'package:flutter/material.dart';
import 'package:projeto_brademo/conta.dart';
import 'package:projeto_brademo/form.dart';
import 'package:projeto_brademo/home.dart';
import 'package:projeto_brademo/widgets/headerRotas.dart';

class Mapa extends StatelessWidget {
  const Mapa({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF222425),

      appBar: AppBar(
        title: const Text("Cinemas"),
        backgroundColor: const Color(0xFF222425),
        foregroundColor: Colors.white,
      ),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: const Color(0xFF222425),
              ),
            ),

            MenuWidget(
              onHome: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Home()),
                );
              },
              onForm: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SecondScreen()),
                );
              },
              onMapa: () {},
              onConta: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Conta()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
