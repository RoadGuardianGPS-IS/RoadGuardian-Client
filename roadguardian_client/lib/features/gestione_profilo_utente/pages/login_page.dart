import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'package:roadguardian_client/services/api/mock_profile_service.dart';
import 'area_personale_page.dart';
import 'register_page.dart';
import '../../gestione_mappa/pages/visualizzazione_mappa.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final MockProfileService _service = MockProfileService();

  bool loading = false;

  @override
  void initState() {
    super.initState();
    if (_service.currentUser != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => AreaPersonalePage(user: _service.currentUser!)),
        );
      });
    }
  }

  void _login() async {
    setState(() => loading = true);
    UserModel? user = await _service.fetchUserByEmail(emailController.text);

    if (!mounted) return;

    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Utente non trovato")));
      setState(() => loading = false);
      return;
    }

    if (user.password != passwordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password o Utente errati")));
      setState(() => loading = false);
      return;
    }

    _service.currentUser = user;

    setState(() => loading = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => AreaPersonalePage(user: user)),
    );
  }

  void _goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterPage()),
    );
  }

  void _goToMappa() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MappaPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color bgGrey = Color(0xFFF0F0F0);
    const Color buttonRed = Color(0xFFE53935);
    const Color buttonGreen = Colors.green;

    return Scaffold(
      backgroundColor: bgGrey,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // --- LOGO MODIFICATO ---
                // Assicurati che il file esista in: assets/logo/logo_app.png
                // Se non c'è l'immagine, mostrerà un'icona di fallback pulita.
                SizedBox(
                  height: 120,
                  child: Image.asset(
                    'assets/logo/logo_app.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback se l'immagine non viene trovata
                      return const Icon(Icons.security, size: 100, color: Colors.purple);
                    },
                  ),
                ),
                // -----------------------

                const SizedBox(height: 20),
                const Text("ROAD GUARDIAN",
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                const SizedBox(height: 40),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withAlpha(13),
                            blurRadius: 10,
                            offset: const Offset(0, 5))
                      ]),
                  child: Column(
                    children: [
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: "Email",
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: loading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6561C0),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: loading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text("ACCEDI",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _goToRegister,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: buttonRed,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    child: const Text("REGISTRATI",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _goToMappa,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: buttonGreen,
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
      ),
    );
  }
}