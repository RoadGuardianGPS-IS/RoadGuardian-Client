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

/// MappaPage: Mappa interattiva che visualizza segnalazioni di incidenti, localizzazione
/// dell'utente, e permette la creazione di segnalazioni manuali/veloci con tracking.
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
  final Map<String, String> _manualMarkerIds = {}; // Mappa posizione -> ID segnalazione

  bool _showSegnalazioneVeloce = false;
  bool _isLoadingSegnalazioni = true;

  Timer? _positionUpdateTimer; // Timer per aggiornamento posizione ogni 30 secondi

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _posizioneUtente = napoliLatLng;
    _loadSavedPosition();
    _initializeNotifications();
    _startPositionUpdateTimer();
    debugPrint('✅ [MappaPage] initState completato - NotificationService token: ${_notificationService.fcmToken}');
    // Carica le segnalazioni subito dopo l'inizializzazione
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _caricaSegnalazioni();
    });
  }

  Future<void> _loadSavedPosition() async {
    /// Carica la posizione precedentemente salvata dall'app da SharedPreferences.
    /// Scopo: Ripristinare la locazione dell'utente al riavvio dell'app.
    /// Parametri: Nessuno.
    /// Valore di ritorno: Future<void>.
    /// Eccezioni: Nessuna (fallback a napoliLatLng se non trovata).
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
    /// Salva la posizione attuale dell'utente su SharedPreferences.
    /// Scopo: Persistenza della locazione per il ripristino al riavvio.
    /// Parametri: position (LatLng) - coordinate geografiche da salvare.
    /// Valore di ritorno: Future<void>.
    /// Eccezioni: Nessuna.
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
    /// Notifiche già inizializzate in main.dart
    /// Scopo: Verificare che il token sia disponibile.
    /// Parametri: Nessuno.
    /// Valore di ritorno: Future<void>.
    /// Eccezioni: Nessuna.
    debugPrint('🔔 Notifiche controllate. Token: ${_notificationService.fcmToken}');
  }

  void _startPositionUpdateTimer() {
    /// Avvia un timer periodico che invia la posizione dell'utente al server ogni 30 sec.
    /// Scopo: Mantener sincronizzata la localizzazione del server con l'app.
    /// Parametri: Nessuno.
    /// Valore di ritorno: void.
    /// Eccezioni: Nessuna.

    // Invia la posizione subito, ma con delay per permettere al token FCM di essere disponibile
    Future.delayed(const Duration(milliseconds: 500), _sendPositionToServer);

    _positionUpdateTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _sendPositionToServer(),
    );
    debugPrint('⏱️ Timer aggiornamento posizione avviato (ogni 30 secondi)');
  }

  Future<void> _sendPositionToServer() async {
    /// Invia la posizione attuale dell'utente e token FCM al server backend.
    /// Scopo: Sincronizzare localizzazione per segnalazioni e notifiche.
    /// Parametri: Nessuno (usa _posizioneUtente e _notificationService.fcmToken).
    /// Valore di ritorno: Future<void>.
    /// Eccezioni: Nessuna (errori loggati tramite debugPrint).
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
    /// Carica tutte le segnalazioni attive dal server e le visualizza sulla mappa.
    /// Scopo: Aggiornare la lista di incidenti visibili sulla mappa in tempo reale.
    /// Parametri: Nessuno.
    /// Valore di ritorno: Future<void>.
    /// Eccezioni: Nessuna (errori gestiti e loggati, fallback a lista vuota).
    if (mounted) {
      setState(() {
        _isLoadingSegnalazioni = true;
      });
    }
    try {
      debugPrint('📍 Caricamento segnalazioni attive...');
      final tutteLeSegnalazioni = await _segnalazioneService
          .getSegnalazioniAttive();
      debugPrint('📍 Trovate ${tutteLeSegnalazioni.length} segnalazioni dal server');

      // Mostra tutte le segnalazioni senza filtro di distanza
      // per permettere la visualizzazione completa
      if (mounted) {
        setState(() {
          _segnalazioni = tutteLeSegnalazioni;
          _isLoadingSegnalazioni = false;
        });
        debugPrint('✅ Segnalazioni caricate: ${_segnalazioni.length}');
      }
    } catch (e) {
      debugPrint("❌ Errore caricamento segnalazioni: $e");
      if (mounted) {
        setState(() {
          _isLoadingSegnalazioni = false;
        });
      }
    }
  }

  void _vaiASegnalazioneManuale() {
    /// Naviga alla pagina di segnalazione manuale con le coordinate attuali.
    /// Scopo: Aprire il form per creare una segnalazione manuale con localizzazione.
    /// Parametri: Nessuno (usa _posizioneUtente).
    /// Valore di ritorno: void.
    /// Eccezioni: Nessuna.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SegnalazioneManualePage(
          latitude: _posizioneUtente.latitude,
          longitude: _posizioneUtente.longitude,
          onSegnalazioneConfermata: (String? segnalazioneId) {
            // Salva l'ID per rendere il marker cliccabile
            aggiungiMarker(
              LatLng(_posizioneUtente.latitude, _posizioneUtente.longitude),
              segnalazioneId: segnalazioneId,
            );

            // Ricarica le segnalazioni dal server
            Future.delayed(
              const Duration(milliseconds: 500),
              _caricaSegnalazioni,
            );
          },
        ),
      ),
    );
  }

  void aggiungiMarker(LatLng posizione, {String? segnalazioneId}) {
    /// Aggiunge un marker alla mappa associandolo a una segnalazione.
    /// Scopo: Tracciare quali marker sono associati a segnalazioni create manualmente.
    /// Parametri: posizione (LatLng) - coordinate; segnalazioneId (String?) - ID della segnalazione.
    /// Valore di ritorno: void.
    /// Eccezioni: Nessuna.
    final markerKey = '${posizione.latitude}_${posizione.longitude}';
    if (segnalazioneId != null) {
      _manualMarkerIds[markerKey] = segnalazioneId;
    }
  }

  void _toggleSegnalazioneVeloce() {
    /// Attiva/disattiva la modalità segnalazione veloce con autenticazione.
    /// Scopo: Permettere segnalazione rapida di incidenti solo agli utenti loggati.
    /// Parametri: Nessuno.
    /// Valore di ritorno: void.
    /// Eccezioni: Mostra SnackBar di errore se utente non autenticato.

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
              // Ricarica le segnalazioni dal server per ottenere quella appena creata
              _caricaSegnalazioni();
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
          // Indicatore di caricamento
          if (_isLoadingSegnalazioni)
            Positioned(
              top: 50,
              left: MediaQuery.of(context).size.width / 2 - 30,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(50),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Caricamento...',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
