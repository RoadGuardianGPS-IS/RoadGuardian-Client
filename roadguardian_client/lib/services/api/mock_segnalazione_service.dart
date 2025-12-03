import 'package:roadguardian_client/features/gestione_mappa/models/segnalazione_model.dart';

class MockSegnalazioneService {

  final Map<String, dynamic> _mockIncidente = {
    "id": "101",
    "titolo": "Incidente Stradale",
    "descrizione": "Tamponamento a catena. Traffico bloccato.",
    "indirizzo": "Corso Vittorio Emanuele, Napoli",
    "data_ora": "2023-10-25T14:30:00",
    "gravita": "Alta",
    "stato": "In Corso",
    // Se metti null qui sotto, vedrai l'icona grigia. Se metti un URL valido, vedrai la foto.
    "immagine_url": "https://via.placeholder.com/600x400",

    // Linee guida generiche
    "linee_guida": [
      "Indossare il giubbotto catarifrangente.",
      "Non scendere dall'auto se non necessario.",
      "Mantenere libera la corsia di emergenza.",
      "Chiamare i soccorsi (112) se ci sono feriti."
    ]
  };

  Future<SegnalazioneModel> getDettaglioSegnalazione(String id) async {
    await Future.delayed(const Duration(seconds: 1));
    return SegnalazioneModel.fromJson(_mockIncidente);
  }
}