import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/topbar.dart';

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
        appBar: TopBar(title: "Navalha", drawer: const SizedBox()),
        drawer: Drawer(
            width: MediaQuery.of(context).size.width * 0.8,
            child: ListView(
            padding: EdgeInsets.zero,
            children: const [
                DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: Text("Menu (em breve)", style: TextStyle(color: Colors.white, fontSize: 24)),
                ),
                // Itens do menu do cliente/profissional serão criados depois
            ],
            ),
        ),
        body: const Center(child: Text("Bem-vindo")),
        );

  }
}
