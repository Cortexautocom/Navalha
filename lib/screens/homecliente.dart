import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/topbar.dart';
import 'agendamento.dart';

class HomeCliente extends StatelessWidget {
  const HomeCliente({super.key});

  Future<String> _getClienteSalaoId() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc =
        await FirebaseFirestore.instance.collection('clientes').doc(uid).get();
    if (doc.exists) {
      return doc['salaoId'];
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: TopBar(title: "Navalha", drawer: const SizedBox()),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.8,
        child: ListView(
          padding: EdgeInsets.zero,
          children: const [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                "Menu (em breve)",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Botão novo agendamento
            ElevatedButton.icon(
              onPressed: () async {
                final salaoId = await _getClienteSalaoId();
                if (salaoId.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("⚠️ Cliente não vinculado a nenhum salão")),
                  );
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AgendamentoPage(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text("Novo Agendamento"),
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),

            const Text(
              "Agendamentos Ativos",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Lista de agendamentos ativos do cliente
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("agendamentos")
                    .where("clienteId", isEqualTo: uid)
                    .where("status", isEqualTo: "pendente") // só os ativos
                    //.orderBy("data")
                    //.orderBy("hora")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    print("❌ Erro no StreamBuilder: ${snapshot.error}");
                    return const Center(
                        child: Text("❌ Erro ao carregar agendamentos."));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // DEBUG: mostrar no console a quantidade
                  print("🔍 Total de agendamentos recebidos: ${snapshot.data?.docs.length}");

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text("⚠️ Nenhum agendamento ativo."));
                  }

                  final agendamentos = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: agendamentos.length,
                    itemBuilder: (context, index) {
                      final ag = agendamentos[index].data()
                          as Map<String, dynamic>;

                      // DEBUG: logando cada agendamento
                      print("📌 Agendamento carregado: $ag");

                      final data = ag['data'] ?? "";
                      final hora = ag['hora'] ?? "";
                      final servico = ag['servico'] ?? "";
                      final profissionalId = ag['profissionalId'];

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection("usuarios")
                            .doc(profissionalId)
                            .get(),
                        builder: (context, snapshotProf) {
                          String profissionalNome = "Profissional";
                          if (snapshotProf.hasData &&
                              snapshotProf.data!.exists) {
                            profissionalNome =
                                snapshotProf.data!['nomeCompleto'] ??
                                    "Profissional";
                          }

                          return Card(
                            child: ListTile(
                              leading: const Icon(Icons.schedule),
                              title: Text("$data às $hora"),
                              subtitle: Text(
                                  "Profissional: $profissionalNome\nServiço: $servico"),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
