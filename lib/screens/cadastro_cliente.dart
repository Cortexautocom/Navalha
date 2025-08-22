import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CadastroClientePage extends StatefulWidget {
  const CadastroClientePage({super.key});

  @override
  State<CadastroClientePage> createState() => _CadastroClientePageState();
}

class _CadastroClientePageState extends State<CadastroClientePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  String? _salaoSelecionado;
  List<Map<String, dynamic>> _saloes = [];

  @override
  void initState() {
    super.initState();
    _carregarSaloes();
  }

  Future<void> _carregarSaloes() async {
    final snapshot = await FirebaseFirestore.instance.collection('saloes').get();
    setState(() {
      _saloes = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'nome': doc['nome'],
        };
      }).toList();
    });
  }

  Future<void> _cadastrarCliente() async {
    if (!_formKey.currentState!.validate() || _salaoSelecionado == null) return;

    try {
      // Cria usuário no Firebase Auth
      UserCredential cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _senhaController.text.trim(),
      );

      // Salva no Firestore
      await FirebaseFirestore.instance.collection('clientes').doc(cred.user!.uid).set({
        'nome': _nomeController.text.trim(),
        'email': _emailController.text.trim(),
        'salaoId': _salaoSelecionado,
        'criadoEm': DateTime.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Cliente cadastrado com sucesso!")),
      );

      Navigator.pop(context); // volta para a tela anterior
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Erro no cadastro: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cadastro de Cliente")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: "Nome"),
                validator: (v) => v == null || v.isEmpty ? "Digite seu nome" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "E-mail"),
                validator: (v) => v == null || !v.contains('@') ? "Digite um e-mail válido" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _senhaController,
                decoration: const InputDecoration(labelText: "Senha"),
                obscureText: true,
                validator: (v) => v == null || v.length < 6 ? "Mínimo 6 caracteres" : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Selecione o salão"),
                items: _saloes.map((s) {
                  return DropdownMenuItem<String>(
                    value: s['id'],
                    child: Text(s['nome']),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _salaoSelecionado = val;
                  });
                },
                validator: (v) => v == null ? "Selecione um salão" : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _cadastrarCliente,
                child: const Text("Cadastrar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
