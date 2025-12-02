import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../../../services/api/mock_profile_service.dart';
import 'modifica_profilo_page.dart';

class AreaPersonalePage extends StatefulWidget {
  const AreaPersonalePage({super.key});

  @override
  State<AreaPersonalePage> createState() => _AreaPersonalePageState();
}

class _AreaPersonalePageState extends State<AreaPersonalePage> {
  UserModel? _utente;
  bool _isLoading = true;
  final MockProfileService _service = MockProfileService();

  @override
  void initState() {
    super.initState();
    _caricaDati();
  }

  Future<void> _caricaDati() async {
    try {
      UserModel dati = await _service.fetchUserProfile();
      if (mounted) {
        setState(() {
          _utente = dati;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Errore fetch: $e");
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

    return Scaffold(
      backgroundColor: customBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Center(child: Text("AREA PERSONALE", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
              const SizedBox(height: 40),

              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    // MENU 1: Informazioni Personali
                    _buildMenuTile(
                      context,
                      icon: Icons.person_outline,
                      color: customPurple,
                      title: "Informazioni personali",
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => DettagliProfiloPage(utente: _utente!)));
                      },
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20),

                    // MENU 2: Storico Segnalazioni
                    _buildMenuTile(
                      context,
                      icon: Icons.history,
                      color: Colors.orange,
                      title: "Storico Segnalazioni",
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const SegnalazioniPage(titolo: "Storico Segnalazioni")));
                      },
                    ),


                  ],
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () { print("Logout"); },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text("ESCI", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTile(BuildContext context, {required IconData icon, required Color color, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: color, size: 28),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    );
  }
}

class DettagliProfiloPage extends StatelessWidget {
  final UserModel utente;
  const DettagliProfiloPage({super.key, required this.utente});

  @override
  Widget build(BuildContext context) {
    const Color customPurple = Color(0xFF6561C0);
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      appBar: AppBar(title: const Text("I TUOI DATI"), backgroundColor: Colors.transparent, elevation: 0, foregroundColor: Colors.black),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Center(child: CircleAvatar(radius: 50, backgroundColor: Colors.white, child: Icon(Icons.person, size: 60, color: customPurple))),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    _buildInfoRow("Nome", utente.nome),
                    const Divider(),
                    _buildInfoRow("Cognome", utente.cognome),
                    const Divider(),
                    _buildInfoRow("Email", utente.email),
                    const Divider(),
                    _buildInfoRow("Telefono", utente.numeroTelefono ?? "-"),
                    const Divider(),
                    // NUOVO CAMPO PASSWORD (Visualizza pallini o testo placeholder)
                    _buildInfoRow("Password", "••••••••"),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ModificaProfiloPage()));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: customPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text("MODIFICA DATI", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ]),
    );
  }
}

class SegnalazioniPage extends StatelessWidget {
  final String titolo;
  const SegnalazioniPage({super.key, required this.titolo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      appBar: AppBar(title: Text(titolo), backgroundColor: Colors.transparent, elevation: 0, foregroundColor: Colors.black),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_late_outlined, size: 80, color: Colors.grey.withOpacity(0.5)),
            const SizedBox(height: 20),
            const Text("Nessuna segnalazione", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}