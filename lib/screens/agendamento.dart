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

  String? _salaoIdDoCliente;
  bool _loadingSalao = true;

  @override
  void initState() {
    super.initState();
    _carregarSalaoDoCliente();
  }

  Future<void> _carregarSalaoDoCliente() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final clienteDoc = await FirebaseFirestore.instance
        .collection("clientes")
        .doc(user.uid)
        .get();

    if (clienteDoc.exists) {
      setState(() {
        _salaoIdDoCliente = clienteDoc['salaoId']; // 👈 campo salvo no cadastro do cliente
        _loadingSalao = false;
      });
    } else {
      setState(() => _loadingSalao = false);
    }
  }

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
      await FirebaseFirestore.instance.collection("agendamentos").add({
        "clienteId": user!.uid,
        "profissionalId": _profissionalSelecionado,
        "salaoId": _salaoIdDoCliente,
        "data": "${_dataSelecionada!.year}-${_dataSelecionada!.month.toString().padLeft(2, '0')}-${_dataSelecionada!.day.toString().padLeft(2, '0')}", // formato yyyy-MM-dd
        "hora": "${_dataSelecionada!.hour.toString().padLeft(2, '0')}:${_dataSelecionada!.minute.toString().padLeft(2, '0')}",
        "servico": _servicoController.text.trim(),
        "status": "pendente",
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Agendamento criado com sucesso!")),
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
    if (_loadingSalao) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_salaoIdDoCliente == null) {
      return const Scaffold(
        body: Center(child: Text("⚠️ Não foi possível identificar o salão do cliente.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Novo Agendamento")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Lista suspensa de profissionais (filtrados pelo salão do cliente)
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("usuarios")
                  .where("tipo", isEqualTo: "profissional")
                  .where("salaoId", isEqualTo: _salaoIdDoCliente)
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
                      child: Text(doc["nomeCompleto"] ?? doc["email"]),
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
