import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

/// Servizio per gestire l'invio della posizione al server
class MappaService {
  static final MappaService _instance = MappaService._internal();
  factory MappaService() => _instance;
  MappaService._internal();

  final String baseUrl = "http://10.0.2.2:8000"; // Indirizzo server per emulatore Android
  http.Client _httpClient = http.Client();

  /// Permette di iniettare un client HTTP per i test
  void setHttpClient(http.Client client) {
    _httpClient = client;
  }

  /// Invia la posizione dell'utente al server
  /// Il server controllerà se ci sono segnalazioni nel raggio di 3km
  /// e invierà notifiche push se necessario
  Future<bool> updateUserPosition({
    required double latitude,
    required double longitude,
    String? fcmToken,
  }) async {
    try {
      final payload = {
        'latitudine': latitude,
        'longitudine': longitude,
        if (fcmToken != null) 'fcm_token': fcmToken,
      };

      debugPrint('📍 Invio posizione al server: lat=$latitude, lon=$longitude');

      final response = await _httpClient.post(
        Uri.parse('$baseUrl/mappa/posizione'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Posizione aggiornata con successo');
        return true;
      } else {
        debugPrint(
          '❌ Errore aggiornamento posizione: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('❌ Errore connessione server: $e');
      return false;
    }
  }

  /// Ottiene tutte le segnalazioni attive dal server
  Future<List<dynamic>> getSegnalazioniAttive() async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/mappa/segnalazioni/attive'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data;
      } else {
        debugPrint(
          '❌ Errore caricamento segnalazioni: ${response.statusCode}',
        );
        return [];
      }
    } catch (e) {
      debugPrint('❌ Errore: $e');
      return [];
    }
  }

  /// Ottiene le segnalazioni filtrate per categoria
  Future<List<dynamic>> getSegnalazioniFiltrate(
    List<String> tipiIncidente,
  ) async {
    try {
      // Costruisci i query params
      final queryParams =
          tipiIncidente.map((tipo) => 'tipi_incidente=$tipo').join('&');

      final response = await _httpClient.get(
        Uri.parse('$baseUrl/mappa/segnalazioni/filtrate?$queryParams'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data;
      } else {
        debugPrint(
          '❌ Errore caricamento segnalazioni filtrate: ${response.statusCode}',
        );
        return [];
      }
    } catch (e) {
      debugPrint('❌ Errore: $e');
      return [];
    }
  }
}
