import 'package:flutter/material.dart';
import '../../../widgets/button.dart';
import '../inicio/inicial.dart';
import '../login/esqueciSenha.dart';

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
                        backgroundColor: cinza,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        content: const Text(
                          "As alterações foram salvas!",
                          style: TextStyle(color: Colors.white),
                        ),
                        actions: [
                          Center(
                            child: Botao(
                              text: "OK",
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 15),

              Botao(
                text: 'Deletar conta',
                onPressed: () {
                  final TextEditingController senhaController =
                      TextEditingController();
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor: cinza,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: const Text(
                          "Confirme sua senha",
                          style: TextStyle(color: Colors.white),
                        ),
                        content: TextField(
                          controller: senhaController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Digite sua senha",
                            hintStyle: const TextStyle(color: Colors.white54),
                            filled: true,
                            fillColor: Colors.white24,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        actions: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: Botao(
                                  text: "Cancelar",
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Botao(
                                  text: "Confirmar",
                                  onPressed: () {
                                    String senhaDigitada = senhaController.text;
                                    if (senhaDigitada == "123456") {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            backgroundColor: const Color(
                                              0xFF222425,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            content: const Text(
                                              "Conta excluída com sucesso!",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            actions: [
                                              Center(
                                                child: Botao(
                                                  text: "OK",
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            const Apresentacao(),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    } else {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            backgroundColor: const Color(
                                              0xFF222425,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            content: const Text(
                                              "Senha incorreta! Tente novamente ou recupere sua senha.",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            actions: [
                                              Center(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Botao(
                                                      text: "Tentar novamente",
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Botao(
                                                      text: "Esqueci a senha",
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                const EsqueceuSenha(),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
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
