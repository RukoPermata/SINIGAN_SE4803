import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Utilitas sederhana untuk memformat tanggal dan waktu ke dalam format yang rapi.
class DateTimeUtils {
  DateTimeUtils._();

  /// Format tanggal singkat, contoh: 29 Okt 2026
  static String formatDate(DateTime date) {
    try {
      return DateFormat('dd MMM yyyy', 'id_ID').format(date);
    } catch (_) {
      return DateFormat('dd MMM yyyy').format(date);
    }
  }

  /// Format tanggal lengkap, contoh: Kamis, 29 Oktober 2026
  static String formatDateLong(DateTime date) {
    try {
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);
    } catch (_) {
      return DateFormat('EEEE, dd MMMM yyyy').format(date);
    }
  }

  /// Format jam dari TimeOfDay, contoh: 09:30
  static String formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Format tanggal dan waktu, contoh: 29 Okt 2026, 09:30
  static String formatDateTime(DateTime dateTime) {
    try {
      return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(dateTime);
    } catch (_) {
      return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
    }
  }
}
