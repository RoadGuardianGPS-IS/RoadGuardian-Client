import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:roadguardian_client/services/api/profile_service.dart';

/// SegnalazioneVelocePage: Interfaccia rapida per segnalare incidenti con geolocalizzazione automatica.
class SegnalazioneVelocePage extends StatefulWidget {
  final Function(LatLng) aggiungiMarkerCallback;

  const SegnalazioneVelocePage({
    super.key,
    required this.aggiungiMarkerCallback,
  });

  @override
  State<SegnalazioneVelocePage> createState() => _SegnalazioneVelocePageState();
}

class _SegnalazioneVelocePageState extends State<SegnalazioneVelocePage> {
  LatLng? _ultimaPosizione;
  bool _mostraNotifica = false;
  bool _isLoading = false;
  final ProfiloService _profiloService = ProfiloService();
  final String baseUrl =
      "http://10.0.2.2:8000"; // Indirizzo server per emulatore Android

  @override
  void initState() {
    super.initState();
    _verificaAutenticazione();
    _aggiornaPosizione();
  }

  void _verificaAutenticazione() {
    /// Verifica se l'utente è autenticato e mostra errore se assente.
    /// Scopo: Garantire che solo utenti loggati possano fare segnalazioni veloci.
    /// Parametri: Nessuno (usa _profiloService.currentUser).
    /// Valore di ritorno: void.
    /// Eccezioni: Mostra SnackBar e naviga indietro se non autenticato.

    if (_profiloService.currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Devi effettuare il login per creare una segnalazione veloce',
              ),
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
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _ultimaPosizione = LatLng(pos.latitude, pos.longitude);
      });
    } catch (e) {

      setState(() {
        _ultimaPosizione = LatLng(40.8522, 14.2681);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Posizione GPS non disponibile. Uso posizione predefinita.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _mostraSegnalazione() async {
    if (_ultimaPosizione == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attendi il caricamento della posizione...'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_profiloService.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Devi effettuare il login per creare una segnalazione veloce',
          ),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {

      final Map<String, dynamic> payload = {
        'incident_longitude': _ultimaPosizione!.longitude,
        'incident_latitude': _ultimaPosizione!.latitude,
        'seriousness': 'high',
        'category': 'tamponamento', // categoria compatibile con la manuale
        'description':
            'Segnalazione creata rapidamente tramite funzione veloce',
        'img_url': null,
      };

      debugPrint(
        'Segnalazione veloce → POST $baseUrl/segnalazione/creasegnalazione/${_profiloService.currentUser!.id}',
      );
      debugPrint('Payload: $payload');

      final response = await http.post(
        Uri.parse(
          '$baseUrl/segnalazione/creasegnalazione/${_profiloService.currentUser!.id}',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      if (response.statusCode == 201) {

        if (mounted) {
          setState(() {
            _mostraNotifica = true;
          });

          widget.aggiungiMarkerCallback(_ultimaPosizione!);

          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              setState(() {
                _mostraNotifica = false;
              });

              Navigator.pop(context);
            }
          });
        }
      } else {

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
        debugPrint('Errore di rete segnalazione veloce: $e');
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
    return Scaffold(
      appBar: AppBar(title: const Text("Nuova Segnalazione")),
      body: Stack(
        children: [

          if (_ultimaPosizione != null)
            FlutterMap(
              options: MapOptions(center: _ultimaPosizione, zoom: 15.0),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: const ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [

                    Marker(
                      point: _ultimaPosizione!,
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
                              border: Border.all(color: Colors.red, width: 2.0),
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
                  ],
                ),
              ],
            )
          else
            const Center(child: CircularProgressIndicator()),

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
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  '📍 Segnalazione piazzata!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _mostraSegnalazione,
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
