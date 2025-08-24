import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'homecliente.dart';
import 'homeprofissional.dart';
import 'paineladmin.dart';
import 'cadastro_cliente.dart';
import 'criar_salao.dart';

class TelaInicial extends StatelessWidget {
  const TelaInicial({super.key});

  void _mostrarLoginDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController senhaController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Login"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "E-mail"),
              ),
              TextField(
                controller: senhaController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Senha"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: emailController.text.trim(),
                    password: senhaController.text.trim(),
                  );

                  final uid = cred.user!.uid;

                  // Verificar se é usuário (admin/profissional)
                  final usuarioDoc = await FirebaseFirestore.instance
                      .collection('usuarios')
                      .doc(uid)
                      .get();

                  if (usuarioDoc.exists) {
                    final tipo = usuarioDoc['tipo'];
                    if (tipo == 'administrador') {
                      Navigator.pop(context); // fecha modal
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const PainelAdmin()),
                      );
                      return;
                    } else if (tipo == 'profissional') {
                      Navigator.pop(context); // fecha modal
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeProfissional()),
                      );
                      return;
                    }
                  }

                  // Verificar se é cliente
                  final clienteDoc = await FirebaseFirestore.instance
                      .collection('clientes')
                      .doc(uid)
                      .get();

                  if (clienteDoc.exists) {
                    Navigator.pop(context); // fecha modal
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeCliente()),
                    );
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("⚠️ Usuário não encontrado no sistema.")),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("❌ Erro no login: $e")),
                  );
                }
              },
              child: const Text("Entrar"),
            ),
          ],
        );
      },
    );
  }

  void _mostrarCadastroDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Cadastrar-se"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // fecha modal
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CadastroClientePage()),
                  );
                },
                child: const Text("Sou Cliente"),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // fecha modal
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CriarSalaoPage()),
                  );
                },
                child: const Text("Sou Gestor de Negócio"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Navalha")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _mostrarLoginDialog(context),
              child: const Text("Login"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _mostrarCadastroDialog(context),
              child: const Text("Cadastrar"),
            ),
          ],
        ),
      ),
    );
  }
}
