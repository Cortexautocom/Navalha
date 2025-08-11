import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'screens/homecliente.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Sem opções específicas
  runApp(const Navalha());

  if (!kIsWeb) {
    try {
      await Firebase.initializeApp();
      debugPrint('✅ Firebase inicializado com sucesso');

      FirebaseAnalytics analytics = FirebaseAnalytics.instance;
      analytics.logEvent(name: 'teste_inicializacao');
    } catch (e) {
      debugPrint('❌ Erro ao inicializar Firebase: $e');
    }
  }

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

