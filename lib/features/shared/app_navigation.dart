import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../admin/screens/admin_dashboard_tab.dart';
import '../admin/screens/admin_profile_screen.dart';
import '../admin/screens/booking_requests_screen.dart';
import '../admin/screens/room_condition_screen.dart';
import '../admin/screens/schedule_management_screen.dart';
import '../student/screens/booking_history_screen.dart';
import '../student/screens/room_catalog_screen.dart';
import '../student/screens/student_home_tab.dart';
import '../student/screens/student_profile_screen.dart';

/// Peran pengguna untuk menentukan daftar tab navigasi yang ditampilkan.
enum UserRole { student, admin }

/// Satu tab navigasi: label, ikon, halaman, dan peran yang diizinkan.
class NavDestination {
  const NavDestination({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.page,
    required this.roles,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;

  /// Pembangun halaman untuk tab ini.
  final Widget Function() page;

  /// Peran yang boleh melihat tab ini.
  final Set<UserRole> roles;
}

/// Satu sumber kebenaran (single source of truth) untuk seluruh tab navigasi.
///
/// Tab dan halaman dideklarasikan sekali di sini sehingga daftar navigasi dan
/// daftar halaman tidak mungkin "bergeser" satu sama lain. [forRole] berperan
/// sebagai *user checker*: menyaring tab sesuai peran pengguna yang aktif.
class AppNavigation {
  AppNavigation._();

  static final List<NavDestination> _destinations = [
    // ===== Mahasiswa =====
    NavDestination(
      label: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      roles: const {UserRole.student},
      page: () => const StudentHomeTab(),
    ),
    NavDestination(
      label: 'Explore',
      icon: Icons.search_rounded,
      activeIcon: Icons.search_rounded,
      roles: const {UserRole.student},
      page: () => const RoomCatalogScreen(),
    ),
    NavDestination(
      label: 'Bookings',
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month_rounded,
      roles: const {UserRole.student},
      page: () => const BookingHistoryScreen(),
    ),
    NavDestination(
      label: 'Profile',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      roles: const {UserRole.student},
      page: () => const StudentProfileScreen(),
    ),

    // ===== Admin / Pengelola =====
    NavDestination(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      roles: const {UserRole.admin},
      page: () => const AdminDashboardTab(),
    ),
    NavDestination(
      label: 'Schedule',
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month_rounded,
      roles: const {UserRole.admin},
      page: () => const ScheduleManagementScreen(),
    ),
    NavDestination(
      label: 'Requests',
      icon: Icons.assignment_outlined,
      activeIcon: Icons.assignment_rounded,
      roles: const {UserRole.admin},
      page: () => const BookingRequestsScreen(),
    ),
    NavDestination(
      label: 'Condition',
      icon: Icons.fact_check_outlined,
      activeIcon: Icons.fact_check_rounded,
      roles: const {UserRole.admin},
      page: () => const RoomConditionScreen(),
    ),
    NavDestination(
      label: 'Profile',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      roles: const {UserRole.admin},
      page: () => const AdminProfileScreen(),
    ),
  ];

  /// *User checker*: kembalikan tab yang boleh dilihat oleh [role].
  static List<NavDestination> forRole(UserRole role) =>
      _destinations.where((d) => d.roles.contains(role)).toList();
}

/// Memberi akses ke fungsi pindah tab dari dalam sebuah halaman tab.
class AppShellScope extends InheritedWidget {
  const AppShellScope({
    super.key,
    required this.role,
    required this.selectTab,
    required super.child,
  });

  final UserRole role;

  /// Pindah ke tab berdasarkan [NavDestination.label].
  final ValueChanged<String> selectTab;

  static AppShellScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppShellScope>();
    assert(scope != null, 'AppShellScope tidak ditemukan pada context.');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppShellScope oldWidget) => role != oldWidget.role;
}

/// Shell bersama untuk peran Mahasiswa maupun Admin.
///
/// Membangun `IndexedStack` halaman dan `BottomNav` dari daftar destinasi yang
/// sama ([AppNavigation.forRole]) sehingga tidak ada duplikasi maupun pergeseran.
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.role});

  final UserRole role;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  late final List<NavDestination> _destinations =
      AppNavigation.forRole(widget.role);

  void _selectIndex(int index) {
    if (index < 0 || index >= _destinations.length || index == _currentIndex) {
      return;
    }
    setState(() => _currentIndex = index);
  }

  void _selectByLabel(String label) {
    final index = _destinations.indexWhere((d) => d.label == label);
    if (index != -1) _selectIndex(index);
  }

  void _logout() => Get.offAllNamed(AppRoutes.login);

  void _handleBack() {
    if (_currentIndex != 0) {
      setState(() => _currentIndex = 0);
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack();
      },
      child: AppShellScope(
        role: widget.role,
        selectTab: _selectByLabel,
        child: Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: [
              for (final destination in _destinations) destination.page(),
            ],
          ),
          bottomNavigationBar: BottomNav(
            destinations: _destinations,
            currentIndex: _currentIndex,
            onTap: _selectIndex,
          ),
        ),
      ),
    );
  }
}

/// Navigasi bawah yang dirender dari daftar [NavDestination].
class BottomNav extends StatelessWidget {
  const BottomNav({
    super.key,
    required this.destinations,
    required this.currentIndex,
    required this.onTap,
  });

  final List<NavDestination> destinations;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
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
            children: List.generate(destinations.length, (index) {
              final item = destinations[index];
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
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
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
