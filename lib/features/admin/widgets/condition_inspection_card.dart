// PIC: Kaisar - Condition Inspection Card Widget - FR-15, FR-16, FR-17, FR-18

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../models/booking.dart';

/// Kartu ringkasan antrean pemeriksaan kondisi ruangan.
class ConditionInspectionCard extends StatelessWidget {
  const ConditionInspectionCard({
    super.key,
    required this.booking,
    required this.isCompleted,
    required this.onTap,
  });

  final Booking booking;
  final bool isCompleted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final predicted = booking.predictedLayout ?? 'Standar';
    final isMatching = predicted.toLowerCase() == 'standar';
    final confidence = (booking.cvConfidence ?? 0.94) * 100;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isMatching),
              const SizedBox(height: 4),
              _buildScheduleInfo(),
              const SizedBox(height: 12),
              _buildThumbnailsRow(),
              const SizedBox(height: 12),
              _buildAiSummaryBadge(predicted, confidence, isMatching),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMatching) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            booking.roomName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        StatusBadge(
          status: isCompleted
              ? 'approved'
              : (isMatching ? 'approved' : 'pending'),
          customLabel: isCompleted
              ? 'Terverifikasi'
              : (isMatching ? 'Layout Sesuai' : 'Perlu Tinjauan'),
        ),
      ],
    );
  }

  Widget _buildScheduleInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${booking.building} • ${DateTimeUtils.formatDate(booking.date)} (${booking.startTime} - ${booking.endTime})',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          'Pemohon: ${booking.userName} (${booking.userNim})',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildThumbnailsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildThumbnailBox(
            label: 'Foto Sebelum',
            imageUrl: booking.beforePhotoUrl,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildThumbnailBox(
            label: 'Foto Sesudah',
            imageUrl: booking.afterPhotoUrl,
          ),
        ),
      ],
    );
  }

  Widget _buildThumbnailBox({required String label, required String? imageUrl}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Container(
          height: 80,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: imageUrl != null && imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildPlaceholder(),
                )
              : _buildPlaceholder(),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.lavender,
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, size: 24, color: AppColors.primary),
    );
  }

  Widget _buildAiSummaryBadge(String predicted, double confidence, bool isMatching) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isMatching ? Icons.check_circle_outline : Icons.warning_amber_rounded,
            size: 16,
            color: isMatching ? AppColors.success : AppColors.warning,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'AI MobileNetV3: $predicted (${confidence.toStringAsFixed(1)}%)',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
