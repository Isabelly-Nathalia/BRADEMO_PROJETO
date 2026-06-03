class Usuario {
  final int idUsuario;
  final String nome;
  final String email;
  final String nomeUsuario;
  final String senha;
  final String fotoPerfil;
  final String dataNascimento;

  Usuario({
    required this.idUsuario,
    required this.nome,
    required this.email,
    required this.nomeUsuario,
    required this.senha,
    required this.fotoPerfil,
    required this.dataNascimento,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      idUsuario: json['id_usuario'],
      nome: json['nome_usuario'],
      email: json['email_usuario'],
      nomeUsuario: json['nomeDeUsuario_usuario'],
      senha: json['senha_usuario'],
      fotoPerfil: json['fotoPerfil_usuario'] ?? '',
      dataNascimento: json['dataNascimento_usuario'],
    );
  }
}