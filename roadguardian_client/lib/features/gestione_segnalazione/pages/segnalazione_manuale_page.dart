import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:roadguardian_client/services/api/profile_service.dart';

class SegnalazioneManualePage extends StatefulWidget {
  // Riceviamo le coordinate dalla mappa (essenziali per il backend)
  final double latitude;
  final double longitude;
  final String indirizzoStimato;
  final VoidCallback? onSegnalazioneConfermata;

  const SegnalazioneManualePage({
    super.key,
    required this.latitude,
    required this.longitude,
    this.indirizzoStimato = "Posizione selezionata",
    this.onSegnalazioneConfermata,
  });

  @override
  State<SegnalazioneManualePage> createState() =>
      _SegnalazioneManualePageState();
}

class _SegnalazioneManualePageState extends State<SegnalazioneManualePage> {
  final _formKey = GlobalKey<FormState>();

  // Controller
  final TextEditingController _descrizioneController = TextEditingController();

  // Stato
  String? _categoriaSelezionata;
  String? _prioritaSelezionata = "media";
  bool _isLoading = false;

  // LE 5 CATEGORIE DA RAD
  final List<String> _categorieRAD = [
    "Tamponamento",
    "Collisione con ostacolo",
    "Veicolo fuori strada",
    "Investimento",
    "Incendio veicolo"
  ];

  // PRIORITA INCIDENTE
  final List<String> _prioritaIncidente = [
    "bassa",
    "media",
    "alta",
    "critica"
  ];

  // Colori del tema
  final Color customBackground = const Color(0xFFF0F0F0);
  final Color customPurple = const Color(0xFF6561C0);

  // Servizi
  final ProfiloService _profiloService = ProfiloService();
  final String baseUrl = "http://10.0.2.2:8000";

  @override
  void initState() {
    super.initState();
    _verificaAutenticazione();
  }

  void _verificaAutenticazione() {
    // Verifica se l'utente è loggato all'apertura della pagina
    if (_profiloService.currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Devi effettuare il login per creare una segnalazione'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
          Navigator.pop(context);
        }
      });
    }
  }

  // Invio al backend
  Future<void> _inviaSegnalazione() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoriaSelezionata == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Seleziona il tipo di incidente")),
      );
      return;
    }

    // Verifica autenticazione prima dell'invio
    if (_profiloService.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Devi effettuare il login per creare una segnalazione'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Mappa le categorie ai valori accettati dal backend
      final Map<String, String> categoriaMapping = {
        "Tamponamento": "tamponamento",
        "Collisione con ostacolo": "collisione laterale",
        "Veicolo fuori strada": "deragliamento",
        "Investimento": "investimento",
        "Incendio veicolo": "ostacolo sulla strada"
      };

      // Mappa la priorità ai valori accettati dal backend (low, medium, high)
      final Map<String, String> prioritaMapping = {
        "bassa": "low",
        "media": "medium",
        "alta": "high",
        "critica": "high"
      };

      // Ottieni data e ora attuali
      final now = DateTime.now();
      final dateFormat = now.toString().split(' ')[0]; // YYYY-MM-DD
      final timeFormat = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

      final response = await http.post(
        Uri.parse('$baseUrl/segnalazione/creasegnalazione/${_profiloService.currentUser!.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'incident_date': dateFormat,
          'incident_time': timeFormat,
          'incident_longitude': widget.longitude,
          'incident_latitude': widget.latitude,
          'seriousness': prioritaMapping[_prioritaSelezionata] ?? 'medium',
          'category': categoriaMapping[_categoriaSelezionata] ?? _categoriaSelezionata!.toLowerCase(),
          'description': _descrizioneController.text,
        }),
      );

      if (mounted) {
        setState(() => _isLoading = false);
      }

      if (response.statusCode == 201) {
        // Segnalazione creata con successo
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Segnalazione inviata con successo!"),
              backgroundColor: Colors.green,
            ),
          );
          // Chiama il callback per ricaricare le segnalazioni sulla mappa
          widget.onSegnalazioneConfermata?.call();
          Navigator.pop(context);
        }
      } else {
        // Errore dal server
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Errore creazione segnalazione: ${response.statusCode}\nRisposta: ${response.body}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
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
      backgroundColor: customBackground,
      appBar: AppBar(
        title: const Text(
          "SEGNALAZIONE MANUALE",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: customPurple))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- SEZIONE 1: FORM DATI ---
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Dropdown Categoria
                          DropdownButtonFormField<String>(
                            decoration: _inputDecoration("Tipo di Incidente"),
                            initialValue: _categoriaSelezionata,
                            items: _categorieRAD.map((String categoria) {
                              return DropdownMenuItem<String>(
                                value: categoria,
                                child: Text(categoria),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _categoriaSelezionata = newValue;
                              });
                            },
                          ),
                          const SizedBox(height: 16),

                          // Dropdown Priorità
                          DropdownButtonFormField<String>(
                            decoration: _inputDecoration("Priorità Incidente"),
                            initialValue: _prioritaSelezionata,
                            items: _prioritaIncidente.map((String priorita) {
                              return DropdownMenuItem<String>(
                                value: priorita,
                                child: Text(_formatPriority(priorita)),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _prioritaSelezionata = newValue;
                              });
                            },
                          ),
                          const SizedBox(height: 16),

                          // Descrizione
                          TextFormField(
                            controller: _descrizioneController,
                            maxLines: 4,
                            decoration:
                                _inputDecoration("Descrizione dettagliata"),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Descrivi l\'accaduto';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Coordinate (Sola lettura)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.location_on,
                                    color: Colors.redAccent),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Posizione rilevata:",
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      ),
                                      Text(
                                        widget.indirizzoStimato,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        "${widget.latitude.toStringAsFixed(5)}, ${widget.longitude.toStringAsFixed(5)}",
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // --- BOTTONE INVIO ---
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _inviaSegnalazione,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: customPurple,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          "CONFERMA SEGNALAZIONE",
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Stile Campi Input (Coerente con RegisterPage)
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF6561C0), width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  // Formattazione priorità per visualizzazione
  String _formatPriority(String priority) {
    switch (priority) {
      case 'bassa':
        return 'Bassa';
      case 'media':
        return 'Media';
      case 'alta':
        return 'Alta';
      case 'critica':
        return 'Critica';
      default:
        return priority;
    }
  }
}
