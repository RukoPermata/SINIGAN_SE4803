/// Status permohonan peminjaman ruangan.
enum BookingStatus {
  pending('pending', 'Pending'),
  approved('approved', 'Approved'),
  rejected('rejected', 'Rejected');

  const BookingStatus(this.value, this.label);

  final String value;
  final String label;

  /// Helper untuk mengubah string status menjadi enum BookingStatus
  static BookingStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'disetujui':
        return BookingStatus.approved;
      case 'rejected':
      case 'ditolak':
        return BookingStatus.rejected;
      case 'pending':
      case 'menunggu':
      default:
        return BookingStatus.pending;
    }
  }
}

/// Model entitas peminjaman ruangan kampus untuk SINI-GAN.
class Booking {
  const Booking({
    required this.id,
    required this.roomId,
    required this.roomName,
    required this.building,
    required this.userName,
    required this.userNim,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.purpose,
    this.status = BookingStatus.pending,
    this.rejectionReason,
    this.beforePhotoUrl,
    this.afterPhotoUrl,
    this.predictedLayout,
    this.cvConfidence,
    this.createdAt,
  });

  /// Identitas unik peminjaman (misal: 'book-001')
  final String id;

  /// ID ruangan yang dipinjam
  final String roomId;

  /// Nama/Kode ruangan (misal: 'TULT-0701')
  final String roomName;

  /// Nama gedung ruangan
  final String building;

  /// Nama mahasiswa pemohon (misal: 'Raka Pratama')
  final String userName;

  /// NIM mahasiswa pemohon (misal: '1301213001')
  final String userNim;

  /// Tanggal kegiatan
  final DateTime date;

  /// Jam mulai (misal: '09:00')
  final String startTime;

  /// Jam selesai (misal: '11:30')
  final String endTime;

  /// Deskripsi tujuan kegiatan
  final String purpose;

  /// Status pengajuan (pending, approved, rejected)
  final BookingStatus status;

  /// Alasan penolakan jika permohonan ditolak oleh admin
  final String? rejectionReason;

  /// URL foto kondisi ruangan sebelum digunakan
  final String? beforePhotoUrl;

  /// URL foto kondisi ruangan sesudah digunakan
  final String? afterPhotoUrl;

  /// Hasil analisis layout model CV (misal: 'Standar', 'Diskusi')
  final String? predictedLayout;

  /// Tingkat keyakinan model CV (misal: 0.94 untuk 94%)
  final double? cvConfidence;

  /// Waktu pengajuan dibuat
  final DateTime? createdAt;

  /// Helper untuk membuat salinan baru objek Booking dengan field yang diperbarui
  Booking copyWith({
    String? id,
    String? roomId,
    String? roomName,
    String? building,
    String? userName,
    String? userNim,
    DateTime? date,
    String? startTime,
    String? endTime,
    String? purpose,
    BookingStatus? status,
    String? rejectionReason,
    String? beforePhotoUrl,
    String? afterPhotoUrl,
    String? predictedLayout,
    double? cvConfidence,
    DateTime? createdAt,
  }) {
    return Booking(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      roomName: roomName ?? this.roomName,
      building: building ?? this.building,
      userName: userName ?? this.userName,
      userNim: userNim ?? this.userNim,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      purpose: purpose ?? this.purpose,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      beforePhotoUrl: beforePhotoUrl ?? this.beforePhotoUrl,
      afterPhotoUrl: afterPhotoUrl ?? this.afterPhotoUrl,
      predictedLayout: predictedLayout ?? this.predictedLayout,
      cvConfidence: cvConfidence ?? this.cvConfidence,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Serialisasi entitas ke Map agar dapat disimpan sebagai JSON lokal.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomId': roomId,
      'roomName': roomName,
      'building': building,
      'userName': userName,
      'userNim': userNim,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'purpose': purpose,
      'status': status.value,
      'rejectionReason': rejectionReason,
      'beforePhotoUrl': beforePhotoUrl,
      'afterPhotoUrl': afterPhotoUrl,
      'predictedLayout': predictedLayout,
      'cvConfidence': cvConfidence,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  /// Membuat entitas Booking dari Map hasil dekode JSON.
  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      roomId: json['roomId'] as String,
      roomName: json['roomName'] as String,
      building: json['building'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
      userNim: json['userNim'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
      startTime: json['startTime'] as String? ?? '00:00',
      endTime: json['endTime'] as String? ?? '00:00',
      purpose: json['purpose'] as String? ?? '',
      status: BookingStatus.fromString(json['status'] as String? ?? 'pending'),
      rejectionReason: json['rejectionReason'] as String?,
      beforePhotoUrl: json['beforePhotoUrl'] as String?,
      afterPhotoUrl: json['afterPhotoUrl'] as String?,
      predictedLayout: json['predictedLayout'] as String?,
      cvConfidence: (json['cvConfidence'] as num?)?.toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }
}
