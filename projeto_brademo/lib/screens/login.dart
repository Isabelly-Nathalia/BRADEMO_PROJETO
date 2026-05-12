import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../widgets/button.dart';
import 'form.dart';
import 'criarConta.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController senhaController =
      TextEditingController();

  bool ocultarSenha = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F232B),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 30,
            ),

            child: Column(
              children: [

                const SizedBox(height: 40),

                // TÍTULO
                const Text(
                  'LOGIN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 50),

                // EMAIL
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'E-mail',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller: emailController,

                  style: const TextStyle(
                    color: Colors.white,
                  ),

                  decoration: InputDecoration(
                    hintText: 'exemplo@gmail.com',

                    hintStyle: const TextStyle(
                      color: Colors.white38,
                    ),

                    filled: true,
                    fillColor: Colors.white24,

                    contentPadding:
                        const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),

                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(30),

                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // SENHA
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Senha',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller: senhaController,
                  obscureText: ocultarSenha,

                  style: const TextStyle(
                    color: Colors.white,
                  ),

                  decoration: InputDecoration(
                    hintText: '••••••••',

                    hintStyle: const TextStyle(
                      color: Colors.white38,
                    ),

                    filled: true,
                    fillColor: Colors.white24,

                    contentPadding:
                        const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),

                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(30),

                      borderSide: BorderSide.none,
                    ),

                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          ocultarSenha =
                              !ocultarSenha;
                        });
                      },

                      icon: Icon(
                        ocultarSenha
                            ? Icons.visibility
                            : Icons.visibility_off,

                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                // BOTÃO ENTRAR

              Botao(
                text: 'Entrar',
                onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SecondScreen(),
                  ),
                );
              },
              ),

                const SizedBox(height: 15),

              Botao(
                text: 'Criar uma conta',
                onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PaginaCadastro(),
                  ),
                );
              },
              ),

                const SizedBox(height: 30),

                GestureDetector(
                  onTap: () {},

                  child: const Text(
                    'Esqueceu sua senha? Clique aqui!',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                const Text(
                  'Ou entre com:',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),

                const SizedBox(height: 20),

                // ÍCONES
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  children: [

                    IconButton(
                      onPressed: () {},

                      icon: const FaIcon(
                        FontAwesomeIcons.instagram,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),

                    IconButton(
                      onPressed: () {},

                      icon: const FaIcon(
                        FontAwesomeIcons.facebook,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),

                    IconButton(
                      onPressed: () {},

                      icon: const FaIcon(
                        FontAwesomeIcons.google,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),

                    IconButton(
                      onPressed: () {},

                      icon: const FaIcon(
                        FontAwesomeIcons.apple,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                const Text(
                  'Não tem uma conta? Crie sua conta',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
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