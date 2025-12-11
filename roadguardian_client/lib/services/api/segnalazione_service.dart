import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:roadguardian_client/features/gestione_segnalazione/models/segnalazione_model.dart';

class SegnalazioneService {
  final String baseUrl = "http://10.0.2.2:8000"; // indirizzo server

  // Singleton
  static final SegnalazioneService _instance = SegnalazioneService._internal();

  factory SegnalazioneService() {
    return _instance;
  }

  SegnalazioneService._internal();

  // OTTIENI SEGNALAZIONI ATTIVE DAL SERVER
  Future<List<SegnalazioneModel>> getSegnalazioniAttive() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/mappa/segnalazioni/attive'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => SegnalazioneModel.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Errore caricamento segnalazioni: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Errore: $e');
    }
  }

  // OTTIENI DETTAGLI SEGNALAZIONE
  Future<SegnalazioneModel> getDettaglioSegnalazione(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/segnalazione/dettagli/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SegnalazioneModel.fromJson(data);
      } else {
        throw Exception('Errore caricamento segnalazione: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Errore: $e');
    }
  }
}
