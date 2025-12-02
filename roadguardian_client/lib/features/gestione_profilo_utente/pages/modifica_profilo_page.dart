import 'package:flutter/material.dart';

class ModificaProfiloPage extends StatefulWidget {
  const ModificaProfiloPage({super.key});

  @override
  State<ModificaProfiloPage> createState() => _ModificaProfiloPageState();
}

class _ModificaProfiloPageState extends State<ModificaProfiloPage> {
  final TextEditingController _nomeController = TextEditingController(text: "Mario");
  final TextEditingController _cognomeController = TextEditingController(text: "Rossi");
  final TextEditingController _emailController = TextEditingController(text: "mario.rossi@studenti.unisa.it");
  final TextEditingController _telefonoController = TextEditingController(text: "+39 333 1234567");
  final TextEditingController _passwordController = TextEditingController(text: "password123");

  // Variabile di stato per gestire la visibilità della password
  bool _obscurePassword = true;

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

                    // Campo Password con logica di visibilità
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword, // Usa la variabile di stato
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Modifiche salvate (Simulazione)")),
                    );
                    Future.delayed(const Duration(seconds: 1), () {
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