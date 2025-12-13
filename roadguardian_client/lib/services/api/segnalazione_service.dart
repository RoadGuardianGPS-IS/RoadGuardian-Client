import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:roadguardian_client/features/gestione_segnalazione/models/segnalazione_model.dart';

class SegnalazioneService {
  final String baseUrl = "http://10.0.2.2:8000"; // indirizzo server

  static final SegnalazioneService _instance = SegnalazioneService._internal();

  factory SegnalazioneService() {
    return _instance;
  }

  SegnalazioneService._internal();

  Future<List<SegnalazioneModel>> getSegnalazioniAttive() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/mappa/segnalazioni/attive'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map(
              (json) =>
                  SegnalazioneModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      } else {
        throw Exception(
          'Errore caricamento segnalazioni: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Errore: $e');
    }
  }

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
        throw Exception(
          'Errore caricamento segnalazione: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Errore: $e');
    }
  }

  Future<bool> createSegnalazione(
    String userId,
    double latitude,
    double longitude, {
    String seriousness = 'high',
    String category = 'incidente stradale',
    String? description,
  }) async {
    try {
      final now = DateTime.now();
      final dateFormat = now.toIso8601String().split('T')[0]; // YYYY-MM-DD
      final timeFormat =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

      final payload = {
        'incident_date': dateFormat,
        'incident_time': timeFormat,
        'incident_longitude': longitude,
        'incident_latitude': latitude,
        'seriousness': seriousness,
        'category': category,
        'description': description,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/segnalazione/creasegnalazione/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      return response.statusCode == 201;
    } catch (e) {
      throw Exception('Errore creazione segnalazione: $e');
    }
  }
}
