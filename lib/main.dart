import 'package:flutter/material.dart';
import 'package:sini_gan/features/shared/bottom_nav.dart';
import 'package:sini_gan/features/student/screens/student_home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SINI-GAN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
        searchBarTheme: const SearchBarThemeData(
          elevation: WidgetStatePropertyAll(0),
          shadowColor: WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const StudentHomeScreen(
        // role: UserRole.student,
        role: UserRole.admin,
      ),
    );
  }
}
