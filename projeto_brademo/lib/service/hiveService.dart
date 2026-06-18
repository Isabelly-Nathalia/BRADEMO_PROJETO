import 'package:hive/hive.dart';

class HiveService {
  final Box box = Hive.box('formulario');

  void salvar(String chave, dynamic valor) {
    box.put(chave, valor);
  }

  dynamic buscar(String chave) {
    return box.get(chave);
  }

  void limpar() {
    box.clear();
  }
}