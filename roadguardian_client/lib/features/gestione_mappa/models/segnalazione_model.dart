class SegnalazioneModel {
  final String id;
  final String titolo;
  final String descrizione;
  final String indirizzo;
  final double latitude;
  final double longitude;
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
    required this.latitude,
    required this.longitude,
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
      latitude: (json['latitude'] is String)
          ? double.tryParse(json['latitude']) ?? 40.8518
          : (json['latitude'] ?? 40.8518),
      longitude: (json['longitude'] is String)
          ? double.tryParse(json['longitude']) ?? 14.2681
          : (json['longitude'] ?? 14.2681),
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