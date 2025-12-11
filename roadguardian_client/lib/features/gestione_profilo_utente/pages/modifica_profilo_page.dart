import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'package:roadguardian_client/services/api/profilo_service.dart';

class ModificaProfiloPage extends StatefulWidget {
  final UserModel user;

  const ModificaProfiloPage({super.key, required this.user});

  @override
  State<ModificaProfiloPage> createState() => _ModificaProfiloPageState();
}

class _ModificaProfiloPageState extends State<ModificaProfiloPage> {
  late TextEditingController _nomeController;
  late TextEditingController _cognomeController;
  late TextEditingController _telefonoController;
  late TextEditingController _passwordController;

  bool _obscurePassword = true;
  bool _loading = false;

  final ProfiloService _service = ProfiloService();

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.user.nome);
    _cognomeController = TextEditingController(text: widget.user.cognome);
    _telefonoController =
        TextEditingController(text: widget.user.numeroTelefono ?? '');
    _passwordController =
        TextEditingController(text: widget.user.password ?? '');
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cognomeController.dispose();
    _telefonoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _salvaModifiche() async {
    setState(() => _loading = true);

    UserModel updatedUser = UserModel(
      id: widget.user.id,
      nome: _nomeController.text.trim(),
      cognome: _cognomeController.text.trim(),
      email: widget.user.email, // Email fissa
      numeroTelefono: _telefonoController.text.trim().isEmpty
          ? null
          : _telefonoController.text.trim(),
      password: _passwordController.text.trim().isEmpty
          ? widget.user.password
          : _passwordController.text.trim(),
    );

    try {
      final result = await _service.updateUser(updatedUser);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profilo aggiornato con successo")),
      );

      Navigator.pop(context, result);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Errore aggiornamento: $e")),
      );
    }

    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    const Color bgGrey = Color(0xFFF0F0F0);
    const Color buttonPurple = Color(0xFF6561C0);

    return Scaffold(
      backgroundColor: bgGrey,
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
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildTextField("Nome", _nomeController),
                    const SizedBox(height: 16),
                    _buildTextField("Cognome", _cognomeController),
                    const SizedBox(height: 16),
                    _buildTextField("Email", TextEditingController(text: widget.user.email), readOnly: true),
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
                  onPressed: _loading ? null : _salvaModifiche,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "SALVA MODIFICHE",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
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
