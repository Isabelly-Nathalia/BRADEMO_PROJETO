import 'package:flutter/material.dart';
import 'screens/inicial.dart';

void main() {
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

    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white),
    ),
  ),

  home: const Apresentacao(),
    );
  }
}