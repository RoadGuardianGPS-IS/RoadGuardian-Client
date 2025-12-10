import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class SegnalazioneVelocePage extends StatefulWidget {
  final Function(LatLng) aggiungiMarkerCallback;

  const SegnalazioneVelocePage({super.key, required this.aggiungiMarkerCallback});

  @override
  State<SegnalazioneVelocePage> createState() => _SegnalazioneVelocePageState();
}

class _SegnalazioneVelocePageState extends State<SegnalazioneVelocePage> {
  LatLng? _ultimaPosizione;
  bool _mostraNotifica = false;

  @override
  void initState() {
    super.initState();
    _aggiornaPosizione();
  }

  Future<void> _aggiornaPosizione() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _ultimaPosizione = LatLng(pos.latitude, pos.longitude);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore ottenendo la posizione: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _mostraSegnalazione() {
    setState(() {
      _mostraNotifica = true;
    });

    if (_ultimaPosizione != null) {
      widget.aggiungiMarkerCallback(_ultimaPosizione!);
    }

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _mostraNotifica = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                onPressed: _mostraSegnalazione,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
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