// PIC: Rayazka - Admin Dashboard Screen - FR-09

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/mock_data_store.dart';
import '../../../models/booking.dart';
import '../../shared/bottom_nav.dart';
import '../widgets/booking_request_card.dart';
import 'booking_requests_screen.dart';
import 'booking_review_screen.dart';
import 'room_condition_screen.dart';

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
      _currentIndex = 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    /// Urutan halaman harus sesuai dengan urutan item pada BottomNav.
    final pages = [
      _buildDashboardPage(),
      _buildPlaceholder(
        title: 'Manajemen Ruangan',
        subtitle: 'Modul master data ruangan dan status aktif/nonaktif.',
        picName: 'Fityah (FR-10)',
        icon: Icons.meeting_room_outlined,
      ),
      _buildPlaceholder(
        title: 'Jadwal & Blokir Tanggal',
        subtitle: 'Modul jadwal perkuliahan reguler dan penonaktifan tanggal.',
        picName: 'Fityah (FR-11, FR-12)',
        icon: Icons.calendar_month_outlined,
      ),
      const BookingRequestsScreen(),
      const RoomConditionScreen(),
    ];

    return Scaffold(
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
    );
  }

  /// Membuat halaman dashboard utama.
  Widget _buildDashboardPage() {
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

  /// Header bagian permohonan yang masih menunggu.
  Widget _buildPendingHeader({
    required int pendingCount,
  }) {
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
            'Tidak ada permohonan yang menunggu.',
            textAlign: TextAlign.center,
            style: AppTextStyles.cardTitle,
          ),
          const SizedBox(height: 6),
          Text(
            'Semua permohonan sudah diproses.',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  /// Placeholder untuk halaman admin yang belum menjadi fokus tugas ini.
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
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 64,
                color: AppColors.primary,
              ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
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

