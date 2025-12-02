import 'package:flutter/material.dart';
import 'package:roadguardian_client/features/gestione_profilo_utente/pages/register_page.dart';
import 'package:roadguardian_client/services/api/mock_service.dart';
import '../models/user.dart';

class CancellazioneProfiloPage extends StatefulWidget {
  final User user; // Riceve l'utente registrato

  const CancellazioneProfiloPage({super.key, required this.user});

  @override
  State<CancellazioneProfiloPage> createState() => _CancellazioneProfiloPageState();
}

class _CancellazioneProfiloPageState extends State<CancellazioneProfiloPage> {
  late TextEditingController _nomeController;
  late TextEditingController _cognomeController;
  late TextEditingController _emailController;
  late TextEditingController _telefonoController;
  late TextEditingController _passwordController;

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    final parts = widget.user.name.split(' ');
    _nomeController = TextEditingController(text: parts[0]);
    _cognomeController = TextEditingController(text: parts.length > 1 ? parts[1] : '');
    _emailController = TextEditingController(text: widget.user.email);
    _telefonoController = TextEditingController(text: widget.user.phone ?? '');
    _passwordController = TextEditingController(text: widget.user.password);
  }

  @override
  Widget build(BuildContext context) {
    const Color customBackground = Color(0xFFF0F0F0);
    const Color customPurple = Color(0xFF6561C0);

    return Scaffold(
      backgroundColor: customBackground,
      appBar: AppBar(
        title: const Text(
          "MODIFICA PROFILO",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 60, color: customPurple),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    _buildTextField("Nome", _nomeController),
                    const SizedBox(height: 16),
                    _buildTextField("Cognome", _cognomeController),
                    const SizedBox(height: 16),
                    _buildTextField("Email", _emailController, readOnly: true),
                    const SizedBox(height: 16),
                    _buildTextField("Telefono", _telefonoController, isPhone: true),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Modifiche salvate (Simulazione)")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: customPurple,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    "SALVA MODIFICHE",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // CANCELLAZIONE UTENTE
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text(
                            "Conferma eliminazione",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          content: const Text(
                            "Sei sicuro di voler eliminare il tuo account? "
                            "Questa azione è irreversibile.",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Annulla"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                // Naviga direttamente alla pagina di registrazione
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const RegisterPage()),
                                );
                              },
                              child: const Text(
                                "Conferma",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    "CANCELLAZIONE UTENTE",
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

  Widget _buildTextField(String label, TextEditingController controller,
      {bool readOnly = false, bool isPhone = false}) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: readOnly ? Colors.grey[100] : Colors.white,
      ),
    );
  }
}
