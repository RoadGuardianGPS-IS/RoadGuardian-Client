class UserModel {
  final String id;
  final String nome;
  final String cognome;
  final String email;
  final String? numeroTelefono;
  final String? password;

  UserModel({
    required this.id,
    required this.nome,
    required this.cognome,
    required this.email,
    this.numeroTelefono,
    this.password,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      nome: json['first_name'] ?? '',
      cognome: json['last_name'] ?? '',
      email: json['email'] ?? '',
      numeroTelefono: json['num_tel'],
      password: json['password'], // probabilmente null dal server
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': nome,
      'last_name': cognome,
      'email': email,
      'num_tel': numeroTelefono,
      'password': password,
    };
  }
}
