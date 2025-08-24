import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CadastroGestorPage extends StatefulWidget {
  final String salaoId;

  const CadastroGestorPage({super.key, required this.salaoId});

  @override
  State<CadastroGestorPage> createState() => _CadastroGestorPageState();
}

class _CadastroGestorPageState extends State<CadastroGestorPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  bool _loading = false;

  Future<void> _cadastrarGestor() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      // Criar usuário no Firebase Auth
      UserCredential cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _senhaController.text.trim(),
      );

      final uid = cred.user!.uid;

      // Salvar no Firestore
      await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
        'uid': uid,
        'nomeCompleto': _nomeController.text.trim(),
        'email': _emailController.text.trim(),
        'tipo': 'administrador', // também é gestor
        'salaoId': widget.salaoId,
        'createdAt': DateTime.now(),
        'isPrimario': false, // 👈 marcamos que é secundário
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Gestor cadastrado com sucesso!")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Erro ao cadastrar: $e")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cadastrar Novo Gestor")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: "Nome completo"),
                validator: (v) => v == null || v.isEmpty ? "Informe o nome" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "E-mail"),
                validator: (v) =>
                    v == null || !v.contains('@') ? "Digite um e-mail válido" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _senhaController,
                decoration: const InputDecoration(labelText: "Senha"),
                obscureText: true,
                validator: (v) =>
                    v == null || v.length < 6 ? "Mínimo 6 caracteres" : null,
              ),
              const SizedBox(height: 24),
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _cadastrarGestor,
                      child: const Text("Cadastrar"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
