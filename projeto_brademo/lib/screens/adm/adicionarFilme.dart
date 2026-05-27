import 'package:flutter/material.dart';
import '../../../widgets/button.dart';

class AddFilme extends StatefulWidget {
  final Map<String, dynamic>? filme;
  const AddFilme({super.key, this.filme});
  @override
  State<AddFilme> createState() => _AddFilmeState();
}

class _AddFilmeState extends State<AddFilme> {
  final tituloController = TextEditingController();
  final imagemController = TextEditingController();
  final descricaoController = TextEditingController();
  final notaController = TextEditingController();
  final duracaoController = TextEditingController();
  final diretorController = TextEditingController();
  final streamingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.filme != null) {
      tituloController.text = widget.filme!["titulo"] ?? "";
      imagemController.text = widget.filme!["imagem"] ?? "";
      descricaoController.text = widget.filme!["descricao"] ?? "";
      notaController.text = widget.filme!["nota"] ?? "";
      duracaoController.text = widget.filme!["duracao"] ?? "";
      diretorController.text = widget.filme!["diretor"] ?? "";
      streamingController.text = widget.filme!["streaming"] ?? "";
    }
  }

  Widget campo({
    required String texto,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: texto,
          hintStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: const Color(0xFF681F10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF222425),
      appBar: AppBar(
        backgroundColor: const Color(0xFF222425),
        foregroundColor: Colors.white,
        title: Text(widget.filme == null ? "Adicionar Filme" : "Editar Filme"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 50),
            campo(texto: "Título", controller: tituloController),
            campo(texto: "URL da imagem", controller: imagemController),
            campo(
              texto: "Descrição",
              controller: descricaoController,
              maxLines: 4,
            ),
            campo(texto: "Nota", controller: notaController),
            campo(texto: "Duração", controller: duracaoController),
            campo(texto: "Diretor", controller: diretorController),
            campo(texto: "Streaming", controller: streamingController),

            const SizedBox(height: 20),

            Botao(
              text: "SALVAR",
              onPressed: () {
                final novoFilme = {
                  "titulo": tituloController.text,
                  "imagem": imagemController.text,
                  "descricao": descricaoController.text,
                  "nota": notaController.text,
                  "duracao": duracaoController.text,
                  "diretor": diretorController.text,
                  "fotoDiretor": "",
                  "streaming": streamingController.text,
                  "elenco": [],
                };
                Navigator.pop(context, novoFilme);
              },
            ),
          ],
        ),
      ),
    );
  }
}
