import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart'; // Serve per calcolare la distanza

// IMPORT RIMOSSI/COMMENTATI PER IL BRANCH MAPPA
// import 'package:roadguardian_client/features/gestione_profilo_utente/pages/login_page.dart';
// import 'package:roadguardian_client/features/gestione_profilo_utente/pages/area_personale_page.dart';
// import 'package:roadguardian_client/services/api/mock_profile_service.dart';

// TUOI IMPORT (Mantenuti perché fanno parte della mappa)
import 'package:roadguardian_client/features/gestione_mappa/models/segnalazione_model.dart';
import 'package:roadguardian_client/services/api/mock_segnalazione_service.dart';
import 'package:roadguardian_client/features/gestione_mappa/pages/dettaglio_segnalazione_page.dart';

class MappaPage extends StatefulWidget {
  const MappaPage({super.key});

  @override
  State<MappaPage> createState() => _MappaPageState();
}

class _MappaPageState extends State<MappaPage> {
  // POSIZIONE UTENTE (Napoli Centro)
  final LatLng napoliLatLng = LatLng(40.8522, 14.2681);

  late final MapController _mapController;
  double _currentZoom = 13.0;

  // Lista segnalazioni
  List<SegnalazioneModel> _segnalazioni = [];
  final MockSegnalazioneService _segnalazioneService = MockSegnalazioneService();

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _caricaSegnalazioni();
  }

  // --- LOGICA FILTRO DISTANZA ---
  Future<void> _caricaSegnalazioni() async {
    try {
      // 1. Scarico TUTTE le segnalazioni dal server
      final tutteLeSegnalazioni = await _segnalazioneService.getSegnalazioniAttive();

      // 2. Preparo il calcolatore di distanze
      const Distance distanceCalculator = Distance();

      // 3. Filtro solo quelle vicine (< 3 km)
      final segnalazioniVicine = tutteLeSegnalazioni.where((segnalazione) {

        // Calcolo distanza in Metri
        final double metri = distanceCalculator.as(
          LengthUnit.Meter,
          napoliLatLng, // Posizione Utente
          LatLng(segnalazione.latitude, segnalazione.longitude) // Posizione Incidente
        );

        // Debug print per vedere in console cosa succede
        debugPrint("Segnalazione ${segnalazione.titolo} dista: ${metri.toStringAsFixed(0)} metri.");

        // Tengo solo se distanza <= 3000 metri (3km)
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

  void _goToUserArea() {
    // LOGICA MODIFICATA PER IL BRANCH MAPPA:
    // Non possiamo navigare verso Login/AreaPersonale perché quei file
    // non esistono (o non dovrebbero esistere) in questo branch.

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Gestione Utente non disponibile in questo branch (Map-Only)"),
        duration: Duration(seconds: 2),
      ),
    );

    /* CODICE ORIGINALE (COMMENTATO)
    final profileService = MockProfileService();
    final currentUser = profileService.currentUser;

    if (currentUser != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AreaPersonalePage(user: currentUser)),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
    */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: napoliLatLng,
              zoom: _currentZoom,
              interactiveFlags: InteractiveFlag.all,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.roadguardian',
              ),

              // MARKER SEGNALAZIONI (Solo quelle filtrate appariranno qui)
              MarkerLayer(
                markers: _segnalazioni.map((segnalazione) {
                  return Marker(
                    point: LatLng(segnalazione.latitude, segnalazione.longitude),
                    width: 40,
                    height: 40,
                    builder: (context) => GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DettaglioSegnalazionePage(
                              segnalazioneId: segnalazione.id,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: const Icon(
                          Icons.priority_high,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              // MARKER UTENTE (Blu)
              MarkerLayer(
                markers: [
                  Marker(
                    point: napoliLatLng,
                    width: 60,
                    height: 60,
                    builder: (context) => Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
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
            ],
          ),

          // Tasti Flottanti
          Positioned(
            bottom: 20,
            right: 10,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'user_btn',
                  mini: false,
                  onPressed: _goToUserArea,
                  backgroundColor: Colors.deepPurple,
                  child: const Icon(Icons.person, size: 28, color: Colors.white),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}