import '../../features/gestione_profilo_utente/models/user_model.dart';

class MockProfileService {
  static final MockProfileService _instance = MockProfileService._internal();
  factory MockProfileService() => _instance;
  MockProfileService._internal();

  final List<UserModel> _users = [];

  UserModel? currentUser;

  void registerUser(UserModel user) {
    _users.add(user);
  }

  Future<UserModel?> fetchUserByEmailAndPassword(
    String email,
    String password,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return _users.firstWhere(
        (u) => u.email == email && u.password == password,
      );
    } catch (_) {
      return null;
    }
  }

  Future<UserModel?> fetchUserByEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return _users.firstWhere((u) => u.email == email);
    } catch (_) {
      return null;
    }
  }

  void deleteUser(UserModel user) {
    _users.removeWhere((u) => u.id == user.id);
    if (currentUser?.id == user.id) {
      currentUser = null;
    }
  }

  void addDefaultUser() {
    if (_users.isEmpty) {
      _users.add(
        UserModel(
          id: "1",
          nome: "Mario",
          cognome: "Rossi",
          email: "mario.rossi@studenti.unisa.it",
          password: "passwordSegreta123",
          numeroTelefono: "+39 333 1234567",
        ),
      );
    }
  }

  void clearAllUsers() {
    _users.clear();
    currentUser = null;
  }

  List<UserModel> getAllUsers() => List.unmodifiable(_users);
}
