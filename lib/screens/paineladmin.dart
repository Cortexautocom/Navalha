import 'package:flutter/material.dart';

class PainelAdmin extends StatelessWidget {
  const PainelAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Painel do Administrador')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Filtros de pesquisa
            Row(
              children: const [
                Expanded(child: TextField(decoration: InputDecoration(labelText: 'Profissional'))),
                SizedBox(width: 10),
                Expanded(child: TextField(decoration: InputDecoration(labelText: 'Data'))),
                SizedBox(width: 10),
                Expanded(child: TextField(decoration: InputDecoration(labelText: 'Cliente'))),
              ],
            ),
            const SizedBox(height: 20),
            const Expanded(
              child: Center(
                child: Text('Resultados da pesquisa aparecerão aqui.'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
