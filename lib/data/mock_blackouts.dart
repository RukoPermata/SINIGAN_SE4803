import '../models/blackout_period.dart';

/// Data tiruan (mock data) periode blackout / pemblokiran ruangan kampus untuk demonstrasi UTS.
final List<BlackoutPeriod> mockBlackoutPeriods = [
  BlackoutPeriod(
    id: 'bo-001',
    roomId: null, // Berlaku global untuk semua ruangan
    roomName: 'Semua Ruangan Kampus',
    title: 'Pekan Ujian Tengah Semester (UTS) Genap',
    reason: 'Seluruh ruangan kelas dan laboratorium dialokasikan untuk pelaksanaan ujian tertulis terpusat.',
    startDate: DateTime(2025, 4, 14, 0, 0),
    endDate: DateTime(2025, 4, 25, 23, 59),
    isActive: true,
    createdBy: 'Biro Administrasi Akademik (BAA)',
  ),
  BlackoutPeriod(
    id: 'bo-002',
    roomId: 'room-fif-lab-multi',
    roomName: 'Lab Multimedia FIF',
    title: 'Maintenance Jaringan & Upgrade Workstation',
    reason: 'Instalasi kartu grafis baru dan upgrade storage server lab multimedia untuk sertifikasi industri.',
    startDate: DateTime(2025, 3, 20, 8, 0),
    endDate: DateTime(2025, 3, 22, 17, 0),
    isActive: true,
    createdBy: 'Laboratorium FIF',
  ),
  BlackoutPeriod(
    id: 'bo-003',
    roomId: 'room-aula-ku3',
    roomName: 'Aula Tokong Nanas',
    title: 'Gladi Bersih & Sidang Terbuka Wisuda Gelombang II',
    reason: 'Sterilisasi ruangan untuk persiapan protokoler wisuda universitas.',
    startDate: DateTime(2025, 5, 2, 7, 0),
    endDate: DateTime(2025, 5, 3, 22, 0),
    isActive: true,
    createdBy: 'Bagian Logistik & Sarana Prasarana',
  ),
];
