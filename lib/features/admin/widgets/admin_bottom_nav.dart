// PIC: Rayazka & Fauzan - Admin Bottom Nav Widget - FR-01, FR-09
// Komponen navigasi bawah terpadu dialihkan ke `lib/features/shared/bottom_nav.dart`

import 'package:flutter/material.dart';

import '../../shared/bottom_nav.dart';

class AdminBottomNav extends StatelessWidget {
  const AdminBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return BottomNav(
      role: UserRole.admin,
      currentIndex: currentIndex,
      onTap: onTap,
    );
  }
}
