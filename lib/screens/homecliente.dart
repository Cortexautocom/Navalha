import 'package:flutter/material.dart';
import 'agendamento.dart';
import 'paineladmin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class HomeCliente extends StatelessWidget {
  const HomeCliente({super.key});

  void adicionarCliente() {
    FirebaseFirestore.instance.collection('clientes').add({
      'nome': 'Leonardo',
      'email': 'leonardo@email.com',
      'criado_em': Timestamp.now(),
    }).then((_) {
      debugPrint('✅ Cliente adicionado com sucesso');
    }).catchError((error) {
      debugPrint('❌ Erro ao adicionar cliente: $error');
    });
  }

  void listarClientes() async {
    final snapshot = await FirebaseFirestore.instance.collection('clientes').get();
    for (var doc in snapshot.docs) {
      debugPrint('📄 ${doc.data()}');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendar Horário'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Agendamento()),
                );
              },
              child: const Text('Agendar agora'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PainelAdmin()),
                );
              },
              child: const Text('Painel do Administrador'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: adicionarCliente,
              child: const Text('➕ Adicionar Cliente'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: listarClientes,
              child: const Text('📄 Listar Clientes no Console'),
            ),
          ],
        ),
      ),
    );
  }
}
