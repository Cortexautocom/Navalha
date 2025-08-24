import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CadastroProfissionalPage extends StatefulWidget {
  final String salaoId; // ID do salão do admin logado

  const CadastroProfissionalPage({super.key, required this.salaoId});

  @override
  State<CadastroProfissionalPage> createState() => _CadastroProfissionalPageState();
}

class _CadastroProfissionalPageState extends State<CadastroProfissionalPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  bool _loading = false;

  Future<void> _cadastrarProfissional() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      // 1. Criar usuário no Firebase Auth
      UserCredential cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _senhaController.text.trim(),
      );

      final uid = cred.user!.uid;

      // 2. Salvar no Firestore em "usuarios"
      await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
        'uid': uid,
        'nomeCompleto': _nomeController.text.trim(),
        'email': _emailController.text.trim(),
        'tipo': 'profissional',
        'salaoId': widget.salaoId,
        'createdAt': DateTime.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Profissional cadastrado com sucesso!")),
      );

      Navigator.pop(context); // volta para painel admin
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
      appBar: AppBar(title: const Text("Cadastrar Profissional")),
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
                      onPressed: _cadastrarProfissional,
                      child: const Text("Cadastrar"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
