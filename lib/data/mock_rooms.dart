import '../models/room.dart';

/// Data tiruan (mock data) daftar ruangan kampus untuk keperluan demonstrasi UTS.
final List<Room> mockRooms = [
  const Room(
    id: 'room-tult-0701',
    name: 'TULT-0701',
    building: 'Gedung TULT',
    floor: 7,
    capacity: 40,
    facilities: ['Proyektor HD', 'AC', 'Papan Tulis', 'Wi-Fi Eduroam', 'Stopkontak Tiap Meja'],
    imageUrl:
        'https://images.unsplash.com/photo-1580582932707-520aed937b7b?auto=format&fit=crop&w=800&q=80',
    isActive: true,
    targetLayout: 'Standar',
    description:
        'Ruang kelas teori reguler ber-AC dengan pencahayaan alami yang baik, cocok untuk perkuliahan dan kegiatan belajar kelompok.',
    locationNotes: 'Sayap Barat, dekat tangga darurat lantai 7',
  ),
  const Room(
    id: 'room-tult-1102',
    name: 'TULT-1102',
    building: 'Gedung TULT',
    floor: 11,
    capacity: 45,
    facilities: ['Proyektor Ganda', 'Sound System', 'AC', 'Papan Tulis', 'Wi-Fi Eduroam'],
    imageUrl:
        'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?auto=format&fit=crop&w=800&q=80',
    isActive: true,
    targetLayout: 'Standar',
    description:
        'Ruang kelas berkapasitas sedang dengan sistem audio terintegrasi, sangat ideal untuk presentasi proyek besar dan workshop.',
    locationNotes: 'Sayap Utara, tepat di depan lift utama',
  ),
  const Room(
    id: 'room-ku3-0301',
    name: 'KU3.03.01',
    building: 'Gedung Tokong Nanas (KU3)',
    floor: 3,
    capacity: 50,
    facilities: ['Smart TV 65 Inch', 'Proyektor', 'AC', 'Whiteboard Kaca', 'Wi-Fi Eduroam'],
    imageUrl:
        'https://images.unsplash.com/photo-1524178232363-1fb2b075b655?auto=format&fit=crop&w=800&q=80',
    isActive: true,
    targetLayout: 'Standar',
    description:
        'Ruang kuliah interaktif dengan fasilitas Smart TV dan whiteboard kaca modern untuk kemudahan visualisasi materi.',
    locationNotes: 'Koridor tengah lantai 3',
  ),
  const Room(
    id: 'room-fif-lab-multi',
    name: 'Lab Multimedia FIF',
    building: 'Gedung Panambulai (FIF)',
    floor: 2,
    capacity: 35,
    facilities: ['35 PC Workstation', 'LAN Gigabit', 'AC', 'Proyektor', 'Headset Studio'],
    imageUrl:
        'https://images.unsplash.com/photo-1562774053-701939374585?auto=format&fit=crop&w=800&q=80',
    isActive: true,
    targetLayout: 'Standar',
    description:
        'Laboratorium komputer spesifikasi tinggi khusus untuk kegiatan praktikum grafika, game development, dan pengolahan citra.',
    locationNotes: 'Gedung Panambulai lantai 2, samping Lab AI',
  ),
  const Room(
    id: 'room-aula-ku3',
    name: 'Aula Tokong Nanas',
    building: 'Gedung Tokong Nanas (KU3)',
    floor: 1,
    capacity: 120,
    facilities: ['Panggung Utama', 'Sound System Premium', 'Videotron / Proyektor Raksasa', 'AC Central', 'Mic Wireless'],
    imageUrl:
        'https://images.unsplash.com/photo-1505373877841-8d25f7d46678?auto=format&fit=crop&w=800&q=80',
    isActive: true,
    targetLayout: 'Standar',
    description:
        'Aula serbaguna berkapasitas besar untuk seminar nasional, kuliah umum tamu, temu ormawa, dan sidang yudisium.',
    locationNotes: 'Lobby utama Gedung Tokong Nanas lantai 1',
  ),
  const Room(
    id: 'room-sc-hima',
    name: 'Ruang Rapat HIMA RPL',
    building: 'Gedung Student Center',
    floor: 2,
    capacity: 20,
    facilities: ['Meja Rapat Melingkar', 'Smart Monitor', 'AC', 'Whiteboard', 'Dispenser'],
    imageUrl:
        'https://images.unsplash.com/photo-1497366216548-37526070297c?auto=format&fit=crop&w=800&q=80',
    isActive: true,
    targetLayout: 'Diskusi',
    description:
        'Ruang rapat kolaboratif berkonsep diskusi melingkar untuk koordinasi panitia, rapat pengurus harian himpunan, dan konsultasi tim.',
    locationNotes: 'Gedung SC lantai 2, blok sekretariat himpunan',
  ),
];
