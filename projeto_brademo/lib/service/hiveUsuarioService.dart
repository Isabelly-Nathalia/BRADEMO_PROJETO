import 'package:hive/hive.dart';
import '../model/usuario.dart';

class HiveUsuarioService {
  final Box box = Hive.box('usuario');

  void salvarUsuario(Usuario usuario) {
    box.put('idUsuario', usuario.idUsuario);
    box.put('nome', usuario.nome);
    box.put('email', usuario.email);
    box.put('nomeUsuario', usuario.nomeUsuario);
    box.put('senha', usuario.senha);
    box.put('fotoPerfil', usuario.fotoPerfil);
    box.put('dataNascimento', usuario.dataNascimento);
  }

  Usuario? buscarUsuario() {
    final id = box.get('idUsuario');
    if (id == null) return null;

    return Usuario(
      idUsuario: id,
      nome: box.get('nome'),
      email: box.get('email'),
      nomeUsuario: box.get('nomeUsuario'),
      senha: box.get('senha'),
      fotoPerfil: box.get('fotoPerfil'),
      dataNascimento: box.get('dataNascimento'),
    );
  }

  void limparUsuario() {
    box.clear();
  }
}