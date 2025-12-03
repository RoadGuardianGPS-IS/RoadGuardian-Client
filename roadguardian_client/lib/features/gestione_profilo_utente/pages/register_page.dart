import 'package:flutter/material.dart';
import 'package:roadguardian_client/features/gestione_profilo_utente/pages/cancellazione_profilo.dart';
import 'package:roadguardian_client/services/api/mock_service.dart';
import 'package:roadguardian_client/features/gestione_profilo_utente/models/user_model.dart';

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

  bool loading = false;
  List<UserModel> users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() async {
    final fetchedUsers = await fetchUsers();
    if (!mounted) return;
    setState(() {
      users = fetchedUsers;
    });
  }

  void _register() async {
    if (passwordController.text != confirmPasswordController.text) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le password non coincidono!')),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    final fullName = '${nameController.text} ${surnameController.text}';

    final newUser = await registerUser(
      fullName,
      emailController.text,
      passwordController.text,
      phone: phoneController.text,
    );

    if (!mounted) return;

    setState(() {
      loading = false;
      nameController.clear();
      surnameController.clear();
      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();
      phoneController.clear();
      users.add(newUser);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Utente ${newUser.nome} registrato!')),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CancellazioneProfiloPage(user: newUser),
      ),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "AREA REGISTRAZIONE",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 40),

              // FORM
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Nome",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: surnameController,
                      decoration: const InputDecoration(
                        labelText: "Cognome",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 16),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Conferma Password",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: "Numero di telefono",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: loading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6561C0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "CONFERMA REGISTRAZIONE",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Utenti registrati:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  // user.nome, user.cognome e user.email sono non-nullable per come è definita la UserModel
                  // user.numeroTelefono rimane opzionale: uso ?? '' per sicurezza
                  return ListTile(
                    title: Text('${user.nome} ${user.cognome}'),
                    subtitle: Text('${user.email} • ${user.numeroTelefono ?? ""}'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
