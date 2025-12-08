import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'modifica_profilo_page.dart';
// import '../../gestione_mappa/pages/visualizzazione_mappa.dart'; // COMMENTATO
import 'logout_page.dart';
import 'login_page.dart';
import 'package:roadguardian_client/services/api/mock_profile_service.dart';

// ---------------- DETTAGLI PROFILO ----------------
class DettagliProfiloPage extends StatelessWidget {
  final UserModel utente;
  const DettagliProfiloPage({super.key, required this.utente});

  @override
  Widget build(BuildContext context) {
    const Color customPurple = Color(0xFF6561C0);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      appBar: AppBar(
        title: const Text("I TUOI DATI"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16)),
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
                    _buildInfoRow("Password", "••••••••"),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Modifica dati
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ModificaProfiloPage(user: utente)));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: customPurple,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    "MODIFICA DATI",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // CANCELLAZIONE ACCOUNT
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () async {
                    final bool? conferma = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Conferma cancellazione"),
                        content: const Text(
                            "Stai per cancellare il tuo account. Vuoi proseguire?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("No"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text("Conferma"),
                          ),
                        ],
                      ),
                    );

                    if (conferma == true) {
                      MockProfileService().deleteUser(utente);
                      MockProfileService().currentUser = null;

                      // Torna al Login invece che alla Mappa
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                        (route) => false,
                      );

                      await Future.delayed(const Duration(milliseconds: 300));
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Account cancellato"),
                          content: const Text(
                              "Il tuo account è stato cancellato con successo."),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("OK"))
                          ],
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    "CANCELLAZIONE ACCOUNT",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // INDIETRO
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    "INDIETRO",
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}

// ---------------- SEGNALAZIONI (Placeholder) ----------------
class SegnalazioniPage extends StatelessWidget {
  final String titolo;
  const SegnalazioniPage({super.key, required this.titolo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      appBar: AppBar(
          title: Text(titolo),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.black),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_late_outlined,
                size: 80, color: const Color.fromRGBO(128, 128, 128, 0.5)),
            const SizedBox(height: 20),
            const Text("Nessuna segnalazione",
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// ---------------- AREA PERSONALE ----------------
class AreaPersonalePage extends StatefulWidget {
  final UserModel user;
  const AreaPersonalePage({super.key, required this.user});

  @override
  State<AreaPersonalePage> createState() => _AreaPersonalePageState();
}

class _AreaPersonalePageState extends State<AreaPersonalePage> {
  late UserModel _utente;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _caricaDati();
  }

  void _caricaDati() {
    _utente = widget.user;
    setState(() {
      _isLoading = false;
    });
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
              const Center(
                child: Text(
                  "AREA PERSONALE",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 40),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    _buildMenuTile(
                      context,
                      icon: Icons.person_outline,
                      color: customPurple,
                      title: "Informazioni personali",
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    DettagliProfiloPage(utente: _utente)));
                      },
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    _buildMenuTile(
                      context,
                      icon: Icons.history,
                      color: Colors.orange,
                      title: "Storico Segnalazioni",
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SegnalazioniPage(
                                    titolo: "Storico Segnalazioni")));
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // LOGOUT
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    MockProfileService().currentUser = null;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LogoutPage()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: const Text("LOGOUT",
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              // TORNA ALLA MAPPA
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Mappa non disponibile in questo branch")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: const Text("TORNA ALLA MAPPA",
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTile(BuildContext context,
      {required IconData icon,
      required Color color,
      required String title,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: color, size: 28),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    );
  }
}