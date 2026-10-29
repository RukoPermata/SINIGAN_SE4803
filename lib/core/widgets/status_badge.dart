import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Widget lencana status sederhana untuk menampilkan status peminjaman
/// atau status keaktifan ruangan dengan warna yang mudah dipahami.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.status,
    this.customLabel,
  });

  /// Nilai status: 'pending', 'approved', 'rejected', 'active', 'inactive'
  final String status;
  final String? customLabel;

  @override
  Widget build(BuildContext context) {
    Color textColor;
    Color bgColor;
    String label;

    switch (status.toLowerCase()) {
      case 'approved':
      case 'disetujui':
      case 'active':
      case 'tersedia':
        textColor = AppColors.success;
        bgColor = AppColors.successLight;
        label = customLabel ??
            (status == 'active' ? 'Aktif' : (status == 'tersedia' ? 'Tersedia' : 'Disetujui'));
        break;

      case 'pending':
      case 'menunggu':
        textColor = AppColors.warning;
        bgColor = AppColors.warningLight;
        label = customLabel ?? 'Menunggu';
        break;

      case 'rejected':
      case 'ditolak':
      case 'inactive':
      default:
        textColor = AppColors.error;
        bgColor = AppColors.errorLight;
        label = customLabel ?? (status == 'inactive' ? 'Nonaktif' : 'Ditolak');
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
