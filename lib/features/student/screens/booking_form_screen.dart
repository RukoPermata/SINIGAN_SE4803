import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../data/mock_data_store.dart';
import '../../../models/booking.dart';
import '../../../models/room.dart';
import 'booking_history_screen.dart';

/// Formulir pengajuan peminjaman ruangan (FR-06).
/// Memvalidasi tanggal, jam mulai/selesai, tujuan kegiatan, serta bentrok jadwal
/// sebelum menyimpan permohonan ke store.
class BookingFormScreen extends StatefulWidget {
  const BookingFormScreen({
    super.key,
    required this.room,
    this.initialDate,
    this.initialStart,
    this.initialEnd,
  });

  final Room room;
  final DateTime? initialDate;
  final String? initialStart;
  final String? initialEnd;

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _purposeController = TextEditingController();

  late DateTime _date;
  late String _startTime;
  late String _endTime;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _date = widget.initialDate ?? DateTime(today.year, today.month, today.day);
    _startTime = widget.initialStart ?? '09:00';
    _endTime = widget.initialEnd ?? '10:00';
  }

  @override
  void dispose() {
    _purposeController.dispose();
    super.dispose();
  }

  int _toMinutes(String hhmm) => MockDataStore.toMinutes(hhmm);

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(today.year, today.month, today.day),
      lastDate: today.add(const Duration(days: 60)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime({required bool isStart}) async {
    final current = isStart ? _startTime : _endTime;
    final parts = current.split(':');
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 9,
        minute: int.tryParse(parts[1]) ?? 0,
      ),
    );
    if (picked != null) {
      final value = DateTimeUtils.formatTime(picked);
      setState(() {
        if (isStart) {
          _startTime = value;
        } else {
          _endTime = value;
        }
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final startMin = _toMinutes(_startTime);
    final endMin = _toMinutes(_endTime);

    if (endMin <= startMin) {
      _showError('End time must be after start time.');
      return;
    }

    if (!MockDataStore.instance
        .isSlotAvailable(widget.room.id, _date, startMin, endMin)) {
      _showError(
        'The selected time overlaps with a class, another booking, '
        'or a blackout period.',
      );
      return;
    }

    final booking = Booking(
      id: 'book-${DateTime.now().millisecondsSinceEpoch}',
      roomId: widget.room.id,
      roomName: widget.room.name,
      building: widget.room.building,
      userName: AppConstants.currentStudentName,
      userNim: AppConstants.currentStudentNim,
      date: _date,
      startTime: _startTime,
      endTime: _endTime,
      purpose: _purposeController.text.trim(),
      status: BookingStatus.pending,
      createdAt: DateTime.now(),
    );

    MockDataStore.instance.addBooking(booking);

    Get.snackbar(
      'Request Submitted',
      'Your request for ${widget.room.name} is awaiting admin approval.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );

    Get.off(() => const BookingHistoryScreen());
  }

  void _showError(String message) {
    Get.snackbar(
      'Validation Failed',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.error,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Booking')),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            _buildRoomBanner(),
            const SizedBox(height: 20),
            _label('Activity Date'),
            const SizedBox(height: 8),
            _buildPickerTile(
              icon: Icons.calendar_today_outlined,
              text: DateTimeUtils.formatDate(_date),
              onTap: _pickDate,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Start Time'),
                      const SizedBox(height: 8),
                      _buildPickerTile(
                        icon: Icons.schedule,
                        text: _startTime,
                        onTap: () => _pickTime(isStart: true),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('End Time'),
                      const SizedBox(height: 8),
                      _buildPickerTile(
                        icon: Icons.schedule,
                        text: _endTime,
                        onTap: () => _pickTime(isStart: false),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _label('Purpose'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _purposeController,
              maxLines: 4,
              maxLength: 200,
              decoration: const InputDecoration(
                hintText:
                    'e.g. Extra class tutorial, student council meeting, etc.',
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'Purpose is required';
                if (text.length < 5) return 'Purpose is too short';
                return null;
              },
            ),
            const SizedBox(height: 12),
            _buildInfoNote(),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.send_rounded, size: 18),
              label: const Text('Submit Request'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildRoomBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lavender.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.meeting_room_outlined, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.room.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  widget.room.building,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickerTile({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, size: 20, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: AppColors.primary),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your request will be reviewed by an admin. You can track its status '
              'in the History tab.',
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
