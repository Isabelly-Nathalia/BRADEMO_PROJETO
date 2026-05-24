import 'package:flutter/material.dart';
import '../../widgets/button.dart';

class EditarConta extends StatefulWidget {
  const EditarConta({super.key});
  @override
  State<EditarConta> createState() => _EditarContaState();
}

class _EditarContaState extends State<EditarConta> {
  final Color cinza = const Color(0xFF222425);
  final TextEditingController nomeController = TextEditingController(
    text: "Usuario123",
  );
  final TextEditingController usuarioController = TextEditingController(
    text: "@usuario123",
  );
  final TextEditingController nascimentoController = TextEditingController(
    text: "10/05/2005",
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cinza,
      appBar: AppBar(
        backgroundColor: cinza,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Editar Perfil",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white24,
                    child: const Icon(
                      Icons.person,
                      size: 55,
                      color: Colors.white54,
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 35),

              campoTexto(
                titulo: "Nome",
                controller: nomeController,
                hint: "Digite seu nome",
              ),

              const SizedBox(height: 20),

              campoTexto(
                titulo: "Usuário",
                controller: usuarioController,
                hint: "@usuario",
              ),

              const SizedBox(height: 20),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Data de nascimento',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller: nascimentoController,
                    readOnly: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'dd/mm/aaaa',
                      hintStyle: const TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Colors.white24,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: const Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                      ),
                    ),

                    onTap: () async {
                      DateTime? dataSelecionada = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                      );
                      if (dataSelecionada != null) {
                        String dataFormatada =
                            "${dataSelecionada.day.toString().padLeft(2, '0')}/"
                            "${dataSelecionada.month.toString().padLeft(2, '0')}/"
                            "${dataSelecionada.year}";
                        setState(() {
                          nascimentoController.text = dataFormatada;
                        });
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 40),

              Botao(
                text: 'Salvar alterações',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor: const Color(0xFF222425),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        content: const Text(
                          "As alterações foram salvas!",
                          style: TextStyle(color: Colors.white),
                        ),

                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "OK",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget campoTexto({
    required String titulo,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: const TextStyle(color: Colors.white, fontSize: 13)),

        const SizedBox(height: 8),

        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white),
            filled: true,
            fillColor: Colors.white24,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
