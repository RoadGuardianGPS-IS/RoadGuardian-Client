import 'package:roadguardian_client/features/gestione_profilo_utente/models/user_model.dart';

// MOCK LIST D'USO INTERNO
List<Map<String, dynamic>> mockUsers = [
  {
    "id": "1",
    "nome": "Mario",
    "cognome": "Rossi",
    "email": "mario.rossi@example.com",
    "password": "123456",
    "telefono": "+39 333 1234567",
  }
];

// 🔵 Funzione per registrare un nuovo utente (mock)
Future<UserModel> registerUser(
  String fullName,
  String email,
  String password, {
  String? phone,
}) async {
  await Future.delayed(const Duration(seconds: 1));

  // separo nome e cognome
  final parts = fullName.trim().split(" ");
  final nome = parts.isNotEmpty ? parts.first : "";
  final cognome = parts.length > 1 ? parts.sublist(1).join(" ") : "";

  final newUser = UserModel(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    nome: nome,
    cognome: cognome,
    email: email,
    password: password,
    numeroTelefono: phone,
  );

  mockUsers.add(newUser.toJson());

  return newUser;
}

// 🔵 Ottieni tutti gli utenti mock
Future<List<UserModel>> fetchUsers() async {
  await Future.delayed(const Duration(seconds: 1));
  return mockUsers.map((json) => UserModel.fromJson(json)).toList();
}

// 🔵 Ultimo utente registrato
Future<UserModel?> getLastRegisteredUser() async {
  await Future.delayed(const Duration(milliseconds: 500));
  if (mockUsers.isEmpty) return null;
  return UserModel.fromJson(mockUsers.last);
}
