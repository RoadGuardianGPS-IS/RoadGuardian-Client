import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'package:roadguardian_client/services/api/mock_profile_service.dart';
import 'area_personale_page.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final MockProfileService _service = MockProfileService();
  bool loading = false;

  final RegExp _emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
  final RegExp _italianPhoneRegExp = RegExp(r'^3\d{9}$');

  void _register() {
    String nome = nameController.text.trim();
    String cognome = surnameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;
    String phone = phoneController.text.trim();

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Le password non corrispondono')));
      return;
    }

    if (!_emailRegExp.hasMatch(email)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Inserisci un indirizzo email valido')));
      return;
    }

    if (phone.isNotEmpty && !_italianPhoneRegExp.hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Numero di telefono non valido (es. 3331234567)')));
      return;
    }

    setState(() => loading = true);

    UserModel newUser = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nome: nome,
      cognome: cognome,
      email: email,
      password: password,
      numeroTelefono: phone.isEmpty ? null : phone,
    );

    _service.registerUser(newUser);
    setState(() => loading = false);

    // Login automatico dopo registrazione
    _service.currentUser = newUser;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => AreaPersonalePage(user: newUser)),
      (route) => false,
    );
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text("REGISTRAZIONE",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    TextField(
                      key: const Key('register_nome'),
                      controller: nameController,
                      decoration: const InputDecoration(
                          labelText: "Nome", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      key: const Key('register_cognome'),
                      controller: surnameController,
                      decoration: const InputDecoration(
                          labelText: "Cognome", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      key: const Key('register_email'),
                      controller: emailController,
                      decoration: const InputDecoration(
                          labelText: "Email", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      key: const Key('register_telefono'),
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                          labelText: "Telefono (opzionale)", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      key: const Key('register_password'),
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: "Password", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      key: const Key('register_confirm_password'),
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: "Conferma Password", border: OutlineInputBorder()),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: loading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape:
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "REGISTRATI",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _goToLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape:
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    "TORNA AL LOGIN",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
