import 'package:flutter/material.dart';

class Agendamento extends StatefulWidget {
  const Agendamento({super.key});

  @override
  State<Agendamento> createState() => _AgendamentoState();
}

class _AgendamentoState extends State<Agendamento> {
  String? profissionalSelecionado;
  DateTime? dataSelecionada;
  TimeOfDay? horarioSelecionado;

  final List<String> profissionais = ['Anderson', 'Carlos', 'Mateus'];

  void _selecionarData() async {
    final DateTime? data = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (data != null) {
      setState(() {
        dataSelecionada = data;
      });
    }
  }

  void _selecionarHorario() async {
    final TimeOfDay? horario = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (horario != null) {
      setState(() {
        horarioSelecionado = horario;
      });
    }
  }

  void _confirmarAgendamento() {
    if (profissionalSelecionado != null && dataSelecionada != null && horarioSelecionado != null) {
      // Aqui futuramente você vai salvar no Firebase
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agendamento confirmado!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Agendamento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: profissionalSelecionado,
              decoration: const InputDecoration(labelText: 'Profissional'),
              items: profissionais.map((String nome) {
                return DropdownMenuItem(value: nome, child: Text(nome));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  profissionalSelecionado = value;
                });
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(
                dataSelecionada != null
                    ? 'Data: ${dataSelecionada!.day}/${dataSelecionada!.month}/${dataSelecionada!.year}'
                    : 'Selecionar data',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selecionarData,
            ),
            ListTile(
              title: Text(
                horarioSelecionado != null
                    ? 'Horário: ${horarioSelecionado!.format(context)}'
                    : 'Selecionar horário',
              ),
              trailing: const Icon(Icons.access_time),
              onTap: _selecionarHorario,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _confirmarAgendamento,
              child: const Text('Confirmar Agendamento'),
            ),
          ],
        ),
      ),
    );
  }
}
