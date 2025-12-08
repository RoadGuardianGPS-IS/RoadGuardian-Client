import 'package:flutter/material.dart';
import 'package:roadguardian_client/features/gestione_profilo_utente/models/user_model.dart';

class ModificaProfiloPage extends StatefulWidget {
  final UserModel user;

  const ModificaProfiloPage({super.key, required this.user});

  @override
  State<ModificaProfiloPage> createState() => ModificaProfiloPageState();
}

class ModificaProfiloPageState extends State<ModificaProfiloPage> {
  late TextEditingController _nomeController;
  late TextEditingController _cognomeController;
  late TextEditingController _emailController;
  late TextEditingController _telefonoController;
  late TextEditingController _passwordController;

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Inizializzo i controller con i dati dell'utente passato
    _nomeController = TextEditingController(text: widget.user.nome);
    _cognomeController = TextEditingController(text: widget.user.cognome);
    _emailController = TextEditingController(text: widget.user.email);
    _telefonoController = TextEditingController(text: widget.user.numeroTelefono ?? '');
    _passwordController = TextEditingController(text: widget.user.password ?? '');
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cognomeController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color customBackground = Color(0xFFF0F0F0);
    const Color customPurple = Color(0xFF6561C0);

    return Scaffold(
      backgroundColor: customBackground,
      appBar: AppBar(
        title: const Text("MODIFICA PROFILO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
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
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
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
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
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
                    // qui puoi integrare la logica di salvataggio reale
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Modifiche salvate (Simulazione)")),
                    );
                    // torno indietro alla pagina precedente
                    Future.delayed(const Duration(milliseconds: 400), () {
                      if (mounted) Navigator.pop(context);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: customPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("SALVA MODIFICHE", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool readOnly = false, bool isPhone = false}) {
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
