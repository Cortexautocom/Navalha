import 'package:flutter/material.dart';
import '../widgets/topbar.dart';

class HomeProfissional extends StatelessWidget {
  const HomeProfissional({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(title: "Navalha", drawer: const SizedBox()),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.8,
        child: ListView(
          padding: EdgeInsets.zero,
          children: const [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                "Menu (em breve)",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            // futuramente adicionaremos os itens do menu
          ],
        ),
      ),
      body: const Center(
        child: Text(
          "Bem-vindo, profissional",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
