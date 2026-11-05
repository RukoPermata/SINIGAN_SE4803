import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/mock_data_store.dart';
import '../../../models/booking.dart';
import '../../shared/app_navigation.dart';
import '../widgets/booking_request_card.dart';
import 'booking_review_screen.dart';

/// Tab Dashboard Admin (FR-09) — Metrik statistik dan permohonan terbaru.
class AdminDashboardTab extends StatefulWidget {
  const AdminDashboardTab({super.key});

  @override
  State<AdminDashboardTab> createState() => _AdminDashboardTabState();
}

class _AdminDashboardTabState extends State<AdminDashboardTab> {
  final MockDataStore _dataStore = MockDataStore.instance;

  Future<void> _openBookingDetail(Booking booking) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BookingReviewScreen(booking: booking),
      ),
    );
  }

  void _openBookingRequests() {
    try {
      AppShellScope.of(context).selectTab('Requests');
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        automaticallyImplyLeading: false,
      ),
      body: AnimatedBuilder(
        animation: _dataStore,
        builder: (context, child) {
          final bookings = _dataStore.bookings;
          final totalBookings = bookings.length;
          final pendingBookings = bookings
              .where((b) => b.status == BookingStatus.pending)
              .toList();
          final approvedBookings = bookings
              .where((b) => b.status == BookingStatus.approved)
              .toList();
          final rejectedBookings = bookings
              .where((b) => b.status == BookingStatus.rejected)
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
        _buildPendingHeader(pendingCount: pendingBookings.length),
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

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selamat datang, Admin',
          style: AppTextStyles.pageTitle,
        ),
        const SizedBox(height: 8),
        Text(
          'Pantau dan kelola aktivitas peminjaman ruangan kampus.',
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

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
          title: 'Menunggu',
          value: pendingBookings.toString(),
          icon: Icons.hourglass_empty,
          color: AppColors.warning,
          backgroundColor: AppColors.warningLight,
        ),
        _MetricCard(
          title: 'Disetujui',
          value: approvedBookings.toString(),
          icon: Icons.check_circle_outline,
          color: AppColors.success,
          backgroundColor: AppColors.successLight,
        ),
        _MetricCard(
          title: 'Ditolak',
          value: rejectedBookings.toString(),
          icon: Icons.cancel_outlined,
          color: AppColors.error,
          backgroundColor: AppColors.errorLight,
        ),
      ],
    );
  }

  Widget _buildPendingHeader({required int pendingCount}) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Permohonan Menunggu',
            style: AppTextStyles.sectionTitle,
          ),
        ),
        TextButton(
          onPressed: _openBookingRequests,
          child: Text(
            'Lihat Semua${pendingCount > 0 ? ' ($pendingCount)' : ''}',
          ),
        ),
      ],
    );
  }

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
            'Tidak ada permohonan yang menunggu.',
            textAlign: TextAlign.center,
            style: AppTextStyles.cardTitle,
          ),
          const SizedBox(height: 6),
          const Text(
            'Semua permohonan sudah diproses.',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

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
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 16),
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
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
