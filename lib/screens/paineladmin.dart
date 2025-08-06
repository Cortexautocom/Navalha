import 'package:flutter/material.dart';

class PainelAdmin extends StatelessWidget {
  const PainelAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    // Lista de agendamentos fictícios (para teste visual)
    final List<Map<String, String>> agendamentos = [
      {
        'cliente': 'João Silva',
        'profissional': 'Anderson',
        'data': '07/08/2025',
        'hora': '14:00',
      },
      {
        'cliente': 'Maria Souza',
        'profissional': 'Carlos',
        'data': '07/08/2025',
        'hora': '15:30',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel do Administrador'),
      ),
      body: ListView.builder(
        itemCount: agendamentos.length,
        itemBuilder: (context, index) {
          final agendamento = agendamentos[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(agendamento['cliente']!),
              subtitle: Text(
                  '${agendamento['profissional']} • ${agendamento['data']} às ${agendamento['hora']}'),
              trailing: const Icon(Icons.check_circle_outline),
            ),
          );
        },
      ),
    );
  }
}
