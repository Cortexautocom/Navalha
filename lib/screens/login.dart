import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'criar_salao.dart';
import 'cadastro_cliente.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  Future<void> _login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _senhaController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Login realizado com sucesso")),
      );

      // TODO: Redirecionar para a tela certa (cliente, admin ou profissional)
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Erro no login: $e")),
      );
    }
  }

  void _abrirCadastro() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cadastrar como:"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // fecha o diálogo
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CadastroClientePage()),
              );
            },
            child: const Text("Cliente"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // fecha o diálogo
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CriarSalaoPage()),
              );
            },
            child: const Text("Dono de Salão"),
          ),
        ],
      ),
    );
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
              decoration: const InputDecoration(labelText: "Senha"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text("Entrar"),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _abrirCadastro,
              child: const Text("Cadastrar"),
            ),
          ],
        ),
      ),
    );
  }
}
