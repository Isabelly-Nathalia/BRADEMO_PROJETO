import 'package:flutter/material.dart';
import 'package:projeto_brademo/widgets/headerRotas.dart';
import 'home.dart';
import 'form.dart';
import 'mapa.dart';

class Conta extends StatelessWidget {
  const Conta({super.key});

  final Color cinza = const Color(0xFF222425);
  final Color azul = const Color(0xFF001C30);
  final Color vermelho = const Color(0xFF681F10);

  // LISTA FILMES
  final List<Map<String, String>> filmes = const [
    {
      "titulo": "Cidade de Deus",
      "imagem":
          "https://upload.wikimedia.org/wikipedia/pt/thumb/1/10/CidadedeDeus.jpg/250px-CidadedeDeus.jpg",
    },

    {
      "titulo": "Central do Brasil",
      "imagem":
          "https://m.media-amazon.com/images/M/MV5BMWI3YTg2YmItY2QzYi00NTc2LWExNTQtYWE4ZmIzNjE3ZjMyXkEyXkFqcGc@._V1_.jpg",
    },

    {
      "titulo": "La La Land",
      "imagem":
          "https://i5.walmartimages.com/seo/Rolled-Poster-La-La-Land-Movie-24-x-36-Poster_20f02811-01b4-4aea-9bb2-a79942bd2642_1.856c035d66f8fd216f6d933259bc3dfb.jpeg",
    },

    {
      "titulo": "Her",
      "imagem":
          "https://upload.wikimedia.org/wikipedia/pt/9/9b/Her.jpg",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cinza,

      body: SafeArea(
        child: Column(
          children: [

            const SizedBox(height: 20),

            // TOPO
            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 20,
              ),

              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,

                children: [

                  // FOTO + INFO
                  Row(
                    children: [

                      CircleAvatar(
                        radius: 35,
                        backgroundColor:
                            Colors.white24,

                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white54,
                        ),
                      ),

                      const SizedBox(width: 15),

                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: const [

                          Text(
                            "Usuario123",
                            style: TextStyle(
                              color:
                                  Colors.white,
                              fontSize: 18,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),

                          SizedBox(height: 4),

                          Text(
                            "@usuario123",
                            style: TextStyle(
                              color: Colors
                                  .white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // NOTIFICAÇÃO
                  Container(
                    padding:
                        const EdgeInsets.all(8),

                    decoration: BoxDecoration(
                      color: vermelho,
                      shape: BoxShape.circle,
                    ),

                    child: const Icon(
                      Icons.notifications,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // BOTÃO EDITAR
            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 20,
              ),

              child: SizedBox(
                width: double.infinity,

                child: ElevatedButton(
                  onPressed: () {},

                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        vermelho,

                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 14,
                    ),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        30,
                      ),
                    ),
                  ),

                  child: const Text(
                    "Editar perfil",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // TÍTULO
            const Padding(
              padding:
                  EdgeInsets.symmetric(
                horizontal: 20,
              ),

              child: Align(
                alignment:
                    Alignment.centerLeft,

                child: Text(
                  "Filmes curtidos",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // GRID FILMES
            Expanded(
              child: GridView.builder(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 20,
                ),

                itemCount: filmes.length,

                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.62,
                ),

                itemBuilder: (context, index) {

                  final filme =
                      filmes[index];

                  return Column(
                    children: [

                      Container(
                        height: 250,

                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(
                            15,
                          ),

                          image:
                              DecorationImage(
                            image: NetworkImage(
                              filme["imagem"]!,
                            ),

                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        filme["titulo"]!,

                        textAlign:
                            TextAlign.center,

                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // MENU
            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
              ),

              child: MenuWidget(
                onHome: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              const Home(),
                    ),
                  );
                },

                onForm: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              const SecondScreen(),
                    ),
                  );
                },

                onMapa: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              const Mapa(),
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