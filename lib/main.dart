import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/agendamento.dart';
import 'screens/tela_inicial.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const Navalha());
}

class Navalha extends StatelessWidget {
  const Navalha({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navalha',
      theme: ThemeData(primarySwatch: Colors.teal),
      initialRoute: '/tela_inicial',
      routes: {
        '/tela_inicial': (_) => const TelaInicial(),          
        '/agendamento': (_) => const AgendamentoPage(),
      },
    );
  }
}

