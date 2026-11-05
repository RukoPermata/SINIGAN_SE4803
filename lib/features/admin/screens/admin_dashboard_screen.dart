// PIC: Rayazka - Admin Dashboard Screen - FR-09

import 'package:flutter/material.dart';

import '../../shared/app_navigation.dart';

/// Shell navigasi admin / pengelola.
///
/// Tab dan halamannya dibangun otomatis dari [AppNavigation] sesuai peran,
/// sehingga daftar navigasi dan daftar halaman tidak mungkin bergeser.
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) => const AppShell(role: UserRole.admin);
}
