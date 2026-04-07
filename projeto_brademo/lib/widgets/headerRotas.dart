import 'package:flutter/material.dart';

class MenuWidget extends StatelessWidget {
  final VoidCallback? onHome;
  final VoidCallback? onForm;
  final VoidCallback? onMapa;
  final VoidCallback? onConta;

  const MenuWidget({
    super.key,
    this.onHome,
    this.onForm,
    this.onMapa,
    this.onConta,
  });

  final Color Cinza = const Color(0xFF222425);
  final Color Azul = const Color(0xFF001C30);
  final Color vermelhoEscuro = const Color(0xFF250203);
  final Color vermelho = const Color(0xFF681F10);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: vermelho,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: onHome,
              icon: const Icon(Icons.home, color: Colors.white),
            ),
            IconButton(
              onPressed: onForm,
              icon: const Icon(Icons.description, color: Colors.white),
            ),
            IconButton(
              onPressed: onMapa,
              icon: const Icon(Icons.location_on_sharp, color: Colors.white),
            ),
            IconButton(
              onPressed: onConta,
              icon: const Icon(Icons.person, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
