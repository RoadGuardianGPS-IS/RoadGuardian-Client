import 'package:flutter/material.dart';
import 'package:roadguardian_client/features/gestione_mappa/models/segnalazione_model.dart';
import 'package:roadguardian_client/services/api/mock_segnalazione_service.dart';

class DettaglioSegnalazionePage extends StatefulWidget {
  final String segnalazioneId;

  const DettaglioSegnalazionePage({super.key, required this.segnalazioneId});

  @override
  State<DettaglioSegnalazionePage> createState() => _DettaglioSegnalazionePageState();
}

class _DettaglioSegnalazionePageState extends State<DettaglioSegnalazionePage> {
  SegnalazioneModel? _segnalazione;
  bool _isLoading = true;
  final MockSegnalazioneService _service = MockSegnalazioneService();

  @override
  void initState() {
    super.initState();
    _caricaDati();
  }

  Future<void> _caricaDati() async {
    try {
      final dati = await _service.getDettaglioSegnalazione(widget.segnalazioneId);
      if (mounted) {
        setState(() {
          _segnalazione = dati;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Errore: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color customBackground = Color(0xFFF0F0F0);
    const Color customPurple = Color(0xFF6561C0);

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: customBackground,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_segnalazione == null) {
      return const Scaffold(body: Center(child: Text("Errore caricamento")));
    }

    return Scaffold(
      backgroundColor: customBackground,
      appBar: AppBar(
        title: const Text(
          "DETTAGLIO",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FOTO INCIDENTE
            Container(
              width: double.infinity,
              height: 250,
              color: Colors.grey[300],
              child: _segnalazione!.immagineUrl != null
                  ? Image.network(
                      _segnalazione!.immagineUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (c, o, s) =>
                          const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                    )
                  : const Icon(Icons.map, size: 80, color: Colors.grey),
            ),

            // CARD CONTENUTO
            Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titolo
                    Text(
                      _segnalazione!.titolo.toUpperCase(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: customPurple,
                      ),
                    ),
                    const SizedBox(height: 5),

                    // Data
                    Text(
                      "${_segnalazione!.dataOra.day}/${_segnalazione!.dataOra.month}/${_segnalazione!.dataOra.year} - ${_segnalazione!.dataOra.hour}:${_segnalazione!.dataOra.minute.toString().padLeft(2, '0')}",
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 15),

                    // Badge Gravità e Stato
                    Row(
                      children: [
                        _buildBadge(_segnalazione!.stato, Colors.blue),
                        const SizedBox(width: 10),
                        _buildBadge(
                          _segnalazione!.gravita,
                          _getColorForSeverity(_segnalazione!.gravita),
                        ),
                      ],
                    ),

                    const Divider(height: 30),

                    // Indirizzo
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Color.fromARGB(255, 255, 0, 0)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _segnalazione!.indirizzo,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Descrizione
                    const Text("Descrizione",
                        style:
                            TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text(
                      _segnalazione!.descrizione,
                      style: const TextStyle(
                          fontSize: 15, color: Colors.black87, height: 1.5),
                    ),

                    const SizedBox(height: 30),

                    // Linee guida
                    if (_segnalazione!.lineeGuida.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(235, 248, 255, 1.0),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Color.fromRGBO(0, 0, 255, 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline,
                                    color: Color.fromARGB(255, 0, 0, 180)),
                                const SizedBox(width: 10),
                                const Text(
                                  "Linee Guida di Sicurezza",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black87),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ..._segnalazione!.lineeGuida.map(
                              (consiglio) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("• ",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    Expanded(
                                        child: Text(consiglio,
                                            style:
                                                const TextStyle(fontSize: 14))),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],

                    // Bottone Indietro
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text("TORNA INDIETRO"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: customPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // BANNER COLOR CORRETTO
  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Color.fromRGBO(
          (color.r * 255.0).round().clamp(0, 255),
          (color.g * 255.0).round().clamp(0, 255),
          (color.b * 255.0).round().clamp(0, 255),
          0.1,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _getColorForSeverity(String gravita) {
    switch (gravita.toLowerCase()) {
      case 'alta':
        return const Color.fromARGB(255, 255, 0, 0); // rosso
      case 'media':
        return const Color.fromARGB(255, 255, 165, 0); // arancione
      case 'bassa':
        return const Color.fromARGB(255, 0, 128, 0); // verde
      default:
        return const Color.fromARGB(255, 128, 128, 128); // grigio
    }
  }
}
