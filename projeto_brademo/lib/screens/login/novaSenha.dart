import 'package:flutter/material.dart';
import '../../../widgets/button.dart';
import 'login.dart';
import '../form/form.dart';
import '../../../service/usuarioService.dart';
import '../../../config/sessaoUsuario.dart';

class NovaSenha extends StatefulWidget {
  final bool exclusao;

  const NovaSenha({super.key, this.exclusao = false});

  @override
  State<NovaSenha> createState() => _NovaSenhaState();
}

class _NovaSenhaState extends State<NovaSenha> {
  final TextEditingController senhaController = TextEditingController();
  final TextEditingController confirmarSenhaController =
      TextEditingController();
  final UsuarioService usuarioService = UsuarioService();

  bool ocultarSenha = true;
  bool ocultarConfirmarSenha = true;

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
                const SizedBox(height: 50),
                const Text(
                  'NOVA SENHA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 25),

                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Código de verificação',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),

                const SizedBox(height: 8),

                TextField(
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Digite o código',
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

                const SizedBox(height: 40),

                const Text(
                  'Digite sua nova senha.',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Nova senha',
                    style: TextStyle(color: Colors.white, fontSize: 13),
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
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Confirmar senha',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller: confirmarSenhaController,
                  obscureText: ocultarConfirmarSenha,
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
                          ocultarConfirmarSenha = !ocultarConfirmarSenha;
                        });
                      },
                      icon: Icon(
                        ocultarConfirmarSenha
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                Botao(
                  text: 'Salvar nova senha',
                  onPressed: () async {
                    if (senhaController.text != confirmarSenhaController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('As senhas não coincidem'),
                        ),
                      );
                      return;
                    }

                    else {
                      final usuario = SessaoUsuario.usuarioLogado!;

                      final usuarioAtualizado = await usuarioService
                          .atualizarUsuario(
                            id: usuario.idUsuario,
                            nome: usuario.nome,
                            nomeUsuario: usuario.nomeUsuario,
                            email: usuario.email,
                            senha: senhaController.text,
                            fotoPerfil: usuario.fotoPerfil,
                            dataNascimento: usuario.dataNascimento,
                          );

                      if (usuarioAtualizado == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Erro ao alterar senha'),
                          ),
                        );
                        return;
                      }

                      SessaoUsuario.usuarioLogado = usuarioAtualizado;
                    }
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: const Color(0xFF222425),
                          title: const Text(
                            'Senha alterada!',
                            style: TextStyle(color: Colors.white),
                          ),
                          content: const Text(
                            'Sua senha foi alterada com sucesso.',
                            style: TextStyle(color: Colors.white),
                          ),
                          actions: [
                            Center(
                              child: Botao(
                                text: "OK",
                                onPressed: () {
                                  Navigator.pop(context);
                                  if (widget.exclusao) {
                                    Navigator.pop(context);
                                    Navigator.pop(context, true);
                                  } else {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SecondScreen(),
                                      ),
                                      (route) => false,
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 30),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Login()),
                    );
                  },
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
