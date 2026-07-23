// Flutter 앱의 최상위 설정과 첫 화면을 연결하는 파일입니다.
// 테마 설정과 home 화면 연결이 포함되어 있습니다.

import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

class SafetyMonitorClientApp extends StatelessWidget {
  const SafetyMonitorClientApp({
    super.key,
    this.home,
    this.title = 'Safety Monitor Client',
  });

  final Widget? home;
  final String title;

  @override
  Widget build(BuildContext context) {
    const surface = Color(0xFF15171C);
    const panel = Color(0xFF1D2027);
    const accent = Color(0xFFE05252);
    return MaterialApp(
      title: title,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0E1014),
        colorScheme: const ColorScheme.dark(
          primary: accent,
          secondary: Color(0xFF5BC0BE),
          surface: surface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF111318),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: const CardThemeData(color: panel, margin: EdgeInsets.zero),
        dividerColor: Colors.white12,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: panel,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white12),
          ),
        ),
      ),
      home: home ?? const HomeScreen(),
    );
  }
}
