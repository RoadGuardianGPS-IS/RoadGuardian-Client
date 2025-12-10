import 'package:flutter/material.dart';

class SegnalazioneManualePage extends StatefulWidget {
  // Riceviamo le coordinate dalla mappa
  final double latitude;
  final double longitude;
  final String indirizzoStimato;

  const SegnalazioneManualePage({
    super.key,
    required this.latitude,
    required this.longitude,
    this.indirizzoStimato = "Posizione selezionata",
  });

  @override
  State<SegnalazioneManualePage> createState() =>
      _SegnalazioneManualePageState();
}

class _SegnalazioneManualePageState extends State<SegnalazioneManualePage> {
  final _formKey = GlobalKey<FormState>();

  // Controller
  final TextEditingController _titoloController = TextEditingController();
  final TextEditingController _descrizioneController = TextEditingController();

  // Stato
  String? _categoriaSelezionata;
  bool _isLoading = false;
  // RIMOSSO STATO FOTO CARICATA

  // LE 5 CATEGORIE DA RAD
  final List<String> _categorieRAD = [
    "Tamponamento",
    "Collisione con ostacolo",
    "Veicolo fuori strada",
    "Investimento",
    "Incendio veicolo"
  ];

  final Color customBackground = const Color(0xFFF0F0F0);
  final Color customPurple = const Color(0xFF6561C0);

  Future<void> _inviaSegnalazione() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoriaSelezionata == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Seleziona una categoria")));
      return;
    }

    setState(() => _isLoading = true);

    // Simulazione invio al backend
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Segnalazione inviata con successo!"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context); // Torna alla mappa
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: customBackground,
      appBar: AppBar(
        title: const Text("NUOVA SEGNALAZIONE"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Coordinate (Read Only)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.withAlpha(50)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.blue),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Posizione Rilevata",
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                                Text(
                                  "${widget.latitude.toStringAsFixed(5)}, ${widget.longitude.toStringAsFixed(5)}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Titolo
                    TextFormField(
                      controller: _titoloController,
                      decoration: _inputDecoration("Titolo (es. Incidente lieve)"),
                      validator: (value) =>
                          value!.isEmpty ? "Inserisci un titolo" : null,
                    ),
                    const SizedBox(height: 15),

                    // Categoria Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _categoriaSelezionata,
                      decoration: _inputDecoration("Categoria Incidente"),
                      items: _categorieRAD.map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat));
                      }).toList(),
                      onChanged: (val) =>
                          setState(() => _categoriaSelezionata = val),
                    ),
                    const SizedBox(height: 15),

                    // Descrizione
                    TextFormField(
                      controller: _descrizioneController,
                      maxLines: 4,
                      decoration:
                          _inputDecoration("Descrizione dettagliata (opzionale)"),
                    ),
                    const SizedBox(height: 25),

                    // --- RIMOSSA SEZIONE FOTO ---

                    const SizedBox(height: 10),

                    // Bottone Conferma
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
}