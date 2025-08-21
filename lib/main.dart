import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_options.dart';
import 'screens/homecliente.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase usando as opções corretas
  print('🔥 FirebaseOptions: ${DefaultFirebaseOptions.currentPlatform}');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicializa o Analytics (opcional, mas útil para depuração)
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  await analytics.logEvent(name: 'app_iniciado');

  runApp(const Navalha());
}

class Navalha extends StatelessWidget {
  const Navalha({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navalha',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeCliente(),
    );
  }
}
