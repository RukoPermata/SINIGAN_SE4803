// PIC: Rayazka - Booking Request Card Widget - FR-13
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../models/booking.dart';
import '../../../core/widgets/status_badge.dart';

class BookingRequestCard extends StatelessWidget {
  const BookingRequestCard({
    super.key,
    required this.booking,
    this.onTap,
  });

  final Booking booking;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: const EdgeInsets.only(bottom: 12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                SizedBox(height: 16),
                Divider(
                  height: 1,
                  color: AppColors.border,
                ),
                SizedBox(height: 14),
                _buildBookingInformation(),
                SizedBox(height: 16),
                _buildPurposeSection(),
              ],
            ),
          )
        )
      );
  }

  // Widget Header, isinya identitas pemohon dan status permohonanan
Widget _buildHeader() {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              booking.userName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.cardTitle,
            ),
            const SizedBox(height: 4),
            Text(
              'NIM ${booking.userNim}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
      const SizedBox(width: 12),
      StatusBadge(
        status: booking.status.value,
        customLabel: booking.status.label,
      ),
    ],
  );
}
  // Widget buat informasi booking
    /*
    * - Nama Ruangan
    * - Tanggal Booking
    * - Waktu Booking
    * - Gedung
    */
  Widget _buildBookingInformation() {
    return Column(
      children: [
        _BookingInfoRow(
          icon: Icons.meeting_room_outlined,
          label: 'Ruangan',
          value: booking.roomName,
        ),
        const SizedBox(height: 10),
        _BookingInfoRow(
          icon: Icons.location_on_outlined,
          label: 'Gedung',
          value: booking.building,
        ),
        const SizedBox(height: 10),
        _BookingInfoRow(
          icon: Icons.calendar_today_outlined,
          label: 'Tanggal',
          value: DateTimeUtils.formatDate(booking.date),
        ),
        const SizedBox(height: 10),
        _BookingInfoRow(
          icon: Icons.access_time_outlined,
          label: 'Waktu',
          value: '${booking.startTime} - ${booking.endTime}',
        ),
      ],
    );
  }

  /// Membuat bagian tujuan kegiatan.
  ///
  /// Teks dibatasi maksimal dua baris agar kartu tidak terlalu tinggi
  /// ketika tujuan kegiatan cukup panjang.
  Widget _buildPurposeSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.description_outlined,
          size: 20,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tujuan Kegiatan',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 3),
              Text(
                booking.purpose,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body,
              ),
            ],
          ),
        ),
        if (onTap != null) ...[
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary,
          ),
        ],
      ],
    );
  }
}

// Widget kecil untuk menampilkan satu baris informasi booking.
class _BookingInfoRow extends StatelessWidget {
  const _BookingInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: AppTextStyles.caption,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}