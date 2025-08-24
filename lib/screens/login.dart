import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Importar as telas
import 'homecliente.dart';
import 'homeprofissional.dart';
import 'paineladmin.dart';

class LoginPage extends StatefulWidget {
  final String email;
  final String senha;

  const LoginPage({
    super.key,
    this.email = "",
    this.senha = "",
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController _emailController;
  late TextEditingController _senhaController;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.email);
    _senhaController = TextEditingController(text: widget.senha);
  }

  Future<void> _login() async {
    setState(() => _loading = true);

    try {
      // 1. Autenticar usuário
      UserCredential cred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _senhaController.text.trim(),
      );

      User? user = cred.user;
      if (user == null) throw Exception("Erro ao logar.");

      final uid = user.uid;

      // 2. Buscar em "usuarios"
      final usuarioDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .get();

      if (usuarioDoc.exists) {
        final data = usuarioDoc.data()!;
        final tipo = data['tipo'];

        if (tipo == 'administrador') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => PainelAdmin()),
          );
          return;
        } else if (tipo == 'profissional') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomeProfissional()),
          );
          return;
        }
      }

      // 3. Se não achou em usuarios, buscar em clientes
      final clienteDoc = await FirebaseFirestore.instance
          .collection('clientes')
          .doc(uid)
          .get();

      if (clienteDoc.exists) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeCliente()),
        );
        return;
      }

      // 4. Se não achou em nenhum lugar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Usuário não encontrado no sistema.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Erro no login: $e")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "E-mail"),
            ),
            TextField(
              controller: _senhaController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Senha"),
            ),
            const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    child: const Text("Entrar"),
                  ),
          ],
        ),
      ),
    );
  }
}
