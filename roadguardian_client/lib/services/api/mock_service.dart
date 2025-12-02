import 'package:roadguardian_client/features/gestione_profilo_utente/models/user.dart';

// Lista mock di utenti
List<Map<String, dynamic>> mockUsers = [
  {
    "name": "Mario Rossi",
    "email": "mario.rossi@example.com",
    "password": "123456",
    "phone": "+39 333 1234567"
  }
];

// Simula la registrazione di un utente
Future<User> registerUser(String name, String email, String password, {String? phone}) async {
  await Future.delayed(const Duration(seconds: 1));

  final newUser = User(name: name, email: email, password: password, phone: phone ?? "");

  mockUsers.add(newUser.toJson());

  return newUser;
}

// Simula il fetch di tutti gli utenti
Future<List<User>> fetchUsers() async {
  await Future.delayed(const Duration(seconds: 1));
  return mockUsers.map((e) => User.fromJson(e)).toList();
}

// Restituisce l'ultimo utente registrato
Future<User?> getLastRegisteredUser() async {
  await Future.delayed(const Duration(milliseconds: 500));
  if (mockUsers.isEmpty) return null;
  return User.fromJson(mockUsers.last);
}
