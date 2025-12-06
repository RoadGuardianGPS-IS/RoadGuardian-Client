import 'package:roadguardian_client/features/gestione_mappa/models/segnalazione_model.dart';

class MockSegnalazioneService {

  // DATABASE FINTO
  final List<Map<String, dynamic>> _mockDatabase = [
    {
      "id": "101",
      "titolo": "Tamponamento",
      "descrizione": "Tamponamento a catena. Traffico bloccato.",
      "indirizzo": "Corso Vittorio Emanuele, Napoli",
      // Distanza da Napoli Centro (User): ~1.5 km -> DEVE APPARIRE
      "latitude": 40.8399,
      "longitude": 14.2384,
      "data_ora": "2023-10-25T14:30:00",
      "gravita": "Alta",
      "stato": "In Corso",
      "immagine_url": "https://via.placeholder.com/600x400",
      "linee_guida": ["Indossare giubbotto.", "Chiamare 118."]
    },
    {
      "id": "102",
      "titolo": "Incidente Generico",
      "descrizione": "Incidente tra più veicoli.",
      "indirizzo": "Via Toledo, Napoli",
      // Distanza da Napoli Centro (User): ~1.2 km -> DEVE APPARIRE
      "latitude": 40.8427,
      "longitude": 14.2494,
      "data_ora": "2023-10-26T09:15:00",
      "gravita": "Media",
      "stato": "Aperta",
      "immagine_url": null,
      "linee_guida": ["Rallentare.", "Segnalare ostacolo."]
    },
    {
      "id": "103",
      "titolo": "Allagamento (LONTANO)",
      "descrizione": "Sottopasso allagato a Casoria.",
      "indirizzo": "Casoria, NA",
      // Distanza da Napoli Centro (User): ~7.0 km -> NON DEVE APPARIRE (> 3km)
      "latitude": 40.9120,
      "longitude": 14.2980,
      "data_ora": "2023-10-26T18:00:00",
      "gravita": "Alta",
      "stato": "In Corso",
      "immagine_url": null,
      "linee_guida": ["Non attraversare.", "Cercare percorso alternativo."]
    }
  ];

  Future<List<SegnalazioneModel>> getSegnalazioniAttive() async {
    await Future.delayed(const Duration(seconds: 1));
    return _mockDatabase.map((e) => SegnalazioneModel.fromJson(e)).toList();
  }

  Future<SegnalazioneModel> getDettaglioSegnalazione(String id) async {
    await Future.delayed(const Duration(seconds: 1));
    final json = _mockDatabase.firstWhere(
      (element) => element['id'] == id,
      orElse: () => _mockDatabase[0]
    );
    return SegnalazioneModel.fromJson(json);
  }
}