/// Model entitas jadwal perkuliahan reguler mingguan untuk SINI-GAN.
class RegularSchedule {
  const RegularSchedule({
    required this.id,
    required this.roomId,
    required this.roomName,
    required this.courseCode,
    required this.courseName,
    required this.lecturerName,
    required this.classGroup,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.semester,
    this.isActive = true,
  });

  /// Identitas unik jadwal perkuliahan (misal: 'sched-001')
  final String id;

  /// ID ruangan yang digunakan (sesuai ID pada Room)
  final String roomId;

  /// Nama/Kode ruangan (misal: 'TULT-0701')
  final String roomName;

  /// Kode mata kuliah (misal: 'SE4803')
  final String courseCode;

  /// Nama mata kuliah (misal: 'Pemrograman Aplikasi Bergerak')
  final String courseName;

  /// Nama dosen pengampu (misal: 'Dr. Ir. Budi Santoso, M.T.')
  final String lecturerName;

  /// Kelas/kelompok mahasiswa (misal: 'SE-48-03')
  final String classGroup;

  /// Hari pelaksanaan (1 = Senin, 2 = Selasa, ..., 7 = Minggu)
  final int dayOfWeek;

  /// Jam mulai perkuliahan format HH:mm (misal: '07:30')
  final String startTime;

  /// Jam selesai perkuliahan format HH:mm (misal: '10:30')
  final String endTime;

  /// Periode semester (misal: 'Genap 2024/2025')
  final String semester;

  /// Status keaktifan jadwal reguler
  final bool isActive;

  /// Helper untuk mendapatkan nama hari dalam bahasa Indonesia
  String get dayName {
    switch (dayOfWeek) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'Unknown';
    }
  }

  /// Helper format rentang waktu (misal: '07:30 - 10:30')
  String get timeRange => '$startTime - $endTime';

  /// Method copyWith untuk modifikasi atribut jadwal secara imutabel
  RegularSchedule copyWith({
    String? id,
    String? roomId,
    String? roomName,
    String? courseCode,
    String? courseName,
    String? lecturerName,
    String? classGroup,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    String? semester,
    bool? isActive,
  }) {
    return RegularSchedule(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      roomName: roomName ?? this.roomName,
      courseCode: courseCode ?? this.courseCode,
      courseName: courseName ?? this.courseName,
      lecturerName: lecturerName ?? this.lecturerName,
      classGroup: classGroup ?? this.classGroup,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      semester: semester ?? this.semester,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Serialisasi entitas ke Map agar dapat disimpan sebagai JSON lokal.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomId': roomId,
      'roomName': roomName,
      'courseCode': courseCode,
      'courseName': courseName,
      'lecturerName': lecturerName,
      'classGroup': classGroup,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'semester': semester,
      'isActive': isActive,
    };
  }

  /// Membuat entitas RegularSchedule dari Map hasil dekode JSON.
  factory RegularSchedule.fromJson(Map<String, dynamic> json) {
    return RegularSchedule(
      id: json['id'] as String,
      roomId: json['roomId'] as String,
      roomName: json['roomName'] as String? ?? '',
      courseCode: json['courseCode'] as String? ?? '',
      courseName: json['courseName'] as String? ?? '',
      lecturerName: json['lecturerName'] as String? ?? '',
      classGroup: json['classGroup'] as String? ?? '',
      dayOfWeek: (json['dayOfWeek'] as num?)?.toInt() ?? 1,
      startTime: json['startTime'] as String? ?? '00:00',
      endTime: json['endTime'] as String? ?? '00:00',
      semester: json['semester'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}
