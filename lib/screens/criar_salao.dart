import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CriarSalaoPage extends StatefulWidget {
  const CriarSalaoPage({super.key});

  @override
  State<CriarSalaoPage> createState() => _CriarSalaoPageState();
}

class _CriarSalaoPageState extends State<CriarSalaoPage> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final _nomeSalaoController = TextEditingController();
  final _adminNomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  bool _isLoading = false;

  Future<void> _registerAdmin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      print("👉 Criando usuário admin...");

      // Cria usuário no Firebase Auth
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _senhaController.text.trim(),
      );

      final uid = credential.user?.uid;
      print("✅ Usuário criado: $uid");

      if (uid == null) throw Exception("Usuário não retornado do Firebase");

      // Cria documento do salão no Firestore
      final salaoRef = FirebaseFirestore.instance.collection("saloes").doc();

      final salaoData = {
        "id": salaoRef.id,
        "nome_salao": _nomeSalaoController.text.trim(),
        "admin_nome": _adminNomeController.text.trim(),
        "telefone": _telefoneController.text.trim(),
        "endereco": _enderecoController.text.trim(),
        "email": _emailController.text.trim(),
        "criado_em": FieldValue.serverTimestamp(),
        "usuarios": [
          {
            "uid": uid,
            "email": _emailController.text.trim(),
            "tipo": "administrador",
          }
        ]
      };

      print("👉 Criando salão no Firestore (ID: ${salaoRef.id})");
      await salaoRef.set(salaoData);
      print("✅ Salão criado com sucesso!");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Salão cadastrado com sucesso!")),
        );
        Navigator.pop(context); // volta para tela anterior
      }
    } on FirebaseAuthException catch (e) {
      print("❌ Erro no FirebaseAuth: ${e.code} - ${e.message}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro: ${e.message}")),
      );
    } catch (e) {
      print("❌ Erro inesperado: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro inesperado: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cadastrar Salão")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomeSalaoController,
                decoration: const InputDecoration(labelText: "Nome do salão"),
                validator: (v) => v == null || v.isEmpty ? "Informe o nome do salão" : null,
              ),
              TextFormField(
                controller: _adminNomeController,
                decoration: const InputDecoration(labelText: "Nome completo do administrador"),
                validator: (v) => v == null || v.isEmpty ? "Informe o nome do administrador" : null,
              ),
              TextFormField(
                controller: _telefoneController,
                decoration: const InputDecoration(labelText: "Telefone"),
                keyboardType: TextInputType.phone,
                validator: (v) => v == null || v.isEmpty ? "Informe o telefone" : null,
              ),
              TextFormField(
                controller: _enderecoController,
                decoration: const InputDecoration(labelText: "Endereço"),
                validator: (v) => v == null || v.isEmpty ? "Informe o endereço" : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v == null || v.isEmpty ? "Informe o email" : null,
              ),
              TextFormField(
                controller: _senhaController,
                decoration: const InputDecoration(labelText: "Senha"),
                obscureText: true,
                validator: (v) => v != null && v.length < 6 ? "A senha deve ter ao menos 6 caracteres" : null,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _registerAdmin,
                      child: const Text("Cadastrar salão"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
