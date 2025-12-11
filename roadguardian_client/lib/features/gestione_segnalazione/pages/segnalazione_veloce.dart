import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:roadguardian_client/services/api/profile_service.dart';

class SegnalazioneVelocePage extends StatefulWidget {
  final Function(LatLng) aggiungiMarkerCallback;

  const SegnalazioneVelocePage({super.key, required this.aggiungiMarkerCallback});

  @override
  State<SegnalazioneVelocePage> createState() => _SegnalazioneVelocePageState();
}

class _SegnalazioneVelocePageState extends State<SegnalazioneVelocePage> {
  LatLng? _ultimaPosizione;
  bool _mostraNotifica = false;
  bool _isLoading = false;
  final ProfiloService _profiloService = ProfiloService();
  final String baseUrl = "http://10.0.2.2:8000"; // Indirizzo server per emulatore Android

  @override
  void initState() {
    super.initState();
    _verificaAutenticazione();
    _aggiornaPosizione();
  }

  void _verificaAutenticazione() {
    // Verifica se l'utente è loggato all'apertura della pagina
    if (_profiloService.currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Devi effettuare il login per creare una segnalazione veloce'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
          Navigator.pop(context);
        }
      });
    }
  }

  Future<void> _aggiornaPosizione() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _ultimaPosizione = LatLng(pos.latitude, pos.longitude);
      });
    } catch (e) {
      // Se fallisce la geolocalizzazione, usa posizione di default (Napoli)
      setState(() {
        _ultimaPosizione = LatLng(40.8522, 14.2681);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Posizione GPS non disponibile. Uso posizione predefinita.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _mostraSegnalazione() async {
    print('[DEBUG] _mostraSegnalazione chiamato');
    print('[DEBUG] _ultimaPosizione: $_ultimaPosizione');
    print('[DEBUG] currentUser: ${_profiloService.currentUser}');

    if (_ultimaPosizione == null) {
      print('[DEBUG] Posizione mancante, uscita anticipata');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attendi il caricamento della posizione...'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Verifica nuovamente se l'utente è loggato prima dell'invio
    if (_profiloService.currentUser == null) {
      print('[DEBUG] Utente non loggato, uscita anticipata');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Devi effettuare il login per creare una segnalazione veloce'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context);
      return;
    }

    print('[DEBUG] Controlli superati, inizio invio');
    setState(() {
      _isLoading = true;
    });

    try {
      // Payload con campi obbligatori e default espliciti per compatibilità con Pydantic
      final Map<String, dynamic> payload = {
        'incident_longitude': _ultimaPosizione!.longitude,
        'incident_latitude': _ultimaPosizione!.latitude,
        'seriousness': 'high',
        'category': 'incidente stradale',
        'description': null,
        'img_url': null,
      };

      // Log in console (anche in release usa print)
      print('[DEBUG] Segnalazione veloce → POST $baseUrl/segnalazione/createsegnalazioneveloce/${_profiloService.currentUser!.id}');
      print('[DEBUG] Payload: $payload');

      final response = await http.post(
        Uri.parse('$baseUrl/segnalazione/createsegnalazioneveloce/${_profiloService.currentUser!.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      print('[DEBUG] Response status: ${response.statusCode}');
      print('[DEBUG] Response body: ${response.body}');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      if (response.statusCode == 201) {
        // Segnalazione creata con successo
        if (mounted) {
          setState(() {
            _mostraNotifica = true;
          });

          // Aggiungi marker sulla mappa
          widget.aggiungiMarkerCallback(_ultimaPosizione!);

          // Nascondi notifica dopo 1.5 secondi
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              setState(() {
                _mostraNotifica = false;
              });
              // Torna alla mappa dopo aver mostrato la notifica
              Navigator.pop(context);
            }
          });
        }
      } else {
        // Errore dal server: mostro status e body
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
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        print('Errore di rete segnalazione veloce: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore di rete: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('[BUILD] _isLoading: $_isLoading, _ultimaPosizione: $_ultimaPosizione');
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nuova Segnalazione"),
      ),
      body: Stack(
        children: [
          // MAPPA SOTTO
          if (_ultimaPosizione != null)
            FlutterMap(
              options: MapOptions(
                center: _ultimaPosizione,
                zoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: const ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    // --- NUOVO STILE MARKER (Uniformato) ---
                    Marker(
                      point: _ultimaPosizione!,
                      width: 100,
                      height: 100,
                      builder: (ctx) => Stack(
                        alignment: Alignment.center,
                        children: [
                          // Alone rosso trasparente
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.red.withAlpha((0.2 * 255).toInt()),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.red, width: 2.0),
                            ),
                          ),
                          // Cerchio centrale pieno
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
                  ],
                ),
              ],
            )
          else
            const Center(child: CircularProgressIndicator()),

          // NOTIFICA ANIMATA
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            top: _mostraNotifica ? 50 : -80,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
                ],
              ),
              child: const Center(
                child: Text(
                  '📍 Segnalazione piazzata!',
                  style: TextStyle(
                      color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),

          // PULSANTE AZIONE
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: () {
                  print('[BUTTON] Pulsante premuto! _isLoading: $_isLoading');
                  if (!_isLoading) {
                    _mostraSegnalazione();
                  } else {
                    print('[BUTTON] Bloccato perché _isLoading è true');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  minimumSize: const Size(double.infinity, 50),
                  disabledBackgroundColor: Colors.grey,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "CONFERMA SEGNALAZIONE VELOCE",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}