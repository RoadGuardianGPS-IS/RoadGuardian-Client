class RegisterInput {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String? numTel; // <-- numero telefono opzionale

  RegisterInput({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    this.numTel,
  });

  Map<String, dynamic> toJson() {
    return {
      "first_name": firstName,
      "last_name": lastName,
      "email": email,
      "password": password,
      if (numTel != null && numTel!.isNotEmpty) "num_tel": numTel,
    };
  }
}
