import '../../features/gestione_profilo_utente/models/user_model.dart';

class MockProfileService {
  // Singleton
  static final MockProfileService _instance = MockProfileService._internal();
  factory MockProfileService() => _instance;
  MockProfileService._internal();

  // Lista interna utenti
  final List<UserModel> _users = [];

  // Aggiunge un utente (registrazione)
  void registerUser(UserModel user) {
    _users.add(user);
  }

  // Recupera utente per email e password (login)
  Future<UserModel?> fetchUserByEmailAndPassword(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simula rete lenta
    try {
      return _users.firstWhere((u) => u.email == email && u.password == password);
    } catch (_) {
      return null; // Non trovato
    }
  }

  // Recupera utente solo per email
  Future<UserModel?> fetchUserByEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return _users.firstWhere((u) => u.email == email);
    } catch (_) {
      return null; // Non trovato
    }
  }

  // Cancella un utente (per cancellazione account)
  void deleteUser(UserModel user) {
    _users.removeWhere((u) => u.id == user.id);
  }

  // Aggiunge utente di default se la lista è vuota
  void addDefaultUser() {
    if (_users.isEmpty) {
      _users.add(UserModel(
        id: "1",
        nome: "Mario",
        cognome: "Rossi",
        email: "mario.rossi@studenti.unisa.it",
        password: "passwordSegreta123",
        numeroTelefono: "+39 333 1234567",
      ));
    }
  }

  // Restituisce la lista di utenti (solo per debug)
  List<UserModel> getAllUsers() => _users;
}
