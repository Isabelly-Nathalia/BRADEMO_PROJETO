import 'package:flutter/material.dart';
import 'package:moviematch/screens/login/semLogin.dart';
import '../home/home.dart';
import '../form/form.dart';
import '../home/detalheFilme.dart';
import 'editarConta.dart';
import '../../../widgets/cardFilme.dart';
import '../../../widgets/headerRotas.dart';
import '../../../widgets/button.dart';
import '../../../config/sessaoUsuario.dart';
import 'dart:io';
import '../../../service/usuarioService.dart';
import '../../../service/listaService.dart';
import '../../../model/filme.dart';
import '../../../model/lista.dart';

class Conta extends StatefulWidget {
  const Conta({super.key});

  @override
  State<Conta> createState() => _ContaState();
}

class _ContaState extends State<Conta> {
  final Color cinza = const Color(0xFF222425);
  final Color azul = const Color(0xFF001C30);
  final Color vermelho = const Color(0xFF681F10);

  @override
  void initState() {
    super.initState();
    carregarCurtidos();
    carregarListas();
  }

  int abaSelecionada = 0;
  int? listaEditando;
  final TextEditingController editarListaController = TextEditingController();

  Future<void> carregarCurtidos() async {
    if (SessaoUsuario.usuarioLogado == null) {
      return;
    }
    final resultado = await usuarioService.buscarCurtidos(
      SessaoUsuario.usuarioLogado!.idUsuario,
    );
    setState(() {
      filmesCurtidos = resultado;
    });
  }

  Future<void> carregarListas() async {
    final resultado = await listaService.buscarListasUsuario(
      SessaoUsuario.usuarioLogado!.idUsuario,
    );

    setState(() {
      minhasListas = resultado;
    });
  }

  final UsuarioService usuarioService = UsuarioService();
  final ListaService listaService = ListaService();
  List<Filme> filmesCurtidos = [];
  List<Lista> minhasListas = [];

  @override
  Widget build(BuildContext context) {
    final usuario = SessaoUsuario.usuarioLogado;

    return Scaffold(
      backgroundColor: cinza,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white24,
                    backgroundImage:
                        usuario != null && usuario.fotoPerfil.isNotEmpty
                        ? FileImage(File(usuario.fotoPerfil))
                        : null,
                    child: usuario == null || usuario.fotoPerfil.isEmpty
                        ? const Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.white54,
                          )
                        : null,
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        usuario?.nome ?? "Usuário",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "@${usuario?.nomeUsuario ?? ""}",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (SessaoUsuario.usuarioLogado == null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SemLogin(),
                        ),
                      );
                      return;
                    }
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditarConta(),
                      ),
                    );

                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: vermelho,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Editar perfil",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => setState(() => abaSelecionada = 0),
                  child: Column(
                    children: [
                      Text(
                        "Filmes que Curti",
                        style: TextStyle(
                          color: abaSelecionada == 0
                              ? Colors.white
                              : Colors.white54,
                        ),
                      ),
                      Container(
                        height: 2,
                        width: 120,
                        color: abaSelecionada == 0
                            ? vermelho
                            : Colors.transparent,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 25),
                GestureDetector(
                  onTap: () => setState(() => abaSelecionada = 1),
                  child: Column(
                    children: [
                      Text(
                        "Minha Lista",
                        style: TextStyle(
                          color: abaSelecionada == 1
                              ? Colors.white
                              : Colors.white54,
                        ),
                      ),
                      Container(
                        height: 2,
                        width: 90,
                        color: abaSelecionada == 1
                            ? vermelho
                            : Colors.transparent,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Expanded(
              child: abaSelecionada == 0
                  ? GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filmesCurtidos.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 20,
                            childAspectRatio: 0.68,
                          ),
                      itemBuilder: (context, index) {
                        final filme = filmesCurtidos[index];

                        return CardFilme(
                          filme: {
                            "idFilme": filme.idFilme,
                            "titulo": filme.titulo,
                            "imagem": filme.imagem,
                            "descricao": filme.descricao,
                            "nota": filme.nota.toString(),
                            "duracao": filme.duracao,
                            "diretor": filme.diretor,
                            "fotoDiretor": filme.fotoDiretor,
                            "streaming": filme.streaming,
                            "elenco": [filme.atores],
                          },
                        );
                      },
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: minhasListas.length,
                      itemBuilder: (context, index) {
                        final lista = minhasListas[index];
                        final filmesLista = lista.filmes;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 40),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF222425),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  listaEditando == index
                                      ? SizedBox(
                                          width: 200,
                                          child: TextField(
                                            controller: editarListaController,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
                                      : Text(
                                          lista.nomeLista,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () async {
                                          if (listaEditando == index) {
                                            await listaService.editarLista(
                                              lista.idLista,
                                              editarListaController.text,
                                            );

                                            await carregarListas();

                                            setState(() {
                                              listaEditando = null;
                                            });
                                          } else {
                                            editarListaController.text =
                                                lista.nomeLista;

                                            setState(() {
                                              listaEditando = index;
                                            });
                                          }
                                        },
                                        icon: Icon(
                                          listaEditando == index
                                              ? Icons.check
                                              : Icons.edit,
                                          color: Colors.white,
                                        ),
                                      ),

                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                        ),
                                        onPressed: () async {
                                          bool sucesso = await listaService
                                              .excluirLista(lista.idLista);

                                          if (sucesso) {
                                            await carregarListas();
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(height: 15),

                              SizedBox(
                                height: 280,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: filmesLista.length,
                                  itemBuilder: (context, i) {
                                    return Stack(
                                      children: [
                                        CardFilme(
                                          filme: {
                                            "idFilme": filmesLista[i].idFilme,
                                            "titulo": filmesLista[i].titulo,
                                            "imagem": filmesLista[i].imagem,
                                            "descricao":
                                                filmesLista[i].descricao,
                                            "nota": filmesLista[i].nota
                                                .toString(),
                                            "duracao": filmesLista[i].duracao,
                                            "diretor": filmesLista[i].diretor,
                                            "fotoDiretor":
                                                filmesLista[i].fotoDiretor,
                                            "streaming":
                                                filmesLista[i].streaming,
                                            "elenco": [filmesLista[i].atores],
                                          },
                                        ),
                                        if (listaEditando == index)
                                          Positioned(
                                            top: 5,
                                            right: 10,
                                            child: GestureDetector(
                                              onTap: () async {
                                                bool
                                                sucesso = await listaService
                                                    .removerFilme(
                                                      lista.idLista,
                                                      filmesLista[i].idFilme,
                                                    );

                                                if (sucesso) {
                                                  setState(() {
                                                    filmesLista.removeAt(i);
                                                  });
                                                }
                                              },
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: MenuWidget(
                onHome: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Home()),
                  );
                },
                onForm: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SecondScreen(),
                    ),
                  );
                },
                onConta: () {},
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
