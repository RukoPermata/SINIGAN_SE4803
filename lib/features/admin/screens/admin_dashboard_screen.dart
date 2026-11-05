// PIC: Rayazka - Admin Dashboard Screen - FR-09

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/screens/login_screen.dart';
import '../../shared/bottom_nav.dart';
import 'room_condition_screen.dart';
import 'room_management_screen.dart';
import 'schedule_management_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _handleBack() {
    if (_currentIndex != 0) {
      setState(() {
        _currentIndex = 0;
      });
      return;
    }
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      _logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildPlaceholder(
        title: 'Dashboard Admin',
        subtitle: 'Modul statistik dan ringkasan peminjaman ruangan kampus.',
        picName: 'Rayazka (FR-09)',
        icon: Icons.dashboard_outlined,
      ),
      const RoomManagementScreen(),
      const ScheduleManagementScreen(),
      _buildPlaceholder(
        title: 'Permohonan Peminjaman',
        subtitle: 'Modul antrean persetujuan dan penolakan pengajuan mahasiswa.',
        picName: 'Rayazka (FR-13)',
        icon: Icons.assignment_outlined,
      ),
      const RoomConditionScreen(),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: pages,
        ),
        bottomNavigationBar: BottomNav(
          role: UserRole.admin,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }

  Widget _buildPlaceholder({
    required String title,
    required String subtitle,
    required String picName,
    required IconData icon,
  }) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 64, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.lavender,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'PIC Pengembang: $picName',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
