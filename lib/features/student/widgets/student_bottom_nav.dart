// PIC: Farrel & Fauzan - Student Bottom Nav Widget - FR-01, FR-02
// Komponen navigasi bawah terpadu dialihkan ke `lib/features/shared/bottom_nav.dart`

import 'package:flutter/material.dart';

import '../../shared/bottom_nav.dart';

class StudentBottomNav extends StatelessWidget {
  const StudentBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return BottomNav(
      role: UserRole.student,
      currentIndex: currentIndex,
      onTap: onTap,
    );
  }
}
