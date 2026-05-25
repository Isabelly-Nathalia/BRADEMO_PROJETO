import 'package:flutter/material.dart';

class Pesquisa extends StatelessWidget {
  const Pesquisa({super.key});
  final Color Cinza = const Color(0xFF222425);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF222425),

      appBar: AppBar(backgroundColor: Cinza, title: const Text("Pesquisa")),

      body: const Padding(
        padding: EdgeInsets.all(16),
        child: TextField(
          style: const TextStyle(color: Colors.white),

          decoration: InputDecoration(
            hintText: "Pesquisar",

            hintStyle: TextStyle(color: Colors.white24),

            prefixIcon: Icon(Icons.search, color: Colors.white24),

            border: const OutlineInputBorder(),

            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 2),
            ),
          ),
        ),
      ),
    );
  }
}
