// PIC: Rayazka - Admin Dashboard Screen - FR-09

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/mock_data_store.dart';
import '../../../models/booking.dart';
import '../../shared/app_navigation.dart';
import '../widgets/booking_request_card.dart';
import 'admin_profile_screen.dart';
import 'booking_requests_screen.dart';
import 'booking_review_screen.dart';
import 'room_condition_screen.dart';
import 'schedule_management_screen.dart';

/// Halaman utama admin.
///
/// Halaman ini berfungsi sebagai shell untuk seluruh fitur admin:
/// - Dashboard
/// - Manajemen ruangan
/// - Jadwal
/// - Pengajuan
/// - Kondisi ruangan
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}
class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  /// Index tab yang sedang aktif.
  int _currentIndex = 0;

  /// Satu sumber data mock untuk seluruh fitur aplikasi.
  final MockDataStore _dataStore = MockDataStore.instance;

  /// Membuka detail booking ketika kartu pada dashboard ditekan.
  Future<void> _openBookingDetail(Booking booking) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BookingReviewScreen(
          booking: booking,
        ),
      ),
    );
  }

  /// Membuka tab pengajuan.
  void _openBookingRequests() {
    setState(() {
      _currentIndex = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    /// Urutan halaman mengikuti AppNavigation.forRole(UserRole.admin).
    final pages = [
      _buildDashboardPage(),
      const ScheduleManagementScreen(),
      const BookingRequestsScreen(),
      const RoomConditionScreen(),
      const AdminProfileScreen(),
    ];
    final destinations = AppNavigation.forRole(UserRole.admin);

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
          destinations: destinations,
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

  void _handleBack() {
    if (_currentIndex != 0) {
      setState(() => _currentIndex = 0);
      return;
    }
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  /// Membuat halaman dashboard utama.
  Widget _buildDashboardPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        automaticallyImplyLeading: false,
      ),
      body: GetBuilder<MockDataStore>(
        init: _dataStore,
        builder: (store) {
          final bookings = store.bookings;

          final totalBookings = bookings.length;

          final pendingBookings = bookings
              .where(
                (booking) => booking.status == BookingStatus.pending,
              )
              .toList();

          final approvedBookings = bookings
              .where(
                (booking) => booking.status == BookingStatus.approved,
              )
              .toList();

          final rejectedBookings = bookings
              .where(
                (booking) => booking.status == BookingStatus.rejected,
              )
              .toList();

          return _buildDashboardContent(
            totalBookings: totalBookings,
            pendingBookings: pendingBookings,
            approvedBookings: approvedBookings,
            rejectedBookings: rejectedBookings,
          );
        },
      ),
    );
  }

  /// Isi dashboard yang berisi header, metrik, dan permohonan terbaru.
  Widget _buildDashboardContent({
    required int totalBookings,
    required List<Booking> pendingBookings,
    required List<Booking> approvedBookings,
    required List<Booking> rejectedBookings,
  }) {
    final recentPendingBookings = pendingBookings.take(3).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        _buildWelcomeSection(),
        const SizedBox(height: 24),
        _buildMetricGrid(
          totalBookings: totalBookings,
          pendingBookings: pendingBookings.length,
          approvedBookings: approvedBookings.length,
          rejectedBookings: rejectedBookings.length,
        ),
        const SizedBox(height: 28),
        _buildPendingHeader(
          pendingCount: pendingBookings.length,
        ),
        const SizedBox(height: 12),
        if (recentPendingBookings.isEmpty)
          _buildNoPendingBooking()
        else
          ...recentPendingBookings.map(
            (booking) => BookingRequestCard(
              booking: booking,
              onTap: () => _openBookingDetail(booking),
            ),
          ),
      ],
    );
  }

  /// Header sambutan pada dashboard.
  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome, Admin',
          style: AppTextStyles.pageTitle,
        ),
        const SizedBox(height: 8),
        Text(
          'Monitor and manage campus room booking activity.',
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Membuat grid metrik booking.
  Widget _buildMetricGrid({
    required int totalBookings,
    required int pendingBookings,
    required int approvedBookings,
    required int rejectedBookings,
  }) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.45,
      children: [
        _MetricCard(
          title: 'Total',
          value: totalBookings.toString(),
          icon: Icons.assignment_outlined,
          color: AppColors.primary,
          backgroundColor: AppColors.lavender,
        ),
        _MetricCard(
          title: 'Pending',
          value: pendingBookings.toString(),
          icon: Icons.hourglass_empty,
          color: AppColors.warning,
          backgroundColor: AppColors.warningLight,
        ),
        _MetricCard(
          title: 'Approved',
          value: approvedBookings.toString(),
          icon: Icons.check_circle_outline,
          color: AppColors.success,
          backgroundColor: AppColors.successLight,
        ),
        _MetricCard(
          title: 'Rejected',
          value: rejectedBookings.toString(),
          icon: Icons.cancel_outlined,
          color: AppColors.error,
          backgroundColor: AppColors.errorLight,
        ),
      ],
    );
  }

  /// Header bagian permohonan yang masih menunggu.
  Widget _buildPendingHeader({
    required int pendingCount,
  }) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Pending Requests',
            style: AppTextStyles.sectionTitle,
          ),
        ),
        TextButton(
          onPressed: _openBookingRequests,
          child: Text(
            'View All${pendingCount > 0 ? ' ($pendingCount)' : ''}',
          ),
        ),
      ],
    );
  }

  /// Tampilan ketika tidak ada booking pending.
  Widget _buildNoPendingBooking() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 48,
            color: AppColors.success.withValues(alpha: 0.8),
          ),
          const SizedBox(height: 12),
          const Text(
            'No pending requests.',
            textAlign: TextAlign.center,
            style: AppTextStyles.cardTitle,
          ),
          const SizedBox(height: 6),
          Text(
            'All requests have been processed.',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

}

/// Widget kartu metrik dashboard.
class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
            icon,
            color: color,
            size: 28,
          ),
              SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
            ],
          ),
        ],
      ),
    );
  }
}

