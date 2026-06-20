import 'dart:async';
import 'package:flutter/material.dart';
import 'inicial.dart';
import '../../../service/hiveUsuarioService.dart';
import '../../../config/sessaoUsuario.dart';
import '../form/form.dart';

class Transicao extends StatefulWidget {
  const Transicao({super.key});

  @override
  State<Transicao> createState() => _TransicaoState();
}

class _TransicaoState extends State<Transicao> {

  @override
@override
void initState() {
  super.initState();

  Timer(const Duration(seconds: 3), () {
    final usuarioHive = HiveUsuarioService();
    final usuario = usuarioHive.buscarUsuario();

    Widget destino = const Apresentacao();

    if (usuario != null) {
      SessaoUsuario.usuarioLogado = usuario;
      destino = const SecondScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => destino,
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