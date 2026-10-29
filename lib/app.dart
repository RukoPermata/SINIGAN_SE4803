import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';

class SiniGanApp extends StatelessWidget {
  const SiniGanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SINI-GAN',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const Scaffold(
        body: Center(
          child: Text('SINI-GAN'),
        ),
      ),
    );
  }
}
