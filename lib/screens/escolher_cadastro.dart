import 'package:flutter/material.dart';
import 'cadastro_cliente.dart';
import 'criar_salao.dart';

class EscolherCadastroPage extends StatelessWidget {
  const EscolherCadastroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cadastrar-se")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CadastroClientePage()),
                );
              },
              child: const Text("Sou Cliente"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CriarSalaoPage()),
                );
              },
              child: const Text("Sou Gestor de Negócio"),
            ),
          ],
        ),
      ),
    );
  }
}
