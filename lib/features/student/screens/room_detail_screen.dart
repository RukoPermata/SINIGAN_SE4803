import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/mock_data_store.dart';
import '../../../models/regular_schedule.dart';
import '../../../models/room.dart';
import 'booking_form_screen.dart';
import 'room_calendar_screen.dart';

/// Detail ruangan & denah lokasi untuk mahasiswa (FR-04, FR-05).
class RoomDetailScreen extends StatelessWidget {
  const RoomDetailScreen({super.key, required this.room});

  final Room room;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MockDataStore>(
      init: MockDataStore.instance,
      builder: (store) {
        final current = store.getRoomById(room.id) ?? room;
        final todaySchedules = store
            .getSchedulesByRoomId(current.id)
            .where((s) => s.isActive && s.dayOfWeek == DateTime.now().weekday)
            .toList()
          ..sort((a, b) => a.startTime.compareTo(b.startTime));

        return Scaffold(
          appBar: AppBar(title: Text(current.name)),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _buildHero(current),
              const SizedBox(height: 16),
              _buildSummary(current),
              const SizedBox(height: 22),
              _sectionTitle('Facilities'),
              const SizedBox(height: 10),
              _buildFacilities(current),
              const SizedBox(height: 22),
              _sectionTitle('Description'),
              const SizedBox(height: 8),
              Text(
                current.description.isEmpty
                    ? 'No description available for this room.'
                    : current.description,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 22),
              _sectionTitle('Location Map'),
              const SizedBox(height: 10),
              _buildDenah(current),
              const SizedBox(height: 22),
              _sectionTitle('Today\'s Class Schedule'),
              const SizedBox(height: 10),
              _buildTodaySchedule(todaySchedules),
            ],
          ),
          bottomNavigationBar: _buildActionBar(current),
        );
      },
    );
  }

  Widget _buildHero(Room room) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 200,
        width: double.infinity,
        child: room.imageUrl.isNotEmpty
            ? Image.network(
                room.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _imageFallback(),
              )
            : _imageFallback(),
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      color: AppColors.lavender,
      alignment: Alignment.center,
      child: const Icon(
        Icons.meeting_room_outlined,
        size: 56,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildSummary(Room room) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  room.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              StatusBadge(status: room.isActive ? 'tersedia' : 'nonaktif'),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            room.building,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildStat(Icons.stairs_outlined, 'Floor', '${room.floor}'),
              _buildStat(Icons.people_outline, 'Capacity', '${room.capacity}'),
              _buildStat(Icons.dashboard_outlined, 'Layout', room.targetLayout),
            ],
          ),
          if (room.locationNotes.isNotEmpty) ...[
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    room.locationNotes,
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildFacilities(Room room) {
    if (room.facilities.isEmpty) {
      return const Text(
        'No facility data yet.',
        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: room.facilities.map((f) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.lavender.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, size: 15, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                f,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDenah(Room room) {
    return Container(
      height: 170,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _DenahPainter())),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Colors.white.withValues(alpha: 0.85),
              child: Text(
                'Location of ${room.name} in ${room.building}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySchedule(List<RegularSchedule> schedules) {
    if (schedules.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.successLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: AppColors.success, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'No classes today. The room is mostly free.',
                style: TextStyle(fontSize: 12, color: AppColors.success),
              ),
            ),
          ],
        ),
      );
    }
    return Column(
      children: schedules.map((s) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  s.timeRange,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.warning,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.courseName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${s.courseCode} • ${s.classGroup}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionBar(Room room) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      Get.to(() => RoomCalendarScreen(room: room)),
                  icon: const Icon(Icons.calendar_month_outlined, size: 18),
                  label: const Text('Check Free Hours'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: room.isActive
                      ? () => Get.to(() => BookingFormScreen(room: room))
                      : null,
                  icon: const Icon(Icons.event_available_outlined, size: 18),
                  label: const Text('Request Booking'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Menggambar denah lantai sederhana dengan penanda posisi ruangan.
class _DenahPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    for (double x = 0; x <= size.width; x += 28) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y <= size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final block = Paint()..color = AppColors.primary;
    final rect = Rect.fromLTWH(
      size.width * 0.34,
      size.height * 0.22,
      size.width * 0.34,
      size.height * 0.42,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      block,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
