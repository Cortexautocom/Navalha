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

  // Controllers
  final TextEditingController _nomeSalaoController = TextEditingController();
  final TextEditingController _nomeAdminController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _enderecoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  bool _loading = false;

  Future<void> _registerAdminAndSalon() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      print("👉 Criando usuário admin...");

      // 1. Criar usuário no Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _senhaController.text.trim(),
      );

      User? user = userCredential.user;
      if (user == null) throw Exception("Erro ao criar usuário.");

      print("✅ Usuário criado: ${user.uid}");

      // 2. Criar documento do salão no Firestore (coleção principal)
      String salaoId = FirebaseFirestore.instance.collection('saloes').doc().id;

      print("👉 Criando salão no Firestore (ID: $salaoId)");

      await FirebaseFirestore.instance.collection('saloes').doc(salaoId).set({
        'id': salaoId,
        'nomeSalao': _nomeSalaoController.text.trim(),
        'nomeAdmin': _nomeAdminController.text.trim(),
        'telefone': _telefoneController.text.trim(),
        'endereco': _enderecoController.text.trim(),
        'email': _emailController.text.trim(),
        'adminId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 3. Criar documento público apenas com o nome
      await FirebaseFirestore.instance
          .collection('saloes_publicos')
          .doc(salaoId)
          .set({
        'nomeSalao': _nomeSalaoController.text.trim(),
      });

      // 4. Criar documento do usuário administrador na coleção "usuarios"
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .set({
        'uid': user.uid,
        'nomeCompleto': _nomeAdminController.text.trim(),
        'email': _emailController.text.trim(),
        'tipo': 'administrador',
        'salaoId': salaoId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print("✅ Salão e administrador cadastrados com sucesso!");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Salão criado com sucesso!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print("❌ Erro inesperado: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cadastrar novo salão")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeSalaoController,
                decoration: const InputDecoration(labelText: "Nome do Salão"),
                validator: (value) =>
                    value!.isEmpty ? "Informe o nome do salão" : null,
              ),
              TextFormField(
                controller: _nomeAdminController,
                decoration:
                    const InputDecoration(labelText: "Nome Completo do Admin"),
                validator: (value) =>
                    value!.isEmpty ? "Informe o nome do administrador" : null,
              ),
              TextFormField(
                controller: _telefoneController,
                decoration: const InputDecoration(labelText: "Telefone"),
              ),
              TextFormField(
                controller: _enderecoController,
                decoration: const InputDecoration(labelText: "Endereço"),
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (value) =>
                    value!.isEmpty ? "Informe o email" : null,
              ),
              TextFormField(
                controller: _senhaController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Senha"),
                validator: (value) =>
                    value!.length < 6 ? "Mínimo 6 caracteres" : null,
              ),
              const SizedBox(height: 20),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _registerAdminAndSalon,
                      child: const Text("Cadastrar salão"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
