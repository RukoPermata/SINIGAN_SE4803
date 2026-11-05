// PIC: Rayazka - Booking Requests Screen - FR-13
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/mock_data_store.dart';
import '../../../models/booking.dart';
import '../widgets/booking_request_card.dart';
import 'booking_review_screen.dart';

/// Halaman daftar permohonan peminjaman untuk admin.
/// - Mengambil data booking dari MockDataStore.
/// - Menampilkan daftar BookingRequestCard.
/// - Memfilter booking berdasarkan status.
/// - Menangani interaksi ketika kartu ditekan.

/// Halaman review detail akan disambungkan pada tahap berikutnya.
class BookingRequestsScreen extends StatefulWidget {
  const BookingRequestsScreen({super.key});

  @override
  State<BookingRequestsScreen> createState() => _BookingRequestsScreenState();
}

class _BookingRequestsScreenState extends State<BookingRequestsScreen> {
  /// Mengambil data booking dari satu sumber data global.
  final MockDataStore _dataStore = MockDataStore.instance;

  /// Nilai null berarti tidak ada filter atau menampilkan semua status.
  BookingStatus? _selectedStatus;

  /// Menghasilkan daftar booking berdasarkan status yang dipilih.

List<Booking> _filterBookings(List<Booking> bookings) {
  final filteredBookings = _selectedStatus == null
      ? List<Booking>.from(bookings)
      : bookings
          .where((booking) => booking.status == _selectedStatus)
          .toList();

  filteredBookings.sort((first, second) {
    final firstIsPending = first.status == BookingStatus.pending;
    final secondIsPending = second.status == BookingStatus.pending;

    // Booking pending selalu lebih dahulu.
    if (firstIsPending && !secondIsPending) {
      return -1;
    }

    if (!firstIsPending && secondIsPending) {
      return 1;
    }

    // Jika status sama, booking terbaru ditampilkan lebih dahulu.
    final firstDate =
        first.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

    final secondDate =
        second.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

    return secondDate.compareTo(firstDate);
  });

  return filteredBookings;
}

  /// Mengubah status filter yang dipilih.
  void _selectFilter(BookingStatus? status) {
    setState(() {
      _selectedStatus = status;
    });
  }


  /// BookingReviewScreen dibuka kalau kartu ditekan
  Future<void> _openBookingDetail(Booking booking) async {
    await Get.to<bool>(
      () => BookingReviewScreen(booking: booking),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permohonan Peminjaman'),
        automaticallyImplyLeading: false,
      ),
      body: GetBuilder<MockDataStore>(
        init: MockDataStore.instance,
        builder: (_) {
          final bookings = _filterBookings(_dataStore.bookings);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPageHeader(),
              _buildStatusFilters(),
              const SizedBox(height: 8),
              Expanded(
                child: bookings.isEmpty
                    ? _buildEmptyState()
                    : _buildBookingList(bookings),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Header singkat halaman.
  Widget _buildPageHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Text(
        'Tinjau dan kelola permohonan peminjaman ruangan.',
        style: AppTextStyles.body.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  /// Membuat filter status dalam bentuk chip horizontal.
  Widget _buildStatusFilters() {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildFilterChip(
            label: 'Semua',
            status: null,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: BookingStatus.pending.label,
            status: BookingStatus.pending,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: BookingStatus.approved.label,
            status: BookingStatus.approved,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: BookingStatus.rejected.label,
            status: BookingStatus.rejected,
          ),
        ],
      ),
    );
  }

  /// Membuat satu filter chip.
  Widget _buildFilterChip({
    required String label,
    required BookingStatus? status,
  }) {
    final isSelected = _selectedStatus == status;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => _selectFilter(status),
      showCheckmark: false,
      selectedColor: AppColors.lavender,
      backgroundColor: AppColors.surface,
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.border,
      ),
      labelStyle: TextStyle(
        color: isSelected
            ? AppColors.primary
            : AppColors.textSecondary,
        fontWeight: isSelected
            ? FontWeight.w700
            : FontWeight.w500,
      ),
    );
  }

  /// Menampilkan daftar kartu permohonan.
  Widget _buildBookingList(List<Booking> bookings) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];

        return BookingRequestCard(
          booking: booking,
          onTap: () => _openBookingDetail(booking),
        );
      },
    );
  }

  /// Menampilkan tampilan ketika hasil filter kosong.
  Widget _buildEmptyState() {
    final filterLabel = _selectedStatus == null
        ? 'permohonan'
        : 'permohonan ${_selectedStatus!.label.toLowerCase()}';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada $filterLabel',
              textAlign: TextAlign.center,
              style: AppTextStyles.sectionTitle,
            ),
            const SizedBox(height: 8),
            Text(
              'Belum ada data permohonan yang sesuai dengan filter ini.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}