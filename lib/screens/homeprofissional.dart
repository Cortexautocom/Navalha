import 'package:flutter/material.dart';

class HomeProfissional extends StatelessWidget {
  const HomeProfissional({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agenda do Profissional')),
      body: const Center(
        child: Text('Aqui aparecerão os próximos cortes agendados.'),
      ),
    );
  }
}
