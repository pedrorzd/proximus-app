import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Importa o pacote
import 'home_screen.dart'; // Importa sua tela principal

// --- Nossas Novas Cores ---
const Color proPrimaryBlue = Color(0xFF590303);
const Color proAccentRed = Color(0xFFA60303);
const Color proErrorRed = Color(0xFF260101);
const Color proDarkText = Color(0xFF0D0000);
const Color proLightBackground = Color(0xFF73456B);

void main() {
  runApp(const ProximusApp());
}

class ProximusApp extends StatelessWidget {
  const ProximusApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Pega o tema de texto base do sistema
    final textTheme = Theme.of(context).textTheme;

    return MaterialApp(
      title: 'Proximus',
      theme: ThemeData(
        useMaterial3: true,

        // --- 2. Definição da Nova Paleta de Cores ---
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: proPrimaryBlue, // Cor principal
          onPrimary: Colors.white, // Texto sobre a cor principal
          secondary: proAccentRed, // Cor de acento (vermelho vivo)
          onSecondary: Colors.white, // Texto sobre a cor de acento
          error: proErrorRed, // Cor de erro
          onError: Colors.white, // Texto sobre o fundo
          surface: Colors.white, // Cor de "superfície" (cards)
          onSurface: proDarkText, // Texto sobre as superfícies
        ),

        // --- 3. Aplicação da Fonte Roboto ---
        // Pega o tema de texto base e aplica a fonte Roboto a ele.
        textTheme: GoogleFonts.robotoTextTheme(textTheme),

        // (Opcional) Define a fonte para a AppBar também
        appBarTheme: AppBarTheme(
          backgroundColor: proPrimaryBlue,
          foregroundColor: Colors.white,
          titleTextStyle: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}