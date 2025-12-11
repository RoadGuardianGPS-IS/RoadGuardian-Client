import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../gestione_profilo_utente/pages/login_page.dart';
import '../../gestione_profilo_utente/pages/area_personale_page.dart';
import '../../gestione_segnalazione/pages/segnalazione_manuale_page.dart';
import '../../gestione_segnalazione/pages/dettaglio_segnalazione_page.dart';
import '../../gestione_segnalazione/models/segnalazione_model.dart';
import 'package:roadguardian_client/services/api/segnalazione_service.dart';
import 'package:roadguardian_client/services/api/profile_service.dart';

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
  final SegnalazioneService _segnalazioneService = SegnalazioneService();
  final ProfiloService _profiloService = ProfiloService();
  final List<Marker> _extraMarkers = [];

  bool _showSegnalazioneVeloce = false;
  Set<String> _segnalazioniNotificate = {}; // Traccia le segnalazioni già notificate

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
          width: 100,
          height: 100,
          builder: (ctx) => Stack(
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
    });
  }

  void _toggleSegnalazioneVeloce() {
    // Verifica se l'utente è loggato prima di mostrare l'interfaccia
    if (_profiloService.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Devi effettuare il login per creare una segnalazione veloce'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _showSegnalazioneVeloce = !_showSegnalazioneVeloce;
    });
  }

  Future<void> _confermaSegnalazioneVeloce() async {
    // Verifica autenticazione
    if (_profiloService.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Devi effettuare il login per creare una segnalazione'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Payload per segnalazione veloce
      final Map<String, dynamic> payload = {
        'incident_longitude': _posizioneUtente.longitude,
        'incident_latitude': _posizioneUtente.latitude,
        'seriousness': 'high',
        'category': 'incidente stradale',
        'description': null,
        'img_url': null,
      };

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/segnalazione/createsegnalazioneveloce/${_profiloService.currentUser!.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 201) {
        // Successo: aggiungi marker e mostra notifica
        aggiungiMarker(_posizioneUtente);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('📍 Segnalazione piazzata!'),
              backgroundColor: Colors.green,
              duration: Duration(milliseconds: 1500),
            ),
          );
        }
        _toggleSegnalazioneVeloce();
      } else {
        // Errore dal server
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Errore ${response.statusCode}: ${response.body}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Errore di rete
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore di rete: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _zoomIn() {
    setState(() {
      if (_currentZoom < 18) _currentZoom++;
      _mapController.move(_posizioneUtente, _currentZoom);
    });
  }

  void _zoomOut() {
    setState(() {
      if (_currentZoom > 5) _currentZoom--;
      _mapController.move(_posizioneUtente, _currentZoom);
    });
  }

  void _vaiAllaPosizioneUtente() {
    setState(() {
      _posizioneUtente = napoliLatLng;
      _mapController.move(_posizioneUtente, 16);
    });
    _verificaProssimitaIncidenti();
  }

  void _verificaProssimitaIncidenti() {
    // Verifica se ci sono segnalazioni entro 3 km dalla posizione utente
    const Distance distanceCalculator = Distance();

    for (var segnalazione in _segnalazioni) {
      final double distanzaKm = distanceCalculator.as(
        LengthUnit.Kilometer,
        _posizioneUtente,
        LatLng(segnalazione.latitude, segnalazione.longitude),
      );

      // Se la distanza è <= 3 km e non è già stata notificata
      if (distanzaKm <= 3.0 && !_segnalazioniNotificate.contains(segnalazione.id)) {
        _segnalazioniNotificate.add(segnalazione.id);
        _mostraPopup(segnalazione);
        break; // Mostra solo un popup alla volta
      }
    }
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
                  const SizedBox(height: 8),
                  const Text(
                    "Prestare attenzione: pericolo imminente.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.red),
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
              onTap: (tapPosition, point) {
                // Tap sulla mappa per spostare il marker utente
                setState(() {
                  _posizioneUtente = point;
                });
                // Verifica la prossimità dopo lo spostamento
                _verificaProssimitaIncidenti();
              },
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
                    builder: (ctx) => Container(
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
                    builder: (ctx) => GestureDetector(
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
          // FloatingActionButton avatar - Verifica sessione
          Positioned(
            bottom: 20,
            right: 10,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'login_page',
                  backgroundColor: Colors.purple,
                  onPressed: () {
                    if (_profiloService.currentUser != null) {
                      // Utente loggato → vai all'area personale
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AreaPersonalePage(user: _profiloService.currentUser!),
                        ),
                      );
                    } else {
                      // Utente non loggato → vai al login
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    }
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