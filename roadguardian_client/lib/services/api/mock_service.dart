import 'package:roadguardian_client/features/gestione_profilo_utente/models/user.dart';




List<Map<String, dynamic>> mockUsers = [
  {
    "name": "Mario Rossi",
    "email": "mario.rossi@example.com",
    "password": "123456"
  }
];

// Simula la registrazione di un utente
Future<User> registerUser(String name, String email, String password) async {
  await Future.delayed(const Duration(seconds: 1));

  final newUser = User(name: name, email: email, password: password);

  mockUsers.add(newUser.toJson());

  return newUser;
}

// Simula il fetch di tutti gli utenti
Future<List<User>> fetchUsers() async {
  await Future.delayed(const Duration(seconds: 1));
  return mockUsers.map((e) => User.fromJson(e)).toList();
}
