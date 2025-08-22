import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TestFirebasePage extends StatefulWidget {
  const TestFirebasePage({super.key});

  @override
  State<TestFirebasePage> createState() => _TestFirebasePageState();
}

class _TestFirebasePageState extends State<TestFirebasePage> {
  String _status = "Clique no botão para testar Firebase";

  Future<void> _runTest() async {
    try {
      // 1. Criar usuário fake (se já existir, loga com ele)
      const email = "teste@navalha.com";
      const senha = "123456";

      UserCredential user;
      try {
        user = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: senha,
        );
        setState(() => _status = "Usuário criado: ${user.user?.uid}");
      } catch (e) {
        // Se já existe, faz login
        user = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: senha,
        );
        setState(() => _status = "Login realizado: ${user.user?.uid}");
      }

      // 2. Criar documento no Firestore
      final docRef = FirebaseFirestore.instance.collection("testes").doc();
      await docRef.set({
        "mensagem": "Olá do Navalha!",
        "timestamp": DateTime.now().toIso8601String(),
        "user_id": user.user?.uid,
      });

      // 3. Ler de volta
      final snapshot = await docRef.get();
      setState(() => _status =
          "Firestore OK → ${snapshot.data()?['mensagem']} (doc: ${docRef.id})");
    } catch (e) {
      setState(() => _status = "Erro: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Teste Firebase")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_status, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _runTest,
              child: const Text("Rodar Teste"),
            ),
          ],
        ),
      ),
    );
  }
}
