import 'package:flutter/material.dart';
import 'home_screen.dart';

void main() {
  runApp(const ProximusApp());
}

class ProximusApp extends StatelessWidget {
  const ProximusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Proximus App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(), // Nossa nova tela principal!
    );
  }
}