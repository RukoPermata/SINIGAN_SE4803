import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeUtils {
  DateTimeUtils._();

  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy', 'id_ID').format(date);
  }

  static String formatDateLong(DateTime date) {
    return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);
  }

  static String formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(dateTime);
  }
}
