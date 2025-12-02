import '../../features/gestione_profilo_utente/models/user_model.dart';

class MockProfileService {

  // Dati finti che simulano il Database
  final _mockUserJson = {
    "id": "1",
    "nome": "Mario",
    "cognome": "Rossi",
    "email": "mario.rossi@studenti.unisa.it",
    "telefono": "+39 333 1234567",
    "foto_profilo": null,
    "password": "passwordSegreta123"
  };

  // Funzione che simula la chiamata API con 1 secondo di ritardo
  Future<UserModel> fetchUserProfile() async {
    await Future.delayed(const Duration(seconds: 1)); // Simula rete lenta
    return UserModel.fromJson(_mockUserJson);
  }
}