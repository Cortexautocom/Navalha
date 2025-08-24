import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'cadastro_profissional.dart';
import 'cadastro_gestor.dart';

class PainelAdmin extends StatefulWidget {
  const PainelAdmin({super.key});

  @override
  State<PainelAdmin> createState() => _PainelAdminState();
}

class _PainelAdminState extends State<PainelAdmin> {
  String? _salaoId;
  bool _loading = true;
  bool _ehGestorPrimario = false;

  @override
  void initState() {
    super.initState();
    _carregarSalaoId();
  }

  Future<void> _carregarSalaoId() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final usuarioDoc =
          await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();

      if (usuarioDoc.exists) {
        _salaoId = usuarioDoc['salaoId'];

        // Verificar se este UID é o adminId do salão
        final salaoDoc = await FirebaseFirestore.instance
            .collection('saloes')
            .doc(_salaoId)
            .get();

        if (salaoDoc.exists && salaoDoc['adminId'] == uid) {
          _ehGestorPrimario = true;
        }

        setState(() => _loading = false);
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      print("❌ Erro ao buscar salaoId: $e");
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_salaoId == null) {
      return const Scaffold(
        body: Center(child: Text("⚠️ Nenhum salão vinculado a este admin.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Painel do Gestor")),
      body: Column(
        children: [
          const SizedBox(height: 16),

          // Botão cadastrar profissional (sempre disponível)
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CadastroProfissionalPage(salaoId: _salaoId!),
                ),
              );
            },
            child: const Text("Cadastrar Profissional"),
          ),

          const SizedBox(height: 12),

          // Botão cadastrar gestor (apenas primário)
          if (_ehGestorPrimario)
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CadastroGestorPage(salaoId: _salaoId!),
                  ),
                );
              },
              child: const Text("Cadastrar Novo Gestor"),
            ),

          const SizedBox(height: 20),

          // 🔹 LISTA DE PROFISSIONAIS
          const Text(
            "Profissionais do Salão",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('usuarios')
                  .where('tipo', isEqualTo: 'profissional')
                  .where('salaoId', isEqualTo: _salaoId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("❌ Erro ao carregar profissionais."));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("⚠️ Nenhum profissional cadastrado ainda."));
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final prof = docs[index].data() as Map<String, dynamic>;
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(prof['nomeCompleto'] ?? "Sem nome"),
                      subtitle: Text(prof['email'] ?? "Sem e-mail"),
                    );
                  },
                );
              },
            ),
          ),

          // 🔹 LISTA DE GESTORES
          const Text(
            "Gestores do Salão",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('usuarios')
                  .where('tipo', isEqualTo: 'administrador')
                  .where('salaoId', isEqualTo: _salaoId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("❌ Erro ao carregar gestores."));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("⚠️ Nenhum gestor cadastrado ainda."));
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final gestor = docs[index].data() as Map<String, dynamic>;
                    final isPrimario = gestor['uid'] ==
                        (FirebaseAuth.instance.currentUser!.uid); // só exibição

                    return ListTile(
                      leading: const Icon(Icons.admin_panel_settings),
                      title: Text(gestor['nomeCompleto'] ?? "Sem nome"),
                      subtitle: Text(
                        (gestor['email'] ?? "Sem e-mail") +
                            (isPrimario ? " (Primário)" : ""),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
