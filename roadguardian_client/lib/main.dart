import 'package:flutter/material.dart';
// import 'features/gestione_profilo_utente/models/user_model.dart'; // RIMOSSO PER BRANCH MAPPA
import 'features/gestione_mappa/pages/visualizzazione_mappa.dart';
// import 'features/gestione_profilo_utente/pages/modifica_profilo_page.dart'; // RIMOSSO PER BRANCH MAPPA
// import 'features/gestione_profilo_utente/pages/area_personale_page.dart'; // RIMOSSO PER BRANCH MAPPA

void main() {
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