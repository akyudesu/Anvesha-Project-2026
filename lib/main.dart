import 'package:fire_evacuation_app/features/login/presentation/pages/login.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fire evacution system',
      theme: ThemeData(
        scaffoldBackgroundColor: Color.fromARGB(255, 244, 234, 204),
        primarySwatch: MaterialColor(0xFFB71C1C, const <int, Color>{
          50: Color(0xFFFFEBEE),
          100: Color(0xFFFFCDD2),
          200: Color.fromARGB(255, 243, 220, 159),
          300: Color(0xFFE57373),
          400: Color(0xFFEF5350),
          500: Color(0xFFF44336),
          600: Color(0xFFE53935),
          700: Color(0xFFD32F2F),
          800: Color(0xFFC62828),
          900: Color(0xFFB71C1C),
        }),
      ),
      home: const Login(),
    );
  }
}
