class UserModel {
  final String id;
  final String nome;
  final String cognome;
  final String email;
  final String? numeroTelefono;
  final String? fotoProfiloUrl;
  final String? password;

  UserModel({
    required this.id,
    required this.nome,
    required this.cognome,
    required this.email,
    this.numeroTelefono,
    this.fotoProfiloUrl,
    this.password,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      nome: json['nome'] ?? '',
      cognome: json['cognome'] ?? '',
      email: json['email'] ?? '',
      numeroTelefono: json['telefono'],
      fotoProfiloUrl: json['foto_profilo'],
      password: json['password'] ,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'cognome': cognome,
      'email': email,
      'telefono': numeroTelefono,
      'foto_profilo': fotoProfiloUrl,
      'password': password,
    };
  }
}