import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../widgets/button.dart';
import '../form/form.dart';
import '../../../service/usuarioService.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../model/usuario.dart';
import '../../../config/sessaoUsuario.dart';

class PaginaCadastro extends StatefulWidget {
  const PaginaCadastro({super.key});

  @override
  State<PaginaCadastro> createState() => _PaginaCadastroState();
}

class _PaginaCadastroState extends State<PaginaCadastro> {
  final UsuarioService usuarioService = UsuarioService();

  final TextEditingController nomeController = TextEditingController();

  final TextEditingController usuarioController = TextEditingController();

  final TextEditingController nascimentoController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController senhaController = TextEditingController();

  bool ocultarSenha = true;

  File? fotoPerfil;
  final ImagePicker picker = ImagePicker();

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
      backgroundColor: const Color(0xFF1F232B),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),

            child: Column(
              children: [
                const SizedBox(height: 20),

                // TÍTULO
                const Text(
                  'Crie seu perfil',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 25),

                // FOTO
                GestureDetector(
                  onTap: mostrarOpcoesFoto,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.white24,
                        backgroundImage: fotoPerfil != null
                            ? FileImage(fotoPerfil!)
                            : null,

                        child: fotoPerfil == null
                            ? const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.white54,
                              )
                            : null,
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
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

                const SizedBox(height: 30),

                // NOME
                campoTexto(
                  titulo: 'Nome',
                  controller: nomeController,
                  hint: 'Digite seu nome',
                ),

                const SizedBox(height: 18),

                // USUARIO
                campoTexto(
                  titulo: 'Usuário',
                  controller: usuarioController,
                  hint: '@usuario',
                ),

                const SizedBox(height: 18),

                // NASCIMENTO
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Data de nascimento',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      controller: nascimentoController,
                      readOnly: true,

                      style: const TextStyle(color: Colors.white),

                      decoration: InputDecoration(
                        hintText: 'dd/mm/aaaa',

                        hintStyle: const TextStyle(color: Colors.white38),

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
                          color: Colors.white70,
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

                const SizedBox(height: 18),

                // EMAIL
                campoTexto(
                  titulo: 'E-mail',
                  controller: emailController,
                  hint: 'exemplo@gmail.com',
                ),

                const SizedBox(height: 18),

                // SENHA
                const Align(
                  alignment: Alignment.centerLeft,

                  child: Text(
                    'Senha',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller: senhaController,
                  obscureText: ocultarSenha,

                  style: const TextStyle(color: Colors.white),

                  decoration: InputDecoration(
                    hintText: '••••••••',

                    hintStyle: const TextStyle(color: Colors.white38),

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

                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          ocultarSenha = !ocultarSenha;
                        });
                      },

                      icon: Icon(
                        ocultarSenha ? Icons.visibility : Icons.visibility_off,

                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 35),

                Botao(
                  text: 'Entrar',
                  onPressed: () async {
                    if (nomeController.text.isEmpty ||
                        usuarioController.text.isEmpty ||
                        nascimentoController.text.isEmpty ||
                        emailController.text.isEmpty ||
                        senhaController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Preencha todos os campos'),
                        ),
                      );

                      return;
                    }

                    Usuario? usuario = await usuarioService.cadastrarUsuario(
                      nome: nomeController.text,
                      email: emailController.text,
                      nomeUsuario: usuarioController.text,
                      senha: senhaController.text,
                      fotoPerfil: fotoPerfil?.path,
                      dataNascimento: nascimentoController.text,
                    );

                    if (usuario != null) {
                      SessaoUsuario.usuarioLogado = usuario;
                      if (!mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SecondScreen(),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Erro ao cadastrar usuário'),
                        ),
                      );
                    }
                  },
                ),

                const SizedBox(height: 30),

                const Text(
                  'Ou cadastre-se com:',
                  style: TextStyle(color: Colors.white54, fontSize: 11),
                ),

                const SizedBox(height: 20),

                // ÍCONES
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    IconButton(
                      onPressed: () {},

                      icon: const FaIcon(
                        FontAwesomeIcons.instagram,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),

                    IconButton(
                      onPressed: () {},

                      icon: const FaIcon(
                        FontAwesomeIcons.facebook,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),

                    IconButton(
                      onPressed: () {},

                      icon: const FaIcon(
                        FontAwesomeIcons.google,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),

                    IconButton(
                      onPressed: () {},

                      icon: const FaIcon(
                        FontAwesomeIcons.apple,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
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
        Text(
          titulo,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: controller,

          style: const TextStyle(color: Colors.white),

          decoration: InputDecoration(
            hintText: hint,

            hintStyle: const TextStyle(color: Colors.white38),

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