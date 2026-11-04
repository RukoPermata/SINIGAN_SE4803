import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Peran pengguna untuk menentukan daftar tab navigasi yang ditampilkan.
enum UserRole {
  student,
  admin,
}

/// Widget navigasi bawah terpadu untuk peran Mahasiswa dan Admin.
/// Menggabungkan arsitektur role-based (Fauzan) dengan desain visual Material 3 (Farrel).
class BottomNav extends StatelessWidget {
  const BottomNav({
    super.key,
    required this.role,
    required this.currentIndex,
    required this.onTap,
  });

  final UserRole role;
  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<_NavItem> _studentItems = [
    _NavItem(
      label: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
    ),
    _NavItem(
      label: 'Explore',
      icon: Icons.search_rounded,
      activeIcon: Icons.search_rounded,
    ),
    _NavItem(
      label: 'Bookings',
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month_rounded,
    ),
    _NavItem(
      label: 'Profile',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
  ];

  static const List<_NavItem> _adminItems = [
    _NavItem(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
    ),
    _NavItem(
      label: 'Ruangan',
      icon: Icons.meeting_room_outlined,
      activeIcon: Icons.meeting_room_rounded,
    ),
    _NavItem(
      label: 'Jadwal',
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month_rounded,
    ),
    _NavItem(
      label: 'Pengajuan',
      icon: Icons.assignment_outlined,
      activeIcon: Icons.assignment_rounded,
    ),
    _NavItem(
      label: 'Kondisi',
      icon: Icons.fact_check_outlined,
      activeIcon: Icons.fact_check_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final items = role == UserRole.student ? _studentItems : _adminItems;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = currentIndex == index;

              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isSelected ? item.activeIcon : item.icon,
                        size: 24,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}
