import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import '../../gestione_profilo_utente/pages/login_page.dart';
import '../../gestione_profilo_utente/pages/area_personale_page.dart';
import '../../gestione_segnalazione/pages/segnalazione_manuale_page.dart';
import '../../gestione_segnalazione/pages/dettaglio_segnalazione_page.dart';
import '../../gestione_segnalazione/models/segnalazione_model.dart';
import 'package:roadguardian_client/services/api/segnalazione_service.dart';
import 'package:roadguardian_client/services/api/profile_service.dart';
import 'package:roadguardian_client/services/api/notification_service.dart';
import 'package:roadguardian_client/services/api/mappa_service.dart';

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
  final NotificationService _notificationService = NotificationService();
  final MappaService _mappaService = MappaService();
  static final List<Marker> _persistentExtraMarkers = [];

  bool _showSegnalazioneVeloce = false;

  Timer? _positionUpdateTimer; // Timer per aggiornamento posizione ogni 30 secondi

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _posizioneUtente = napoliLatLng;
    _loadSavedPosition();
    _caricaSegnalazioni();
    _initializeNotifications();
    _startPositionUpdateTimer();
  }

  Future<void> _loadSavedPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble('user_position_lat');
    final lng = prefs.getDouble('user_position_lng');
    
    if (lat != null && lng != null && mounted) {
      setState(() {
        _posizioneUtente = LatLng(lat, lng);
      });
    }
  }

  Future<void> _savePosition(LatLng position) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('user_position_lat', position.latitude);
    await prefs.setDouble('user_position_lng', position.longitude);
  }

  @override
  void dispose() {
    _positionUpdateTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
    debugPrint('🔔 Notifiche inizializzate. Token: ${_notificationService.fcmToken}');
  }

  void _startPositionUpdateTimer() {

    _sendPositionToServer();

    _positionUpdateTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _sendPositionToServer(),
    );
    debugPrint('⏱️ Timer aggiornamento posizione avviato (ogni 30 secondi)');
  }

  Future<void> _sendPositionToServer() async {
    final fcmToken = _notificationService.fcmToken;
    
    if (fcmToken == null) {
      debugPrint('⚠️ Token FCM non disponibile, invio posizione senza token');
    }

    final success = await _mappaService.updateUserPosition(
      latitude: _posizioneUtente.latitude,
      longitude: _posizioneUtente.longitude,
      fcmToken: fcmToken,
    );

    if (success) {
      debugPrint('✅ Posizione inviata al server: ${_posizioneUtente.latitude}, ${_posizioneUtente.longitude}');
    } else {
      debugPrint('❌ Errore invio posizione al server');
    }
  }

  Future<void> _caricaSegnalazioni() async {
    try {
      final tutteLeSegnalazioni = await _segnalazioneService
          .getSegnalazioniAttive();
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
          onSegnalazioneConfermata: () {

            aggiungiMarker(
              LatLng(_posizioneUtente.latitude, _posizioneUtente.longitude),
            );

            Future.delayed(
              const Duration(milliseconds: 500),
              _caricaSegnalazioni,
            );
          },
        ),
      ),
    );
  }

  void aggiungiMarker(LatLng posizione) {
    setState(() {
      _persistentExtraMarkers.add(
        Marker(
          point: posizione,
          width: 100,
          height: 100,
          builder: (ctx) => Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha((0.4 * 255).toInt()),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.red, width: 4),
                ),
              ),
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: const Icon(
                  Icons.priority_high,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _toggleSegnalazioneVeloce() {

    if (_profiloService.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Devi effettuare il login per creare una segnalazione veloce',
          ),
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

  void _confermaSegnalazioneVeloce() {

    aggiungiMarker(_posizioneUtente);

    if (_profiloService.currentUser != null) {
      final userId = _profiloService.currentUser!.id;

      _segnalazioneService
          .createSegnalazione(
            userId,
            _posizioneUtente.latitude,
            _posizioneUtente.longitude,
            seriousness: 'high',
            description: 'Segnalazione veloce',
          )
          .then((ok) {
            if (!mounted) return;
            if (ok) {

              Future.delayed(
                const Duration(milliseconds: 400),
                _caricaSegnalazioni,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('📍 Segnalazione inviata al server'),
                  backgroundColor: Colors.green,
                  duration: Duration(milliseconds: 1500),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Errore invio segnalazione al server'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          })
          .catchError((e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Errore rete: $e'),
                backgroundColor: Colors.red,
              ),
            );
          });
    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Segnalazione piazzata localmente (login mancante)'),
          backgroundColor: Colors.orange,
          duration: Duration(milliseconds: 1500),
        ),
      );
    }

    _toggleSegnalazioneVeloce();
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

  void _centraSulMarker() {
    if (!mounted) return;
    setState(() {
      _mapController.move(_posizioneUtente, _currentZoom);
    });
  }

  void _aggiornaPosizioneUtente(LatLng nuovaPosizione) {
    setState(() {
      _posizioneUtente = nuovaPosizione;
    });

    _savePosition(nuovaPosizione);
    _sendPositionToServer();
  }

  void _simulaIncidente() async {
    if (_segnalazioni.isEmpty) return;
    final SegnalazioneModel incidente = _segnalazioni.first;
    final LatLng centroIncidente = LatLng(
      incidente.latitude,
      incidente.longitude,
    );

    final double latDiff = centroIncidente.latitude - _posizioneUtente.latitude;
    final double lngDiff =
        centroIncidente.longitude - _posizioneUtente.longitude;

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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                    ),
                    child: const Text("Vai alle linee guida"),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.grey),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
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
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(animation1),
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

                _aggiornaPosizioneUtente(point);
              },
              onLongPress: (tapPosition, point) {

                _aggiornaPosizioneUtente(point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.roadguardian',
              ),

              CircleLayer(
                circles: [
                  CircleMarker(
                    point: _posizioneUtente,
                    radius: 3000, // 3 km in metri
                    useRadiusInMeter: true,
                    color: Colors.blue.withAlpha((0.2 * 255).toInt()),
                    borderColor: Colors.blue.withAlpha((0.6 * 255).toInt()),
                    borderStrokeWidth: 3,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _posizioneUtente,
                    width: 70,
                    height: 70,
                    builder: (ctx) => GestureDetector(
                      onPanUpdate: (details) {

                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.blue.withAlpha(51),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: const Icon(
                              Icons.my_location,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const Positioned(
                            bottom: 0,
                            child: Text(
                              '📍',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
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
                            builder: (context) =>
                                DettaglioSegnalazionePage(segnalazioneId: s.id),
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
              MarkerLayer(markers: _persistentExtraMarkers),
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
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "SEGNALAZIONE VELOCE",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
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

          Positioned(
            bottom: 20,
            right: 10,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'login_page_menu',
                  backgroundColor: Colors.purple,
                  onPressed: () {
                    if (_profiloService.currentUser != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AreaPersonalePage(
                            user: _profiloService.currentUser!,
                          ),
                        ),
                      );
                    } else {
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
                  heroTag: 'segnalazione_manuale_menu',
                  backgroundColor: Colors.orange,
                  onPressed: _vaiASegnalazioneManuale,
                  child: const Icon(Icons.add_alert, color: Colors.white),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'segnalazione_veloce_menu',
                  backgroundColor: Colors.green,
                  onPressed: _toggleSegnalazioneVeloce,
                  child: const Icon(
                    Icons.notifications_active,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'posizione_utente_menu',
                  backgroundColor: Colors.blue,
                  onPressed: _centraSulMarker,
                  child: const Icon(Icons.my_location, color: Colors.white),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'fake_incidente_menu',
                  backgroundColor: Colors.red,
                  onPressed: _simulaIncidente,
                  child: const Icon(Icons.warning, color: Colors.white),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 20,
            right: 84,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'zoom_in_pos',
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: _zoomIn,
                  child: const Icon(Icons.add, color: Colors.black),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'zoom_out_pos',
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
