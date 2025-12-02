class User {
  final String name;
  final String email;
  final String password;
  final String? phone; // nuovo campo opzionale per il numero di telefono

  User({
    required this.name,
    required this.email,
    required this.password,
    this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      email: json['email'],
      password: json['password'],
      phone: json['phone'], // recupera il numero di telefono se presente
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'phone': phone ?? "", // salva phone, default a stringa vuota
    };
  }
}
