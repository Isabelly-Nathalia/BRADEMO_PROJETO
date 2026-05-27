import 'dart:async';
import 'package:flutter/material.dart';
import 'inicial.dart';

class Transicao extends StatefulWidget {
  const Transicao({super.key});

  @override
  State<Transicao> createState() => _TransicaoState();
}

class _TransicaoState extends State<Transicao> {

  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const Apresentacao(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF222425),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/MovieMatch_Vert.png',
              width: 380,
            ),
          ],
        ),
      ),
    );
  }
}