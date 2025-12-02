import 'package:flutter/material.dart';
// IMPORTANTE: Assicurati che questo percorso corrisponda a dove hai salvato il file.
// Se hai usato una cartella diversa, PyCharm te lo segnerà in rosso: cliccaci sopra e premi Option+Enter (o Alt+Enter) per correggere l'import.
import 'features/gestione_profilo_utente/pages/area_personale_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RoadGuardian Test',
      debugShowCheckedModeBanner: false, // Rimuove la scritta "DEBUG" in alto a destra
      theme: ThemeData(
        // Impostiamo il tema base per assomigliare a quello del progetto
        primarySwatch: Colors.blue,
        useMaterial3: true,
        // Colore di sfondo generale dell'app (coerente con le tue pagine)
        scaffoldBackgroundColor: const Color(0xFFF0F0F0),
      ),
      // Qui diciamo all'app: "Appena parti, mostra l'Area Personale"
      home: const AreaPersonalePage(),
    );
  }
}