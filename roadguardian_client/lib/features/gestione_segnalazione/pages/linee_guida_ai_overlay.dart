import 'package:flutter/material.dart';
import 'package:roadguardian_client/services/api/segnalazione_service.dart';

/// LineeGuidaAIOverlay: Pagina overlay per visualizzare le linee guida AI di un incidente.
/// Scopo: Mostrare in overlay le linee guida AI recuperate dal server.
class LineeGuidaAIOverlay extends StatefulWidget {
  final String segnalazioneId;
  final String titoloSegnalazione;

  const LineeGuidaAIOverlay({
    super.key,
    required this.segnalazioneId,
    required this.titoloSegnalazione,
  });

  @override
  State<LineeGuidaAIOverlay> createState() => _LineeGuidaAIOverlayState();
}

class _LineeGuidaAIOverlayState extends State<LineeGuidaAIOverlay> {
  List<String> _lineeGuida = [];
  bool _isLoading = true;
  String? _errorMessage;
  final SegnalazioneService _service = SegnalazioneService();

  @override
  void initState() {
    super.initState();
    _caricaLineeGuidaAI();
  }

  Future<void> _caricaLineeGuidaAI() async {
    /// Carica le linee guida AI dal server.
    /// Scopo: Recuperare e visualizzare le linee guida AI per la segnalazione.
    /// Parametri: Nessuno (usa widget.segnalazioneId).
    /// Valore di ritorno: Future<void>.
    /// Eccezioni: Eccezione generica durante fetch (loggata e gestita).
    try {
      final lineeGuida = await _service.getLineeGuidaAI(widget.segnalazioneId);
      if (mounted) {
        setState(() {
          _lineeGuida = lineeGuida;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Errore caricamento linee guida AI: $e");
      if (mounted) {
        setState(() {
          _errorMessage = "Impossibile caricare le linee guida AI";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color customBackground = Color(0xFFF0F0F0);
    const Color customPurple = Color(0xFF6561C0);

    return Scaffold(
      backgroundColor: customBackground,
      appBar: AppBar(
        title: const Text(
          "LINEE GUIDA AI",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(customPurple),
    );
  }

  Widget _buildBody(Color customPurple) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              "Caricamento linee guida AI...",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _caricaLineeGuidaAI();
                },
                icon: const Icon(Icons.refresh),
                label: const Text("Riprova"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: customPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_lineeGuida.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 60,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              const Text(
                "Nessuna linea guida AI disponibile per questa segnalazione",
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con icona AI
          Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  customPurple.withAlpha(200),
                  customPurple,
                ],
              ),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 50,
                  color: Colors.white,
                ),
                SizedBox(height: 10),
                Text(
                  "Suggerimenti Intelligenti",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Contenuto principale
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
                    color: Colors.black.withAlpha(13),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titolo segnalazione
                  Text(
                    widget.titoloSegnalazione.toUpperCase(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: customPurple,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Linee guida suggerite dall'intelligenza artificiale",
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.black54,
                    ),
                  ),
                  const Divider(height: 30),

                  // Lista delle linee guida AI
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.purple[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: customPurple.withAlpha(77),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.psychology,
                              color: customPurple,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "Linee Guida AI",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        ..._lineeGuida.asMap().entries.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: customPurple,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      "${entry.key + 1}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    entry.value,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Pulsante torna indietro
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
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
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
