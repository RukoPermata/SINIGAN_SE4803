import 'package:flutter/material.dart';

import '../models/booking.dart';
import '../models/room.dart';
import 'mock_bookings.dart';
import 'mock_rooms.dart';

/// Single source of truth sementara berbasis memori untuk demonstrasi antarmuka UTS.
/// Menggunakan [ChangeNotifier] standar Flutter agar perubahan data (seperti submit booking
/// atau persetujuan admin) langsung reaktif tercermin pada seluruh layar aplikasi.
class MockDataStore extends ChangeNotifier {
  MockDataStore._internal() {
    _rooms = List.from(mockRooms);
    _bookings = List.from(mockBookings);
  }

  /// Singleton instance agar seluruh layar mengakses data yang sama
  static final MockDataStore instance = MockDataStore._internal();

  late List<Room> _rooms;
  late List<Booking> _bookings;

  /// Daftar seluruh ruangan
  List<Room> get rooms => List.unmodifiable(_rooms);

  /// Daftar seluruh permohonan peminjaman
  List<Booking> get bookings => List.unmodifiable(_bookings);

  /// Mengambil ruangan berdasarkan ID
  Room? getRoomById(String id) {
    try {
      return _rooms.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Menambah permohonan peminjaman baru (dipanggil saat mahasiswa submit form)
  void addBooking(Booking booking) {
    _bookings.insert(0, booking);
    notifyListeners();
  }

  /// Menyetujui permohonan peminjaman (dipanggil saat admin approve)
  void approveBooking(String bookingId) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(
        status: BookingStatus.approved,
        rejectionReason: null,
      );
      notifyListeners();
    }
  }

  /// Menolak permohonan peminjaman dengan alasan wajib (dipanggil saat admin reject)
  void rejectBooking(String bookingId, String reason) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(
        status: BookingStatus.rejected,
        rejectionReason: reason.trim().isEmpty ? 'Tidak memenuhi ketentuan' : reason.trim(),
      );
      notifyListeners();
    }
  }

  /// Mengubah status aktif/nonaktif ruangan (dipanggil pada layar kelola ruangan admin)
  void toggleRoomStatus(String roomId) {
    final index = _rooms.indexWhere((r) => r.id == roomId);
    if (index != -1) {
      final current = _rooms[index];
      _rooms[index] = current.copyWith(isActive: !current.isActive);
      notifyListeners();
    }
  }

  /// Menambahkan foto kondisi ruangan sebelum atau sesudah penggunaan
  void updatePhotos(
    String bookingId, {
    String? beforePhotoUrl,
    String? afterPhotoUrl,
    String? predictedLayout,
    double? cvConfidence,
  }) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(
        beforePhotoUrl: beforePhotoUrl ?? _bookings[index].beforePhotoUrl,
        afterPhotoUrl: afterPhotoUrl ?? _bookings[index].afterPhotoUrl,
        predictedLayout: predictedLayout ?? _bookings[index].predictedLayout,
        cvConfidence: cvConfidence ?? _bookings[index].cvConfidence,
      );
      notifyListeners();
    }
  }
}
