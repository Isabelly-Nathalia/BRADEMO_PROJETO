import 'package:flutter/material.dart';
import '../../../widgets/button.dart';
import '../inicio/inicial.dart';
import '../login/esqueciSenha.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../config/sessaoUsuario.dart';
import '../../../model/usuario.dart';
import '../../../service/usuarioService.dart';

class EditarConta extends StatefulWidget {
  const EditarConta({super.key});
  @override
  State<EditarConta> createState() => _EditarContaState();
}

class _EditarContaState extends State<EditarConta> {
  final Color cinza = const Color(0xFF222425);
  final UsuarioService usuarioService = UsuarioService();

  late TextEditingController nomeController;
  late TextEditingController usuarioController;
  late TextEditingController nascimentoController;

  File? fotoPerfil;
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    final usuario = SessaoUsuario.usuarioLogado!;

    nomeController = TextEditingController(text: usuario.nome);

    usuarioController = TextEditingController(text: usuario.nomeUsuario);

    nascimentoController = TextEditingController(text: usuario.dataNascimento);
  }

  void abrirRecuperacaoSenha() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EsqueceuSenha(exclusao: true),
      ),
    ).then((resultado) {
      if (resultado == true) {
        mostrarPopupConfirmarSenha();
      }
    });
  }

  void mostrarPopupConfirmarSenha() {
    final TextEditingController senhaController = TextEditingController();
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
                    onPressed: () async {
                      String senhaDigitada = senhaController.text;
                      if (senhaDigitada == SessaoUsuario.usuarioLogado!.senha) {
                        bool excluido = await usuarioService.excluirUsuario(
                          SessaoUsuario.usuarioLogado!.idUsuario,
                        );
                        if (!excluido) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Erro ao excluir conta'),
                            ),
                          );
                          return;
                        }
                        SessaoUsuario.usuarioLogado = null;
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: const Color(0xFF222425),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              content: const Text(
                                "Conta excluída com sucesso!",
                                style: TextStyle(color: Colors.white),
                              ),
                              actions: [
                                Center(
                                  child: Botao(
                                    text: "OK",
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const Apresentacao(),
                                        ),
                                        (route) => false,
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
                              backgroundColor: const Color(0xFF222425),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              content: const Text(
                                "Senha incorreta! Tente novamente ou recupere sua senha.",
                                style: TextStyle(color: Colors.white),
                              ),
                              actions: [
                                Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
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
                                          abrirRecuperacaoSenha();
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
  }

  Future<void> selecionarImagem(ImageSource source) async {
    final XFile? imagem = await picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (imagem != null) {
      setState(() {
        fotoPerfil = File(imagem.path);
      });
    }
  }

  void mostrarOpcoesFoto() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F232B),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Colors.white),
                title: const Text(
                  "Tirar foto",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  selecionarImagem(ImageSource.camera);
                },
              ),

              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white),
                title: const Text(
                  "Escolher da galeria",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  selecionarImagem(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

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

              GestureDetector(
                onTap: mostrarOpcoesFoto,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white24,
                      backgroundImage: fotoPerfil != null
                          ? FileImage(fotoPerfil!)
                          : null,
                      child: fotoPerfil == null
                          ? const Icon(
                              Icons.person,
                              size: 55,
                              color: Colors.white54,
                            )
                          : null,
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
                onPressed: () async {
                  if (nomeController.text.isEmpty ||
                      usuarioController.text.isEmpty ||
                      nascimentoController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Preencha todos os campos')),
                    );

                    return;
                  }

                  final usuarioAtualizado = await usuarioService
                      .atualizarUsuario(
                        id: SessaoUsuario.usuarioLogado!.idUsuario,
                        nome: nomeController.text,
                        nomeUsuario: usuarioController.text,
                        email: SessaoUsuario.usuarioLogado!.email,
                        senha: SessaoUsuario.usuarioLogado!.senha,
                        fotoPerfil:
                            fotoPerfil?.path ??
                            SessaoUsuario.usuarioLogado!.fotoPerfil,
                        dataNascimento: nascimentoController.text,
                      );

                  if (usuarioAtualizado != null) {
                    SessaoUsuario.usuarioLogado = usuarioAtualizado;
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
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Erro ao atualizar usuário'),
                      ),
                    );
                  }
                },
              ),

              const SizedBox(height: 15),

              Botao(
                text: 'Excluir conta',
                onPressed: () {
                  mostrarPopupConfirmarSenha();
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
