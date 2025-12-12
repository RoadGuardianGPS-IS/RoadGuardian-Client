class SegnalazioneModel {
  final String id;
  final String titolo;
  final String categoria;
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
    required this.categoria,
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
    // Supporta sia il formato del backend mappa (_id, incident_latitude, incident_longitude)
    // sia il formato del backend segnalazione (id, latitude, longitude)
    final String idValue = json['_id'] ?? json['id'] ?? '';
    final dynamic latValue =
        json['incident_latitude'] ?? json['latitude'] ?? 40.8518;
    final dynamic lonValue =
        json['incident_longitude'] ?? json['longitude'] ?? 14.2681;

    return SegnalazioneModel(
      id: idValue,
      titolo: json['titolo'] ?? '',
      categoria: json['category'] ?? json['categoria'] ?? 'Altro',
      descrizione: json['descrizione'] ?? '',
      indirizzo: json['indirizzo'] ?? '',
      latitude: (latValue is String)
          ? double.tryParse(latValue) ?? 40.8518
          : (latValue is num ? latValue.toDouble() : 40.8518),
      longitude: (lonValue is String)
          ? double.tryParse(lonValue) ?? 14.2681
          : (lonValue is num ? lonValue.toDouble() : 14.2681),
      dataOra: DateTime.tryParse(json['data_ora'] ?? '') ?? DateTime.now(),
      gravita: json['seriousness'] ?? json['gravita'] ?? 'low',
      stato: json['stato'] ?? 'Aperta',
      immagineUrl: json['immagine_url'],
      lineeGuida:
          (json['linee_guida'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}
