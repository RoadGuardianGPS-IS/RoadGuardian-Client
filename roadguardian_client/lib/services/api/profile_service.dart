import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:roadguardian_client/features/gestione_profilo_utente/models/user_model.dart';
import 'package:roadguardian_client/services/login_input.dart';
import 'package:roadguardian_client/services/api/register_input.dart';

class ProfiloService {
  final String baseUrl = "http://10.0.2.2:8000"; // indirizzo server
  UserModel? currentUser;

  http.Client _httpClient = http.Client();

  static final ProfiloService _instance = ProfiloService._internal();

  factory ProfiloService() {
    return _instance;
  }

  ProfiloService._internal();

  void setHttpClient(http.Client client) {
    _httpClient = client;
  }

  Future<UserModel?> login(LoginInput input) async {
    final response = await _httpClient.post(
      Uri.parse('$baseUrl/profilo/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(input.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      currentUser = UserModel.fromJson(data);
      return currentUser;
    } else if (response.statusCode == 401) {
      return null;
    } else {
      throw Exception("Errore login: ${response.statusCode}");
    }
  }

  Future<UserModel?> register(RegisterInput input) async {
    final response = await _httpClient.post(
      Uri.parse('$baseUrl/profilo/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'first_name': input.firstName,
        'last_name': input.lastName,
        'email': input.email,
        'password': input.password,
        'num_tel': input.numTel,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      currentUser = UserModel.fromJson(data);
      return currentUser;
    } else {
      throw Exception("Errore registrazione: ${response.body}");
    }
  }

  Future<void> deleteUser(String userId, String email, String password) async {
    final response = await _httpClient.post(
      Uri.parse('$baseUrl/profilo/delete/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      currentUser = null;
    } else if (response.statusCode == 401) {
      throw Exception('Password errata');
    } else if (response.statusCode == 404) {
      throw Exception('Utente non trovato');
    } else {
      throw Exception('Errore cancellazione account: ${response.body}');
    }
  }

  Future<UserModel?> updateUser(UserModel user) async {
    final Map<String, dynamic> body = {};

    if (user.nome.isNotEmpty) body['first_name'] = user.nome;
    if (user.cognome.isNotEmpty) body['last_name'] = user.cognome;
    if (user.numeroTelefono != null) body['num_tel'] = user.numeroTelefono;
    if (user.password != null && user.password!.isNotEmpty) {
      body['password'] = user.password;
    }

    final response = await _httpClient.put(
      Uri.parse('$baseUrl/profilo/${user.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      currentUser = UserModel.fromJson(data);
      return currentUser;
    } else {
      throw Exception('Errore aggiornamento profilo: ${response.statusCode}');
    }
  }
}
