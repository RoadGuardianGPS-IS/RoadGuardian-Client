import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';

import 'package:roadguardian_client/features/gestione_mappa/models/segnalazione_model.dart';
import 'package:roadguardian_client/services/api/mock_segnalazione_service.dart';
import 'package:roadguardian_client/features/gestione_mappa/pages/dettaglio_segnalazione_page.dart';
import '../../gestione_profilo_utente/pages/login_page.dart';

class MappaPage extends StatefulWidget {
  const MappaPage({super.key});

  static final GlobalKey<_MappaPageState> globalKey = GlobalKey<_MappaPageState>();

  @override
  State<MappaPage> createState() => _MappaPageState();
}

class _MappaPageState extends State<MappaPage> {
  final LatLng napoliLatLng = LatLng(40.8522, 14.2681);

  late LatLng _posizioneUtente;
  late final MapController _mapController;
  double _currentZoom = 13.0;

  List<SegnalazioneModel> _segnalazioni = [];
  final MockSegnalazioneService _segnalazioneService = MockSegnalazioneService();

  final List<Marker> _extraMarkers = [];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _posizioneUtente = napoliLatLng;
    _caricaSegnalazioni();
  }

  Future<void> _caricaSegnalazioni() async {
    try {
      final tutteLeSegnalazioni = await _segnalazioneService.getSegnalazioniAttive();
      const Distance distanceCalculator = Distance();

      final segnalazioniVicine = tutteLeSegnalazioni.where((segnalazione) {
        final double metri = distanceCalculator.as(
          LengthUnit.Meter,
          napoliLatLng,
          LatLng(segnalazione.latitude, segnalazione.longitude),
        );
        return metri <= 3000;
      }).toList();

      if (mounted) {
        setState(() {
          _segnalazioni = segnalazioniVicine;
        });
      }
    } catch (e) {
      debugPrint("Errore caricamento segnalazioni: $e");
    }
  }

  void _zoomIn() {
    setState(() {
      if (_currentZoom < 18) _currentZoom++;
      _mapController.move(_mapController.center, _currentZoom);
    });
  }

  void _zoomOut() {
    setState(() {
      if (_currentZoom > 5) _currentZoom--;
      _mapController.move(_mapController.center, _currentZoom);
    });
  }

  void _vaiAllaPosizioneUtente() {
    setState(() {
      _posizioneUtente = napoliLatLng;
      _mapController.move(_posizioneUtente, 16);
    });
  }

  void _simulaIncidente() async {
    if (_segnalazioni.isEmpty) return;
    final SegnalazioneModel incidente = _segnalazioni.first;
    final LatLng centroIncidente = LatLng(incidente.latitude, incidente.longitude);

    final double latDiff = centroIncidente.latitude - _posizioneUtente.latitude;
    final double lngDiff = centroIncidente.longitude - _posizioneUtente.longitude;

    const double distanzaPerc = 1.0;
    final double latStep = latDiff * distanzaPerc / 100;
    final double lngStep = lngDiff * distanzaPerc / 100;

    for (int i = 0; i < 100; i++) {
      await Future.delayed(const Duration(milliseconds: 40), () {
        setState(() {
          _posizioneUtente = LatLng(
            _posizioneUtente.latitude + latStep,
            _posizioneUtente.longitude + lngStep,
          );
          _mapController.move(_posizioneUtente, 16);
        });
      });
    }

    if (!mounted) return;
    _mostraPopup(incidente);
  }

  void _mostraPopup(SegnalazioneModel incidente) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Incidente",
      pageBuilder: (context, animation1, animation2) {
        return Align(
          alignment: Alignment.topCenter,
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.only(top: 50, left: 16, right: 16),
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.3 * 255).toInt()),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.warning, color: Colors.red, size: 48),
                  const SizedBox(height: 12),
                  const Text(
                    "Incidente rilevato",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Vuoi visualizzare le linee guida?",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DettaglioSegnalazionePage(
                            segnalazioneId: incidente.id,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    ),
                    child: const Text("Vai alle linee guida"),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.grey),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    ),
                    child: const Text("No"),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation1, animation2, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
              .animate(animation1),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  void aggiungiMarker(LatLng posizione) {
    setState(() {
      _extraMarkers.add(
        Marker(
          point: posizione,
          width: 40,
          height: 40,
          builder: (ctx) => const Icon(Icons.location_on, color: Colors.red, size: 40),
        ),
      );
    });
  }

  // Funzione per test combo sul pulsante emulator
  void testCombo() {
    // Simula aggiunta marker direttamente
    final testPos = LatLng(_posizioneUtente.latitude + 0.0005, _posizioneUtente.longitude + 0.0005);
    aggiungiMarker(testPos);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Segnalazione combo test piazzata!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _posizioneUtente,
              zoom: _currentZoom,
              interactiveFlags: InteractiveFlag.all,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.roadguardian',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _posizioneUtente,
                    width: 60,
                    height: 60,
                    builder: (context) => Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.withAlpha(51),
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              MarkerLayer(
                markers: _segnalazioni.map((s) {
                  return Marker(
                    point: LatLng(s.latitude, s.longitude),
                    width: 100,
                    height: 100,
                    builder: (context) => GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DettaglioSegnalazionePage(
                              segnalazioneId: s.id,
                            ),
                          ),
                        );
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.red.withAlpha((0.2 * 255).toInt()),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.red, width: 2),
                            ),
                          ),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.priority_high,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              MarkerLayer(markers: _extraMarkers),
            ],
          ),
          Positioned(
            bottom: 20,
            right: 10,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'login_page',
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  },
                  backgroundColor: Colors.purple,
                  child: const Icon(Icons.person, size: 28, color: Colors.white),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'posizione_utente',
                  onPressed: _vaiAllaPosizioneUtente,
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.my_location, size: 28, color: Colors.white),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'fake_incidente',
                  onPressed: _simulaIncidente,
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.warning, size: 28, color: Colors.white),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'zoom_in',
                  mini: true,
                  onPressed: _zoomIn,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.add, color: Colors.black),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'zoom_out',
                  mini: true,
                  onPressed: _zoomOut,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.remove, color: Colors.black),
                ),
                const SizedBox(height: 12),
                // BOTTONE TEST COMBO EMULATORE
                FloatingActionButton(
                  heroTag: 'test_combo',
                  mini: false,
                  onPressed: testCombo,
                  backgroundColor: Colors.blueGrey,
                  child: const Icon(Icons.vibration, size: 28, color: Colors.white),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
