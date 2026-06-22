import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/inicio/transicao.dart';
import 'service/notificacaoService.dart';
import 'package:provider/provider.dart';
import 'provider/formProvider.dart';
import 'config/sessaoUsuario.dart';

class LifecycleEventHandler extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      if (SessaoUsuario.usuarioLogado != null) {
        mostrarNotificacao();
      }
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await inicializarNotificacoes();
  await Hive.initFlutter();
  await Hive.openBox('formulario');
  await Hive.openBox('usuario');
  WidgetsBinding.instance.addObserver(LifecycleEventHandler());

  runApp(
    ChangeNotifierProvider(create: (_) => FormProvider(), child: const MyApp()),
  );
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
