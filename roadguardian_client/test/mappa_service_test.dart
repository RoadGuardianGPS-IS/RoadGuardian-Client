import 'package:flutter_test/flutter_test.dart';
import 'package:roadguardian_client/services/api/mappa_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';

void main() {
  group('MappaService - Aggiornamento Posizione', () {
    late MappaService mappaService;

    setUp(() {
      mappaService = MappaService();
    });

    test('updateUserPosition invia correttamente i dati al server', () async {
      // Arrange: Mock HTTP client
      final mockClient = MockClient((request) async {
        // Verifica che la richiesta sia corretta
        expect(request.url.toString(), contains('/mappa/posizione'));
        expect(request.method, 'POST');
        expect(
          request.headers['Content-Type'],
          contains('application/json'),
        );

        // Verifica il payload
        final body = jsonDecode(request.body);
        expect(body['latitudine'], 40.8522);
        expect(body['longitudine'], 14.2681);
        expect(body['fcm_token'], 'test_token_123');

        // Simula risposta del server
        return http.Response('{"message": "Posizione aggiornata"}', 200);
      });

      mappaService.setHttpClient(mockClient);

      // Act: Invia posizione
      final result = await mappaService.updateUserPosition(
        latitude: 40.8522,
        longitude: 14.2681,
        fcmToken: 'test_token_123',
      );

      // Assert: Verifica risultato
      expect(result, true);
    });

    test('updateUserPosition gestisce errori del server', () async {
      // Arrange: Mock HTTP client con errore
      final mockClient = MockClient((request) async {
        return http.Response('{"error": "Server error"}', 500);
      });

      mappaService.setHttpClient(mockClient);

      // Act: Invia posizione
      final result = await mappaService.updateUserPosition(
        latitude: 40.8522,
        longitude: 14.2681,
        fcmToken: 'test_token_123',
      );

      // Assert: Verifica che ritorni false
      expect(result, false);
    });

    test('updateUserPosition funziona anche senza token FCM', () async {
      // Arrange: Mock HTTP client
      final mockClient = MockClient((request) async {
        final body = jsonDecode(request.body);
        // Verifica che fcm_token non sia presente
        expect(body.containsKey('fcm_token'), false);
        expect(body['latitudine'], 40.8522);
        expect(body['longitudine'], 14.2681);

        return http.Response('{"message": "Posizione aggiornata"}', 200);
      });

      mappaService.setHttpClient(mockClient);

      // Act: Invia posizione senza token
      final result = await mappaService.updateUserPosition(
        latitude: 40.8522,
        longitude: 14.2681,
        fcmToken: null,
      );

      // Assert: Verifica risultato
      expect(result, true);
    });
  });

  group('MappaService - Segnalazioni', () {
    late MappaService mappaService;

    setUp(() {
      mappaService = MappaService();
    });

    test('getSegnalazioniAttive ritorna lista corretta', () async {
      // Arrange: Mock HTTP client
      final mockClient = MockClient((request) async {
        expect(request.url.toString(), contains('/mappa/segnalazioni/attive'));
        expect(request.method, 'GET');

        return http.Response(
          jsonEncode([
            {
              '_id': '1',
              'category': 'incidente',
              'seriousness': 'high',
              'incident_latitude': 40.8522,
              'incident_longitude': 14.2681,
            },
            {
              '_id': '2',
              'category': 'tamponamento',
              'seriousness': 'medium',
              'incident_latitude': 40.8530,
              'incident_longitude': 14.2690,
            },
          ]),
          200,
        );
      });

      mappaService.setHttpClient(mockClient);

      // Act: Ottieni segnalazioni
      final result = await mappaService.getSegnalazioniAttive();

      // Assert: Verifica risultato
      expect(result.length, 2);
      expect(result[0]['_id'], '1');
      expect(result[0]['category'], 'incidente');
      expect(result[1]['_id'], '2');
    });

    test('getSegnalazioniFiltrate invia correttamente i parametri', () async {
      // Arrange: Mock HTTP client
      final mockClient = MockClient((request) async {
        expect(
          request.url.toString(),
          contains('/mappa/segnalazioni/filtrate'),
        );
        expect(request.url.toString(), contains('tipi_incidente=incidente'));
        expect(request.url.toString(), contains('tipi_incidente=tamponamento'));

        return http.Response(jsonEncode([]), 200);
      });

      mappaService.setHttpClient(mockClient);

      // Act: Ottieni segnalazioni filtrate
      final result = await mappaService.getSegnalazioniFiltrate(
        ['incidente', 'tamponamento'],
      );

      // Assert: Verifica risultato
      expect(result, isA<List>());
    });
  });
}
