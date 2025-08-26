import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget drawer; // menu lateral diferente para cada perfil

  const TopBar({super.key, required this.title, required this.drawer});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: Text(title),
      centerTitle: true,
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.account_circle),
          onSelected: (value) async {
            if (value == "Perfil") {
              // ação futura do perfil
            } else if (value == "Sair") {
              await FirebaseAuth.instance.signOut();
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Você foi desconectado"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // fecha modal
                        Navigator.pushReplacementNamed(
                            context, "/tela_inicial");
                      },
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: "Perfil",
              child: Text("Perfil"),
            ),
            const PopupMenuItem(
              value: "Sair",
              child: Text("Sair"),
            ),
          ],
        ),
      ],
    );
  }
}
