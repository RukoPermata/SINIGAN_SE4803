import 'package:flutter/material.dart';

import '../models/blackout_period.dart';
import '../models/booking.dart';
import '../models/regular_schedule.dart';
import '../models/room.dart';
import 'mock_blackouts.dart';
import 'mock_bookings.dart';
import 'mock_rooms.dart';
import 'mock_schedules.dart';

/// Single source of truth sementara berbasis memori untuk demonstrasi antarmuka UTS.
/// Menggunakan [ChangeNotifier] standar Flutter agar perubahan data (seperti submit booking,
/// persetujuan admin, pengelolaan ruangan, dan jadwal kuliah/blackout) langsung reaktif tercermin pada seluruh layar aplikasi.
class MockDataStore extends ChangeNotifier {
  MockDataStore._internal() {
    _rooms = List.from(mockRooms);
    _bookings = List.from(mockBookings);
    _regularSchedules = List.from(mockRegularSchedules);
    _blackoutPeriods = List.from(mockBlackoutPeriods);
  }

  /// Singleton instance agar seluruh layar mengakses data yang sama
  static final MockDataStore instance = MockDataStore._internal();

  late List<Room> _rooms;
  late List<Booking> _bookings;
  late List<RegularSchedule> _regularSchedules;
  late List<BlackoutPeriod> _blackoutPeriods;

  // ==========================================
  // GETTERS
  // ==========================================

  /// Daftar seluruh ruangan kampus
  List<Room> get rooms => List.unmodifiable(_rooms);

  /// Daftar seluruh permohonan peminjaman
  List<Booking> get bookings => List.unmodifiable(_bookings);

  /// Daftar seluruh jadwal perkuliahan reguler mingguan
  List<RegularSchedule> get regularSchedules => List.unmodifiable(_regularSchedules);

  /// Daftar seluruh periode blackout/pemblokiran ruangan
  List<BlackoutPeriod> get blackoutPeriods => List.unmodifiable(_blackoutPeriods);

  // ==========================================
  // ROOM METHODS
  // ==========================================

  /// Mengambil data ruangan berdasarkan ID
  Room? getRoomById(String id) {
    try {
      return _rooms.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Menambah ruangan baru ke dalam sistem
  void addRoom(Room room) {
    _rooms.add(room);
    notifyListeners();
  }

  /// Memperbarui informasi data ruangan yang sudah ada
  void updateRoom(Room room) {
    final index = _rooms.indexWhere((r) => r.id == room.id);
    if (index != -1) {
      _rooms[index] = room;
      notifyListeners();
    }
  }

  /// Mengubah status aktif/nonaktif ruangan
  void toggleRoomStatus(String roomId) {
    final index = _rooms.indexWhere((r) => r.id == roomId);
    if (index != -1) {
      final current = _rooms[index];
      _rooms[index] = current.copyWith(isActive: !current.isActive);
      notifyListeners();
    }
  }

  /// Menghapus ruangan dari master data
  void deleteRoom(String roomId) {
    _rooms.removeWhere((r) => r.id == roomId);
    notifyListeners();
  }

  // ==========================================
  // REGULAR SCHEDULE METHODS
  // ==========================================

  /// Mengambil seluruh jadwal kuliah untuk ruangan tertentu
  List<RegularSchedule> getSchedulesByRoomId(String roomId) {
    return _regularSchedules.where((s) => s.roomId == roomId).toList();
  }

  /// Menambah jadwal kuliah reguler baru
  void addRegularSchedule(RegularSchedule schedule) {
    _regularSchedules.add(schedule);
    notifyListeners();
  }

  /// Memperbarui jadwal kuliah reguler yang sudah ada
  void updateRegularSchedule(RegularSchedule schedule) {
    final index = _regularSchedules.indexWhere((s) => s.id == schedule.id);
    if (index != -1) {
      _regularSchedules[index] = schedule;
      notifyListeners();
    }
  }

  /// Menghapus jadwal kuliah reguler berdasarkan ID
  void deleteRegularSchedule(String scheduleId) {
    _regularSchedules.removeWhere((s) => s.id == scheduleId);
    notifyListeners();
  }

  /// Mengubah status aktif/nonaktif jadwal perkuliahan reguler
  void toggleRegularScheduleStatus(String scheduleId) {
    final index = _regularSchedules.indexWhere((s) => s.id == scheduleId);
    if (index != -1) {
      final current = _regularSchedules[index];
      _regularSchedules[index] = current.copyWith(isActive: !current.isActive);
      notifyListeners();
    }
  }

  // ==========================================
  // BLACKOUT PERIOD METHODS
  // ==========================================

  /// Mengambil periode blackout yang berlaku untuk ruangan tertentu
  /// (termasuk blackout global yang berlaku untuk seluruh ruangan)
  List<BlackoutPeriod> getBlackoutsForRoom(String roomId) {
    return _blackoutPeriods.where((bo) {
      return bo.appliesToAllRooms || bo.roomId == roomId;
    }).toList();
  }

  /// Menambah periode blackout baru
  void addBlackoutPeriod(BlackoutPeriod period) {
    _blackoutPeriods.add(period);
    notifyListeners();
  }

  /// Memperbarui periode blackout yang sudah ada
  void updateBlackoutPeriod(BlackoutPeriod period) {
    final index = _blackoutPeriods.indexWhere((bo) => bo.id == period.id);
    if (index != -1) {
      _blackoutPeriods[index] = period;
      notifyListeners();
    }
  }

  /// Menghapus periode blackout berdasarkan ID
  void deleteBlackoutPeriod(String periodId) {
    _blackoutPeriods.removeWhere((bo) => bo.id == periodId);
    notifyListeners();
  }

  /// Mengubah status aktif/nonaktif periode blackout
  void toggleBlackoutStatus(String periodId) {
    final index = _blackoutPeriods.indexWhere((bo) => bo.id == periodId);
    if (index != -1) {
      final current = _blackoutPeriods[index];
      _blackoutPeriods[index] = current.copyWith(isActive: !current.isActive);
      notifyListeners();
    }
  }

  // ==========================================
  // BOOKING METHODS
  // ==========================================

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
