import 'dart:async';
import 'package:flutter/material.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../gestione_mappa/pages/visualizzazione_mappa.dart';

class SegnalazioneVelocePage extends StatefulWidget {
  const SegnalazioneVelocePage({super.key});

  @override
  State<SegnalazioneVelocePage> createState() => _SegnalazioneVelocePageState();
}

class _SegnalazioneVelocePageState extends State<SegnalazioneVelocePage> {
  double _previousVolume = 0.5;
  DateTime? _lastPressTime;
  String _lastDirection = "NONE";
  final int _comboTimeoutMs = 1500; // Tempo massimo combo in ms

  @override
  void initState() {
    super.initState();

    // Imposta volume iniziale al 50%
    VolumeController.instance.setVolume(0.5);

    // Listener volume
    VolumeController.instance.addListener((volume) {
      _analyzeSequence(volume);
    }, fetchInitialVolume: true);
  }

  void _analyzeSequence(double newVolume) async {
    final now = DateTime.now();
    String currentDirection;
    if (newVolume > _previousVolume) {
      currentDirection = "UP";
    } else if (newVolume < _previousVolume) {
      currentDirection = "DOWN";
    } else {
      return;
    }
    _previousVolume = newVolume;

    if (_lastDirection != "NONE" && _lastPressTime != null) {
      final diff = now.difference(_lastPressTime!).inMilliseconds;
      if (diff < _comboTimeoutMs && _lastDirection != currentDirection) {
        await _inviaSegnalazione();
        _resetCombo();
        return;
      }
    }
    _lastDirection = currentDirection;
    _lastPressTime = now;
  }

  void _resetCombo() {
    _lastDirection = "NONE";
    _lastPressTime = null;
  }

  @override
  void dispose() {
    VolumeController.instance.removeListener();
    super.dispose();
  }

  Future<LatLng> _getPosizione() async {
    final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    return LatLng(pos.latitude, pos.longitude);
  }

  Future<void> _inviaSegnalazione() async {
    final posizione = await _getPosizione();
    MappaPage.globalKey.currentState?.aggiungiMarker(posizione);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📍 Segnalazione piazzata!'),
        backgroundColor: Colors.green,
        duration: Duration(milliseconds: 1500),
      ),
    );
  }

  // Pulsante di test combinazione (solo per debug su emulator)
  void _testCombo() {
    _analyzeSequence(_previousVolume + 0.1); // simula volume UP
    Future.delayed(const Duration(milliseconds: 200), () {
      _analyzeSequence(_previousVolume - 0.1); // simula volume DOWN
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Mappa senza const, altrimenti errore
          MappaPage(key: MappaPage.globalKey),

          // Overlay con pulsanti
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: Offset(0, -4),
                  )
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "SEGNALAZIONE VELOCE",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Premi i tasti fisici in sequenza (Su-Giù)\nper confermare senza guardare.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 25),

                  // Pulsante ANNULLA
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      "Annulla segnalazione",
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Pulsante CONFERMA MANUALE
                  ElevatedButton(
                    onPressed: _inviaSegnalazione,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      "Conferma",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Pulsante TEST combo per emulator
                  ElevatedButton(
                    onPressed: _testCombo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      "TEST COMBO (Emulatore)",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
