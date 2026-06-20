import 'package:flutter/material.dart';
import '../../../service/hiveService.dart';

class FormProvider extends ChangeNotifier {
  FormProvider() {
    carregarDados();
  }

  List<String> generosSelecionados = [];
  List<String> streamingSelecionados = [];
  List<String> paisesSelecionados = [];
  String? duracaoSelecionada;
  String? classificacaoSelecionada;
  String ator = '';

  final hive = HiveService();

  void carregarDados() {
    generosSelecionados = List<String>.from(hive.buscar('generos') ?? []);
    streamingSelecionados = List<String>.from(hive.buscar('streaming') ?? []);
    paisesSelecionados = List<String>.from(hive.buscar('pais') ?? []);
    duracaoSelecionada = hive.buscar('duracao');
    classificacaoSelecionada = hive.buscar('classificacao');
    ator = hive.buscar('ator') ?? '';
    notifyListeners();
  }

  void toggleGenero(String genero) {
    if (generosSelecionados.contains(genero)) {
      generosSelecionados.remove(genero);
    } else {
      generosSelecionados.add(genero);
    }
    hive.salvar('generos', generosSelecionados);
    notifyListeners();
  }

  void toggleStreaming(String streaming) {
    if (streamingSelecionados.contains(streaming)) {
      streamingSelecionados.remove(streaming);
    } else {
      streamingSelecionados.add(streaming);
    }
    hive.salvar('streaming', streamingSelecionados);
    notifyListeners();
  }

  void togglePais(String pais) {
    if (paisesSelecionados.contains(pais)) {
      paisesSelecionados.remove(pais);
    } else {
      paisesSelecionados.add(pais);
    }
    hive.salvar('pais', paisesSelecionados);
    notifyListeners();
  }

  void setDuracao(String? duracao) {
    duracaoSelecionada = duracao;
    hive.salvar('duracao', duracao);
    notifyListeners();
  }

  void setClassificacao(String? classificacao) {
    if (classificacaoSelecionada == classificacao) {
      classificacaoSelecionada = null;
    } else {
      classificacaoSelecionada = classificacao;
    }
    hive.salvar('classificacao', classificacaoSelecionada);
    notifyListeners();
  }

  void setAtor(String valor) {
    ator = valor;
    hive.salvar('ator', ator);
    notifyListeners();
  }

  void limparFormulario() {
    hive.limpar();
    generosSelecionados.clear();
    streamingSelecionados.clear();
    paisesSelecionados.clear();
    duracaoSelecionada = null;
    classificacaoSelecionada = null;
    ator = '';
    notifyListeners();
  }
}
