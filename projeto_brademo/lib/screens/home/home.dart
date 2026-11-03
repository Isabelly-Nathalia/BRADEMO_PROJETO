import 'package:flutter/material.dart';
import '../perfil/conta.dart';
import '../form/form.dart';
import 'notificacao.dart';
import 'pesquisa.dart';
import 'filmeStreaming.dart';
import '../../service/notificacaoService.dart';
import '../../../widgets/headerRotas.dart';
import '../../../widgets/cardFilme.dart';
import '../../../service/filmeService.dart';
import '../../../model/filme.dart';
import '../../../config/sessaoUsuario.dart';
import '../login/semLogin.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'detalheFilme.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  final PageController controladorCarrossel = PageController(
    viewportFraction: 0.82,
  );
  final PageController controllerFIlmes = PageController(
    viewportFraction: 0.46,
  );

  List<Filme> filmesMaisAssistidos = [];
  bool carregandoMaisAssistidos = true;

  final FilmeService filmeService = FilmeService();

  List<Filme> filmes = [];

  final List<String> generos = [
    "Romance",
    "Ação",
    "Aventura",
    "Drama",
    "Comédia",
    "Animação",
    "Ficção",
    "Mistério",
    "Fantasia",
    "Terror",
    "Musical",
    "Documentário",
    "Suspense",
  ];
  Future<void> carregarFilmes() async {
    final resultado = await filmeService.buscarTodosFilmes();

    if (!mounted) return;

    setState(() {
      filmes = resultado;
    });
  }

  String normalizarGenero(String genero) {
    final valor = genero.trim().toLowerCase();
    if (valor == "roamnce") {
      return "romance";
    }
    return valor;
  }

  List<Filme> buscarFilmesPorGenero(String genero) {
    return filmes.where((filme) {
      return filme.generos.any(
        (generoFilme) =>
            normalizarGenero(generoFilme) == normalizarGenero(genero),
      );
    }).toList();
  }

  Future<void> carregarFilmesMaisAssistidos() async {
    final resultado = await filmeService.buscarFilmes(quantidade: 10);

    print('Quantidade de filmes recebidos: ${resultado.length}');

    if (!mounted) return;

    setState(() {
      filmesMaisAssistidos = resultado;
      carregandoMaisAssistidos = false;
    });
  }

  List<Widget> construirSecoesGeneros() {
    final generosComFilmes = generos
        .map(
          (genero) => {
            "genero": genero,
            "filmes": buscarFilmesPorGenero(genero),
          },
        )
        .where((secao) => (secao["filmes"] as List<Filme>).isNotEmpty)
        .toList();

    return List.generate(generosComFilmes.length, (index) {
      final genero = generosComFilmes[index]["genero"] as String;
      final filmesGenero = generosComFilmes[index]["filmes"] as List<Filme>;

      final conteudo = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              genero.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 295,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: filmesGenero.length,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemBuilder: (context, index) {
                final filme = filmesGenero[index];

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
            ),
          ),
        ],
      );

      return Padding(
        padding: const EdgeInsets.only(bottom: 12, top: 8),
        child: conteudo,
      );
    });
  }

  final Color Cinza = const Color(0xFF222425);
  final Color vermelho = const Color(0xFF681F10);

  bool notificacaoEnviada = false;

  @override
  void initState() {
    super.initState();
    carregarFilmesMaisAssistidos();
    carregarFilmes();
  }

  @override
  Widget build(BuildContext context) {
    final largura = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Cinza,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 25),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Olá!",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Encontre o filme perfeito para sua noite",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const Notificacao(),
                                    ),
                                  );
                                },
                                child: _iconeTopo(Icons.notifications),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const Pesquisa(),
                                    ),
                                  );
                                },
                                child: _iconeTopo(Icons.search),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 35),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: const Text(
                        "Confira os mais assistidos da semana!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: largura * 1.17,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            left: 0,
                            right: 0,
                            top: 22,
                            bottom: 22,
                            child: Container(color: vermelho),
                          ),

                          if (carregandoMaisAssistidos)
                            const Center(child: CircularProgressIndicator())
                          else if (filmesMaisAssistidos.isEmpty)
                            const Center(
                              child: Text(
                                "Nenhum filme disponível",
                                style: TextStyle(color: Colors.white70),
                              ),
                            )
                          else
                            PageView.builder(
                              controller: controladorCarrossel,
                              itemCount: filmesMaisAssistidos.length,
                              itemBuilder: (context, index) {
                                final filme = filmesMaisAssistidos[index];

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetalheFilme(
                                          idFilme: filme.idFilme,
                                          titulo: filme.titulo,
                                          imagem: filme.imagem,
                                          descricao: filme.descricao,
                                          nota: filme.nota.toString(),
                                          duracao: filme.duracao,
                                          diretor: filme.diretor,
                                          fotoDiretor: filme.fotoDiretor,
                                          streaming: filme.streaming,
                                          elenco: [filme.atores],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Center(
                                    child: SizedBox(
                                      width: largura * 0.76,
                                      child: AspectRatio(
                                        aspectRatio: 0.68,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl: filme.imagem,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) {
                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            },
                                            errorWidget: (context, url, error) {
                                              return const Center(
                                                child: Icon(
                                                  Icons.broken_image,
                                                  color: Colors.white,
                                                  size: 40,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    const SizedBox(height: 15),
                    
                    if (filmes.isEmpty)
                      const Center(child: CircularProgressIndicator())
                    else
                      ...construirSecoesGeneros(),
                    const SizedBox(height: 20),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Descubra novos filmes por streaming",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      height: 90,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          _streamingLogo(
                            context,
                            "Netflix",
                            "assets/netflix.png",
                          ),
                          _streamingLogo(
                            context,
                            "HBO Max",
                            "assets/hbomax.png",
                          ),
                          _streamingLogo(
                            context,
                            "Disney+",
                            "assets/disney.png",
                          ),
                          _streamingLogo(
                            context,
                            "Apple TV",
                            "assets/appletv.png",
                          ),
                          _streamingLogo(
                            context,
                            "GloboPlay",
                            "assets/globoplay.png",
                          ),
                          _streamingLogo(
                            context,
                            "Prime Video",
                            "assets/prime.png",
                          ),
                          _streamingLogo(
                            context,
                            "Tela Brasil",
                            "assets/telaBrasil.png",
                          ),
                          _streamingLogo(
                            context,
                            "Outros Streamings",
                            "assets/outros.png",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: MenuWidget(
                onHome: () {},
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

  Widget _iconeTopo(IconData icone) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: vermelho, shape: BoxShape.circle),
      child: Icon(icone, color: Colors.white, size: 18),
    );
  }

  Widget _streamingLogo(BuildContext context, String nome, String logo) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FilmeStreaming(nomeStreaming: nome),
          ),
        );
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 15),
        child: Column(
          children: [
            ClipOval(
              child: SizedBox(
                width: 65,
                height: 65,
                child: Image.asset(logo, fit: BoxFit.cover),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
