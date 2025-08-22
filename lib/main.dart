import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login.dart';
import 'screens/agendamento.dart';

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
      home: const LoginPage(),
      routes: {
        '/agendamento': (_) => const AgendamentoPage(),
      },
    );
  }
}
