import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../data/mock_data_store.dart';
import '../../../models/room.dart';
import 'booking_form_screen.dart';

/// Kalender mingguan & cek jam kosong ruangan (FR-05).
/// Menampilkan pita tanggal mingguan dan grid slot jam harian yang membedakan
/// jam terpakai (kuliah reguler / peminjaman / blackout) dan jam kosong.
class RoomCalendarScreen extends StatefulWidget {
  const RoomCalendarScreen({super.key, required this.room});

  final Room room;

  @override
  State<RoomCalendarScreen> createState() => _RoomCalendarScreenState();
}

class _RoomCalendarScreenState extends State<RoomCalendarScreen> {
  static const int _openHour = 7;
  static const int _closeHour = 21;

  late final List<DateTime> _days;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    final base = DateTime(today.year, today.month, today.day);
    _days = List.generate(7, (i) => base.add(Duration(days: i)));
    _selectedDay = _days.first;
  }

  static const List<String> _dayNames = [
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
    'Min',
  ];

  @override
  Widget build(BuildContext context) {
    final store = MockDataStore.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('Cek Jam Kosong')),
      body: Column(
        children: [
          _buildDayStrip(),
          _buildLegend(),
          Expanded(
            child: _buildSlotGrid(store),
          ),
        ],
      ),
    );
  }

  Widget _buildDayStrip() {
    return SizedBox(
      height: 86,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        itemCount: _days.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final day = _days[index];
          final selected = day.day == _selectedDay.day;
          return GestureDetector(
            onTap: () => setState(() => _selectedDay = day),
            child: Container(
              width: 56,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _dayNames[day.weekday - 1],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${day.day}',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: selected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Row(
        children: [
          _legendDot(AppColors.success, 'Kosong / bisa dipinjam'),
          const SizedBox(width: 16),
          _legendDot(AppColors.textSecondary, 'Terpakai'),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildSlotGrid(MockDataStore store) {
    final slots = <Widget>[];
    for (int hour = _openHour; hour < _closeHour; hour++) {
      final startMin = hour * 60;
      final endMin = (hour + 1) * 60;
      final startLabel = '${hour.toString().padLeft(2, '0')}:00';
      final endLabel = '${(hour + 1).toString().padLeft(2, '0')}:00';

      final slotStart =
          DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day, hour);
      final isPast = slotStart.isBefore(DateTime.now());
      final available =
          !isPast && store.isSlotAvailable(widget.room.id, _selectedDay, startMin, endMin);

      slots.add(
        _buildSlotRow(
          startLabel: startLabel,
          endLabel: endLabel,
          available: available,
          isPast: isPast,
          onTap: available
              ? () => Get.to(
                    () => BookingFormScreen(
                      room: widget.room,
                      initialDate: _selectedDay,
                      initialStart: startLabel,
                      initialEnd: endLabel,
                    ),
                  )
              : null,
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
      children: [
        Text(
          '${DateTimeUtils.formatDate(_selectedDay)} • ${widget.room.name}',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...slots,
      ],
    );
  }

  Widget _buildSlotRow({
    required String startLabel,
    required String endLabel,
    required bool available,
    required bool isPast,
    required VoidCallback? onTap,
  }) {
    final Color color;
    final String statusLabel;
    if (available) {
      color = AppColors.success;
      statusLabel = 'Kosong';
    } else if (isPast) {
      color = AppColors.textSecondary;
      statusLabel = 'Terlewat';
    } else {
      color = AppColors.error;
      statusLabel = 'Terpakai';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: available
            ? AppColors.successLight
            : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: available ? AppColors.success.withValues(alpha: 0.4) : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 92,
                  child: Text(
                    '$startLabel - $endLabel',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
                if (available)
                  const Row(
                    children: [
                      Text(
                        'Pinjam',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded,
                          size: 16, color: AppColors.success),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
