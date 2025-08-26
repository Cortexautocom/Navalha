import 'package:flutter/material.dart';
import '../widgets/topbar.dart';

class HomeCliente extends StatelessWidget {
  const HomeCliente({super.key});

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
              child: Text("Menu (em breve)", style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            // Itens do menu do cliente/profissional serão criados depois
          ],
        ),
      ),
      body: const Center(child: Text("Bem-vindo")),
    );

  }
}
