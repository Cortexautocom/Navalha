import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AgendamentoPage extends StatefulWidget {
  const AgendamentoPage({super.key});

  @override
  State<AgendamentoPage> createState() => _AgendamentoPageState();
}

class _AgendamentoPageState extends State<AgendamentoPage> {
  String? _profissionalSelecionado;
  DateTime? _dataSelecionada;
  final TextEditingController _servicoController = TextEditingController();

  Future<void> _salvarAgendamento() async {
    final user = FirebaseAuth.instance.currentUser;

    if (_profissionalSelecionado == null ||
        _dataSelecionada == null ||
        _servicoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preencha todos os campos")),
      );
      return;
    }

    try {
      // pegar dados do cliente logado
      final usuarioDoc = await FirebaseFirestore.instance
          .collection("usuarios")
          .doc(user!.uid)
          .get();

      final salaoId = usuarioDoc['salao_id'];

      await FirebaseFirestore.instance.collection("agendamentos").add({
        "cliente_id": user.uid,
        "profissional_id": _profissionalSelecionado,
        "salao_id": salaoId,
        "data_hora": _dataSelecionada!.toIso8601String(),
        "servico": _servicoController.text.trim(),
        "status": "pendente",
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Agendamento criado com sucesso!")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao salvar: $e")),
      );
    }
  }

  Future<void> _selecionarData() async {
    final agora = DateTime.now();
    final data = await showDatePicker(
      context: context,
      initialDate: agora,
      firstDate: agora,
      lastDate: DateTime(agora.year + 1),
    );

    if (data != null) {
      final hora = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (hora != null) {
        setState(() {
          _dataSelecionada = DateTime(
            data.year,
            data.month,
            data.day,
            hora.hour,
            hora.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Novo Agendamento")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Lista suspensa de profissionais
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("usuarios")
                  .where("tipo", isEqualTo: "profissional")
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                final docs = snapshot.data!.docs;
                return DropdownButtonFormField<String>(
                  value: _profissionalSelecionado,
                  hint: const Text("Selecione o profissional"),
                  isExpanded: true,
                  items: docs.map((doc) {
                    return DropdownMenuItem<String>(
                      value: doc.id,
                      child: Text(doc["email"]),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _profissionalSelecionado = value;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 20),

            // Campo serviço
            TextField(
              controller: _servicoController,
              decoration: const InputDecoration(labelText: "Serviço"),
            ),
            const SizedBox(height: 20),

            // Seleção de data/hora
            Row(
              children: [
                Expanded(
                  child: Text(
                    _dataSelecionada == null
                        ? "Nenhuma data selecionada"
                        : "Data: ${_dataSelecionada.toString()}",
                  ),
                ),
                ElevatedButton(
                  onPressed: _selecionarData,
                  child: const Text("Selecionar Data/Hora"),
                ),
              ],
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _salvarAgendamento,
              child: const Text("Salvar Agendamento"),
            )
          ],
        ),
      ),
    );
  }
}
