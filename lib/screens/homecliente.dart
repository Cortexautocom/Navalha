import 'package:flutter/material.dart';

class HomeCliente extends StatelessWidget {
  const HomeCliente({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Área do Cliente')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Bem-vindo, Cliente!'),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/agendamento');
              },
              child: const Text('Novo Agendamento'),
            ),
          ],
        ),
      ),
    );
  }
}
