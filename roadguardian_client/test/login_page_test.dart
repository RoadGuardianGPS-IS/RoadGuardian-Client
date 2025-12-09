import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roadguardian_client/features/gestione_profilo_utente/pages/register_page.dart';
import 'package:roadguardian_client/features/gestione_profilo_utente/pages/area_personale_page.dart';
import 'package:roadguardian_client/features/gestione_profilo_utente/pages/modifica_profilo_page.dart';
import 'package:roadguardian_client/services/api/mock_profile_service.dart';

void main() {
  testWidgets('Registrazione automatica apre AreaPersonalePage e ModificaProfiloPage',
      (WidgetTester tester) async {
    // Reset dello stato del Mock
    MockProfileService().currentUser = null;

    await tester.pumpWidget(
      const MaterialApp(home: RegisterPage()),
    );

    // Inserisci dati nella form
    await tester.enterText(find.byKey(const Key('register_nome')), 'Luca');
    await tester.enterText(find.byKey(const Key('register_cognome')), 'Bianchi');
    await tester.enterText(find.byKey(const Key('register_email')), 'luca.bianchi@test.com');
    await tester.enterText(find.byKey(const Key('register_telefono')), '3331234567');
    await tester.enterText(find.byKey(const Key('register_password')), 'Password123');
    await tester.enterText(find.byKey(const Key('register_confirm_password')), 'Password123');

    // Premi REGISTRATI
    await tester.tap(find.text('REGISTRATI'));
    await tester.pumpAndSettle();

    // Verifica che siamo su AreaPersonalePage
    expect(find.byType(AreaPersonalePage), findsOneWidget);

    // Apri ModificaProfiloPage cliccando sul primo ListTile
    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();

    // Verifica che siamo su ModificaProfiloPage
    expect(find.byType(ModificaProfiloPage), findsOneWidget);

    // Controlla che i campi siano correttamente popolati
    expect(find.widgetWithText(TextField, 'Luca'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Bianchi'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'luca.bianchi@test.com'), findsOneWidget);
    expect(find.widgetWithText(TextField, '3331234567'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Password123'), findsOneWidget);
  });
}
