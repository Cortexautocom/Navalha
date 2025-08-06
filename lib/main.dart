import 'package:flutter/material.dart';
import 'screens/homecliente.dart';

void main() {
  runApp(const AppBarbearia());
}

class AppBarbearia extends StatelessWidget {
  const AppBarbearia({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Barbearia',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeCliente(),
    );
  }
}
