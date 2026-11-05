import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/blackout_period.dart';
import '../models/booking.dart';
import '../models/regular_schedule.dart';
import '../models/room.dart';
import 'mock_blackouts.dart';
import 'mock_bookings.dart';
import 'mock_rooms.dart';
import 'mock_schedules.dart';

/// Single source of truth aplikasi SINI-GAN.
/// Menyimpan seluruh data (ruangan, peminjaman, jadwal kuliah, dan blackout) di memori
/// dan mem-persistensinya secara lokal melalui [SharedPreferences] dalam format JSON.
/// Menggunakan [GetxController] agar perubahan data langsung reaktif tercermin pada
/// seluruh layar aplikasi yang mendengarkan instance ini.
class MockDataStore extends GetxController {
  MockDataStore._internal() {
    _rooms = List.from(mockRooms);
    _bookings = List.from(mockBookings);
    _regularSchedules = List.from(mockRegularSchedules);
    _blackoutPeriods = List.from(mockBlackoutPeriods);
  }

  static MockDataStore? _instance;

  /// Singleton instance agar seluruh layar mengakses data yang sama.
  /// Terdaftar otomatis pada container dependensi GetX melalui `Get.put`.
  static MockDataStore get instance {
    if (Get.isRegistered<MockDataStore>()) {
      return Get.find<MockDataStore>();
    }
    final controller = _instance ??= MockDataStore._internal();
    Get.put<MockDataStore>(controller, permanent: true);
    return controller;
  }

  // Kunci penyimpanan lokal
  static const String _kSeedVersion = 'sg_seed_version';
  static const String _kRooms = 'sg_rooms';
  static const String _kBookings = 'sg_bookings';
  static const String _kSchedules = 'sg_schedules';
  static const String _kBlackouts = 'sg_blackouts';

  /// Versi skema data tiruan. Naikkan nilai ini untuk memaksa seed ulang data lokal.
  static const int _seedVersion = 1;

  late List<Room> _rooms;
  late List<Booking> _bookings;
  late List<RegularSchedule> _regularSchedules;
  late List<BlackoutPeriod> _blackoutPeriods;

  // ==========================================
  // PERSISTENCE
  // ==========================================

  /// Memuat data dari penyimpanan lokal. Bila belum pernah di-seed (atau versi
  /// skema berubah), data tiruan awal akan dimuat lalu disimpan.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final storedVersion = prefs.getInt(_kSeedVersion);

    if (storedVersion != _seedVersion) {
      await _seed(prefs);
      return;
    }

    _rooms = _decodeList(prefs.getString(_kRooms), Room.fromJson) ??
        List.from(mockRooms);
    _bookings = _decodeList(prefs.getString(_kBookings), Booking.fromJson) ??
        List.from(mockBookings);
    _regularSchedules =
        _decodeList(prefs.getString(_kSchedules), RegularSchedule.fromJson) ??
            List.from(mockRegularSchedules);
    _blackoutPeriods =
        _decodeList(prefs.getString(_kBlackouts), BlackoutPeriod.fromJson) ??
            List.from(mockBlackoutPeriods);

    update();
  }

  Future<void> _seed(SharedPreferences prefs) async {
    _rooms = List.from(mockRooms);
    _bookings = List.from(mockBookings);
    _regularSchedules = List.from(mockRegularSchedules);
    _blackoutPeriods = List.from(mockBlackoutPeriods);
    await _persist(prefs);
    await prefs.setInt(_kSeedVersion, _seedVersion);
    update();
  }

  List<T>? _decodeList<T>(
    String? raw,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  /// Menulis seluruh koleksi ke penyimpanan lokal. Kegagalan penyimpanan
  /// (misalnya saat unit test tanpa plugin) diabaikan agar aplikasi tidak crash.
  Future<void> _persist([SharedPreferences? prefs]) async {
    try {
      final p = prefs ?? await SharedPreferences.getInstance();
      await p.setString(
        _kRooms,
        jsonEncode(_rooms.map((r) => r.toJson()).toList()),
      );
      await p.setString(
        _kBookings,
        jsonEncode(_bookings.map((b) => b.toJson()).toList()),
      );
      await p.setString(
        _kSchedules,
        jsonEncode(_regularSchedules.map((s) => s.toJson()).toList()),
      );
      await p.setString(
        _kBlackouts,
        jsonEncode(_blackoutPeriods.map((bo) => bo.toJson()).toList()),
      );
    } catch (_) {
      // Penyimpanan lokal tidak tersedia - lewati.
    }
  }

  void _save() {
    _persist();
  }

  // ==========================================
  // GETTERS
  // ==========================================

  /// Daftar seluruh ruangan kampus
  List<Room> get rooms => List.unmodifiable(_rooms);

  /// Daftar seluruh permohonan peminjaman
  List<Booking> get bookings => List.unmodifiable(_bookings);

  /// Daftar seluruh jadwal perkuliahan reguler mingguan
  List<RegularSchedule> get regularSchedules =>
      List.unmodifiable(_regularSchedules);

  /// Daftar seluruh periode blackout/pemblokiran ruangan
  List<BlackoutPeriod> get blackoutPeriods =>
      List.unmodifiable(_blackoutPeriods);

  /// Jumlah permohonan peminjaman yang masih menunggu persetujuan
  int get pendingCount =>
      _bookings.where((b) => b.status == BookingStatus.pending).length;

  /// Jumlah peminjaman disetujui yang kegiatannya berlangsung hari ini
  int get approvedTodayCount {
    final now = DateTime.now();
    return _bookings.where((b) {
      return b.status == BookingStatus.approved &&
          b.date.year == now.year &&
          b.date.month == now.month &&
          b.date.day == now.day;
    }).length;
  }

  /// Jumlah ruangan yang berstatus aktif
  int get activeRoomCount => _rooms.where((r) => r.isActive).length;

  /// Seluruh peminjaman milik seorang mahasiswa berdasarkan NIM
  List<Booking> bookingsForUser(String nim) =>
      _bookings.where((b) => b.userNim == nim).toList();

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
    update();
    _save();
  }

  /// Memperbarui informasi data ruangan yang sudah ada
  void updateRoom(Room room) {
    final index = _rooms.indexWhere((r) => r.id == room.id);
    if (index != -1) {
      _rooms[index] = room;
      update();
      _save();
    }
  }

  /// Mengubah status aktif/nonaktif ruangan
  void toggleRoomStatus(String roomId) {
    final index = _rooms.indexWhere((r) => r.id == roomId);
    if (index != -1) {
      final current = _rooms[index];
      _rooms[index] = current.copyWith(isActive: !current.isActive);
      update();
      _save();
    }
  }

  /// Menghapus ruangan dari master data
  void deleteRoom(String roomId) {
    _rooms.removeWhere((r) => r.id == roomId);
    update();
    _save();
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
    update();
    _save();
  }

  /// Memperbarui jadwal kuliah reguler yang sudah ada
  void updateRegularSchedule(RegularSchedule schedule) {
    final index = _regularSchedules.indexWhere((s) => s.id == schedule.id);
    if (index != -1) {
      _regularSchedules[index] = schedule;
      update();
      _save();
    }
  }

  /// Menghapus jadwal kuliah reguler berdasarkan ID
  void deleteRegularSchedule(String scheduleId) {
    _regularSchedules.removeWhere((s) => s.id == scheduleId);
    update();
    _save();
  }

  /// Mengubah status aktif/nonaktif jadwal perkuliahan reguler
  void toggleRegularScheduleStatus(String scheduleId) {
    final index = _regularSchedules.indexWhere((s) => s.id == scheduleId);
    if (index != -1) {
      final current = _regularSchedules[index];
      _regularSchedules[index] = current.copyWith(isActive: !current.isActive);
      update();
      _save();
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
    update();
    _save();
  }

  /// Memperbarui periode blackout yang sudah ada
  void updateBlackoutPeriod(BlackoutPeriod period) {
    final index = _blackoutPeriods.indexWhere((bo) => bo.id == period.id);
    if (index != -1) {
      _blackoutPeriods[index] = period;
      update();
      _save();
    }
  }

  /// Menghapus periode blackout berdasarkan ID
  void deleteBlackoutPeriod(String periodId) {
    _blackoutPeriods.removeWhere((bo) => bo.id == periodId);
    update();
    _save();
  }

  /// Mengubah status aktif/nonaktif periode blackout
  void toggleBlackoutStatus(String periodId) {
    final index = _blackoutPeriods.indexWhere((bo) => bo.id == periodId);
    if (index != -1) {
      final current = _blackoutPeriods[index];
      _blackoutPeriods[index] = current.copyWith(isActive: !current.isActive);
      update();
      _save();
    }
  }

  // ==========================================
  // AVAILABILITY
  // ==========================================

  /// Mengubah string jam 'HH:mm' menjadi total menit sejak tengah malam.
  static int toMinutes(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length != 2) return 0;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return hour * 60 + minute;
  }

  /// Mengecek apakah suatu slot waktu pada ruangan tertentu masih kosong
  /// (tidak terkena jadwal kuliah reguler, peminjaman disetujui, atau blackout).
  bool isSlotAvailable(
    String roomId,
    DateTime date,
    int startMinute,
    int endMinute,
  ) {
    if (startMinute >= endMinute) return false;

    final room = getRoomById(roomId);
    if (room == null || !room.isActive) return false;

    // Terkena blackout?
    final blocked = getBlackoutsForRoom(roomId)
        .any((bo) => bo.containsDate(date));
    if (blocked) return false;

    bool overlaps(int otherStart, int otherEnd) =>
        startMinute < otherEnd && otherStart < endMinute;

    // Bentrok jadwal kuliah reguler pada hari yang sama?
    final weekday = date.weekday; // 1 = Senin ... 7 = Minggu
    final clashWithClass = _regularSchedules.any((s) {
      if (s.roomId != roomId || !s.isActive) return false;
      if (s.dayOfWeek != weekday) return false;
      return overlaps(toMinutes(s.startTime), toMinutes(s.endTime));
    });
    if (clashWithClass) return false;

    // Bentrok peminjaman yang sudah disetujui?
    final clashWithBooking = _bookings.any((b) {
      if (b.roomId != roomId || b.status != BookingStatus.approved) return false;
      if (b.date.year != date.year ||
          b.date.month != date.month ||
          b.date.day != date.day) {
        return false;
      }
      return overlaps(toMinutes(b.startTime), toMinutes(b.endTime));
    });
    if (clashWithBooking) return false;

    return true;
  }

  // ==========================================
  // BOOKING METHODS
  // ==========================================

  /// Menambah permohonan peminjaman baru (dipanggil saat mahasiswa submit form)
  void addBooking(Booking booking) {
    _bookings.insert(0, booking);
    update();
    _save();
  }

  /// Menyetujui permohonan peminjaman (dipanggil saat admin approve)
  void approveBooking(String bookingId) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(
        status: BookingStatus.approved,
        rejectionReason: null,
      );
      update();
      _save();
    }
  }

  /// Menolak permohonan peminjaman dengan alasan wajib (dipanggil saat admin reject)
  void rejectBooking(String bookingId, String reason) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(
        status: BookingStatus.rejected,
        rejectionReason:
            reason.trim().isEmpty ? 'Tidak memenuhi ketentuan' : reason.trim(),
      );
      update();
      _save();
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
      update();
      _save();
    }
  }
}
