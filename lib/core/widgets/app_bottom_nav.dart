import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Widget navigasi bawah terpadu untuk peran Mahasiswa dan Admin.
/// Menampilkan daftar tab yang berbeda sesuai peran yang sedang aktif.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.role,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final String role; // 'student' atau 'admin'

  @override
  Widget build(BuildContext context) {
    final isStudent = role.toLowerCase() == 'student';

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.lavender,
      destinations: isStudent ? _studentDestinations : _adminDestinations,
    );
  }

  static const List<NavigationDestination> _studentDestinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home, color: AppColors.primary),
      label: 'Beranda',
    ),
    NavigationDestination(
      icon: Icon(Icons.meeting_room_outlined),
      selectedIcon: Icon(Icons.meeting_room, color: AppColors.primary),
      label: 'Katalog',
    ),
    NavigationDestination(
      icon: Icon(Icons.history_outlined),
      selectedIcon: Icon(Icons.history, color: AppColors.primary),
      label: 'Riwayat',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person, color: AppColors.primary),
      label: 'Profil',
    ),
  ];

  static const List<NavigationDestination> _adminDestinations = [
    NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard, color: AppColors.primary),
      label: 'Dashboard',
    ),
    NavigationDestination(
      icon: Icon(Icons.room_preferences_outlined),
      selectedIcon: Icon(Icons.room_preferences, color: AppColors.primary),
      label: 'Ruangan',
    ),
    NavigationDestination(
      icon: Icon(Icons.calendar_month_outlined),
      selectedIcon: Icon(Icons.calendar_month, color: AppColors.primary),
      label: 'Jadwal',
    ),
    NavigationDestination(
      icon: Icon(Icons.assignment_outlined),
      selectedIcon: Icon(Icons.assignment, color: AppColors.primary),
      label: 'Pengajuan',
    ),
    NavigationDestination(
      icon: Icon(Icons.fact_check_outlined),
      selectedIcon: Icon(Icons.fact_check, color: AppColors.primary),
      label: 'Kondisi',
    ),
  ];
}
