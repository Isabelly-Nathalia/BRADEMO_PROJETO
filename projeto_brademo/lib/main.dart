import 'package:flutter/material.dart';
import 'screens/inicio/transicao.dart';
import 'service/notificacaoService.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await inicializarNotificacoes();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primaryColor: const Color(0xFF222425),
        scaffoldBackgroundColor: const Color(0xFF222425),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF222425),
          foregroundColor: Colors.white,
        ),

        textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
      ),

      home: const Transicao(),
    );
  }
}
