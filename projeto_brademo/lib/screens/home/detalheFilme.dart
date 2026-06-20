import 'package:flutter/material.dart';
import 'package:moviematch/model/lista.dart';
import '../perfil/conta.dart';
import '../form/form.dart';
import '../../../widgets/button.dart';
import '../../../widgets/headerRotas.dart';
import 'home.dart';
import '../../../service/filmeService.dart';
import '../../../config/sessaoUsuario.dart';
import '../login/semLogin.dart';
import '../../../service/usuarioService.dart';
import '../../../config/sessaoUsuario.dart';
import '../../../service/listaService.dart';

class DetalheFilme extends StatefulWidget {
  final int idFilme;
  final String titulo;
  final String imagem;
  final String descricao;
  final String nota;
  final int duracao;
  final String diretor;
  final List<String> elenco;
  final String fotoDiretor;
  final String streaming;

  const DetalheFilme({
    super.key,
    required this.idFilme,
    required this.titulo,
    required this.imagem,
    required this.descricao,
    required this.nota,
    required this.duracao,
    required this.diretor,
    required this.elenco,
    required this.fotoDiretor,
    required this.streaming,
  });

  @override
  State<DetalheFilme> createState() => _DetalheFilmeState();
}

class _DetalheFilmeState extends State<DetalheFilme> {
  final Color cinza = const Color(0xFF222425);
  final Color vermelho = const Color(0xFF681F10);
  final Color azul = const Color(0xFF001C30);
  final TextEditingController controllerLista = TextEditingController();
  final UsuarioService usuarioService = UsuarioService();
  final ListaService listaService = ListaService();

  List<Lista> listas = [];
  bool mostrarCampo = false;
  Lista? listaSelecionada;
  bool curtido = false;

  @override
  void initState() {
    super.initState();
    verificarCurtida();
    carregarListas();
  }

  Future<void> carregarListas() async {
    if (SessaoUsuario.usuarioLogado == null) {
      return;
    }

    final resultado = await listaService.buscarListasUsuario(
      SessaoUsuario.usuarioLogado!.idUsuario,
    );

    setState(() {
      listas = resultado;
    });
  }

  Future<void> verificarCurtida() async {
    if (SessaoUsuario.usuarioLogado == null) {
      return;
    }
    bool resultado = await usuarioService.filmeJaCurtido(
      SessaoUsuario.usuarioLogado!.idUsuario,
      widget.idFilme,
    );
    setState(() {
      curtido = resultado;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cinza,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Stack(
                      children: [
                        const Center(
                          child: Text(
                            "BOA ESCOLHA!",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          Container(
                            height: 450,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                              image: DecorationImage(
                                image: NetworkImage(widget.imagem),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: azul,
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(10),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        widget.titulo.toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.star,
                                      color: Colors.white,
                                      size: 16,
                                    ),

                                    const SizedBox(width: 4),

                                    Text(
                                      widget.nota,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),

                                    const SizedBox(width: 15),

                                    const Icon(
                                      Icons.access_time,
                                      color: Colors.white,
                                      size: 16,
                                    ),

                                    const SizedBox(width: 4),

                                    Text(
                                      FilmeService.formatarDuracao(
                                        widget.duracao,
                                      ),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 160,
                          child: GestureDetector(
                            // onTap: () {
                            //   if (SessaoUsuario.usuarioLogado == null) {
                            //     Navigator.push(
                            //       context,
                            //       MaterialPageRoute(
                            //         builder: (context) => const SemLogin(),
                            //       ),
                            //     );
                            //     return;
                            //   }

                            //   setState(() {
                            //     curtido = !curtido;
                            //   });

                            //   ScaffoldMessenger.of(context).showSnackBar(
                            //     SnackBar(
                            //       backgroundColor: azul,
                            //       content: Text(
                            //         curtido
                            //             ? 'Filme adicionado aos curtidos'
                            //             : 'Filme removido dos curtidos',
                            //       ),
                            //       duration: const Duration(seconds: 2),
                            //     ),
                            //   );
                            // },
                            onTap: () async {
                              if (SessaoUsuario.usuarioLogado == null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SemLogin(),
                                  ),
                                );
                                return;
                              }

                              bool sucesso;

                              if (curtido) {
                                sucesso = await usuarioService.removerCurtida(
                                  SessaoUsuario.usuarioLogado!.idUsuario,
                                  widget.idFilme,
                                );

                                if (sucesso) {
                                  setState(() {
                                    curtido = false;
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: azul,
                                      content: const Text(
                                        'Filme removido dos curtidos',
                                      ),
                                    ),
                                  );
                                }
                              } else {
                                sucesso = await usuarioService.curtirFilme(
                                  SessaoUsuario.usuarioLogado!.idUsuario,
                                  widget.idFilme,
                                );

                                if (sucesso) {
                                  setState(() {
                                    curtido = true;
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: azul,
                                      content: const Text(
                                        'Filme adicionado aos curtidos',
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: vermelho,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.thumb_up,
                                    color: curtido ? azul : Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    curtido ? "Curtido" : "Curtir",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 15),

                        SizedBox(
                          width: 160,
                          child: GestureDetector(
                            onTap: () {
                              if (SessaoUsuario.usuarioLogado == null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SemLogin(),
                                  ),
                                );
                                return;
                              }
                              abrirMinhasListas();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: vermelho,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Minha Lista",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundImage: NetworkImage(widget.fotoDiretor),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Direção",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                widget.diretor,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(color: Colors.white24),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Descrição",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            widget.descricao,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          const Text(
                            "Disponível em: ",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          Text(
                            widget.streaming,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(color: Colors.white24),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Elenco",
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: widget.elenco.map((ator) {
                          return Text(
                            "• $ator",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 15),
                  ],
                ),
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
                onConta: () {
                  if (SessaoUsuario.usuarioLogado == null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SemLogin()),
                    );
                    return;
                  }

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Conta()),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void abrirMinhasListas() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: cinza,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Minhas Listas",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      ...listas.map((lista) {
                        final selecionada = listaSelecionada?.idLista == lista.idLista;
                        return ListTile(
                          leading: Icon(
                            selecionada
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: selecionada ? azul : Colors.white54,
                          ),
                          title: Text(
                            lista.nomeLista,
                            style: const TextStyle(color: Colors.white),
                          ),
                          onTap: () {
                            setModalState(() {
                              listaSelecionada = lista;
                            });
                          },
                        );
                      }),
                      ListTile(
                        leading: const Icon(Icons.add, color: Colors.white),
                        title: const Text(
                          "Criar nova lista",
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          setModalState(() {
                            mostrarCampo = !mostrarCampo;
                            listaSelecionada = null;
                          });
                        },
                      ),
                      if (mostrarCampo) ...[
                        const SizedBox(height: 10),
                        TextField(
                          controller: controllerLista,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Nome da lista",
                            hintStyle: const TextStyle(color: Colors.white54),
                            filled: true,
                            fillColor: azul,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      Botao(
                        text: "Salvar",
                        onPressed: () async {
                          if (controllerLista.text.isNotEmpty) {
                            final listaCriada = await listaService.criarLista(
                              SessaoUsuario.usuarioLogado!.idUsuario,
                              controllerLista.text,
                            );
                            if (listaCriada != null) {
                              await listaService.adicionarFilme(listaCriada.idLista, widget.idFilme,);
                              setState(() {
                                listas.add(listaCriada);
                                listaSelecionada = listaCriada;
                              });
                              controllerLista.clear();
                            }
                          }
                          else if (listaSelecionada != null) {
                            await listaService.adicionarFilme(
                              listaSelecionada!.idLista,
                              widget.idFilme,
                            );
                          }

                          if (listaSelecionada != null) {
                            Navigator.pop(context);
                            showDialog(
                              context: this.context,
                              builder: (context) {
                                return AlertDialog(
                                  backgroundColor: cinza,
                                  title: const Text(
                                    'Filme salvo!',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  content: Text(
                                    'O filme foi adicionado em "${listaSelecionada!.nomeLista}".',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  actions: [
                                    Center(
                                      child: Botao(
                                        text: "OK",
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _iconeTopo(IconData icone) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: vermelho, shape: BoxShape.circle),
      child: Icon(icone, color: Colors.white, size: 18),
    );
  }
}
