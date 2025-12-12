import 'package:flutter/material.dart';
import 'login_page.dart';
import 'logout_page.dart';
import '../../gestione_mappa/pages/visualizzazione_mappa.dart';
import 'package:roadguardian_client/services/api/profile_service.dart';
import '../models/user_model.dart';
import 'modifica_profilo_page.dart';

class AreaPersonalePage extends StatefulWidget {
  final UserModel user;
  const AreaPersonalePage({super.key, required this.user});

  @override
  State<AreaPersonalePage> createState() => _AreaPersonalePageState();
}

class _AreaPersonalePageState extends State<AreaPersonalePage> {
  late UserModel _utente;
  bool _isLoading = true;
  final ProfiloService _service = ProfiloService();

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
                              builder: (_) => DettagliProfiloPage(utente: _utente),
                            ),
                          );
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
                    final ctx = context;
                    _service.currentUser = null;

                    Navigator.pushAndRemoveUntil(
                      ctx,
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

              // BOTTONE TORNA ALLA MAPPA
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const MappaPage()),
                      (route) => false,
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

// ================= DETTAGLI PROFILO =================
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
                    _buildInfoRow("Telefono", utente.numeroTelefono ?? ""),
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
                        builder: (_) => ModificaProfiloPage(user: utente),
                      ),
                    );
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
                    final ctx = context;

                    // Dialog per chiedere la password di conferma
                    final TextEditingController passwordController = TextEditingController();
                    final bool? conferma = await showDialog<bool>(
                      context: ctx,
                      builder: (dialogCtx) => AlertDialog(
                        title: const Text("Conferma cancellazione"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Stai per cancellare il tuo account. Questa azione non può essere annullata.",
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: "Inserisci la tua password",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogCtx, false),
                            child: const Text("Annulla"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(dialogCtx, true),
                            child: const Text("Cancella Account"),
                          ),
                        ],
                      ),
                    );

                    if (conferma == true && passwordController.text.isNotEmpty) {
                      try {
                        final service = ProfiloService();
                        await service.deleteUser(utente.id, utente.email, passwordController.text);

                        if (!ctx.mounted) return;

                        Navigator.pushAndRemoveUntil(
                          ctx,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                          (route) => false,
                        );
                      } catch (e) {
                        if (!ctx.mounted) return;
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(content: Text('Errore cancellazione: $e')),
                        );
                      }
                    } else if (conferma == true && passwordController.text.isEmpty) {
                      if (!ctx.mounted) return;
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('Inserisci la password per confermare')),
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
                  onPressed: () => Navigator.pop(context),
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

// Storico segnalazioni rimosso: se necessario riaggiungere in futuro