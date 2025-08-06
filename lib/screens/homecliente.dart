import 'package:flutter/material.dart';
import 'agendamento.dart';
import 'paineladmin.dart';

class HomeCliente extends StatelessWidget {
  const HomeCliente({super.key});

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
          ],
        ),
      ),
    );
  }
}
