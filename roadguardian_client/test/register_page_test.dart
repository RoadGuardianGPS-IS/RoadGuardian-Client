import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';

import 'package:roadguardian_client/services/api/profile_service.dart';
import 'package:roadguardian_client/services/api/register_input.dart';

void main() {
  group('Registrazione ProfiloService', () {
    test('Ritorna UserModel su registrazione riuscita (201)', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, equals('POST'));
        // Return a fake created user JSON
        final body = jsonEncode({
          '_id': 'user123',
          'first_name': 'Mario',
          'last_name': 'Rossi',
          'email': 'mario@example.com',
          'num_tel': '+391234567890'
        });
        return http.Response(body, 201);
      });

      final service = ProfiloService();
      service.setHttpClient(mockClient);

      final result = await service.register(RegisterInput(
        firstName: 'Mario',
        lastName: 'Rossi',
        email: 'mario@example.com',
        password: 'P4ssw0rd!',
        numTel: '+391234567890',
      ));

      expect(result, isNotNull);
      expect(result!.email, equals('mario@example.com'));
      expect(result.nome, equals('Mario'));
      expect(result.cognome, equals('Rossi'));
    });

    test('Email già esistente', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Email già registrata', 400);
      });

      final service = ProfiloService();
      service.setHttpClient(mockClient);

      expect(
        () async => await service.register(RegisterInput(
          firstName: 'Mario',
          lastName: 'Rossi',
          email: 'mario@example.com',
          password: 'P4ssw0rd!',
          numTel: '+391234567890',
        )),
        throwsA(isA<Exception>()),
      );
    });

    test('Mostra messaggio specifico se email già associata', () async {
      final mockClient = MockClient((request) async {
        return http.Response('La email è già associata a un altro account', 400);
      });

      final service = ProfiloService();
      service.setHttpClient(mockClient);

      try {
        await service.register(RegisterInput(
          firstName: 'Luca',
          lastName: 'Bianchi',
          email: 'luca@example.com',
          password: 'P4ssw0rd!',
          numTel: '+391234567891',
        ));
        fail('Expected exception not thrown');
      } catch (e) {
        final msg = e.toString();
        expect(msg, contains('La email è già associata a un altro account'));
      }
    });

    test('Password non coincidono', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Le password non coincidono', 400);
      });

      final service = ProfiloService();
      service.setHttpClient(mockClient);

      try {
        await service.register(RegisterInput(
          firstName: 'Anna',
          lastName: 'Verdi',
          email: 'anna@example.com',
          password: 'Password1!',
          numTel: '+391234567892',
        ));
        fail('Expected exception not thrown');
      } catch (e) {
        final msg = e.toString();
        expect(msg, contains('Le password non coincidono'));
      }
    });

    test('Password non contiene tutti i dati obbligatori', () async {
      final mockClient = MockClient((request) async {
        return http.Response('La password non contiene i caratteri obbligatori', 400);
      });

      final service = ProfiloService();
      service.setHttpClient(mockClient);

      try {
        await service.register(RegisterInput(
          firstName: 'Marco',
          lastName: 'Neri',
          email: 'marco@example.com',
          password: 'password',
          numTel: '+391234567893',
        ));
        fail('Expected exception not thrown');
      } catch (e) {
        final msg = e.toString();
        expect(msg, contains('La password non contiene i caratteri obbligatori'));
      }
    });

    test('La lunghezza del numero del telefono è errata', () async {
      final mockClient = MockClient((request) async {
        return http.Response('La lunghezza del numero del telefono è errata', 400);
      });

      final service = ProfiloService();
      service.setHttpClient(mockClient);

      try {
        await service.register(RegisterInput(
          firstName: 'Giovanni',
          lastName: 'Rossi',
          email: 'giovanni@example.com',
          password: 'P4ssw0rd!',
          numTel: '+3936621893945',
        ));
        fail('Expected exception not thrown');
      } catch (e) {
        final msg = e.toString();
        expect(msg, contains('La lunghezza del numero del telefono è errata'));
      }
    });
  });
}
