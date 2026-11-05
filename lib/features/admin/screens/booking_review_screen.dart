// PIC: Rayazka - Booking Review Screen - FR-13
// Halaman detail untuk meninjau satu permohonan peminjaman.

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/mock_data_store.dart';
import '../../../models/booking.dart';

/// Admin dapat:
/// - Melihat detail lengkap permohonan.
/// - Menyetujui permohonan.
/// - Menolak permohonan dengan alasan wajib.
class BookingReviewScreen extends StatefulWidget {
  const BookingReviewScreen({
    super.key,
    required this.booking,
  });

  /// Data booking yang sedang ditinjau.
  final Booking booking;

  @override
  State<BookingReviewScreen> createState() => _BookingReviewScreenState();
}

class _BookingReviewScreenState extends State<BookingReviewScreen> {
  final MockDataStore _dataStore = MockDataStore.instance;

  /// Mengecek apakah booking masih bisa diproses.
  bool get _isPending {
    return widget.booking.status == BookingStatus.pending;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Detail'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusSection(),
            const SizedBox(height: 20),
            _buildApplicantSection(),
            const SizedBox(height: 16),
            _buildBookingSection(),
            const SizedBox(height: 16),
            _buildPurposeSection(),
            if (widget.booking.rejectionReason != null) ...[
              const SizedBox(height: 16),
              _buildRejectionReasonSection(),
            ],
            const SizedBox(height: 28),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  /// Menampilkan status booking saat ini.
  Widget _buildStatusSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.assignment_outlined,
            color: AppColors.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Request Status',
              style: AppTextStyles.cardTitle,
            ),
          ),
          StatusBadge(
            status: widget.booking.status.value,
            customLabel: widget.booking.status.label,
          ),
        ],
      ),
    );
  }

  /// Menampilkan identitas pemohon.
  Widget _buildApplicantSection() {
    return _ReviewSection(
      title: 'Applicant Information',
      icon: Icons.person_outline,
      children: [
        _DetailRow(
          label: 'Name',
          value: widget.booking.userName,
        ),
        _DetailRow(
          label: 'Student ID',
          value: widget.booking.userNim,
        ),
      ],
    );
  }

  /// Menampilkan informasi ruangan dan jadwal.
  Widget _buildBookingSection() {
    return _ReviewSection(
      title: 'Booking Information',
      icon: Icons.meeting_room_outlined,
      children: [
        _DetailRow(
          label: 'Room',
          value: widget.booking.roomName,
        ),
        _DetailRow(
          label: 'Building',
          value: widget.booking.building,
        ),
        _DetailRow(
          label: 'Date',
          value: DateTimeUtils.formatDateLong(widget.booking.date),
        ),
        _DetailRow(
          label: 'Time',
          value:
              '${widget.booking.startTime} - ${widget.booking.endTime}',
        ),
      ],
    );
  }

  /// Menampilkan tujuan kegiatan.
  Widget _buildPurposeSection() {
    return _ReviewSection(
      title: 'Purpose',
      icon: Icons.description_outlined,
      children: [
        Text(
          widget.booking.purpose,
          style: AppTextStyles.body,
        ),
      ],
    );
  }

  /// Menampilkan alasan penolakan jika booking pernah ditolak.
  Widget _buildRejectionReasonSection() {
    return _ReviewSection(
      title: 'Rejection Reason',
      icon: Icons.info_outline,
      children: [
        Text(
          widget.booking.rejectionReason!,
          style: AppTextStyles.body.copyWith(
            color: AppColors.error,
          ),
        ),
      ],
    );
  }

  /// Menampilkan tombol aksi approve dan reject.
  ///
  /// Tombol hanya muncul ketika status booking masih pending.
  Widget _buildActionButtons() {
    if (!_isPending) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          'This request has already been processed.',
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _approveBooking,
            icon: const Icon(Icons.check),
            label: const Text('Approve Request'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _rejectBooking,
            icon: const Icon(Icons.close),
            label: const Text('Reject Request'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Menampilkan dialog konfirmasi approve.
  Future<void> _approveBooking() async {
    final shouldApprove = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Approve Request?'),
          content: const Text(
            'This request will be marked as approved.',
          ),
          actions: [
  SizedBox(
    width: double.infinity,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(dialogContext, true);
          },
          child: const Text('Approve'),
        ),
        Center(
          child: TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
            child: const Text('Cancel'),
          ),
        ),
      ],
    ),
  ),
],
        );
      },
    );

    if (shouldApprove != true) {
      return;
    }

    _dataStore.approveBooking(widget.booking.id);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Request approved successfully.'),
      ),
    );

    Navigator.pop(context, true);
  }

  /// Menampilkan dialog input alasan penolakan.
  Future<void> _rejectBooking() async {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.center,
          title: const Text('Reject Request'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: reasonController,
              autofocus: true,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Rejection reason',
                hintText: 'Enter a rejection reason...',
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'A rejection reason is required.';
                }

                if (value.trim().length < 5) {
                  return 'Reason must be at least 5 characters.';
                }

                return null;
              },
            ),
          ),
          actions: [
  SizedBox(
    width: double.infinity,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              Navigator.pop(
                dialogContext,
                reasonController.text.trim(),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
          ),
          child: const Text('Reject'),
        ),
        Center(
          child: TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
            child: const Text('Cancel'),
          ),
        ),
      ],
    ),
  ),
],
        );
      },
    );

    reasonController.dispose();

    if (reason == null || reason.isEmpty) {
      return;
    }

    _dataStore.rejectBooking(
      widget.booking.id,
      reason,
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Request rejected successfully.'),
      ),
    );

    Navigator.pop(context, true);
  }
}

/// buat mengelompokkan informasi detail.
class _ReviewSection extends StatelessWidget {
  const _ReviewSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.cardTitle,
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

//buat detail booking.
class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTextStyles.caption,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}