class SegnalazioneModel {
  final String id;
  final String titolo;
  final String descrizione;
  final String indirizzo;
  final DateTime dataOra;
  final String gravita;
  final String stato;
  final String? immagineUrl;

  final List<String> lineeGuida;

  SegnalazioneModel({
    required this.id,
    required this.titolo,
    required this.descrizione,
    required this.indirizzo,
    required this.dataOra,
    required this.gravita,
    required this.stato,
    this.immagineUrl,
    required this.lineeGuida,
  });

  factory SegnalazioneModel.fromJson(Map<String, dynamic> json) {
    return SegnalazioneModel(
      id: json['id'] ?? '',
      titolo: json['titolo'] ?? '',
      descrizione: json['descrizione'] ?? '',
      indirizzo: json['indirizzo'] ?? '',
      dataOra: DateTime.tryParse(json['data_ora'] ?? '') ?? DateTime.now(),
      gravita: json['gravita'] ?? 'Bassa',
      stato: json['stato'] ?? 'Aperta',
      immagineUrl: json['immagine_url'],
      lineeGuida: (json['linee_guida'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
    );
  }
}