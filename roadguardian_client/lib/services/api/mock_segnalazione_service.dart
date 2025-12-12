import 'package:roadguardian_client/features/gestione_segnalazione/models/segnalazione_model.dart'; // <--- IMPORT AGGIORNATO

class MockSegnalazioneService {
  final List<Map<String, dynamic>> _mockDatabase = [
    {
      "id": "101",
      "titolo": "Incidente Stradale",
      "categoria": "Tamponamento", // <--- NUOVO CAMPO AGGIUNTO
      "descrizione": "Tamponamento a catena. Traffico bloccato.",
      "indirizzo": "Corso Vittorio Emanuele, Napoli",
      "latitude": 40.8399,
      "longitude": 14.2384,
      "data_ora": "2023-10-25T14:30:00",
      "gravita": "Alta",
      "stato": "In Corso",
      "immagine_url": "https://via.placeholder.com/600x400",
      "linee_guida": ["Indossare giubbotto.", "Chiamare 118."],
    },
    {
      "id": "102",
      "titolo": "Buca Pericolosa",
      "categoria": "Buca / Dissesto", // <--- NUOVO CAMPO AGGIUNTO
      "descrizione": "Voragine al centro della carreggiata.",
      "indirizzo": "Via Toledo, Napoli",
      "latitude": 40.8427,
      "longitude": 14.2494,
      "data_ora": "2023-10-26T09:15:00",
      "gravita": "Media",
      "stato": "Aperta",
      "immagine_url": null,
      "linee_guida": ["Rallentare.", "Segnalare ostacolo."],
    },
    // ... altri dati ...
  ];

  Future<List<SegnalazioneModel>> getSegnalazioniAttive() async {
    await Future.delayed(const Duration(seconds: 1));
    return _mockDatabase.map((e) => SegnalazioneModel.fromJson(e)).toList();
  }

  Future<SegnalazioneModel> getDettaglioSegnalazione(String id) async {
    await Future.delayed(const Duration(seconds: 1));
    final json = _mockDatabase.firstWhere(
      (element) => element['id'] == id,
      orElse: () => _mockDatabase[0],
    );
    return SegnalazioneModel.fromJson(json);
  }
}
