import 'package:flutter/material.dart';

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Formulário"),
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF222425),
      ),
      backgroundColor: const Color(0xFF222425),
      body: const Center(child: Text("Bla bla bla")),
    );
  }
}
