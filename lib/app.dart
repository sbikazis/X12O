import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

abstract final class Palette {
  static const ink = Color(0xFF080D19);
  static const panel = Color(0xFF111A2B);
  static const panel2 = Color(0xFF1A2940);
  static const cyan = Color(0xFF55E6E0);
  static const coral = Color(0xFFFF786F);
  static const gold = Color(0xFFFFD27A);
  static const muted = Color(0xFF8E9AB0);
  static const line = Color(0xFF26334A);
}

class X12OApp extends StatelessWidget {
  const X12OApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'X12O',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Palette.ink,
      colorScheme: ColorScheme.fromSeed(seedColor: Palette.cyan, brightness: Brightness.dark),
      appBarTheme: const AppBarTheme(backgroundColor: Palette.ink, centerTitle: true),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 35, fontWeight: FontWeight.w900, letterSpacing: -1.2),
        headlineMedium: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        bodyMedium: TextStyle(color: Palette.muted, height: 1.5),
      ),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(
        backgroundColor: Palette.cyan, foregroundColor: Palette.ink,
        minimumSize: const Size(0, 52), textStyle: const TextStyle(fontWeight: FontWeight.w900),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      )),
    ),
    home: const HomeScreen(),
  );
}
