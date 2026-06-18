import 'package:flutter/material.dart';

class FormProvider extends ChangeNotifier {
  List<String> generosSelecionados = [];
  List<String> streamingSelecionados = [];
  List<String> paisesSelecionados = [];

  String? duracaoSelecionada;
  String? classificacaoSelecionada;

  String ator = '';

  void toggleGenero(String genero) {
    if (generosSelecionados.contains(genero)) {
      generosSelecionados.remove(genero);
    } else {
      generosSelecionados.add(genero);
    }
    notifyListeners();
  }

  void toggleStreaming(String streaming) {
    if (streamingSelecionados.contains(streaming)) {
      streamingSelecionados.remove(streaming);
    } else {
      streamingSelecionados.add(streaming);
    }
    notifyListeners();
  }

  void togglePais(String pais) {
    if (paisesSelecionados.contains(pais)) {
      paisesSelecionados.remove(pais);
    } else {
      paisesSelecionados.add(pais);
    }
    notifyListeners();
  }

  void setDuracao(String? duracao) {
    duracaoSelecionada = duracao;
    notifyListeners();
  }

  void setClassificacao(String? classificacao) {
    classificacaoSelecionada = classificacao;
    notifyListeners();
  }

  void setAtor(String valor) {
    ator = valor;
    notifyListeners();
  }

  void limparFormulario() {
    generosSelecionados.clear();
    streamingSelecionados.clear();
    paisesSelecionados.clear();

    duracaoSelecionada = null;
    classificacaoSelecionada = null;
    ator = '';

    notifyListeners();
  }
}