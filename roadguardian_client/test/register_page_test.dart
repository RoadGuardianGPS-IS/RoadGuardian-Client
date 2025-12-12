import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roadguardian_client/features/gestione_profilo_utente/pages/register_page.dart';
import 'package:roadguardian_client/features/gestione_profilo_utente/pages/area_personale_page.dart';
import 'package:roadguardian_client/services/api/mock_profile_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Flusso registrazione', () {
    testWidgets('Registrazione corretto porta ad AreaPersonalePage', (
      tester,
    ) async {
      // --- Build dell'app con RegisterPage ---
      await tester.pumpWidget(const MaterialApp(home: RegisterPage()));

      // --- Inserimento dati di registrazione ---
      await tester.enterText(find.byKey(const Key('register_nome')), 'Mario');
      await tester.enterText(
        find.byKey(const Key('register_cognome')),
        'Rossi',
      );
      await tester.enterText(
        find.byKey(const Key('register_email')),
        'mario.rossi@test.it',
      );
      await tester.enterText(
        find.byKey(const Key('register_password')),
        'Password123',
      );
      await tester.enterText(
        find.byKey(const Key('register_confirm_password')),
        'Password123',
      );
      await tester.enterText(
        find.byKey(const Key('register_telefono')),
        '3331234567',
      );

      await tester.pumpAndSettle();

      // --- Assicurati che il pulsante REGISTRATI sia visibile e tappabile ---
      final registerButton = find.text('REGISTRATI');
      await tester.ensureVisible(registerButton);
      await tester.tap(registerButton);

      // Attendi la navigazione
      await tester.pumpAndSettle();

      // --- Controlla se siamo su AreaPersonalePage ---
      expect(find.byType(AreaPersonalePage), findsOneWidget);

      // --- Controllo utente registrato ---
      final user = MockProfileService().currentUser;
      expect(user, isNotNull);
      expect(user!.nome, 'Mario');
      expect(user.cognome, 'Rossi');
      expect(user.email, 'mario.rossi@test.it');
    });
  });
}
