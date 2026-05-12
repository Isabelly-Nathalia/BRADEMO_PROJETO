import 'package:flutter/material.dart';
import 'package:projeto_brademo/widgets/button.dart';
import 'mapa.dart';
import 'home.dart';
import 'conta.dart';
import '../widgets/headerRotas.dart';
import 'sugestao.dart';

class SecondScreen extends StatefulWidget {
  const SecondScreen({super.key});

  @override
  State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  final Color Cinza = const Color(0xFF222425);
  final Color Azul = const Color(0xFF001C30);
  final Color vermelhoEscuro = const Color(0xFF250203);
  final Color vermelho = const Color(0xFF681F10);

  final _formKey = GlobalKey<FormState>();

  TextEditingController fController = TextEditingController();

  String? duracaoSelecionada;
  String? streamingSelecionado;
  String? classificacaoSelecionada;
  String? paisSelecionado;

  bool acao = false;
  bool aventura = false;
  bool comedia = false;
  bool drama = false;
  bool romance = false;
  bool terror = false;
  bool scifi = false;
  bool fantasia = false;
  bool animacao = false;
  bool documentario = false;
  bool misterio = false;
  bool musical = false;

  final List<String> streamings = [
    "Netflix",
    "Prime Video",
    "Disney+",
    "HBO Max",
    "Apple TV+",
    "Globoplay",
  ];

  final List<String> paises = [
    "Brasil",
    "Estados Unidos",
    "Canadá",
    "Argentina",
    "Portugal",
    "França",
    "Alemanha",
    "Japão",
    "China",
    "Coreia do Sul",
    "Itália",
  ];

  TextStyle tituloStyle = const TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  void selecionarPais() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: 400,
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: paises.map((pais) {
              return ListTile(
                title: Text(pais),
                onTap: () {
                  setState(() {
                    paisSelecionado = pais;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void enviar() {
    if (!_formKey.currentState!.validate()) return;

    if (duracaoSelecionada == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Selecione a duração")));
      return;
    }

    if (!acao &&
        !comedia &&
        !drama &&
        !romance &&
        !terror &&
        !scifi &&
        !fantasia &&
        !animacao &&
        !documentario &&
        !misterio &&
        !musical) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecione pelo menos um gênero")),
      );
      return;
    }

    showDialog(
      //popup
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Sucesso"),
          content: const Text("Dados enviados, buscando sugestões..."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                limpar();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void limpar() {
    setState(() {
      duracaoSelecionada = null;
      streamingSelecionado = null;
      classificacaoSelecionada = null;
      paisSelecionado = null;
      fController.clear();
      acao = false;
      aventura = false;
      comedia = false;
      drama = false;
      romance = false;
      terror = false;
      scifi = false;
      fantasia = false;
      animacao = false;
      documentario = false;
      misterio = false;
      musical = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF222425),

      appBar: AppBar(
        title: const Text("Formulário"),
        backgroundColor: const Color(0xFF222425),
        foregroundColor: Colors.white,
      ),

      body: SafeArea(
        child: Column(
          children: [
            Text(
              "Nos conte o que você gosta e iremos sugerir ótimos filmes!", 
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // duracao
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: vermelho,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Duração do filme", style: tituloStyle),

                            RadioListTile(
                              title: const Text(
                                "Até 1h30",
                                style: TextStyle(color: Colors.white),
                              ),
                              value: "1h30",
                              groupValue: duracaoSelecionada,
                              onChanged: (v) =>
                                  setState(() => duracaoSelecionada = v),
                            ),
                            RadioListTile(
                              title: const Text(
                                "Entre 1h30 e 2h",
                                style: TextStyle(color: Colors.white),
                              ),
                              value: "1h30-2h",
                              groupValue: duracaoSelecionada,
                              onChanged: (v) =>
                                  setState(() => duracaoSelecionada = v),
                            ),
                            RadioListTile(
                              title: const Text(
                                "Entre 2h e 3h",
                                style: TextStyle(color: Colors.white),
                              ),
                              value: "2h-3h",
                              groupValue: duracaoSelecionada,
                              onChanged: (v) =>
                                  setState(() => duracaoSelecionada = v),
                            ),
                            RadioListTile(
                              title: const Text(
                                "Mais que 3h",
                                style: TextStyle(color: Colors.white),
                              ),
                              value: "3h",
                              groupValue: duracaoSelecionada,
                              onChanged: (v) =>
                                  setState(() => duracaoSelecionada = v),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      //streamings
                      Text("Onde assistir", style: tituloStyle),
                      const SizedBox(height: 10),

                      DropdownButtonFormField(
                        dropdownColor: Colors.grey[800],
                        value: streamingSelecionado,
                        items: streamings.map((s) {
                          return DropdownMenuItem(
                            value: s,
                            child: Text(
                              s,
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (v) =>
                            setState(() => streamingSelecionado = v),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // generos
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: vermelho,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Gêneros", style: tituloStyle),
                            CheckboxListTile(
                              title: const Text(
                                "Ação",
                                style: TextStyle(color: Colors.white),
                              ),
                              value: acao,
                              onChanged: (v) => setState(() => acao = v!),
                            ),
                            CheckboxListTile(
                              title: const Text(
                                "Aventura",
                                style: TextStyle(color: Colors.white),
                              ),
                              value: aventura,
                              onChanged: (v) => setState(() => aventura = v!),
                            ),
                            CheckboxListTile(
                              title: const Text(
                                "Comédia",
                                style: TextStyle(color: Colors.white),
                              ),
                              value: comedia,
                              onChanged: (v) => setState(() => comedia = v!),
                            ),
                            CheckboxListTile(
                              title: const Text(
                                "Drama",
                                style: TextStyle(color: Colors.white),
                              ),
                              value: drama,
                              onChanged: (v) => setState(() => drama = v!),
                            ),
                            CheckboxListTile(
                              title: const Text(
                                "Romance",
                                style: TextStyle(color: Colors.white),
                              ),
                              value: romance,
                              onChanged: (v) => setState(() => romance = v!),
                            ),
                            CheckboxListTile(
                              title: const Text(
                                "Terror",
                                style: TextStyle(color: Colors.white),
                              ),
                              value: terror,
                              onChanged: (v) => setState(() => terror = v!),
                            ),
                            CheckboxListTile(
                              title: const Text(
                                "Ficção Científica",
                                style: TextStyle(color: Colors.white),
                              ),
                              value: scifi,
                              onChanged: (v) => setState(() => scifi = v!),
                            ),
                            CheckboxListTile(
                              title: const Text(
                                "Fantasia",
                                style: TextStyle(color: Colors.white),
                              ),
                              value: fantasia,
                              onChanged: (v) => setState(() => fantasia = v!),
                            ),
                            CheckboxListTile(
                              title: const Text(
                                "Animação",
                                style: TextStyle(color: Colors.white),
                              ),
                              value: animacao,
                              onChanged: (v) => setState(() => animacao = v!),
                            ),
                            CheckboxListTile(
                              title: const Text(
                                "Documentário",
                                style: TextStyle(color: Colors.white),
                              ),
                              value: documentario,
                              onChanged: (v) =>
                                  setState(() => documentario = v!),
                            ),
                            CheckboxListTile(
                              title: const Text(
                                "Mistério",
                                style: TextStyle(color: Colors.white),
                              ),
                              value: misterio,
                              onChanged: (v) => setState(() => misterio = v!),
                            ),
                            CheckboxListTile(
                              title: const Text(
                                "Musical",
                                style: TextStyle(color: Colors.white),
                              ),
                              value: musical,
                              onChanged: (v) => setState(() => musical = v!),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // nacionalidade
                      Text("Nacionalidade", style: tituloStyle),
                      const SizedBox(height: 10),

                      GestureDetector(
                        onTap: selecionarPais,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            paisSelecionado ?? "Selecionar país",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      //faixa etaria
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: vermelho,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Classificação indicativa",
                              style: tituloStyle,
                            ),

                            RadioListTile(
                              title: const Text(
                                "Livre",
                                style: TextStyle(color: Colors.white),
                              ),
                              value: "L",
                              groupValue: classificacaoSelecionada,
                              onChanged: (v) =>
                                  setState(() => classificacaoSelecionada = v),
                            ),
                            RadioListTile(
                              title: const Text(
                                "10 - Não recomendável para menores de 10 anos",
                                style: TextStyle(color: Colors.white),
                              ),
                              value: "10",
                              groupValue: classificacaoSelecionada,
                              onChanged: (v) =>
                                  setState(() => classificacaoSelecionada = v),
                            ),
                            RadioListTile(
                              title: const Text(
                                "12 - Não recomendável para menores de 12 anos",
                                style: TextStyle(color: Colors.white),
                              ),
                              value: "12",
                              groupValue: classificacaoSelecionada,
                              onChanged: (v) =>
                                  setState(() => classificacaoSelecionada = v),
                            ),
                            RadioListTile(
                              title: const Text(
                                "14 - Não recomendável para menores de 14 anos",
                                style: TextStyle(color: Colors.white),
                              ),
                              value: "14",
                              groupValue: classificacaoSelecionada,
                              onChanged: (v) =>
                                  setState(() => classificacaoSelecionada = v),
                            ),
                            RadioListTile(
                              title: const Text(
                                "16 - Não recomendável para menores de 16 anos",
                                style: TextStyle(color: Colors.white),
                              ),
                              value: "16",
                              groupValue: classificacaoSelecionada,
                              onChanged: (v) =>
                                  setState(() => classificacaoSelecionada = v),
                            ),
                            RadioListTile(
                              title: const Text(
                                "18+",
                                style: TextStyle(color: Colors.white),
                              ),
                              value: "18",
                              groupValue: classificacaoSelecionada,
                              onChanged: (v) =>
                                  setState(() => classificacaoSelecionada = v),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // atores
                      Text("Atoe, Atriz ou Diretor", style: tituloStyle),
                      const SizedBox(height: 10),

                      TextFormField(
                        controller: fController,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintText:
                              "Ator, Atriz ou Diretor(a) que gostaria de ver",
                          hintStyle: const TextStyle(color: Colors.black54),
                          filled: true,
                          fillColor: Colors.grey,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // limpa envia
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Botao(
                            text: 'Enviar',
                            onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SugestaoFilmes(),
                              ),
                            );
                          },
                        ),
                          Botao(text: "Limpar", onPressed: limpar),
                        ],
                      ),

                      const SizedBox(height: 40),

                      MenuWidget(
                        onHome: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Home(),
                            ),
                          );
                        },
                        onForm: () {},
                        onMapa: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Mapa(),
                            ),
                          );
                        },
                        onConta: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Conta(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
