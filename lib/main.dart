import 'package:flutter/material.dart';
import 'login_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VokraApp());
}

class VokraApp extends StatelessWidget {
  const VokraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vokra',
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'ShareTechMono',
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark().copyWith(
          secondary: Colors.lightBlueAccent,
        ),
      ),
      home: const LoginPage(),
    );
  }
}
