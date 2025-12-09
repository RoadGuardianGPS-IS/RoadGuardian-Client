import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';

import '../../gestione_profilo_utente/pages/login_page.dart';
import '../../gestione_segnalazione/pages/segnalazione_manuale_page.dart';
import '../../gestione_segnalazione/pages/dettaglio_segnalazione_page.dart';
import '../../gestione_segnalazione/models/segnalazione_model.dart';
import 'package:roadguardian_client/services/api/mock_segnalazione_service.dart';

class MappaPage extends StatefulWidget {
  const MappaPage({super.key});

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

  bool _showSegnalazioneVeloce = false;

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

      final segnalazioniVicine = tutteLeSegnalazioni.where((s) {
        final double metri = distanceCalculator.as(
          LengthUnit.Meter,
          napoliLatLng,
          LatLng(s.latitude, s.longitude),
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

  void _vaiASegnalazioneManuale() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SegnalazioneManualePage(
          latitude: _posizioneUtente.latitude,
          longitude: _posizioneUtente.longitude,
        ),
      ),
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

  void _toggleSegnalazioneVeloce() {
    setState(() {
      _showSegnalazioneVeloce = !_showSegnalazioneVeloce;
    });
  }

  void _confermaSegnalazioneVeloce() {
    aggiungiMarker(_posizioneUtente);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📍 Segnalazione piazzata!'),
        backgroundColor: Colors.green,
        duration: Duration(milliseconds: 1500),
      ),
    );
    _toggleSegnalazioneVeloce();
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
        if (mounted) {
          setState(() {
            _posizioneUtente = LatLng(
              _posizioneUtente.latitude + latStep,
              _posizioneUtente.longitude + lngStep,
            );
            _mapController.move(_posizioneUtente, 16);
          });
        }
      });
    }

    if (!mounted) return;
    // Qui puoi richiamare eventuale popup incidente
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Mappa sotto
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
          // Overlay Segnalazione Veloce
          if (_showSegnalazioneVeloce)
            Positioned(
              top: 50,
              left: 16,
              right: 16,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(80),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "SEGNALAZIONE VELOCE",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _confermaSegnalazioneVeloce,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: const Size(double.infinity, 40),
                        ),
                        child: const Text("Conferma"),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: _toggleSegnalazioneVeloce,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 40),
                        ),
                        child: const Text("Annulla"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // Pulsanti floating
          Positioned(
            bottom: 20,
            right: 10,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'login_page',
                  backgroundColor: Colors.purple,
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  },
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'segnalazione_manuale',
                  backgroundColor: Colors.orange,
                  onPressed: _vaiASegnalazioneManuale,
                  child: const Icon(Icons.add_alert, color: Colors.white),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'segnalazione_veloce',
                  backgroundColor: Colors.green,
                  onPressed: _toggleSegnalazioneVeloce,
                  child: const Icon(Icons.notifications_active, color: Colors.white),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'posizione_utente',
                  backgroundColor: Colors.blue,
                  onPressed: _vaiAllaPosizioneUtente,
                  child: const Icon(Icons.my_location, color: Colors.white),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'fake_incidente',
                  backgroundColor: Colors.red,
                  onPressed: _simulaIncidente,
                  child: const Icon(Icons.warning, color: Colors.white),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'zoom_in',
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: _zoomIn,
                  child: const Icon(Icons.add, color: Colors.black),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'zoom_out',
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: _zoomOut,
                  child: const Icon(Icons.remove, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
