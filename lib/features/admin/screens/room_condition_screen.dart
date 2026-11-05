// PIC: Kaisar - Room Condition Screen (Queue List) - FR-15, FR-16, FR-17, FR-18

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/mock_data_store.dart';
import '../../../models/booking.dart';
import '../widgets/condition_inspection_card.dart';
import 'room_condition_detail_screen.dart';

/// Layar utama antrean pemeriksaan kondisi ruangan (Triage Queue).
class RoomConditionScreen extends StatefulWidget {
  const RoomConditionScreen({super.key});

  @override
  State<RoomConditionScreen> createState() => _RoomConditionScreenState();
}

class _RoomConditionScreenState extends State<RoomConditionScreen> {
  final Set<String> _verifiedIds = {};

  void _openDetail(Booking booking) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => RoomConditionDetailScreen(booking: booking),
      ),
    );

    if (result == true && mounted) {
      setState(() {
        _verifiedIds.add(booking.id);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return GetBuilder<MockDataStore>(
      init: MockDataStore.instance,
      builder: (store) {
        final allBookings = store.bookings;

        final pendingReview = allBookings
            .where((b) => !_verifiedIds.contains(b.id))
            .toList();

        final completedReview = allBookings
            .where((b) => _verifiedIds.contains(b.id))
            .toList();

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Tinjauan Kondisi Ruangan'),
              automaticallyImplyLeading: false,
              bottom: TabBar(
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                tabs: [
                  Tab(text: 'Perlu Verifikasi (${pendingReview.length})'),
                  Tab(text: 'Selesai (${completedReview.length})'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _buildBookingList(
                  items: pendingReview,
                  isCompleted: false,
                  emptyMessage:
                      'Tidak ada sesi ruangan yang memerlukan verifikasi saat ini.',
                ),
                _buildBookingList(
                  items: completedReview,
                  isCompleted: true,
                  emptyMessage:
                      'Belum ada sesi peminjaman yang diverifikasi.',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookingList({
    required List<Booking> items,
    required bool isCompleted,
    required String emptyMessage,
  }) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.fact_check_outlined,
                size: 48,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 12),
              Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final booking = items[index];
        return ConditionInspectionCard(
          booking: booking,
          isCompleted: isCompleted,
          onTap: () => _openDetail(booking),
        );
      },
    );
  }
}
