import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'cadastro_profissional.dart';
import '../widgets/topbar.dart';


class PainelAdmin extends StatefulWidget {
  const PainelAdmin({super.key});

  @override
  State<PainelAdmin> createState() => _PainelAdminState();
}

class _PainelAdminState extends State<PainelAdmin> {
  String _paginaAtual = "Agendamentos";
  String? _salaoId;
  String _filtroData = "Hoje";
  DateTime _dataSelecionada = DateTime.now();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _carregarSalaoId();
  }

  Future<void> _carregarSalaoId() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final usuarioDoc =
          await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();

      if (usuarioDoc.exists) {
        setState(() {
          _salaoId = usuarioDoc['salaoId'];
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      print("❌ Erro ao buscar salaoId: $e");
      setState(() => _loading = false);
    }
  }

  Widget _getPagina() {
    switch (_paginaAtual) {
      case "Agendamentos":
        return _buildAgendamentos();
      case "Profissionais cadastrados":
        return _buildProfissionais();
      case "Outros gestores":
        return const Center(child: Text("👥 Lista de gestores"));
      case "Gerenciar planos":
        return const Center(child: Text("💳 Gerenciar planos"));
      default:
        return const Center(child: Text("Página não encontrada"));
    }
  }

  // 🔹 Lista de agendamentos do dia
  Widget _buildAgendamentos() {
    if (_salaoId == null) {
      return const Center(child: Text("⚠️ Nenhum salão vinculado."));
    }

    return Column(
      children: [
        // Dropdown de filtro
        DropdownButton<String>(
          value: _filtroData,
          items: const [
            DropdownMenuItem(value: "Hoje", child: Text("Hoje")),
            DropdownMenuItem(value: "Amanhã", child: Text("Amanhã")),
            DropdownMenuItem(value: "Escolher", child: Text("Escolher data")),
            DropdownMenuItem(value: "Todos", child: Text("Todos")), // 👈 novo
          ],
          onChanged: (value) async {
            if (value == null) return;

            if (value == "Escolher") {
              final data = await showDatePicker(
                context: context,
                initialDate: _dataSelecionada,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (data != null) {
                setState(() {
                  _dataSelecionada = data;
                  _filtroData = "Escolher";
                });
              }
            } else {
              setState(() {
                _filtroData = value;
                if (value == "Hoje") {
                  _dataSelecionada = DateTime.now();
                } else if (value == "Amanhã") {
                  _dataSelecionada = DateTime.now().add(const Duration(days: 1));
                }
              });
            }
          },
        ),

        const SizedBox(height: 10),

        // Lista de agendamentos filtrados
        Expanded(
          child: _buildListaAgendamentos(),
        ),
      ],
    );
  }



  Widget _buildProfissionais() {
    if (_salaoId == null) {
      return const Center(child: Text("⚠️ Nenhum salão vinculado."));
    }

    return Column(
      children: [
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CadastroProfissionalPage(salaoId: _salaoId!),
              ),
            );
          },
          child: const Text("Cadastrar Profissional"),
        ),
        const SizedBox(height: 20),
        const Text(
          "Profissionais do Salão",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Divider(),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('usuarios')
                .where('tipo', isEqualTo: 'profissional')
                .where('salaoId', isEqualTo: _salaoId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text("❌ Erro ao carregar profissionais."));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("⚠️ Nenhum profissional cadastrado ainda."));
              }

              final docs = snapshot.data!.docs;

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final prof = docs[index].data() as Map<String, dynamic>;
                  return ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(prof['nomeCompleto'] ?? "Sem nome"),
                    subtitle: Text(prof['email'] ?? "Sem e-mail"),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildListaAgendamentos() {
    if (_salaoId == null) {
      return const Center(child: Text("⚠️ Nenhum salão vinculado."));
    }

    final dataFormatada =
        "${_dataSelecionada.year}-${_dataSelecionada.month.toString().padLeft(2, '0')}-${_dataSelecionada.day.toString().padLeft(2, '0')}";

    // Query base
    Query query = FirebaseFirestore.instance
        .collection('agendamentos')
        .where('salaoId', isEqualTo: _salaoId);

    // Se não for "Todos", aplica filtro de data
    if (_filtroData != "Todos") {
      query = query.where('data', isEqualTo: dataFormatada);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.orderBy('hora').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print("❌ Erro ao buscar agendamentos: ${snapshot.error}");
          return const Center(child: Text("❌ Erro ao carregar agendamentos."));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("⚠️ Nenhum agendamento encontrado."));
        }

        final agendamentos = snapshot.data!.docs;

        return ListView.builder(
          itemCount: agendamentos.length,
          itemBuilder: (context, index) {
            final ag = agendamentos[index].data() as Map<String, dynamic>;

            final hora = ag['hora'] ?? "Sem hora";
            final clienteId = ag['clienteId'];
            final profissionalId = ag['profissionalId'];

            return FutureBuilder<Map<String, String>>(
              future: _buscarNomes(clienteId, profissionalId),
              builder: (context, snapshotNomes) {
                if (!snapshotNomes.hasData) {
                  return const ListTile(
                    leading: Icon(Icons.access_time),
                    title: Text("Carregando..."),
                  );
                }

                final nomes = snapshotNomes.data!;
                final clienteNome = nomes['cliente'] ?? "Cliente";
                final profissionalNome = nomes['profissional'] ?? "Profissional";

                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.access_time),
                    title: Text("$hora - $clienteNome"),
                    subtitle: Text("Profissional: $profissionalNome"),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }



  // 🔹 Busca nomes de cliente e profissional
  Future<Map<String, String>> _buscarNomes(
      String clienteId, String profissionalId) async {
    String? clienteNome;
    String? profissionalNome;

    try {
      final clienteDoc = await FirebaseFirestore.instance
          .collection('clientes')
          .doc(clienteId)
          .get();
      if (clienteDoc.exists) {
        clienteNome = clienteDoc['nome'];
      }

      final profDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(profissionalId)
          .get();
      if (profDoc.exists) {
        profissionalNome = profDoc['nomeCompleto'];
      }
    } catch (e) {
      print("Erro ao buscar nomes: $e");
    }

    return {
      'cliente': clienteNome ?? "Cliente",
      'profissional': profissionalNome ?? "Profissional",
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      // TOP BAR
      appBar: TopBar(title: "Navalha", drawer: const SizedBox()),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.8,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text("Menu", style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text("Agendamentos"),
              onTap: () {
                setState(() => _paginaAtual = "Agendamentos");
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text("Profissionais cadastrados"),
              onTap: () {
                setState(() => _paginaAtual = "Profissionais cadastrados");
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text("Outros gestores"),
              onTap: () {
                setState(() => _paginaAtual = "Outros gestores");
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text("Gerenciar planos"),
              onTap: () {
                setState(() => _paginaAtual = "Gerenciar planos");
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),


      // CONTEÚDO PRINCIPAL
      body: _getPagina(),
    );
  }
}
