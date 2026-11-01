/// Model entitas periode blackout/pemblokiran ruangan kampus untuk SINI-GAN.
/// Ruangan pada periode blackout tidak dapat dipinjam oleh mahasiswa/ormawa
/// (misal untuk UTS, UAS, Maintenance Gedung, atau Dies Natalis).
class BlackoutPeriod {
  const BlackoutPeriod({
    required this.id,
    this.roomId,
    this.roomName = 'Semua Ruangan',
    required this.title,
    required this.reason,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    required this.createdBy,
  });

  /// Identitas unik periode blackout (misal: 'bo-001')
  final String id;

  /// ID ruangan yang diblokir.
  /// Jika null, pemblokiran berlaku global untuk SEMUA ruangan kampus.
  final String? roomId;

  /// Nama ruangan (atau 'Semua Ruangan' bila berlaku global)
  final String roomName;

  /// Judul periode pemblokiran (misal: 'Pekan Ujian Tengah Semester (UTS)')
  final String title;

  /// Alasan pemblokiran (misal: 'Seluruh ruangan dialokasikan untuk pelaksanaan ujian tertulis')
  final String reason;

  /// Tanggal dan waktu mulai periode blackout
  final DateTime startDate;

  /// Tanggal dan waktu berakhir periode blackout
  final DateTime endDate;

  /// Status apakah blackout sedang aktif
  final bool isActive;

  /// Identitas admin / unit yang membuat kebijakan blackout (misal: 'Biro Akademik')
  final String createdBy;

  /// Apakah blackout berlaku untuk semua ruangan kampus
  bool get appliesToAllRooms => roomId == null || roomId!.isEmpty;

  /// Mengecek apakah suatu waktu tertentu berada dalam periode blackout ini
  bool containsDate(DateTime date) {
    if (!isActive) return false;
    return (date.isAfter(startDate) || date.isAtSameMomentAs(startDate)) &&
        (date.isBefore(endDate) || date.isAtSameMomentAs(endDate));
  }

  /// Method copyWith untuk modifikasi atribut secara imutabel
  BlackoutPeriod copyWith({
    String? id,
    String? roomId,
    bool clearRoomId = false,
    String? roomName,
    String? title,
    String? reason,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    String? createdBy,
  }) {
    return BlackoutPeriod(
      id: id ?? this.id,
      roomId: clearRoomId ? null : (roomId ?? this.roomId),
      roomName: roomName ?? this.roomName,
      title: title ?? this.title,
      reason: reason ?? this.reason,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
