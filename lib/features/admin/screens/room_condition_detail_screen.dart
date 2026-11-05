// PIC: Kaisar - Room Condition Detail Screen - FR-15, FR-16, FR-17, FR-18

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/mock_data_store.dart';
import '../../../models/booking.dart';

/// Layar rincian pemeriksaan kondisi ruangan & evaluasi model Computer Vision
class RoomConditionDetailScreen extends StatelessWidget {
  const RoomConditionDetailScreen({
    super.key,
    required this.booking,
  });

  final Booking booking;

  void _submitDecision(BuildContext context, bool isApproved) {
    final message = isApproved
        ? 'Room condition for ${booking.roomName} verified.'
        : 'A layout mismatch report for ${booking.roomName} has been recorded.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isApproved ? AppColors.success : AppColors.error,
        duration: const Duration(seconds: 2),
      ),
    );
    MockDataStore.instance.update();
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final predicted = booking.predictedLayout ?? 'Standard';
    const target = 'Standard';
    final confidence = (booking.cvConfidence ?? 0.94) * 100;
    final isMatching = predicted.toLowerCase() == target.toLowerCase();

    return Scaffold(
      appBar: AppBar(
        title: Text('Inspection ${booking.roomName}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 20),
            _buildPhotoComparisonSection(),
            const SizedBox(height: 20),
            _buildCvMetricsCard(predicted, target, confidence, isMatching),
            const SizedBox(height: 28),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                booking.roomName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.lavender,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  booking.building,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Pemohon: ${booking.userName} (${booking.userNim})',
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            'Waktu: ${DateTimeUtils.formatDate(booking.date)} • ${booking.startTime} - ${booking.endTime}',
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            'Tujuan: ${booking.purpose}',
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoComparisonSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Room Photo Documentation',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Visual comparison of the room before and after the activity.',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDetailPhotoBox(
                title: 'Before',
                subtitle: 'Key handover',
                imageUrl: booking.beforePhotoUrl,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDetailPhotoBox(
                title: 'After',
                subtitle: 'Student checkout',
                imageUrl: booking.afterPhotoUrl,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailPhotoBox({
    required String title,
    required String subtitle,
    required String? imageUrl,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            color: AppColors.background,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 130,
            width: double.infinity,
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
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.lavender,
      alignment: Alignment.center,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 28, color: AppColors.primary),
          SizedBox(height: 4),
          Text(
            'No photo available',
            style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildCvMetricsCard(
    String predicted,
    String target,
    double confidence,
    bool isMatching,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMatching
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Computer Vision Analysis',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              StatusBadge(
                status: isMatching ? 'approved' : 'pending',
                customLabel: isMatching ? 'Layout Matches' : 'Needs Review',
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _buildRow('Inference Model', 'MobileNetV3 Layout Classifier'),
          const SizedBox(height: 6),
          _buildRow('Detected Layout', predicted),
          const SizedBox(height: 6),
          _buildRow('Target Layout', target),
          const SizedBox(height: 6),
          _buildRow('Confidence Score', '${confidence.toStringAsFixed(1)}%'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isMatching
                  ? 'Note: The desk and chair layout matches the standard classroom configuration.'
                  : 'Note: A change in desk or chair positions was detected versus the room target layout.',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () => _submitDecision(context, true),
          child: const Text('Mark Room Verified'),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: () => _submitDecision(context, false),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: const BorderSide(color: AppColors.error),
          ),
          child: const Text('Flag for Rearrangement'),
        ),
      ],
    );
  }
}
