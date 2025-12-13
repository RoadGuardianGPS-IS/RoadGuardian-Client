import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// import 'features/gestione_profilo_utente/models/user_model.dart'; // RIMOSSO PER BRANCH MAPPA
import 'features/gestione_mappa/pages/visualizzazione_mappa.dart';
import 'services/api/notification_service.dart';
// import 'features/gestione_profilo_utente/pages/modifica_profilo_page.dart'; // RIMOSSO PER BRANCH MAPPA
// import 'features/gestione_profilo_utente/pages/area_personale_page.dart'; // RIMOSSO PER BRANCH MAPPA

/// Handler per notifiche in background (deve essere top-level)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('📬 Notifica ricevuta in background: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Inizializza Firebase
    await Firebase.initializeApp();
    debugPrint('🔥 Firebase inizializzato');
    
    // Registra l'handler per le notifiche in background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint('❌ Errore inizializzazione Firebase: $e');
    debugPrint('⚠️ Assicurati di aver configurato google-services.json');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Utente di default rimosso perché UserModel non esiste in questo branch

    return MaterialApp(
      title: 'RoadGuardian',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // Apri direttamente la mappa all'avvio
      home: const MappaPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
