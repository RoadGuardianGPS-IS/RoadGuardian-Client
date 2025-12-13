import 'package:flutter/material.dart';
import 'package:roadguardian_client/services/login_input.dart';
import 'package:roadguardian_client/services/api/profile_service.dart';
import 'package:roadguardian_client/services/api/notification_service.dart';
import 'area_personale_page.dart';
import 'register_page.dart';
import '../../gestione_mappa/pages/visualizzazione_mappa.dart';

/// LoginPage: Form di autenticazione per accesso all'app con email e password.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final ProfiloService _service = ProfiloService();
  final NotificationService _notificationService = NotificationService();

  bool loading = false;

  @override
  void initState() {
    super.initState();
    _verificaSessione();
  }

  void _verificaSessione() {
    /// Verifica se esiste una sessione utente attiva e naviga di conseguenza.
    /// Scopo: Reindirizzare automaticamente utenti autenticati all'area personale.
    /// Parametri: Nessuno (usa _service.currentUser).
    /// Valore di ritorno: void.
    /// Eccezioni: Nessuna.

    if (_service.currentUser != null) {
      Future.microtask(() {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => AreaPersonalePage(user: _service.currentUser!),
            ),
            (route) => false,
          );
        }
      });
    }
  }

  void _login() async {
    /// Autentica l'utente con email e password presso il backend.
    /// Scopo: Validare credenziali e stabilire sessione utente autenticata.
    /// Parametri: Nessuno (usa emailController e passwordController).
    /// Valore di ritorno: void (Future asincrono).
    /// Eccezioni: Mostra SnackBar con messaggio di errore se login fallisce.
    setState(() => loading = true);

    try {
      final user = await _service.login(
        LoginInput(
          email: emailController.text,
          password: passwordController.text,
        ),
      );

      if (!mounted) return;

      if (user == null) {
        if (!mounted) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email o password errata')),
          );
        });
      } else {
        // Non attendiamo la notifica per evitare ulteriori async gaps
        _notificationService
            .showTestNotification('Accesso effettuato', 'Benvenuto ${user.nome}')
            .catchError((e) => debugPrint('Errore mostra notifica test: $e'));

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => AreaPersonalePage(user: user)),
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Errore: $e')));
    }

    if (!mounted) return;
    setState(() => loading = false);
  }

  void _goToRegister() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const RegisterPage()),
    );
  }

  void _goToMappa() {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MappaPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color bgGrey = Color(0xFFF0F0F0);
    const Color buttonPurple = Color(0xFF6561C0);
    const Color buttonRed = Colors.red;
    const Color buttonGreen = Colors.green;

    return Scaffold(
      backgroundColor: bgGrey,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Logo app
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                child: Image.asset(
                  'assets/logo/logo_app.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "LOGIN",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
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
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(),
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
                  onPressed: loading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "LOGIN",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _goToRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "REGISTRATI",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "TORNA ALLA MAPPA",
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
}
