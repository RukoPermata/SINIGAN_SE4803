// PIC: Farrel - Student Home Screen - FR-02

import 'package:flutter/material.dart';

import '../../shared/app_navigation.dart';

/// Shell navigasi mahasiswa.
///
/// Tab dan halamannya dibangun otomatis dari [AppNavigation] sesuai peran,
/// sehingga daftar navigasi dan daftar halaman tidak mungkin bergeser.
class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const AppShell(role: UserRole.student);
}
