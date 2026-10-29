/// Model entitas ruangan kampus untuk SINI-GAN.
class Room {
  const Room({
    required this.id,
    required this.name,
    required this.building,
    required this.floor,
    required this.capacity,
    required this.facilities,
    required this.imageUrl,
    this.isActive = true,
    this.targetLayout = 'Standar',
    this.description = '',
    this.locationNotes = '',
  });

  /// Identitas unik ruangan (misal: 'room-tult-0701')
  final String id;

  /// Kode/Nama ruangan (misal: 'TULT-0701')
  final String name;

  /// Nama gedung (misal: 'Gedung TULT')
  final String building;

  /// Lantai ruangan (misal: 7)
  final int floor;

  /// Kapasitas maksimal orang (misal: 40)
  final int capacity;

  /// Daftar fasilitas pendukung (misal: ['AC', 'Proyektor', 'Papan Tulis'])
  final List<String> facilities;

  /// URL foto ruangan
  final String imageUrl;

  /// Status apakah ruangan aktif dan dapat dipinjam
  final bool isActive;

  /// Konfigurasi tata letak target ('Standar', 'Ujian', 'Diskusi')
  final String targetLayout;

  /// Deskripsi singkat ruangan
  final String description;

  /// Catatan posisi lokasi (misal: 'Sayap Utara, dekat lift barat')
  final String locationNotes;

  /// Method copyWith untuk memudahkan modifikasi status atau properti secara bersih
  Room copyWith({
    String? id,
    String? name,
    String? building,
    int? floor,
    int? capacity,
    List<String>? facilities,
    String? imageUrl,
    bool? isActive,
    String? targetLayout,
    String? description,
    String? locationNotes,
  }) {
    return Room(
      id: id ?? this.id,
      name: name ?? this.name,
      building: building ?? this.building,
      floor: floor ?? this.floor,
      capacity: capacity ?? this.capacity,
      facilities: facilities ?? this.facilities,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      targetLayout: targetLayout ?? this.targetLayout,
      description: description ?? this.description,
      locationNotes: locationNotes ?? this.locationNotes,
    );
  }
}
